if lua_modifier_enrage == nil then
	lua_modifier_enrage = class({})
end
function lua_modifier_enrage:DeclareFunctions()
	local funcs = {
MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function lua_modifier_enrage:GetModifierAttackSpeedBonus_Constant()
	return 500
end

function lua_modifier_enrage:CheckState()
	local state = {
	[MODIFIER_STATE_INVULNERABLE] = true,
	}
 
	return state
end

