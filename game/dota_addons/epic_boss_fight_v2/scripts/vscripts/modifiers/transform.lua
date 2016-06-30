transform = class({})

function transform:OnCreated(keys) 
end

function transform:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function transform:IsHidden()
  return true
end

function transform:IsBuff() 
  return true
end

function transform:DeclareFunctions()
    local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE 
    }
    return funcs
end


function transform:IsDebuff() 
  return false
end

function transform:IsPurgable() 
  return false
end

function transform:GetModifierModelChange() 
  return "models/items/lone_druid/true_form/form_of_the_atniw/form_of_the_atniw.vmdl"
end
