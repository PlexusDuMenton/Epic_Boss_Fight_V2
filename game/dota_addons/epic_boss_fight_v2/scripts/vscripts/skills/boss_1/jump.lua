if boss_jump == nil then
    boss_jump = class({})
end

function boss_jump:GetBehavior() 
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end
function boss_jump:GetManaCost()
    return 0
end
function boss_jump:GetCooldown()
    return 15
end
function boss_jump:GetCastRange()
    return 9999
end
function boss_jump:OnSpellStart()
	require('libraries/timers')
    local hCaster = self:GetCaster() --We will always have Caster.
    hCaster:Stop()
    local hTarget = found_lowest_hpp_ennemy()
    local vPoint = hTarget:GetAbsOrigin() --We will always have Vector for the point.
    local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
    local vtarget = vPoint

    local time = 0
    local vDiff = vtarget- vOrigin
    print (vtarget)
    local target_particle = ParticleManager:CreateParticle( "particles/target_ring_jump_boss.vpcf", PATTACH_CUSTOMORIGIN , hCaster )
    ParticleManager:SetParticleControl(target_particle, 7, vtarget)
    
    local movement_x_per_frame = vDiff.x/50
    local movement_y_per_frame = vDiff.y/50
    local movement_z_per_frame = (math.abs(vDiff.y)+math.abs(vDiff.x) + 300)/50
    --create warning zone
    print ("doing spell 3")
    Timers:CreateTimer(0.5,function()
    	time = time + 0.02
    	local z_movement = movement_z_per_frame * (0.5 - time)
    	movement = Vector(movement_x_per_frame,movement_y_per_frame,z_movement)
    	print (movement)
    	hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + movement) 
    	if time >= 1 then
    		ParticleManager:DestroyParticle(target_particle, true) 
    		FindClearSpaceForUnit(hCaster, vtarget, false) 
    		enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              hCaster:GetAbsOrigin(),
                              nil,
                              350,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
    		for k,v in pairs(enemy) do
    			local damageTable = {
					victim = v,
					attacker = hCaster,
					damage = 15*(GameRules.difficulty^0.85),
					damage_type = DAMAGE_TYPE_PHYSICAL,
				}
				self:ApplyDataDrivenModifier(hCaster,v, modifier_stun, {duration = 2}) 

    		end
    	else
    		return 0.02
    	end
    end)
end

function found_lowest_hpp_ennemy()
	enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	local lowest_hpp = 100
	local target = nil
	for k,v in pairs(enemy) do
		local hpp = (v:GetHealth()/v:GetMaxHealth())*100
		if hpp <= lowest_hpp then
			lowest_hpp = hpp
			target = v
		end
	end
	return target
end
