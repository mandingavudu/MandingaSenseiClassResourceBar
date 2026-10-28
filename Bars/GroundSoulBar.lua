local _, addonTable = ...

local GroundSoulBar = {}
addonTable.GroundSoulBar = GroundSoulBar
GroundSoulBar.MAX = 10

-- Compile the shared bar text template into engine-owned numeric components.
-- The engine performs percentage arithmetic on the restricted aura count.
function GroundSoulBar:GetTextBinding(bar, data)
    local template = bar:GetTextFormat(data, "SOUL_FRAGMENTS_GROUND")
    local precision = data.textPrecision and math.max(0, #data.textPrecision - 3) or 0
    local tags = bar:GetTagValues("SOUL_FRAGMENTS_GROUND", self.MAX, 0, precision)
    local components = {}
    local format = template:gsub("%%", "%%%%"):gsub("%[.-%]", function(tag)
        if tag == "[current]" or tag == "[percent]" then
            local percent = tag == "[percent]"
            components[#components + 1] = {
                div = percent and self.MAX / 100 or 1,
                step = percent and 10 ^ -precision or 1,
                rounding = Enum.NumericRuleFormatRounding.Nearest,
            }
            return percent and ("%." .. precision .. "f") or "%d"
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
function GroundSoulBar:UpdateProc(bar)
    local indicators = bar._groundSoulIndicators
    if not indicators then return end
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

function GroundSoulBar:LayoutIndicators(bar)
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
        glow:SetBackdropBorderColor(1, 1, 1, 1)
        glow:Hide()
        indicators:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
        indicators:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
        indicators:RegisterEvent("PLAYER_ENTERING_WORLD")
        indicators:RegisterEvent("PLAYER_REGEN_ENABLED")
        indicators:RegisterEvent("PLAYER_REGEN_DISABLED")
        indicators:RegisterUnitEvent("UNIT_AURA", "player")
        indicators:SetScript("OnEvent", function() self:UpdateProc(bar) end)
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
    self:UpdateProc(bar)
end

-- Blizzard owns the bound children, including their visibility and values.
-- Never read their values or modify them while aura restrictions are active.
function GroundSoulBar:Update(bar, layoutName)
    bar.StatusBar:SetAlpha(0)
    bar.TextValue:SetText("")
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
    local textRule = self:GetTextBinding(bar, data)
    local showText = data.showText == true
    local style = addonTable.maskAndBorderStyles[data.maskAndBorderStyle or defaults.maskAndBorderStyle]
    local mask = style and style.mask or [[Interface\AddOns\MandingaSenseiClassResourceBar\Textures\Specials\white.png]]
    local orientation = bar.StatusBar:GetOrientation()
    local reverse = bar.StatusBar:GetReverseFill()
    local strata = bar.Frame:GetFrameStrata()
    local level = bar.StatusBar:GetFrameLevel()
    bar.BorderFrame:SetFrameLevel(level + 2)
    self:LayoutIndicators(bar)
    -- A slot cannot be removed. Rebuild only when its appearance changes,
    -- disabling the previous container so it no longer receives aura events.
    local values = {width, height, font or "", size or 0, flags or "", r, g, b, a,
        tr, tg, tb, ta, texture or "", align, textRule.format, tostring(showText), mask,
        orientation, tostring(reverse), strata, level}
    local key = table.concat(values, ":")
    if bar._groundSoulKey == key then return end
    if not (C_XMLUtil and C_XMLUtil.GetTemplateInfo
        and C_XMLUtil.GetTemplateInfo("CustomAuraContainerTemplate")
        and C_StringUtil and C_StringUtil.CreateNumericRuleFormatter) then
        if not bar._groundSoulWarning then
            bar._groundSoulWarning = true
            print("MandingaSenseiClassResourceBar: ground souls require the client aura-binding APIs.")
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
        container:AddAuraSlot("groundSouls", "HELPFUL|PLAYER", {
            candidateFilters = { includeSpellIDs = { [1245577] = true } },
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
                button:SetApplicationBar(fill, { maxApplications = GroundSoulBar.MAX })

                if showText then
                    local textFrame = CreateFrame("Frame", nil, button)
                    textFrame:SetAllPoints(bar.TextFrame)
                    textFrame:SetFrameLevel(math.max(bar.TextFrame:GetFrameLevel() + 2,
                        bar._groundSoulIndicators.glow:GetFrameLevel() + 1))
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
    bar._groundSoulKey = key -- Do not retry a missing API every update tick.
    if not ok or not initialized then
        retire(container)
        if not bar._groundSoulWarning then
            bar._groundSoulWarning = true
            print("MandingaSenseiClassResourceBar: ground souls require working aura bindings. " .. tostring(err or "Aura initialization failed"))
        end
        return
    end
    retire(bar._groundSoulContainer)
    bar._groundSoulContainer = container
end

function GroundSoulBar:Hide(bar)
    if bar._groundSoulIndicators then bar._groundSoulIndicators:Hide() end
    if bar._groundSoulContainer then bar._groundSoulContainer:Hide() end
end

function GroundSoulBar:Show(bar)
    if bar._groundSoulIndicators then bar._groundSoulIndicators:Show() end
    if bar._groundSoulContainer then bar._groundSoulContainer:Show() end
end
