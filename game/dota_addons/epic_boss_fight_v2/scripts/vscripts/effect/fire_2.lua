if lua_hero_effect_fire_2 == nil then lua_hero_effect_fire_2 = class({}) end
function lua_hero_effect_fire_2:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
	end
end
function lua_hero_effect_fire_2:IsHidden()
	return false
end


function lua_hero_effect_fire_2:DeclareFunctions()
    local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED 
    }
    return funcs
end


function lua_hero_effect_fire_2:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

function lua_hero_effect_fire_2:OnAttackLanded(event)
	if IsServer() then
		local hero = self:GetParent()
		if event.attacker==self:GetParent() then
			local target = event.target
			local percent = 400
			local duration = 5
			local ticktime = 0.2
			local tick = duration/ticktime
			local damage = (event.damage * (percent/100) )/tick
			local timer = 0

			local damageTable = {
				victim = target,
				attacker = hero,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			if math.random(1,100) <= 25 and target.On_Fire_2 == false then
				target.On_Fire_2 = true
				Fire_effect = ParticleManager:CreateParticle( "particles/frozen_flame_effect.vpcf",  PATTACH_ABSORIGIN_FOLLOW , target )
				Timers:CreateTimer(0.2, function()
					timer = timer + 0.2
					if timer <= duration then
						ApplyDamage(damageTable) 
						return 0.2
					else
						target.On_Fire_2 = false
						ParticleManager:DestroyParticle(Fire_effect, false)
					end
			    end)
			end
		end
	end
end