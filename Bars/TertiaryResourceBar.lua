local _, addonTable = ...

local LEM = addonTable.LEM or LibStub("LibEQOLEditMode-1.0")
local L = addonTable.L

local TertiaryResourceBarMixin = Mixin({}, addonTable.PowerBarMixin)

function TertiaryResourceBarMixin:OnLoad()
    addonTable.PowerBarMixin.OnLoad(self)
    if select(2, UnitClass("player")) == "DEATHKNIGHT" then
        self.Frame:RegisterEvent("PLAYER_TALENT_UPDATE")
        self.Frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    end
end

function TertiaryResourceBarMixin:OnEvent(event, ...)
    if event == "PLAYER_TALENT_UPDATE" or event == "TRAIT_CONFIG_UPDATED" then
        self:ApplyLayout(nil, true)
        return
    end
    if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
        if not self._groundSoulContainer then self._groundSoulKey = nil end
    end
    addonTable.PowerBarMixin.OnEvent(self, event, ...)
end

function TertiaryResourceBarMixin:UpdateDisplay(layoutName, force)
    if self:GetResource() == "SOUL_FRAGMENTS_GROUND" or self:GetResource() == "BONE_SHIELD" then
        addonTable.AuraStackBar:Update(self, layoutName)
        addonTable.AuraStackBar:Show(self)
    else
        addonTable.AuraStackBar:Hide(self)
        self.StatusBar:SetAlpha(1)
        addonTable.PowerBarMixin.UpdateDisplay(self, layoutName, force)
    end
end

function TertiaryResourceBarMixin:ApplyLayout(layoutName, force)
    addonTable.PowerBarMixin.ApplyLayout(self, layoutName, force)
    self:UpdateDisplay(layoutName, force)
end

function TertiaryResourceBarMixin:GetResource()
    local playerClass = select(2, UnitClass("player"))
    self._resourceTable = self._resourceTable or {
        ["DEATHKNIGHT"] = { [250] = "BONE_SHIELD" },
        ["DEMONHUNTER"] = {
            [1480] = "SOUL_FRAGMENTS_GROUND", -- Devourer
        },
        ["DRUID"]       = nil,
        ["EVOKER"]      = {
            [1473] = "EBON_MIGHT", -- Augmentation
        },
        ["HUNTER"]      = nil,
        ["MAGE"]        = nil,
        ["MONK"]        = nil,
        ["PALADIN"]     = nil,
        ["PRIEST"]      = nil,
        ["ROGUE"]       = nil,
        ["SHAMAN"]      = nil,
        ["WARLOCK"]     = nil,
        ["WARRIOR"]     = nil,
    }

    local spec = C_SpecializationInfo.GetSpecialization()
    local specID = C_SpecializationInfo.GetSpecializationInfo(spec)

    local resource = self._resourceTable[playerClass]

    -- Druid: form-based
    if playerClass == "DRUID" then
        local formID = GetShapeshiftFormID()
        resource = resource and resource[formID or 0]
    end

    if type(resource) == "table" then
        return resource[specID]
    else
        return resource
    end
end

function TertiaryResourceBarMixin:GetResourceValue(resource)
    if not resource then return nil, nil end
    local data = self:GetData()
    if not data then return nil, nil end

    if resource == "SOUL_FRAGMENTS_GROUND" then
        return addonTable.AuraStackBar.GROUND_SOUL_MAX, 0 -- Actual values belong to the aura bindings.
    end

    if resource == "BONE_SHIELD" then
        return addonTable.AuraStackBar:GetBoneShieldMax(), 0 -- Engine-owned aura count.
    end

    if resource == "EBON_MIGHT" then
        local auraData = C_UnitAuras.GetPlayerAuraBySpellID(395296) -- Ebon Might
        local current = auraData and (auraData.expirationTime - GetTime()) or 0
        local max = 20

        return max, current
    end

    local current = UnitPower("player", resource)
    local max = UnitPowerMax("player", resource)
    if max <= 0 then return nil, nil, nil, nil end

    return max, current
end

function TertiaryResourceBarMixin:GetTagValues(resource, max, current, precision)
    local tagValues = addonTable.PowerBarMixin.GetTagValues(self, resource, max, current, precision)

    if resource == "EBON_MIGHT" then
        tagValues["[current]"] = function() return string.format("%.1f", AbbreviateNumbers(current)) end
    end

    return tagValues
end

addonTable.TertiaryResourceBarMixin = TertiaryResourceBarMixin

