slow = class({})

function slow:OnCreated(keys) 
end

function slow:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function slow:DeclareFunctions()
  local funcs = {
  MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT  
  }
  return funcs
end

function slow:GetModifierMoveSpeedBonus_Constant(event)
	if IsServer() then
		local slow = -0.5 * self:GetParent():GetBaseMoveSpeed()
		if self:GetParent().equip_stats ~= nil then
			slow = -0.5 * (self:GetParent():GetBaseMoveSpeed() + self:GetParent().equip_stats.movespeed)
		end
		self:GetParent().slow = nil
		return slow
	end
end

function slow:IsHidden()
  return true
end

function slow:IsDebuff() 
  return true
end

function slow:IsPurgable() 
  return false
end

function slow:CheckState()
  local state = {
  }
 
  return state
end
