boss_3_boost = class({})

function boss_3_boost:OnCreated(keys)
end

function boss_3_boost:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function boss_3_boost:IsHidden()
  return true
end

function boss_3_boost:IsBuff()
  return true
end

function boss_3_boost:DeclareFunctions()
    local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE,
    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end


function boss_3_boost:IsDebuff()
  return false
end

function boss_3_boost:IsPurgable()
  return false
end

function boss_3_boost:GetModifierModelChange()
  return "models/items/lycan/ultimate/thegreatcalamityti4/thegreatcalamityti4.vmdl"
end
function boss_3_boost:GetModifierDamageOutgoing_Percentage()
  return 100
end

function boss_3_boost:GetModifierIncomingDamage_Percentage()
  return -75
end
