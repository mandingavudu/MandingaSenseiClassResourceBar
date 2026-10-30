local _, addonTable = ...
local L = addonTable.L
local QuaternaryResourceBarMixin = Mixin({}, addonTable.PowerBarMixin)

function QuaternaryResourceBarMixin:OnLoad()
    addonTable.PowerBarMixin.OnLoad(self)
    -- Earlier Voidfall layouts had ticks disabled with no control to enable them.
    for _, data in pairs(MandingaSenseiClassResourceBarDB.quaternaryResourceBarDB) do
        if not data.voidfallDividersConfigured then
            data.showTicks = true
            data.voidfallDividersConfigured = true
        end
    end
    self.Frame:RegisterEvent("PLAYER_TALENT_UPDATE")
    self.Frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
end

function QuaternaryResourceBarMixin:OnEvent(event, ...)
    if event == "PLAYER_TALENT_UPDATE" or event == "TRAIT_CONFIG_UPDATED" then
        self:ApplyVisibilitySettings()
        self:ApplyLayout(nil, true)
        return
    end
    addonTable.PowerBarMixin.OnEvent(self, event, ...)
end

function QuaternaryResourceBarMixin:GetResource()
    local spec = C_SpecializationInfo.GetSpecialization()
    local specID = C_SpecializationInfo.GetSpecializationInfo(spec)
    if (specID == 1480 or specID == 581) and C_SpellBook.IsSpellKnown(1253304) then
        return "VOIDFALL"
    end
end

function QuaternaryResourceBarMixin:GetResourceValue(resource)
    if resource == "VOIDFALL" then return 3, 0 end -- Engine-owned aura stacks.
end

function QuaternaryResourceBarMixin:LayoutVoidfallDivider()
    local marker = self._voidfallDivider
    local spec = C_SpecializationInfo.GetSpecialization()
    if C_SpecializationInfo.GetSpecializationInfo(spec) ~= 1480
        or not addonTable:IsOptionalResourceEnabled("VOIDFALL_DIVIDER") then
        if marker then marker:Hide() end
        return
    end
    if not marker then
        marker = self.BorderFrame:CreateTexture(nil, "OVERLAY", nil, 1)
        self._voidfallDivider = marker
    end
    local color = addonTable:GetOverrideResourceColor("VOIDFALL_DIVIDER")
    marker:SetColorTexture(color.r, color.g, color.b, color.a or 1)
    local width, height = self.StatusBar:GetSize()
    local fraction = self.StatusBar:GetReverseFill() and 1 / 3 or 2 / 3
    marker:ClearAllPoints()
    if self.StatusBar:GetOrientation() == "VERTICAL" then
        marker:SetSize(width, 2)
        marker:SetPoint("CENTER", self.StatusBar, "BOTTOMLEFT", width / 2, height * fraction)
    else
        marker:SetSize(2, height)
        marker:SetPoint("CENTER", self.StatusBar, "BOTTOMLEFT", width * fraction, height / 2)
    end
    marker:Show()
end

function QuaternaryResourceBarMixin:UpdateDisplay(layoutName, force)
    if not addonTable:IsOptionalBarEnabled(self.config) then
        addonTable.AuraStackBar:Hide(self)
        self:Hide()
        return
    end
    if self:GetResource() == "VOIDFALL" then
        self:LayoutVoidfallDivider()
        addonTable.AuraStackBar:Update(self, layoutName)
        addonTable.AuraStackBar:Show(self)
    else
        addonTable.AuraStackBar:Hide(self)
        if self._voidfallDivider then self._voidfallDivider:Hide() end
        self.StatusBar:SetAlpha(1)
        addonTable.PowerBarMixin.UpdateDisplay(self, layoutName, force)
    end
end

function QuaternaryResourceBarMixin:ApplyLayout(layoutName, force)
    addonTable.PowerBarMixin.ApplyLayout(self, layoutName, force)
    self:UpdateDisplay(layoutName, force)
end

addonTable.RegisteredBar.QuaternaryResourceBar = {
    mixin = QuaternaryResourceBarMixin,
    dbName = "quaternaryResourceBarDB",
    editModeName = L["QUATERNARY_POWER_BAR_EDIT_MODE_NAME"],
    frameName = "QuaternaryResourceBar",
    frameLevel = 4,
    defaultValues = { point = "CENTER", x = 0, y = -110, useResourceAtlas = false, showTicks = true,
        tickColor = { r = 0.000, g = 0.000, b = 0.000, a = 1.000 }, tickThickness = 1,
        voidfallDividersConfigured = true },
    allowEditPredicate = function()
        local spec = C_SpecializationInfo.GetSpecialization()
        local specID = C_SpecializationInfo.GetSpecializationInfo(spec)
        return (specID == 1480 or specID == 581) and C_SpellBook.IsSpellKnown(1253304)
    end,
    loadPredicate = function() return select(2, UnitClass("player")) == "DEMONHUNTER" end,
    lemSettings = addonTable.RegisteredBar.TertiaryResourceBar.lemSettings,
}
