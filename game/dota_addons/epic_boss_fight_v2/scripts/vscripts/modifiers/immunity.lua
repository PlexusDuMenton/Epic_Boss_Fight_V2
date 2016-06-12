immunity = class({})

function immunity:OnCreated(keys) 
end

function immunity:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function immunity:IsHidden()
  return true
end

function immunity:IsBuff() 
  return true
end


function immunity:IsDebuff() 
  return false
end

function immunity:IsPurgable() 
  return false
end

function immunity:CheckState()
  local state = {
  [MODIFIER_STATE_INVULNERABLE] = true,
  [MODIFIER_STATE_UNSELECTABLE] = true,
  [MODIFIER_STATE_NO_HEALTH_BAR] = true,
  }
 
  return state
end