addonTable.RegisteredBar = addonTable.RegisteredBar or {}
addonTable.RegisteredBar.TertiaryResourceBar = {
    mixin = addonTable.TertiaryResourceBarMixin,
    dbName = "tertiaryResourceBarDB",
    editModeName = L["TERNARY_POWER_BAR_EDIT_MODE_NAME"],
    frameName = "TertiaryResourceBar",
    frameLevel = 3,
    defaultValues = {
        point = "CENTER",
        x = 0,
        y = -80,
        useResourceAtlas = false,
        showTicks = select(2, UnitClass("player")) == "DEATHKNIGHT",
        tickColor = {r = 0, g = 0, b = 0, a = 1},
        tickThickness = 1,
    },
    allowEditPredicate = function()
        local spec = C_SpecializationInfo.GetSpecialization()
        local specID = C_SpecializationInfo.GetSpecializationInfo(spec)
        return specID == 250 or specID == 1480 -- Devourer
            or specID == 1473 -- Augmentation
            or specID == 64   -- Frost Mage
    end,
    loadPredicate = function()
        local playerClass = select(2, UnitClass("player"))
        return playerClass == "DEATHKNIGHT" or playerClass == "EVOKER" or playerClass == "MAGE" or playerClass == "DEMONHUNTER"
    end,
    lemSettings = function(bar, defaults)
        local dbName = bar:GetConfig().dbName

        local settings = {
            {
                parentId = L["CATEGORY_BAR_SETTINGS"],
                order = 304,
                kind = LEM.SettingType.Divider,
            },
            {
                parentId = L["CATEGORY_BAR_SETTINGS"],
                order = 305,
                name = L["SHOW_TICKS_WHEN_AVAILABLE"],
                kind = LEM.SettingType.CheckboxColor,
                default = defaults.showTicks,
                colorDefault = defaults.tickColor,
                get = function(layoutName)
                    local data = MandingaSenseiClassResourceBarDB[dbName][layoutName]
                    if data and data.showTicks ~= nil then
                        return data.showTicks
                    else
                        return defaults.showTicks
                    end
                end,
                colorGet = function(layoutName)
                    local data = MandingaSenseiClassResourceBarDB[dbName][layoutName]
                    return data and data.tickColor or defaults.tickColor
                end,
                set = function(layoutName, value)
                    MandingaSenseiClassResourceBarDB[dbName][layoutName] = MandingaSenseiClassResourceBarDB[dbName][layoutName] or CopyTable(defaults)
                    MandingaSenseiClassResourceBarDB[dbName][layoutName].showTicks = value
                    bar:UpdateTicksLayout(layoutName)
                end,
                colorSet = function(layoutName, value)
                    MandingaSenseiClassResourceBarDB[dbName][layoutName] = MandingaSenseiClassResourceBarDB[dbName][layoutName] or CopyTable(defaults)
                    MandingaSenseiClassResourceBarDB[dbName][layoutName].tickColor = value
                    bar:UpdateTicksLayout(layoutName)
                end,
            },
            {
                parentId = L["CATEGORY_BAR_SETTINGS"],
                order = 306,
                name = L["TICK_THICKNESS"],
                kind = LEM.SettingType.Slider,
                default = defaults.tickThickness,
                minValue = 1,
                maxValue = 5,
                valueStep = 1,
                get = function(layoutName)
                    local data = MandingaSenseiClassResourceBarDB[dbName][layoutName]
                    return data and addonTable.rounded(data.tickThickness) or defaults.tickThickness
                end,
                set = function(layoutName, value)
                    MandingaSenseiClassResourceBarDB[dbName][layoutName] = MandingaSenseiClassResourceBarDB[dbName][layoutName] or CopyTable(defaults)
                    MandingaSenseiClassResourceBarDB[dbName][layoutName].tickThickness = addonTable.rounded(value)
                    bar:UpdateTicksLayout(layoutName)
                end,
                isEnabled = function(layoutName)
                    local data = MandingaSenseiClassResourceBarDB[dbName][layoutName]
                    return data.showTicks == true
                end,
            },
            {
                parentId = L["CATEGORY_BAR_STYLE"],
                order = 401,
                name = L["USE_RESOURCE_TEXTURE_AND_COLOR"],
                kind = LEM.SettingType.Checkbox,
                default = defaults.useResourceAtlas,
                get = function(layoutName)
                    local data = MandingaSenseiClassResourceBarDB[dbName][layoutName]
                    if data and data.useResourceAtlas ~= nil then
                        return data.useResourceAtlas
                    else
                        return defaults.useResourceAtlas
                    end
                end,
                set = function(layoutName, value)
                    MandingaSenseiClassResourceBarDB[dbName][layoutName] = MandingaSenseiClassResourceBarDB[dbName][layoutName] or CopyTable(defaults)
                    MandingaSenseiClassResourceBarDB[dbName][layoutName].useResourceAtlas = value
                    bar:ApplyLayout(layoutName)
                end,
            },
        }
        if select(2, UnitClass("player")) == "DEMONHUNTER" then
            -- Devourer's ground souls use a continuous bar.
            for _ = 1, 3 do table.remove(settings, 1) end
        end
        return settings
    end
}
