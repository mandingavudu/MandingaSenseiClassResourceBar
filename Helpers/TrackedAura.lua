local _, addonTable = ...

local function readable(value)
    return not issecretvalue(value)
end

local function matches(info, spellID)
    if not readable(info) or not info then return false end
    for _, key in ipairs({"spellID", "overrideSpellID", "overrideTooltipSpellID", "linkedSpellID"}) do
        local value = info[key]
        if readable(value) and value == spellID then return true end
    end
    local linked = info.linkedSpellIDs
    if readable(linked) and type(linked) == "table" then
        for _, value in ipairs(linked) do
            if readable(value) and value == spellID then return true end
        end
    end
    return false
end

-- Cooldown Manager owns spell identification during aura restrictions. Read its
-- existing association only; never change its frames, settings, or aura data.
-- The second result distinguishes a missing aura from unavailable tracking.
function addonTable:GetTrackedPlayerAura(spellID)
    local restricted = InCombatLockdown() or (C_Secrets and C_Secrets.ShouldAurasBeSecret
        and C_Secrets.ShouldAurasBeSecret())
    if not restricted then
        return C_UnitAuras.GetPlayerAuraBySpellID(spellID), true
    end
    local tracked = false
    for _, name in ipairs({"BuffBarCooldownViewer", "BuffIconCooldownViewer"}) do
        local viewer = _G[name]
        if viewer and viewer:IsShown() and viewer.itemFramePool then
            for item in viewer.itemFramePool:EnumerateActive() do
                local info = item.cooldownInfo
                if not info and item.GetCooldownInfo then info = item:GetCooldownInfo() end
                if matches(info, spellID) then
                    local unit = item.auraDataUnit
                    if not readable(unit) or unit == nil or unit == "player" then
                        -- Re-querying this instance is forbidden during combat.
                        -- Consume the viewer's existing cache; its numeric fields
                        -- stay restricted and are passed only to engine APIs.
                        local cached = item.auraDataCached
                        if readable(cached) then
                            tracked = true
                            if cached then return cached, true end
                        end
                    end
                end
            end
        end
    end
    return nil, tracked
end

function addonTable:WarnAuraTracking(bar, spellID)
    bar._auraTrackingWarnings = bar._auraTrackingWarnings or {}
    if bar._auraTrackingWarnings[spellID] then return end
    bar._auraTrackingWarnings[spellID] = true
    local viewerType = "Buff Icon or Buff Bar viewer"
    print("MandingaSenseiClassResourceBar: enable Blizzard Cooldown Manager and track "
        .. (C_Spell.GetSpellName(spellID) or tostring(spellID))
        .. " in a visible " .. viewerType .. " for combat tracking.")
end
