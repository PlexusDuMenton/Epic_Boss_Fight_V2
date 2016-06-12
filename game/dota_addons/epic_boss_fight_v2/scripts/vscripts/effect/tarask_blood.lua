if lua_hero_effect_tarask_blood == nil then lua_hero_effect_tarask_blood = class({}) end
function lua_hero_effect_tarask_blood:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
	end
end
function lua_hero_effect_tarask_blood:IsHidden()
	return false
end


function lua_hero_effect_tarask_blood:DeclareFunctions()
    local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE  
    }
    return funcs
end


function lua_hero_effect_tarask_blood:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

function lua_hero_effect_tarask_blood:GetModifierHealthRegenPercentage()
	return 3.5
end
