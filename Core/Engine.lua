------------------------------------------------------
-- MIDNIGHT ARENA PREDICTOR: CORE ENGINE
-- Combat log processing, CD tracking, state management
------------------------------------------------------
local addonName, ns = ...

-- Default settings (stored in SavedVariables)
local defaults = {
    alertScale = 2.5, -- 0.5 to 4.0 - BIG by default
    alertDuration = 2.0, -- seconds on screen
    flashScreen = true, -- red flash on DANGER alerts
    soundEnabled = true,
    shakeScreen = true, -- screen shake on critical alerts
    trackKicks = true,
    trackBurst = true,
    trackDefensives = true,
    trackCC = true,
    trackTrinkets = true,
    trackUtility = true,
    showKickWarning = true, -- warn when you cast and enemy kick is ready
    showSafeToCast = true, -- alert when enemy kick goes on
    predictBurstSeq = true, -- predict next ability after detecting opener
    predictDefensives = true, -- predict defensive at low HP thresholds
    showGuideTips = true, -- show matchup tips from guide spreadsheet
    ratingBracket = 3, -- default Rival (1800-2099)
}

-- Runtime state (not saved)
ns.state = {
    enemyCDs = {}, -- [guid][spellID] = expirationTime
    enemyTrinkets = {}, -- [guid] = expirationTime
    enemyDR = {}, -- [guid][drCat] = { count, lastTime }
    enemySpecs = {}, -- [guid] = { class, spec }
    enemyNames = {}, -- [guid] = name
    matchHistory = {}, -- [guid] = { {spell, time}, ... }
    inArena = false,
    arenaStart = 0,
    playerCasting = false,
    dampening = 0,
}

-- Create the main engine frame
local engine = CreateFrame("Frame", "MAPEngine", UIParent)

local EVENTS = {
    "PLAYER_LOGIN",
    "PLAYER_ENTERING_WORLD",
    "COMBAT_LOG_EVENT_UNFILTERED",
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_FAILED",
    "ARENA_PREP_OPPONENT_SPECIALIZATIONS",
    "ARENA_OPPONENT_UPDATE",
    "UNIT_HEALTH",
    "UNIT_AURA",
}

for _, event in ipairs(EVENTS) do
    engine:RegisterEvent(event)
end

engine:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

-- PLAYER_LOGIN: Init saved variables and alert system
function engine:PLAYER_LOGIN()
    if not MidnightPredictorDB then
        MidnightPredictorDB = CopyTable(defaults)
    end

    for k, v in pairs(defaults) do
        if MidnightPredictorDB[k] == nil then
            MidnightPredictorDB[k] = v
        end
    end

    ns.db = MidnightPredictorDB
    ns:InitAlerts()
    ns:InitGuide()
    print("|cFFFF0000[MAP]|r |cFF00CCFFMidnight Arena Predictor|r v2.0 loaded!")
    print("|cFFFF0000[MAP]|r IN YOUR FACE mode |cFFFF0000ACTIVE|r | /map help")
end

-- PLAYER_ENTERING_WORLD: Detect arena instance
function engine:PLAYER_ENTERING_WORLD()
    local _, instanceType = IsInInstance()

    if instanceType == "arena" then
        ns.state.inArena = true
        ns.state.arenaStart = GetTime()
        ns.state.enemyCDs = {}
        ns.state.enemyTrinkets = {}
        ns.state.enemyDR = {}
        ns.state.matchHistory = {}
        ns.state.dampening = 0
        print("|cFFFF0000[MAP]|r Arena detected - ALL TRACKING ACTIVE")
    else
        if ns.state.inArena then
            print("|cFFFF0000[MAP]|r Left arena - tracking paused")
        end

        ns.state.inArena = false
    end
end

-- Detect enemy specs from arena API before match starts
function engine:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
    for i = 1, GetNumArenaOpponentSpecs() do
        local specID = GetArenaOpponentSpec(i)

        if specID and specID > 0 then
            local _, specName, _, _, _, classFile = GetSpecializationInfoByID(specID)
            local guid = UnitGUID("arena" .. i)

            if guid then
                ns.state.enemySpecs[guid] = { class = classFile, spec = specName }
                ns.state.enemyCDs[guid] = {}
                ns.state.enemyNames[guid] = UnitName("arena" .. i) or ("Arena" .. i)
                print("|cFFFF0000[MAP]|r Detected: |cFFFFFF00" .. ns.state.enemyNames[guid] .. "|r (" .. classFile .. " - " .. specName .. ")")
            end
        end
    end
