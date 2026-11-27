local _, addonTable = ...

local StaggerOverflow = {}
addonTable.StaggerOverflow = StaggerOverflow

function StaggerOverflow:Hide(bar)
    if bar._staggerOverflow then bar._staggerOverflow:Hide() end
    bar._staggerPercentCurve = nil
end

function StaggerOverflow:Update(bar, current, maxHealth)
    -- Only the readable maximum is used in Lua arithmetic. Restricted Stagger
    -- values go directly through engine curves into status-bar setters.
    if issecretvalue(maxHealth) or maxHealth <= 0 then
        self:Hide(bar)
        return
    end

    local overlay = bar._staggerOverflow
    if not overlay then
        overlay = CreateFrame("StatusBar", nil, bar.StatusBar)
        overlay:SetAllPoints(bar.StatusBar)
        bar._staggerOverflow = overlay
    end
    overlay:SetFrameLevel(bar.StatusBar:GetFrameLevel() + 1)
    bar.TextFrame:SetFrameLevel(overlay:GetFrameLevel() + 1)
    bar.BorderFrame:SetFrameLevel(overlay:GetFrameLevel() + 1)
    overlay:SetStatusBarTexture(bar.StatusBar:GetStatusBarTexture():GetTexture())
    overlay:SetOrientation(bar.StatusBar:GetOrientation())
    overlay:SetReverseFill(bar.StatusBar:GetReverseFill())

    local colors = {}
    local signature = { maxHealth }
    for i = 1, 3 do
        colors[i] = addonTable:GetOverrideResourceColor("STAGGER_EXTREME_" .. i)
        for _, component in ipairs({ "r", "g", "b", "a" }) do
            signature[#signature + 1] = colors[i][component] or 1
        end
    end
    local key = table.concat(signature, ":")
    if bar._staggerCurveKey ~= key then
        local curves = {}
        for _, component in ipairs({ "min", "max", "r", "g", "b", "a" }) do
            local curve = C_CurveUtil.CreateCurve()
            curve:SetType(Enum.LuaCurveType.Step)
            for i = 1, 3 do
                local lower = (1 + (i - 1) * 3) * maxHealth
                local upper = lower + 3 * maxHealth
                local value
                if component == "min" then value = lower
                elseif component == "max" then value = upper
                else value = colors[i][component] or 1 end
                curve:AddPoint(i == 1 and 0 or lower, value)
            end
            curves[component] = curve
        end
        local percent = C_CurveUtil.CreateCurve()
        percent:SetType(Enum.LuaCurveType.Linear)
        percent:AddPoint(0, 0)
        percent:AddPoint(maxHealth * 10, 1000)
        bar._staggerCurves = curves
        bar._staggerPercentCurve = percent
        bar._staggerCurveKey = key
    elseif not bar._staggerPercentCurve then
        -- Restore after switching specs or temporarily receiving restricted HP.
        bar._staggerCurveKey = nil
        return self:Update(bar, current, maxHealth)
    end

    local curves = bar._staggerCurves
    overlay:SetMinMaxValues(curves.min:Evaluate(current), curves.max:Evaluate(current))
    overlay:SetStatusBarColor(curves.r:Evaluate(current), curves.g:Evaluate(current),
        curves.b:Evaluate(current), curves.a:Evaluate(current))
    overlay:SetValue(current)
    overlay:Show()
end
