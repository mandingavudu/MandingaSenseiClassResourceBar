local _, addonTable = ...

local AuraStackBar = {}
addonTable.AuraStackBar = AuraStackBar
AuraStackBar.GROUND_SOUL_MAX = 10

function AuraStackBar:GetBoneShieldMax()
    return C_SpellBook.IsSpellKnown(374715) and 12 or 10
end

-- Compile the shared bar text template into engine-owned numeric components.
-- The engine performs percentage arithmetic on the restricted aura count.
function AuraStackBar:GetTextBinding(bar, data, resource, maximum)
    resource = resource or "SOUL_FRAGMENTS_GROUND"
    maximum = maximum or self.GROUND_SOUL_MAX
    local template = bar:GetTextFormat(data, resource)
    local precision = data.textPrecision and math.max(0, #data.textPrecision - 3) or 0
    local tags = bar:GetTagValues(resource, maximum, 0, precision)
    local duration = resource == "SHIELD_OF_THE_RIGHTEOUS"
    local components = {}
    local format = template:gsub("%%", "%%%%"):gsub("%[.-%]", function(tag)
        if tag == "[current]" or tag == "[percent]" then
            local percent = tag == "[percent]"
            components[#components + 1] = {
                div = percent and maximum / 100 or 1,
                step = (percent or duration) and 10 ^ -precision or 1,
                rounding = Enum.NumericRuleFormatRounding.Nearest,
            }
            return (percent or duration) and ("%." .. precision .. "f") or "%d"
        end
        local value = tags[tag] and tags[tag]() or ""
        return value:gsub("%%", "%%%%")
    end)
    return { threshold = 0, format = format, components = components }
end

local function restricted()
    return InCombatLockdown() or (C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret())
end

local function retire(container)
    if container then
        container:Hide()
        container:SetEnabled(false)
    end
end

-- The spell overlay signal remains readable during combat. Outside restrictions,
-- prefer the actual buff so login and talent changes start in the correct state.
function AuraStackBar:UpdateGroundSoulProc(bar)
    local indicators = bar._groundSoulIndicators
    if not indicators then return end
    local color = addonTable:GetOverrideResourceColor("GLOW_MOMENT_OF_CRAVING")
    indicators.glow:SetBackdropBorderColor(color.r, color.g, color.b, color.a or 1)
    local active = false
    if not restricted() then
        active = C_UnitAuras.GetPlayerAuraBySpellID(1238495) ~= nil
    elseif C_SpellActivationOverlay then
        active = C_SpellActivationOverlay.IsSpellOverlayed(1226019)
            or C_SpellActivationOverlay.IsSpellOverlayed(1245453)
            or C_SpellActivationOverlay.IsSpellOverlayed(1238495)
    end
    indicators.marker:SetShown(not active)
    indicators.glow:SetShown(active)
end

function AuraStackBar:LayoutGroundSoulIndicators(bar)
    local indicators = bar._groundSoulIndicators
    if not indicators then
        indicators = CreateFrame("Frame", nil, bar.Frame)
        bar._groundSoulIndicators = indicators
        indicators.marker = indicators:CreateTexture(nil, "OVERLAY")
        indicators.marker:SetColorTexture(1, 1, 1, 1)
        local glow = CreateFrame("Frame", nil, indicators, "BackdropTemplate")
        indicators.glow = glow
        glow:SetPoint("TOPLEFT", bar.StatusBar, "TOPLEFT", -1, 1)
        glow:SetPoint("BOTTOMRIGHT", bar.StatusBar, "BOTTOMRIGHT", 1, -1)
        glow:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
        glow:Hide()
        indicators:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
        indicators:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
        indicators:RegisterEvent("PLAYER_ENTERING_WORLD")
        indicators:RegisterEvent("PLAYER_REGEN_ENABLED")
        indicators:RegisterEvent("PLAYER_REGEN_DISABLED")
        indicators:RegisterUnitEvent("UNIT_AURA", "player")
        indicators:SetScript("OnEvent", function() self:UpdateGroundSoulProc(bar) end)
    end
    indicators:SetAllPoints(bar.StatusBar)
    indicators:SetFrameStrata(bar.Frame:GetFrameStrata())
    indicators:SetFrameLevel(bar.BorderFrame:GetFrameLevel() + 1)
    local width, height = bar.StatusBar:GetSize()
    local fraction = bar.StatusBar:GetReverseFill() and 0.6 or 0.4
    local marker = indicators.marker
    marker:ClearAllPoints()
    if bar.StatusBar:GetOrientation() == "VERTICAL" then
        marker:SetSize(width, 2)
        marker:SetPoint("CENTER", bar.StatusBar, "BOTTOMLEFT", width / 2, height * fraction)
    else
        marker:SetSize(2, height)
        marker:SetPoint("CENTER", bar.StatusBar, "BOTTOMLEFT", width * fraction, height / 2)
    end
    self:UpdateGroundSoulProc(bar)
end

function AuraStackBar:UpdateSanguineGroundGlow(bar)
    local glow = bar._sanguineGroundGlow
    if not C_SpellBook.IsSpellKnown(391458) then -- Sanguine Ground talent
        if glow then glow:Hide() end
        return
    end
    local aura, available = addonTable:GetTrackedPlayerAura(188290) -- Death and Decay player buff
    if not available then addonTable:WarnAuraTracking(bar, 188290) end
    if not aura then
        if glow then glow:Hide() end
        return
    end
    if not glow then
        glow = CreateFrame("Frame", nil, bar.Frame, "BackdropTemplate")
        bar._sanguineGroundGlow = glow
        glow:SetPoint("TOPLEFT", bar.StatusBar, "TOPLEFT", -1, 1)
        glow:SetPoint("BOTTOMRIGHT", bar.StatusBar, "BOTTOMRIGHT", 1, -1)
        glow:SetBackdrop({edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 12})
    end
    local color = addonTable:GetOverrideResourceColor("GLOW_BONE_SHIELD")
    glow:SetBackdropBorderColor(color.r, color.g, color.b, color.a or 1)
    glow:SetFrameLevel(bar.BorderFrame:GetFrameLevel() + 1)
    glow:Show()
end

-- Blizzard owns the bound children, including their visibility and values.
-- Never read their values or modify them while aura restrictions are active.
function AuraStackBar:Update(bar, layoutName)
    bar.StatusBar:SetAlpha(0)
    bar.TextValue:SetText("")
    if bar:GetResource() == "BONE_SHIELD" then
        self:UpdateSanguineGroundGlow(bar)
    elseif bar._sanguineGroundGlow then
        bar._sanguineGroundGlow:Hide()
    end
    if bar:GetResource() == "SOUL_FRAGMENTS_GROUND" then
        self:UpdateGroundSoulProc(bar)
    end
    if restricted() then return end

    local data = bar:GetData(layoutName)
    if not data then return end
    local defaults = bar.defaults
    local width, height = bar.StatusBar:GetSize()
    local font, size, flags = bar.TextValue:GetFont()
    local r, g, b, a = bar.StatusBar:GetStatusBarColor()
    local tr, tg, tb, ta = bar.TextValue:GetTextColor()
    local texture = bar.StatusBar:GetStatusBarTexture():GetTexture()
    local align = data.textAlign or defaults.textAlign or "CENTER"
    local resource = bar:GetResource()
    local boneShield = resource == "BONE_SHIELD"
    local lesserGhouls = resource == "LESSER_GHOULS"
    local stackDividers = boneShield or lesserGhouls
    local maximum = boneShield and self:GetBoneShieldMax() or lesserGhouls and 8 or self.GROUND_SOUL_MAX
    local auraID = boneShield and 195181 or lesserGhouls and 1254252 or 1245577
    local textRule = self:GetTextBinding(bar, data, resource, maximum)
    local showText = data.showText == true
    local style = addonTable.maskAndBorderStyles[data.maskAndBorderStyle or defaults.maskAndBorderStyle]
    local mask = style and style.mask or [[Interface\AddOns\MandingaSenseiClassResourceBar\Textures\Specials\white.png]]
    local orientation = bar.StatusBar:GetOrientation()
    local reverse = bar.StatusBar:GetReverseFill()
    local strata = bar.Frame:GetFrameStrata()
    local level = bar.StatusBar:GetFrameLevel()
    bar.BorderFrame:SetFrameLevel(level + 2)
    if stackDividers then
        if bar._groundSoulIndicators then bar._groundSoulIndicators:Hide() end
        bar:UpdateTicksLayout(layoutName, data)
    else
        self:LayoutGroundSoulIndicators(bar)
    end
    -- A slot cannot be removed. Rebuild only when its appearance changes,
    -- disabling the previous container so it no longer receives aura events.
    local values = {width, height, font or "", size or 0, flags or "", r, g, b, a,
        tr, tg, tb, ta, texture or "", align, textRule.format, tostring(showText), mask,
        orientation, tostring(reverse), strata, level, resource, maximum}
    local key = table.concat(values, ":")
    if bar._auraStackKey == key then return end
    if not (C_XMLUtil and C_XMLUtil.GetTemplateInfo
        and C_XMLUtil.GetTemplateInfo("CustomAuraContainerTemplate")
        and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter) then
        if not bar._auraStackWarning then
            bar._auraStackWarning = true
            print("MandingaSenseiClassResourceBar: aura stack bars require the client aura-binding APIs.")
        end
        return
    end

    local container
    local initialized = false
    local ok, err = pcall(function()
        local formatter = C_StringUtil.CreateNumericRuleFormatter()
        formatter:SetBreakpoints({textRule})
        container = CreateFrame("AuraContainer", nil, bar.Frame, "CustomAuraContainerTemplate")
        container:SetPoint("TOPLEFT", bar.StatusBar, "TOPLEFT")
        container:SetSize(width, height)
        container:SetFrameStrata(strata)
        container:SetFrameLevel(level)
        container:AddAuraSlot("resourceStacks", "HELPFUL|PLAYER", {
            candidateFilters = { includeSpellIDs = { [auraID] = true } },
            initializeFrame = function(button)
                button:SetPoint("TOPLEFT", bar.StatusBar, "TOPLEFT")
                button:SetSize(width, height)
                button:SetFrameStrata(strata)
                button:SetFrameLevel(level)
                if button.SetMouseMotionEnabled then button:SetMouseMotionEnabled(false) end

                local fill = CreateFrame("StatusBar", nil, button)
                fill:SetAllPoints(bar.StatusBar)
                fill:SetFrameLevel(level)
                fill:SetStatusBarTexture(texture)
                fill:SetStatusBarColor(r, g, b, a)
                fill:SetOrientation(orientation)
                fill:SetReverseFill(reverse)
                local clip = fill:CreateMaskTexture()
                clip:SetTexture(mask)
                clip:SetPoint("CENTER", fill, "CENTER")
                local vertical = orientation == "VERTICAL"
                clip:SetSize(vertical and height or width, vertical and width or height)
                clip:SetRotation(vertical and math.rad(90) or 0)
                fill:GetStatusBarTexture():AddMaskTexture(clip)
                button:SetApplicationBar(fill, { maxApplications = maximum })

                if showText then
                    local textFrame = CreateFrame("Frame", nil, button)
                    textFrame:SetAllPoints(bar.TextFrame)
                    textFrame:SetFrameLevel(math.max(bar.TextFrame:GetFrameLevel() + 2,
                        stackDividers and (bar.BorderFrame:GetFrameLevel() + 1)
                            or (bar._groundSoulIndicators.glow:GetFrameLevel() + 1)))
                    local text = textFrame:CreateFontString(nil, "OVERLAY")
                    text:SetFont(font, size, flags)
                    text:SetTextColor(tr, tg, tb, ta)
                    text:SetShadowColor(0, 0, 0, 0.8)
                    text:SetShadowOffset(1, -1)
                    text:SetJustifyH((align == "LEFT" or align == "RIGHT") and align or "CENTER")
                    local x = align == "LEFT" and 4 or align == "RIGHT" and -4 or 0
                    local y = align == "TOP" and 4 or align == "BOTTOM" and -4 or 0
                    text:SetPoint(align, textFrame, align, x, y)
                    button:SetApplicationCount(text, { formatter = formatter })
                end
                initialized = true
            end,
        })
        -- Register aura events only after slots exist and the container is enabled.
        container:SetEnabled(true)
        container:SetUnit("player")
        container:UpdateAllAuras()
    end)
    bar._auraStackKey = key -- Do not retry a missing API every update tick.
    if not ok or not initialized then
        retire(container)
        if not bar._auraStackWarning then
            bar._auraStackWarning = true
            print("MandingaSenseiClassResourceBar: aura stack bars require working aura bindings. " .. tostring(err or "Aura initialization failed"))
        end
        return
    end
    retire(bar._auraStackContainer)
    bar._auraStackContainer = container
end

function AuraStackBar:Hide(bar)
    if bar._sanguineGroundGlow then bar._sanguineGroundGlow:Hide() end
    if bar._groundSoulIndicators then bar._groundSoulIndicators:Hide() end
    if bar._auraStackContainer then bar._auraStackContainer:Hide() end
end

function AuraStackBar:Show(bar)
    if bar._groundSoulIndicators and bar:GetResource() == "SOUL_FRAGMENTS_GROUND" then
        bar._groundSoulIndicators:Show()
    end
    if bar._auraStackContainer then bar._auraStackContainer:Show() end
end
