knock_back = class({})

function knock_back:OnCreated(keys) 
end

function knock_back:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function knock_back:IsHidden()
  return true
end

function knock_back:IsDebuff() 
  return true
end

function knock_back:IsPurgable() 
  return false
end

function knock_back:CheckState()
  local state = {
  [MODIFIER_STATE_STUNNED] = true,
  }
 
  return state
end