end

function engine:ARENA_OPPONENT_UPDATE(unit, updateType)
    if updateType == "seen" or updateType == "detected" then
        local guid = UnitGUID(unit)

        if guid and not ns.state.enemyCDs[guid] then
            ns.state.enemyCDs[guid] = {}
            local _, classFile = UnitClass(unit)
            local idx = tonumber(unit:match("%d+"))

            if idx then
                local specID = GetArenaOpponentSpec(idx)

                if specID and specID > 0 then
                    local _, specName = GetSpecializationInfoByID(specID)
                    ns.state.enemySpecs[guid] = { class = classFile, spec = specName }
                end
            end

            ns.state.enemyNames[guid] = UnitName(unit) or unit
        end
    end
end

-- COMBAT_LOG_EVENT_UNFILTERED: Process all hostile combat events 
function engine:COMBAT_LOG_EVENT_UNFILTERED() 
    local _, subEvent, _, sourceGUID, sourceName, sourceFlags, _, 
    destGUID, destName, destFlags, _, spellID, spellName = 
    CombatLogGetCurrentEventInfo()
    
    if not sourceGUID then return end 
    local isHostile = bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 
    if not isHostile then return end 
    if subEvent == "SPELL_CAST_SUCCESS" then 
        self:OnEnemyCast(sourceGUID, sourceName, spellID, spellName, destGUID, 
        destName) 
    elseif subEvent == "SPELL_CAST_START" then 
        self:OnEnemyCastStart(sourceGUID, sourceName, spellID, spellName, destGUID, 
        destName) 
    elseif subEvent == "SPELL_INTERRUPT" then 
        self:OnInterruptLanded(sourceGUID, sourceName, spellID, spellName, destGUID, 
        destName) 
    end 
end

-- OnEnemyCast: Route successful enemy casts to the right handler 
function engine:OnEnemyCast(sourceGUID, sourceName, spellID, spellName, destGUID, 
    destName) 
    if not ns.db then return end 
    local now = GetTime() 
    local shortName = sourceName and sourceName:match("^[^-]+") or "Enemy" 
    if not ns.state.enemyCDs[sourceGUID] then ns.state.enemyCDs[sourceGUID] = {} end 
    
    -- INTERRUPTS: Kick used = SAFE TO CAST alert 
    if ns.Interrupts[spellID] then 
        local data = ns.Interrupts[spellID] 
        ns.state.enemyCDs[sourceGUID][spellID] = now + data.cd 
        if ns.db.showSafeToCast then 
            ns:BigAlert("SAFE TO CAST!", shortName.." "..data.name.." ON CD - 
"..data.cd.."s FREE!", "SAFE", data.cd) 
end 
return 
end

-- BURST CDs: Alert and predict next in sequence 
if ns.BurstCDs[spellID] then 
    local data = ns.BurstCDs[spellID] 
    ns.state.enemyCDs[sourceGUID][spellID] = now + data.cd 
    if ns.db.trackBurst 
    then ns:BigAlert(data.alert, shortName.." -> "..data.name.." 
        ("..data.dur.."s)", "DANGER", data.dur) 
        if ns.db.predictBurstSeq then self:PredictNext(sourceGUID, spellName) 
        end 
    end 
    return 
end 

-- DEFENSIVES: Info alert 
if ns.Defensives[spellID] then 
    local data = ns.Defensives[spellID] 
    ns.state.enemyCDs[sourceGUID][spellID] = now + data.cd 
    if ns.db.trackDefensives then 
        ns:BigAlert(data.alert, shortName.." -> "..data.name.." ("..(data.dur or 0).."s)", "INFO", data.dur or 0) 
    end 
    return 
end 

-- CC: Alert if targeting player/team, track DR if ns.CC[spellID] then local data = ns.CC[spellID] 
    ns.state.enemyCDs[sourceGUID][spellID] = now + data.cd 
    local isTargetingPlayer = destGUID == UnitGUID("player") 
    local isTargetingAlly = bit.band(destFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0 and bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 
    if (isTargetingPlayer or isTargetingAlly) and ns.db.trackCC then 
        ns:BigAlert(data.alert, shortName.." -> "..data.name.." ("..data.cd.."s)", "CC", data.cd) 
    end 
    if isTargetingPlayer then self:TrackDR(sourceGUID, data.drCat) end 
    return 
end