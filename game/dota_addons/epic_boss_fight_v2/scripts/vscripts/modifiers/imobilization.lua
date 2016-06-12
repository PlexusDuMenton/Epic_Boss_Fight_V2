imobilization = class({})

function imobilization:OnCreated(keys) 
end

function imobilization:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function imobilization:IsHidden()
  return true
end

function imobilization:IsDebuff() 
  return true
end

function imobilization:IsPurgable() 
  return false
end

function imobilization:CheckState()
  local state = {
  [MODIFIER_STATE_ROOTED] = true
  }
 
  return state
end
