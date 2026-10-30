local _, addonTable = ...

local SettingsLib = addonTable.SettingsLib or LibStub("LibEQOLSettingsMode-1.0")
local L = addonTable.L

local featureId = "SCRB_POWER_COLORS"

addonTable.AvailableFeatures = addonTable.AvailableFeatures or {}
table.insert(addonTable.AvailableFeatures, featureId)

addonTable.FeaturesMetadata = addonTable.FeaturesMetadata or {}
addonTable.FeaturesMetadata[featureId] = {
}

-- Keep saved keys unchanged; this only reorganizes their controls.
local function entry(label, key, specID, glow)
    if glow then label = label .. " (" .. L["COLOR_GLOW"] .. ")" end
    if specID then
        local _, specName = GetSpecializationInfoByID(specID)
        label = specName .. " - " .. label
    end
    return { label = label, key = key }
end

local function spell(id, fallback)
    return C_Spell.GetSpellName(id) or fallback
end

-- Classes are alphabetical; within each class: shared settings, then specs in
-- specialization order, then primary, secondary, and tertiary resources.
local ClassColors = {
    { class = "DEATHKNIGHT", entries = {
        entry(L["RUNIC_POWER"], Enum.PowerType.RunicPower),
        entry(RUNES, Enum.PowerType.RuneBlood, 250),
        entry(spell(195181, "Bone Shield"), "BONE_SHIELD", 250),
        entry(spell(391458, "Sanguine Ground"), "GLOW_BONE_SHIELD", 250, true),
        entry(RUNES, Enum.PowerType.RuneFrost, 251),
        entry(RUNES, Enum.PowerType.RuneUnholy, 252),
        entry(spell(1254252, "Lesser Ghoul"), "LESSER_GHOULS", 252),
        entry(spell(1241077, "Festering Scythe"), "GLOW_FESTERING_SCYTHE", 252, true),
    } },
    { class = "DEMONHUNTER", entries = {
        entry(L["FURY"], Enum.PowerType.Fury),
        entry(L["COLOR_SOUL_FRAGMENTS"], "SOUL_FRAGMENTS_VENGEANCE", 581),
        entry(L["COLOR_SOUL_FRAGMENTS"], "SOUL_FRAGMENTS", 1480),
        entry(L["COLOR_SOUL_FRAGMENTS_VOID_META"], "SOUL_FRAGMENTS_VOID_META", 1480),
        entry(L["COLOR_GROUND_SOUL_FRAGMENTS"], "SOUL_FRAGMENTS_GROUND", 1480),
        entry(spell(1238495, "Moment of Craving"), "GLOW_MOMENT_OF_CRAVING", 1480, true),
    } },
    { class = "DRUID", entries = {
        entry(L["LUNAR_POWER"], Enum.PowerType.LunarPower, 102),
    } },
    { class = "EVOKER", entries = {
        entry(L["ESSENCE"], Enum.PowerType.Essence),
        entry(L["EBON_MIGHT"], "EBON_MIGHT", 1473),
    } },
    { class = "HUNTER", entries = {
        entry(L["FOCUS"], Enum.PowerType.Focus),
        entry(L["TIP_OF_THE_SPEAR"], "TIP_OF_THE_SPEAR", 255),
    } },
    { class = "MAGE", entries = {
        entry(L["ARCANE_CHARGES"], Enum.PowerType.ArcaneCharges, 62),
        entry(L["ICICLES"], "ICICLES", 64),
    } },
    { class = "MONK", entries = {
        entry(L["STAGGER_LOW"], "STAGGER_LOW", 268),
        entry(L["STAGGER_MEDIUM"], "STAGGER_MEDIUM", 268),
        entry(L["STAGGER_HIGH"], "STAGGER_HEAVY", 268),
        entry(L["CHI"], Enum.PowerType.Chi, 269),
    } },
    { class = "PALADIN", entries = {
        entry(L["HOLY_POWER"], Enum.PowerType.HolyPower),
        entry(spell(132403, "Shield of the Righteous"), "SHIELD_OF_THE_RIGHTEOUS", 66),
        entry(spell(188370, "Consecration"), "GLOW_CONSECRATION", 66, true),
    } },
    { class = "PRIEST", entries = {
        entry(L["INSANITY"], Enum.PowerType.Insanity, 258),
    } },
    { class = "ROGUE", entries = {
        entry(L["OVERCHARGED_COMBO_POINTS"], "OVERCHARGED_COMBO_POINTS"),
    } },
    { class = "SHAMAN", entries = {
        entry(L["MAELSTROM"], Enum.PowerType.Maelstrom, 262),
        entry(L["MAELSTROM_WEAPON"], "MAELSTROM_WEAPON", 263),
        entry(L["MAELSTROM_WEAPON"] .. " > 5", "MAELSTROM_WEAPON_ABOVE_5", 263),
    } },
    { class = "WARLOCK", entries = {
        entry(L["SOUL_SHARDS"], Enum.PowerType.SoulShards),
    } },
    { class = "WARRIOR", entries = {
        entry(L["WHIRLWIND"], "WHIRLWIND", 72),
    } },
}

