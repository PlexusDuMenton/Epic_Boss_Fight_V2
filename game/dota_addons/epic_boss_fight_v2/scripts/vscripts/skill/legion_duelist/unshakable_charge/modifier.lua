if unshakable_charge_modifier == nil then
	unshakable_charge_modifier = class({})
end

function unshakable_charge_modifier:CheckState()
  local state = {
  [MODIFIER_STATE_INVULNERABLE] = true,
  [MODIFIER_STATE_DISARMED] = true,
  [MODIFIER_STATE_ROOTED] = true,
  }
 
  return state
end

function unshakable_charge_modifier:IsHidden()
	return true
end

function unshakable_charge_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_NONE
end