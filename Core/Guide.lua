local addonName, ns = ...

local guideTips = {
    DEATHKNIGHT = {
        default = "Track their interrupts and defensive windows; they punish overcommits hard."
    },
    DEMONHUNTER = {
        default = "They are very mobile and bursty. Watch for their big opener windows."
    },
    DRUID = {
        default = "Expect crowd control and heavy defensive cooldowns; save your own pressure for the window after their defensive."
    },
    EVOKER = {
        default = "Their burst is punishing. Delay your big cast if they are in the middle of their cooldowns."
    },
    HUNTER = {
        default = "Kick windows matter; avoid overcommitting into their burst sequence."
    },
    MAGE = {
        default = "Their lockouts are dangerous. Play around your interrupt and defensive timing."
    },
    MONK = {
        default = "Keep pressure up but respect their defensive windows and mobility."
    },
    PALADIN = {
        default = "Their defensives are strong. Punish them when they spend their defensive cooldowns."
    },
    PRIEST = {
        default = "Silence and crowd control windows are very strong. Respect them and play around them."
    },
    ROGUE = {
        default = "They punish mistakes with burst and mobility. Do not overcast into their setup."
    },
    SHAMAN = {
        default = "They can force awkward windows with interrupts and burst; play around their cooldowns."
    },
    WARLOCK = {
        default = "Their defensives and crowd control are punishing. Delay aggressive casts if they are sitting on a defensive."
    },
    WARRIOR = {
        default = "Their burst is simple but strong. They punish mispositioning and overcommitting."
    },
}

function ns:InitGuide()
    self.guideTips = guideTips
end

function ns:GetGuideTip(unit)
    if not unit then
        return "Use your cooldowns when the enemy is under pressure."
    end

    local guid = UnitGUID(unit)
    if not guid then
        return "Use your cooldowns when the enemy is under pressure."
    end

    local enemySpec = ns.state.enemySpecs[guid]
    if not enemySpec then
        return "Use your cooldowns when the enemy is under pressure."
    end

    local classTips = self.guideTips[enemySpec.class]
    if classTips then
        return classTips[enemySpec.spec] or classTips.default or "Use your cooldowns when the enemy is under pressure."
    end

    return "Use your cooldowns when the enemy is under pressure."
end
