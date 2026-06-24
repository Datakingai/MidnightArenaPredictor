-- MIDNIGHT ARENA PREDICTOR: ABILITY DATABASE 
-- Source: wow_midnight_arena_prediction.xlsx 
-- WoW Midnight Patch 12.0.5/12.0.7 - Season 1
 ------------------------------------------------------ 
 local addonName, ns = ...

 ------------------------------------------------------ 
 -- INTERRUPT DATABASE (Tier 1 - ALWAYS TRACK) 
 -- [spellID] = { name, cd, range, lockout, class, spec } 
 -- Priority Tier 1 = Must-Track (from Ability Database sheet) 
 ------------------------------------------------------ 
 ns.Interrupts = { 
    -- Death Knight: Mind Freeze - 15s CD, 15yd melee range, 3s lockout 
    [47528] = { name = "Mind Freeze", cd = 15, range = 15, lockout = 3, class = "DEATHKNIGHT", spec = "All" }, 
    -- Demon Hunter: Disrupt - 15s CD, 10yd, 3s lockout. AGGRESSIVE usage (short CD) 
    [183752] = { name = "Disrupt", cd = 15, range = 10, lockout = 3, class = "DEMONHUNTER", spec = "All" }, 
    -- Druid Feral/Guardian: Skull Bash - 15s CD, 13yd, 4s lockout 
    [106839] = { name = "Skull Bash", cd = 15, range = 13, lockout = 4, class = "DRUID", spec = "Feral/Guardian" }, 
    -- Druid Balance: Solar Beam - 60s CD! 40yd, 8s SILENCE. Always held for kill windows. 
    [78675] = { name = "Solar Beam", cd = 60, range = 40, lockout = 8, class = "DRUID", spec = "Balance" }, 
    -- Evoker: Quell - 40s CD, 25yd, 4s lockout. Held for burst windows. 
    [351338] = { name = "Quell", cd = 40, range = 25, lockout = 4, class = "EVOKER", spec = "Devastation/Aug" }, 
    -- Hunter BM/MM: Counter Shot - 24s CD, 40yd ranged, 3s lockout 
    [147362] = { name = "Counter Shot", cd = 24, range = 40, lockout = 3, class = "HUNTER", spec = "BM/Marksmanship" }, 
    -- Hunter Survival: Muzzle - 15s CD, 5yd melee, 3s lockout 
    [187707] = { name = "Muzzle", cd = 15, range = 5, lockout = 3, class = "HUNTER", spec = "Survival" }, 
    -- Mage: Counterspell - 24s CD, 40yd, 6s lockout! Strategic - longest lockout. 
    [2139] = { name = "Counterspell", cd = 24, range = 40, lockout = 6, class = "MAGE", spec = "All" }, 
    -- Monk: Spear Hand Strike - 15s CD, 5yd melee, 4s lockout 
    [116705] = { name = "Spear Hand Strike", cd = 15, range = 5, lockout = 4, class = "MONK", spec = "All" }, 
    -- Paladin: Rebuke - 15s CD, 5yd melee, 4s lockout. Held for kill attempts. 
    [96231] = { name = "Rebuke", cd = 15, range = 5, lockout = 4, class = "PALADIN", spec = "All" }, 
    -- Priest Shadow: Silence - 45s CD! 30yd, 4s lockout. ALWAYS held for kill windows. 
    [15487] = { name = "Silence", cd = 45, range = 30, lockout = 4, class = "PRIEST", spec = "Shadow" }, 
    -- Rogue: Kick - 15s CD, 5yd melee, 5s lockout! Longest melee kick. 
    [1766] = { name = "Kick", cd = 15, range = 5, lockout = 5, class = "ROGUE", spec = "All" }, 
    -- Shaman Ele/Enh: Wind Shear - 12s CD! Shortest. Used LIBERALLY, almost on CD.
    [57994] = { name = "Wind Shear", cd = 12, range = 30, lockout = 3, class = "SHAMAN", spec = "Elemental/Enhancement" }, 
    -- Shaman Resto: Wind Shear - 30s CD for healer spec. 
    [57995] = { name = "Wind Shear (Resto)", cd = 30, range = 30, lockout = 3, class = "SHAMAN", spec = "Restoration" }, 
    -- Warlock: Spell Lock (pet) - 24s CD, 40yd, 6s lockout! Devastating. 
    [19647] = { name = "Spell Lock", cd = 24, range = 40, lockout = 6, class = "WARLOCK", spec = "Aff/Destruction" }, 
    -- Warlock Demo: Axe Toss (pet) - 30s CD, 30yd, stun interrupt 
    [89766] = { name = "Axe Toss", cd = 30, range = 30, lockout = 3, class = "WARLOCK", spec = "Demonology" }, 
    -- Warrior: Pummel - 15s CD, 5yd melee, 4s lockout. Primary melee interrupt. 
    [6552] = { name = "Pummel", cd = 15, range = 5, lockout = 4, class = "WARRIOR", spec = "All" },
    }
    ------------------------------------------------------ 
    -- INTERRUPT BEHAVIOR PATTERNS (from Interrupt Patterns sheet) 
    -- Calibrates prediction confidence per class 
    ------------------------------------------------------ 
    ns.InterruptBehavior = { DEATHKNIGHT = { philosophy = "Hold for healer casts or counter-setup", 
    aggressive = false,  weight = 0.85 }, 
    DEMONHUNTER = { philosophy = "Aggressive - short CD allows liberal usage", 
    aggressive = true, weight = 0.90 }, 
    DRUID = { philosophy = "Hold for critical healer casts during burst", 
    aggressive = false, weight = 0.80 }, 
    EVOKER = { philosophy = "Long CD - held for burst windows", 
    aggressive = false, weight = 0.85 }, 
    HUNTER = { philosophy = "Hold for healer during burst windows", 
    aggressive = false, weight = 0.75 }, 
    MAGE = { philosophy = "Strategic - 6 sec lockout is devastating", 
    aggressive = false, weight = 0.90 }, 
    MONK = { philosophy = "Hold for healer during burst", 
    aggressive = false, weight = 0.75 }, 
    PALADIN = { philosophy = "Hold for critical healer casts", 
    aggressive = false, weight = 0.75 }, 
    PRIEST = { philosophy = "ALWAYS held for coordinated kill attempts", 
    aggressive = false, weight = 0.95 }, 
    ROGUE = { philosophy = "Strategic - 5 sec lockout is longest melee", 
    aggressive = false, weight = 0.85 }, 
    SHAMAN = { philosophy = "Shortest CD - used LIBERALLY on cooldown", 
    aggressive = true, weight = 0.95 }, 
    WARLOCK = { philosophy = "Held for critical healer casts - 6 sec lockout", 
    aggressive = false, weight = 0.90 }, 
    WARRIOR = { philosophy = "Strategic hold for kill windows", 
    aggressive = false, weight = 0.85 },
    }
    ------------------------------------------------------ 
    -- BURST COOLDOWNS (Tier 1-2, from Ability Database sheet) 
    -- [spellID] = { name, cd, dur, class, spec, alert } 
    ------------------------------------------------------ 
    ns.BurstCDs = { 
    -- Death Knight 
    [51271] = { name = "Pillar of Frost", cd = 60, dur = 12, class = 
    "DEATHKNIGHT", spec = "Frost", alert = "PILLAR OF FROST!" }, 
    [207289] = { name = "Unholy Assault", cd = 90, dur = 20, class = 
    "DEATHKNIGHT", spec = "Unholy", alert = "UNHOLY ASSAULT!" }, 
    -- Demon Hunter 
    [191427] = { name = "Metamorphosis", cd = 180, dur = 24, class = 
    "DEMONHUNTER", spec = "Havoc", alert = "META POPPED!" }, 
    [198013] = { name = "Eye Beam", cd = 30, dur = 2, class = 
    "DEMONHUNTER", spec = "Havoc", alert = "EYE BEAM!" }, 
    [370965] = { name = "The Hunt", cd = 90, dur = 0, class = 
    "DEMONHUNTER", spec = "Havoc", alert = "THE HUNT - MASSIVE HIT!" }, 
    -- Druid 
    [102560] = { name = "Incarnation: Elune", cd = 180, dur = 30, class = 
    "DRUID", spec = "Balance", alert = "INCARNATION - BOOMKIN GO!" }, 
    [106951] = { name = "Berserk", cd = 180, dur = 20, class = 
    "DRUID", spec = "Feral", alert = "BERSERK - FERAL BURST!" }, 
    -- Evoker 
    [375087] = { name = "Dragonrage", cd = 120, dur = 18, class = 
    "EVOKER", spec = "Devastation", alert = "DRAGONRAGE!" }, 
    -- Hunter 
    [19574] = { name = "Bestial Wrath", cd = 90, dur = 15, class = 
    "HUNTER", spec = "BeastMastery", alert = "BESTIAL WRATH!" }, 
    [288613] = { name = "Trueshot", cd = 120, dur = 15, class = 
    "HUNTER", spec = "Marksmanship", alert = "TRUESHOT - MM BURST!" }, 
    [360952] = { name = "Coordinated Assault", cd = 120, dur = 20, class = 
    "HUNTER", spec = "Survival", alert = "COORDINATED ASSAULT!" }, 
    -- Mage 
    [12472] = { name = "Icy Veins", cd = 120, dur = 25, class = 
    "MAGE", spec = "Frost", alert = "ICY VEINS - SHATTER INCOMING!" }, 
    [190319] = { name = "Combustion", cd = 120, dur = 12, class = 
    "MAGE", spec = "Fire", alert = "COMBUSTION!" }, 
    [365350] = { name = "Arcane Surge", cd = 90, dur = 15, class = 
    "MAGE", spec = "Arcane", alert = "ARCANE SURGE!" }, 
    -- Monk 
    [137639] = { name = "Storm, Earth, and Fire", cd = 90, dur = 15, class = 
    "MONK", spec = "Windwalker", alert = "SEF - WW BURST!" }, 
    -- Paladin 
    [31884] = { name = "Avenging Wrath", cd = 60, dur = 20, class = 
    "PALADIN", spec = "Retribution", alert = "WINGS!" }, 
    -- Priest 
    [228260] = { name = "Void Eruption", cd = 90, dur = 15, class = 
    "PRIEST", spec = "Shadow", alert = "VOID FORM!" }, 
    -- Rogue 
    [360194] = { name = "Deathmark", cd = 120, dur = 16, class = 
    "ROGUE", spec = "Assassination", alert = "DEATHMARK!" }, 
    [185313] = { name = "Shadow Dance", cd = 60, dur = 6, class = 
    "ROGUE", spec = "Subtlety", alert = "SHADOW DANCE - SUB GO!" }, 
    [13750] = { name = "Adrenaline Rush", cd = 180, dur = 20, class = 
    "ROGUE", spec = "Outlaw", alert = "ADRENALINE RUSH!" }, 
    -- Shaman 
    [114051] = { name = "Ascendance", cd = 180, dur = 15, class = 
    "SHAMAN", spec = "Elemental", alert = "ASCENDANCE - ELE BURST!" }, 
    [114052] = { name = "Ascendance (Enh)", cd = 180, dur = 15, class = 
    "SHAMAN", spec = "Enhancement", alert = "ASCENDANCE - ENH BURST!" }, 
    -- Warlock 
    [205180] = { name = "Summon Darkglare", cd = 120, dur = 20, class = 
    "WARLOCK", spec = "Affliction", alert = "DARKGLARE!" }, 
    [265187] = { name = "Summon Demonic Tyrant", cd = 90, dur = 15, class = 
    "WARLOCK", spec = "Demonology", alert = "DEMONIC TYRANT!" }, 
    [1122] = { name = "Summon Infernal", cd = 180, dur = 30, class = 
    "WARLOCK", spec = "Destruction", alert = "INFERNAL - AOE STUN!" }, 
    -- Warrior 
    [167105] = { name = "Colossus Smash", cd = 45, dur = 10, class = 
    "WARRIOR", spec = "Arms", alert = "COLOSSUS SMASH - 35% AMP!" }, 
    [107574] = { name = "Avatar", cd = 90, dur = 20, class = 
    "WARRIOR", spec = "Arms", alert = "AVATAR!" }, 
    [1719] = { name = "Recklessness", cd = 90, dur = 12, class = 
    "WARRIOR", spec = "Fury", alert = "RECKLESSNESS!" },
 }
 ------------------------------------------------------ 
 -- DEFENSIVE COOLDOWNS (Tier 1, from Ability Database sheet) 
 -- Ordered by Defensive Priorities sheet usage order 
 ------------------------------------------------------ 
 ns.Defensives = { 
    [48707] = { name = "Anti-Magic Shell", cd = 60, dur = 5, class = 
    "DEATHKNIGHT", alert = "AMS - MAGIC IMMUNE!" }, 
    [48792] = { name = "Icebound Fortitude", cd = 180, dur = 8, class = 
    "DEATHKNIGHT", alert = "IBF - STUN IMMUNE + DR!" }, 
    [198589] = { name = "Blur", cd = 60, dur = 10, class = 
    "DEMONHUNTER", alert = "BLUR - DODGE!" }, 
    [196555] = { name = "Netherwalk", cd = 180, dur = 6, class = 
    "DEMONHUNTER", alert = "NETHERWALK - FULL IMMUNE!" }, 
    [22812] = { name = "Barkskin", cd = 60, dur = 8, class = 
    "DRUID", alert = "BARKSKIN!" }, 
    [61336] = { name = "Survival Instincts", cd = 180, dur = 6, class = 
    "DRUID", alert = "SURVIVAL INSTINCTS - 50% DR!" },
    [363916] = { name = "Obsidian Scales", cd = 90, dur = 12, class = 
    "EVOKER", alert = "OBSIDIAN SCALES!" }, 
    [186265] = { name = "Aspect of the Turtle", cd = 180, dur = 8, class = 
    "HUNTER", alert = "TURTLE - FULL IMMUNE!" }, 
    [109304] = { name = "Exhilaration", cd = 120, dur = 0, class = 
    "HUNTER", alert = "EXHILARATION - BIG HEAL!" }, 
    [45438] = { name = "Ice Block", cd = 240, dur = 10, class = 
    "MAGE", alert = "ICE BLOCK!" }, 
    [342245] = { name = "Alter Time", cd = 60, dur = 10, class = 
    "MAGE", alert = "ALTER TIME - WILL SNAP BACK!" }, 
    [122470] = { name = "Touch of Karma", cd = 90, dur = 10, class = 
    "MONK", alert = "KARMA - STOP HITTING!" }, 
    [122783] = { name = "Diffuse Magic", cd = 90, dur = 6, class = 
    "MONK", alert = "DIFFUSE MAGIC!" }, 
    [642] = { name = "Divine Shield", cd = 300, dur = 8, class = 
    "PALADIN", alert = "BUBBLE!" }, 
    [1022] = { name = "Blessing of Protection", cd = 300, dur = 10, class = 
    "PALADIN", alert = "BOP - PHYS IMMUNE!" }, 
    [498] = { name = "Divine Protection", cd = 60, dur = 8, class = 
    "PALADIN", alert = "DIVINE PROTECTION!" }, 
    [33206] = { name = "Pain Suppression", cd = 180, dur = 8, class = 
    "PRIEST", alert = "PAIN SUPP - 40% DR!" }, 
    [47585] = { name = "Dispersion", cd = 90, dur = 6, class = 
    "PRIEST", alert = "DISPERSION - 75% DR!" }, 
    [5277] = { name = "Evasion", cd = 120, dur = 10, class = 
    "ROGUE", alert = "EVASION - DODGE!" }, 
    [31224] = { name = "Cloak of Shadows", cd = 120, dur = 5, class = 
    "ROGUE", alert = "CLOAK - MAGIC IMMUNE!" }, 
    [1856] = { name = "Vanish", cd = 120, dur = 0, class = 
    "ROGUE", alert = "VANISH!" }, 
    [108271] = { name = "Astral Shift", cd = 90, dur = 12, class = 
    "SHAMAN", alert = "ASTRAL SHIFT - 40% DR!" }, 
    [104773] = { name = "Unending Resolve", cd = 180, dur = 8, class = 
    "WARLOCK", alert = "UNENDING RESOLVE - INTERRUPT IMMUNE!" }, 
    [108416] = { name = "Dark Pact", cd = 45, dur = 20, class = 
    "WARLOCK", alert = "DARK PACT!" }, 
    [118038] = { name = "Die by the Sword", cd = 180, dur = 8, class = 
    "WARRIOR", alert = "DIE BY THE SWORD!" }, 
    [184364] = { name = "Enraged Regeneration", cd = 120, dur = 8, class = 
    "WARRIOR", alert = "ENRAGED REGEN!" }, 
    [97462] = { name = "Rallying Cry", cd = 180, dur = 10, class = 
    "WARRIOR", alert = "RALLYING CRY - TEAM HP!" }, 
    [23920] = { name = "Spell Reflection", cd = 25, dur = 5, class = 
    "WARRIOR", alert = "SPELL REFLECT - DON'T CAST!" },
    } 
    ------------------------------------------------------ 
    -- CC DATABASE (Tier 1, from Ability Database sheet) 
    -- drCat = DR category for 16s Midnight DR tracking
    ------------------------------------------------------ 
    ns.CC = { 
        [408] = { name = "Kidney Shot", cd = 0, dur = 6, class = 
        "ROGUE", drCat = "Stun", alert = "KIDNEY SHOT!" }, 
        [1833] = { name = "Cheap Shot", cd = 0, dur = 4, class = 
        "ROGUE", drCat = "Stun", alert = "CHEAP SHOT!" }, 
        [853] = { name = "Hammer of Justice", cd = 60, dur = 6, class = 
        "PALADIN", drCat = "Stun", alert = "HoJ!" }, 
        [132169] = { name = "Storm Bolt", cd = 30, dur = 4, class = 
        "WARRIOR", drCat = "Stun", alert = "STORM BOLT!" }, 
        [179057] = { name = "Chaos Nova", cd = 45, dur = 5, class = 
        "DEMONHUNTER", drCat = "Stun", alert = "CHAOS NOVA!" }, 
        [119381] = { name = "Leg Sweep", cd = 60, dur = 5, class = 
        "MONK", drCat = "Stun", alert = "LEG SWEEP!" }, 
        [64044] = { name = "Psychic Horror", cd = 45, dur = 4, class = 
        "PRIEST", drCat = "Stun", alert = "PSYCHIC HORROR!" }, 
        [118] = { name = "Polymorph", cd = 0, dur = 8, class = 
        "MAGE", drCat = "Incap", alert = "POLYMORPH!" }, 
        [5782] = { name = "Fear", cd = 0, dur = 6, class = 
        "WARLOCK", drCat = "Disorient", alert = "FEAR!" }, 
        [33786] = { name = "Cyclone", cd = 0, dur = 6, class = 
        "DRUID", drCat = "Disorient", alert = "CYCLONE!" }, 
        [2094] = { name = "Blind", cd = 120, dur = 8, class = 
        "ROGUE", drCat = "Disorient", alert = "BLIND!" }, 
        [51514] = { name = "Hex", cd = 30, dur = 8, class =
        "SHAMAN", drCat = "Incap", alert = "HEX!" }, 
        [3355] = { name = "Freezing Trap", cd = 25, dur = 8, class = 
        "HUNTER", drCat = "Incap", alert = "TRAP!" }, 
        [207167] = { name = "Blinding Sleet", cd = 60, dur = 4, class = 
        "DEATHKNIGHT", drCat = "Disorient", alert = "BLINDING SLEET!" }, 
        [8122] = { name = "Psychic Scream", cd = 30, dur = 8, class = 
        "PRIEST", drCat = "Disorient", alert = "PSYCHIC SCREAM!" }, 
        [5246] = { name = "Intimidating Shout", cd = 90, dur = 8, class = 
        "WARRIOR", drCat = "Disorient", alert = "FEAR!" }, 
        [31661] = { name = "Dragon's Breath", cd = 20, dur = 4, class = 
        "MAGE", drCat = "Disorient", alert = "DRAGON'S BREATH!" }, 
        [115078] = { name = "Paralysis", cd = 45, dur = 4, class = 
        "MONK", drCat = "Incap", alert = "PARALYSIS!" }, 
        [360806] = { name = "Sleep Walk", cd = 15, dur = 6, class = 
        "EVOKER", drCat = "Incap", alert = "SLEEP WALK!" }, 
        [217832] = { name = "Imprison", cd = 45, dur = 4, class = 
        "DEMONHUNTER", drCat = "Incap", alert = "IMPRISON!" },
    }
       
        -- Utility spells (Grounding Totem, Spell Reflect, etc.) 
        ns.Utility = { 
            [23920] = { name = "Spell Reflection", cd = 25, class = 
            "WARRIOR", alert = "SPELL REFLECT - DON'T CAST!" }, 
            [204336] = { name = "Grounding Totem", cd = 25, class = 
            "SHAMAN", alert = "GROUNDING - SNIPE IT!" }, 
            [32375] = { name = "Mass Dispel", cd = 45, class = 
            "PRIEST", alert = "MASS DISPEL!" }, 
            [212182] = { name = "Smoke Bomb", cd = 180, class = 
            "ROGUE", alert = "SMOKE BOMB - CAN'T TARGET!" }, 
        }

        -- PvP Trinket (GetArenaCrowdControlInfo fallback)
        ns.TRINKET_SPELLID = 336126 
        ns.TRINKET_CD = 120
        ------------------------------------------------------ 
        -- BURST SEQUENCES (from Burst Sequences sheet) 
        -- Full step-by-step kill rotations per spec 
        -- After detecting opener, addon predicts next step
        ------------------------------------------------------ 
        ns.BurstSequences = { ["WARRIOR_Arms"] = { 
            { spell = "Storm Bolt", next = "AVATAR NEXT -> THEN COLOSSUS SMASH" }, 
            { spell = "Avatar", next = "COLOSSUS SMASH NEXT -> 35% DMG AMP WINDOW" }, 
            { spell = "Colossus Smash", next = "DEMOLISH INCOMING -> BIG HIT" }, 
            { spell = "Demolish", next = "MORTAL STRIKE -> EXECUTE IF LOW" }, 
            { spell = "Mortal Strike", next = "EXECUTE RANGE? FINISH THEM!" }, 
        }, 
        ["WARRIOR_Fury"] = { 
            { spell = "Recklessness", next = "RAMPAGE SPAM INCOMING" }, 
        }, 
        ["ROGUE_Subtlety"] = { 
            { spell = "Cheap Shot", next = "KIDNEY ON KILL TARGET NEXT" },
            { spell = "Kidney Shot", next = "SHADOW DANCE -> FULL BURST IN STUN!" },
            { spell = "Shadow Dance", next = "BURST DURING STUN - USE DEFENSIVE!" }, 
            { spell = "Blind", next = "BLIND ON HEALER -> KILL ATTEMPT NOW!" }, 
        }, 
        ["PALADIN_Retribution"] = { 
            { spell = "Hammer of Justice", next = "WINGS NEXT -> THEN WAKE OF ASHES" }, 
            { spell = "Avenging Wrath", next = "WAKE OF ASHES -> HAMMER OF LIGHT" }, 
            { spell = "Wake of Ashes", next = "HAMMER OF LIGHT BURST!" }, 
        }, 
        ["MAGE_Frost"] = { 
            { spell = "Polymorph", next = "ICY VEINS NEXT -> SHATTER COMBO" }, 
            { spell = "Icy Veins", next = "ICE NOVA/FROST NOVA -> SHATTER!" }, 
            { spell = "Glacial Spike", next = "ICE LANCE FOLLOW-UP!" }, 
        }, 
        ["HUNTER_Marksmanship"] = { 
            { spell = "Freezing Trap", next = "TRUESHOT + VOLLEY NEXT" }, 
            { spell = "Trueshot", next = "AIMED SHOT SPAM -> RAPID FIRE" }, 
            { spell = "Rapid Fire", next = "KILL SHOT IF LOW!" }, 
        }, 
        ["SHAMAN_Enhancement"] = {
            { spell = "Hex", next = "DOOM WINDS BURST INCOMING!" }, 
            { spell = "Ascendance", next = "SUNDERING -> MASSIVE BURST!" }, 
        }, 
        ["MONK_Windwalker"] = { 
            { spell = "Paralysis", next = "LEG SWEEP ON KILL TARGET NEXT" }, 
            { spell = "Leg Sweep", next = "SEF/TIGEREYE -> FISTS OF FURY!" }, 
            { spell = "Storm, Earth, and Fire", next = "FISTS OF FURY BURST!" }, 
        }, 
        ["DEMONHUNTER_Havoc"] = { 
            { spell = "The Hunt", next = "REAVER'S GLAIVE -> EYE BEAM NEXT" }, 
            { spell = "Eye Beam", next = "ANNIHILATION SPAM IN DEMON FORM!" }, 
            { spell = "Metamorphosis", next = "EXTENDED BURST - DEATH SWEEP SPAM!" }, 
        }, 
        ["DEATHKNIGHT_Frost"] = { 
            { spell = "Blinding Sleet", next = "FROSTWYRM'S FURY -> PILLAR!" }, 
            { spell = "Pillar of Frost", next = "OBLITERATE SPAM - BIG HITS!" }, 
        }, 
        ["WARLOCK_Destruction"] = { 
            { spell = "Fear", next = "MALEVOLENCE -> CHAOS BOLT CHAIN!" }, 
            { spell = "Malevolence", next = "CHAOS BOLT x3-4 INCOMING!" }, 
            { spell = "Summon Infernal", next = "AOE STUN -> CHAOS BOLT SPAM!" }, 
        }, 
        ["PRIEST_Shadow"] = { 
            { spell = "Psychic Horror", next = "VOID TORRENT / DARK ASCENSION!" }, 
            { spell = "Void Eruption", next = "MIND BLAST SPAM!" }, 
        }, 
        ["EVOKER_Devastation"] = { 
            { spell = "Sleep Walk", next = "TIP THE SCALES -> FIRE BREATH!" }, 
            { spell = "Dragonrage", next = "DISINTEGRATE SPAM!" }, 
        }, 
        ["DRUID_Feral"] = { 
            { spell = "Berserk", next = "CONVOKE OR BITE SPAM!" }, 
        }, 
        ["DRUID_Balance"] = { 
            { spell = "Incarnation: Elune", next = "STARSURGE SPAM -> FULL MOON!" }, 
        }, 
    }

    ------------------------------------------------------ 
    -- DR SYSTEM (Midnight values - changed from pre-Midnight!)
    -- DR reset is 16 seconds (was 18), immune at 2 applications (was 3) 
    ------------------------------------------------------ 
    ns.DR_RESET = 16 
    -- 16 seconds in Midnight (was 18) ns.DR_IMMUNE_AT = 2 
    -- Immune after 2 applications (was 3) 
    ------------------------------------------------------ 
    -- PREDICTION WEIGHTS (Bayesian Framework sheet) 
    -- Weights 0.0-1.0 determine confidence score 
    ------------------------------------------------------ 
    ns.Weights = { 
        CooldownAvailable = 1.00, -- Binary: ability off CD. PRIMARY driver. 
        TargetCastBar = 0.90, -- You casting = kick prediction boosted 
        HealthThreshold = 0.85, -- Low HP triggers defensive/offensive patterns 
        Positioning = 0.75, -- Range check eliminates impossible abilities 
        GamePhase = 0.70, -- Opener/mid/late game phase 
        DR_State = 0.65, -- DR full = won't re-CC 
        BuffDebuff = 0.60, -- Current buffs/debuffs active 
        History = 0.50, -- What they did earlier this match }
        ------------------------------------------------------ 
        -- RATING BRACKET MODIFIERS (Rating Bracket Behavior sheet) 
        -- Calibrates prediction confidence based on opponent skill 
        ------------------------------------------------------ 
        ns.RatingBrackets = { 
            { min = 0, max = 1399, confidence = 0.70, label = "Combatant", note = "Unpredictable - random usage" }, 
            { min = 1400, max = 1799, confidence = 0.80, label = "Challenger", note = "Some patterns emerging" }, 
            { min = 1800, max = 2099, confidence = 0.85, label = "Rival", note = "Predictable optimal play" }, 
            { min = 2100, max = 2399, confidence = 0.90, label = "Duelist/Glad", note = "Highly predictable" }, 
            { min = 2400, max = 9999, confidence = 0.95, label = "R1/Pro", note = "Near-perfect optimization" }, 
        }