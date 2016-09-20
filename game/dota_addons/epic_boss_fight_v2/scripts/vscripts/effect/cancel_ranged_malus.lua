if lua_hero_effect_cancel_ranged_malus == nil then lua_hero_effect_cancel_ranged_malus = class({}) end

function lua_hero_effect_cancel_ranged_malus:IsHidden()
	return false
end

function lua_hero_effect_cancel_ranged_malus:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

