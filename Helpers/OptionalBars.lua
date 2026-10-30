local _, addonTable = ...

addonTable.OptionalBars = {
    { key = "BONE_SHIELD", specID = 250, spellID = 195181, name = "Bone Shield", frame = "TertiaryResourceBar" },
    { key = "LESSER_GHOULS", specID = 252, spellID = 1254252, name = "Lesser Ghouls", frame = "TertiaryResourceBar" },
    { key = "SOUL_FRAGMENTS_GROUND", specID = 1480, nameKey = "SOUL_FRAGMENTS_GROUND", frame = "TertiaryResourceBar" },
    { key = "EBON_MIGHT", specID = 1473, spellID = 395296, name = "Ebon Might", frame = "TertiaryResourceBar" },
    { key = "SHIELD_OF_THE_RIGHTEOUS", specID = 66, spellID = 132403, name = "Shield of the Righteous", frame = "TertiaryResourceBar" },
    { key = "VOIDFALL", specID = 1480, otherSpecID = 581, spellID = 1253304, name = "Voidfall", heroNameKey = "ANNIHILATOR", frame = "QuaternaryResourceBar" },
}

function addonTable:IsOptionalResourceEnabled(key)
    local settings = MandingaSenseiClassResourceBarDB and MandingaSenseiClassResourceBarDB._Settings
    local enabled = settings and settings.OptionalBars
    return not enabled or enabled[key] ~= false
end

function addonTable:IsOptionalBarEnabled(config)
    if config.frameName ~= "TertiaryResourceBar" and config.frameName ~= "QuaternaryResourceBar" then return true end
    local spec = C_SpecializationInfo.GetSpecialization()
    local specID = spec and C_SpecializationInfo.GetSpecializationInfo(spec)
    for _, resource in ipairs(self.OptionalBars) do
        if resource.frame == config.frameName and (resource.specID == specID or resource.otherSpecID == specID) then
            return self:IsOptionalResourceEnabled(resource.key)
        end
    end
    return true
end
