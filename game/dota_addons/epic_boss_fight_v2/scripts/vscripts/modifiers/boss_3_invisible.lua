boss_3_invisible = class({})

function boss_3_invisible:OnCreated(keys)
end

function boss_3_invisible:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function boss_3_invisible:IsHidden()
  return true
end

function boss_3_invisible:IsBuff()
  return true
end

function boss_3_invisible:DeclareFunctions()
    local funcs = {
    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
    return funcs
end


function boss_3_invisible:IsDebuff()
  return false
end

function boss_3_invisible:IsPurgable()
  return false
end

function boss_3_invisible:GetModifierInvisibilityLevel()
    return 1.0
end
function boss_3_invisible:CheckState()
  local state = {
  [MODIFIER_STATE_UNSELECTABLE] = true,
  [MODIFIER_STATE_NO_HEALTH_BAR] = true,
  }

  return state
end

function boss_3_invisible:GetModifierDamageOutgoing_Percentage()
  return -80
end
