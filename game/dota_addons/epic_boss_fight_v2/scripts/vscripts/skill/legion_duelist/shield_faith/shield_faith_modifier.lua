if shield_faith_modifier == nil then
	shield_faith_modifier = class({})
end

function shield_faith_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
	return funcs
end

function shield_faith_modifier:IsHidden()
	return false
end

function shield_faith_modifier:IsDebuff()
	return false
end

function shield_faith_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function shield_faith_modifier:GetModifierIncomingDamage_Percentage()
	return -self:GetAbility():GetSpecialValueFor( "damage_reduction" )
end
