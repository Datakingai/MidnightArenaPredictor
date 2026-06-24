local addonName, ns = ...

local engine = _G["MAPEngine"]

local function GetShortName(name)
    if not name then
        return "Enemy"
    end

    return name:match("^[^-]+") or name
end

function engine:OnEnemyCastStart(sourceGUID, sourceName, spellID, spellName, destGUID, destName)
    if not ns.db or not ns.state.inArena then
        return
    end

    local shortName = GetShortName(sourceName)
    if ns.db.showKickWarning and ns.Interrupts[spellID] then
        ns:BigAlert("KICK WARNING", shortName .. " is about to cast with an interrupt available.", "DANGER", 2.5)
    end

    if ns.state.enemyCDs[sourceGUID] then
        ns.state.enemyCDs[sourceGUID][spellID] = nil
    end

    if not ns.state.matchHistory[sourceGUID] then
        ns.state.matchHistory[sourceGUID] = {}
    end

    table.insert(ns.state.matchHistory[sourceGUID], { spell = spellName or spellID, time = GetTime() })
end

function engine:OnInterruptLanded(sourceGUID, sourceName, spellID, spellName, destGUID, destName)
    if not ns.db or not ns.state.inArena then
        return
    end

    local shortName = GetShortName(sourceName)
    ns:BigAlert("INTERRUPT", shortName .. " landed an interrupt on " .. (destName or "target"), "SAFE", 2.0)
end

function engine:PredictNext(sourceGUID, spellName)
    if not ns.db or not ns.state.inArena then
        return
    end

    local prediction = nil
    local lower = string.lower(spellName or "")

    if lower:find("pillar") then
        prediction = "Pillar of Frost -> Remorseless Winter"
    elseif lower:find("metamorphosis") then
        prediction = "Metamorphosis -> Eye Beam"
    elseif lower:find("trueshot") then
        prediction = "Trueshot -> Rapid Fire"
    elseif lower:find("combustion") then
        prediction = "Combustion -> Fireball"
    elseif lower:find("avatar") then
        prediction = "Avatar -> Mortal Strike"
    else
        prediction = "Follow-up burst window detected"
    end

    ns:BigAlert("PREDICTION", prediction, "INFO", 2.0)
end

function engine:TrackDR(sourceGUID, drCat)
    if not drCat then
        return
    end

    if not ns.state.enemyDR[sourceGUID] then
        ns.state.enemyDR[sourceGUID] = {}
    end

    local entry = ns.state.enemyDR[sourceGUID][drCat]
    if not entry then
        entry = { count = 1, lastTime = GetTime() }
        ns.state.enemyDR[sourceGUID][drCat] = entry
    else
        entry.count = entry.count + 1
        entry.lastTime = GetTime()
    end

    if entry.count >= 2 then
        ns:BigAlert("DR STACK", drCat .. " is being used aggressively. Be careful with your next cast.", "CC", 2.0)
    end
end