addonTable.SettingsPanelInitializers = addonTable.SettingsPanelInitializers or {}
addonTable.SettingsPanelInitializers[featureId] = function(category)
    local settings = MandingaSenseiClassResourceBarDB["_Settings"]
    settings.HealthColors = settings.HealthColors or {}
    settings.PowerColors = settings.PowerColors or {}

    local function addSection(name, entries)
        local section = SettingsLib:CreateExpandableSection(category, {
            name = name,
            expanded = true,
            colorizeTitle = true,
        })
        local initializer = SettingsLib:CreateColorOverrides(category, {
            entries = entries,
            hasOpacity = true,
            getColor = function(key)
                local color = key == "HEALTH" and addonTable:GetOverrideHealthBarColor(key)
                    or addonTable:GetOverrideResourceColor(key)
                return color.r, color.g, color.b, color.a or 1
            end,
            setColor = function(key, r, g, b, a)
                local currentSettings = MandingaSenseiClassResourceBarDB["_Settings"]
                local colors = key == "HEALTH" and currentSettings.HealthColors or currentSettings.PowerColors
                colors[key] = { r = r, g = g, b = b, a = a or 1 }
                addonTable.updateBars()
            end,
            getDefaultColor = function(key)
                local color = key == "HEALTH" and addonTable:GetHealthBarColor(key)
                    or addonTable:GetResourceColor(key)
                return color.r, color.g, color.b, color.a or 1
            end,
            colorizeLabel = true,
            parentSection = section,
        })
        hooksecurefunc(initializer, "InitFrame", function(_, panel)
            local labelWidth = 400
            for _, row in ipairs(panel.colorOverrideFrames) do
                labelWidth = math.max(labelWidth, row.Text:GetUnboundedStringWidth())
            end
            for _, row in ipairs(panel.colorOverrideFrames) do
                row.Text:ClearAllPoints()
                row.Text:SetPoint("LEFT", row, "LEFT", 0, 0)
                row.Text:SetWidth(labelWidth)
                row.ColorSwatch:ClearAllPoints()
                row.ColorSwatch:SetPoint("LEFT", row.Text, "RIGHT", 24, 0)
            end
        end)
    end

    addSection(L["SETTINGS_HEADER_GENERAL_COLORS"], {
        entry(L["HEALTH"], "HEALTH"),
        entry(L["MANA"], Enum.PowerType.Mana),
        entry(L["RAGE"], Enum.PowerType.Rage),
        entry(L["ENERGY"], Enum.PowerType.Energy),
        entry(L["COMBO_POINTS"], Enum.PowerType.ComboPoints),
    })
    for _, section in ipairs(ClassColors) do
        addSection(LOCALIZED_CLASS_NAMES_MALE[section.class], section.entries)
    end
end
