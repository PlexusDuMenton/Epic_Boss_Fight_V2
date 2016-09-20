if courage_call_modifier == nil then
	courage_call_modifier = class({})
end

function courage_call_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end
function courage_call_modifier:IsHidden()
	return false
end

function courage_call_modifier:IsDebuff()
	return false
end

function courage_call_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function courage_call_modifier:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor( "movement_bonus" )
end
