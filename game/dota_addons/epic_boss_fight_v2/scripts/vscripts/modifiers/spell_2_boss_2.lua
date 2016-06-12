slow = class({})

function slow:OnCreated(keys) 
end

function slow:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE --+ MODIFIER_ATTRIBUTE_MULTIPLE
end

function slow:DeclareFunctions()
  local funcs = {
MODIFIER_EVENT_ON_ATTACK_LANDED
  }
  return funcs
end

function slow:OnAttackLanded(event)
  if IsServer() then
    local caster = self:GetCaster()
    local target = event.target
    if math.random(1,100) >= 51 then
      LinkLuaModifier( "slow", "modifiers/slow.lua", LUA_MODIFIER_MOTION_NONE )
      target:AddNewModifier(caster, nil, "slow", {duration = 2})
      --grow effect on players
    end
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
