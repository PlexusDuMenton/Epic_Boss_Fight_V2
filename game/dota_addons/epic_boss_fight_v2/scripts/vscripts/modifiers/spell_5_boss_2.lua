immobilize = class({})

function immobilize:OnCreated(keys) 
end

function immobilize:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function immobilize:DeclareFunctions()
  local funcs = {
MODIFIER_EVENT_ON_ATTACK_LANDED
  }
  return funcs
end

function immobilize:OnAttackLanded(event)
  if IsServer() then
    local caster = self:GetCaster()
    local target = event.target
    if math.random(1,100) >= 51 then
      LinkLuaModifier( "imobilization", "modifiers/imobilization.lua", LUA_MODIFIER_MOTION_NONE )
      target:AddNewModifier(caster, nil, "imobilization", {duration = 1 })
      --grow effect on players
    end
  end
end



function immobilize:IsHidden()
  return true
end

function immobilize:IsDebuff() 
  return true
end

function immobilize:IsPurgable() 
  return false
end

function immobilize:CheckState()
  local state = {
  }
 
  return state
end
