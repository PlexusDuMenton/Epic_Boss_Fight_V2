require('libraries/timers')
require('libraries/animations')


function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "Boss_1_think", Boss_1_think, 0.25 )
	thisEntity:SetContextThink( "target_choose", target_choose, 0.2 )
end
CD_DIVISER = math.log(GameRules.difficulty+10)/math.log(10)
print(CD_DIVISER)
boss_state = "idle"
boss_target = nil
change_target_CD = 0
function change_target()
	if math.random(0,5) <= 3 then
			boss_target = found_lowest_hpp_ennemy(false)
		else
			boss_target = found_lowest_hpp_ennemy(true)
		end
end

spell_1_CD = 1.5/CD_DIVISER
spell_2_CD = 7.5/CD_DIVISER
spell_3_CD = 5/CD_DIVISER
spell_4_CD = 0

function Boss_1_think()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then -- verify if unity is not recently dead
		GameRules:SetTimeOfDay(0.8)
		if boss_target~= nil then
			if boss_target:IsAlive() == false then change_target_CD = 0 end
		end
		if change_target_CD == 0 or boss_target == nil then
			change_target_CD = 4.0
			change_target()
		end
		local HPP = (thisEntity:GetHealth()/thisEntity:GetMaxHealth()) * 100
		spell_1_CD = spell_1_CD - 0.5
		change_target_CD = change_target_CD - 0.5
		if change_target_CD < 0 then change_target_CD = 0 end
		if spell_1_CD < 0 then spell_1_CD = 0 end
		if HPP < 25 then
			spell_4_CD = spell_4_CD - 0.5
			if spell_4_CD < 0 then spell_4_CD = 0 end
		end
		if HPP < 50 then
			spell_3_CD = spell_3_CD - 0.5
			if spell_3_CD < 0 then spell_3_CD = 0 end
		end
		if HPP < 75 then
			spell_2_CD = spell_2_CD - 0.5
			if spell_2_CD < 0 then spell_2_CD = 0 end
		end

		if boss_state == "idle" then
			if HPP < 25 then
				if spell_4_CD == 0 then
					boss_state = "rage"
					spell_4()
					Timers:CreateTimer(5,function()
						boss_state = "idle"
					end)
				end
			end
			if HPP < 50 and boss_state == "idle" then
				if spell_3_CD == 0 then
					boss_state = "skill_3"
					spell_3(boss_target)
				end
			end

			if spell_1_CD == 0 and boss_state == "idle" then
				if (boss_target:GetAbsOrigin()-thisEntity:GetAbsOrigin()):Length2D()>500 then
					boss_state = "skill_1"
					spell_1(boss_target)
				end
			end
			if HPP < 75 and boss_state == "idle" then
				if spell_2_CD == 0 then
					if Is_Unit_Close(300,thisEntity:GetAbsOrigin()) == true then
						spell_2()
						boss_state = "skill_2"
					end
				end
			end

			if boss_state == "idle" or boss_state == "rage" then
				thisEntity:MoveToTargetToAttack(boss_target)
			else
				thisEntity:Stop()
			end
		end

		return 0.5
	end
end


function spell_2(target) --earth shake
	spell_2_CD = 25/CD_DIVISER

	local hCaster = thisEntity
	hCaster:Stop()
	StartAnimation(hCaster, {duration=1.0, activity=ACT_DOTA_OVERRIDE_ABILITY_3, rate=1})
	local nTFX = ParticleManager:CreateParticle( "particles/impact_incoming.vpcf",  PATTACH_ABSORIGIN , hTarget )
	ParticleManager:SetParticleControl(nTFX, 4, Vector(2.5,0,0))
	ParticleManager:SetParticleControl(nTFX, 7, hCaster:GetAbsOrigin())
	local nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf",  PATTACH_POINT , hCaster )
	Timers:CreateTimer(1,function()
		StartAnimation(hCaster, {duration=2.5, activity=ACT_DOTA_SPAWN , rate=0.25})
	end)
	hCaster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	Timers:CreateTimer(3.0,function()
		if hCaster:IsAlive() then
			ParticleManager:DestroyParticle(nTFX, true)
			ParticleManager:DestroyParticle(nCasterFX, true)
			boss_state = "idle"
			hCaster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
			enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
		                              hCaster:GetAbsOrigin(),
		                              nil,
		                              500,
		                              DOTA_UNIT_TARGET_TEAM_ENEMY,
		                              DOTA_UNIT_TARGET_ALL,
		                              DOTA_UNIT_TARGET_FLAG_NONE,
		                              FIND_ANY_ORDER,
		                              false)
		    		for k,v in pairs(enemy) do
		    			local damageTable = {
							victim = v,
							attacker = hCaster,
							damage = 25*(GameRules.difficulty^1.2),
							damage_type = DAMAGE_TYPE_PHYSICAL,
						}
						ApplyDamage(damageTable)

						EmitSoundOn( "Hero_Ursa.Earthshock", hCaster )
						LinkLuaModifier( "lua_modifier_stun", "modifiers/lua_modifier_stun.lua", LUA_MODIFIER_MOTION_NONE )
						v:AddNewModifier(hCaster, nil, "lua_modifier_stun", {duration = 1.5})

		    		end
		   end
	end)
end


function spell_4(target)
	spell_4_CD = 10 + 10/CD_DIVISER
	local hCaster = thisEntity
	StartAnimation(hCaster, {duration=1.0, activity=ACT_DOTA_OVERRIDE_ABILITY_3, rate=1.0})
	hCaster:SetBaseAttackTime(0.1)
	LinkLuaModifier( "immunity", "modifiers/immunity.lua", LUA_MODIFIER_MOTION_NONE )
	thisEntity:AddNewModifier(thisEntity, nil, "immunity", {})
	local nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf",  PATTACH_POINT , hCaster )
	Timers:CreateTimer(5,function()
		hCaster:SetBaseAttackTime(1.0)
		thisEntity:RemoveModifierByName("immunity")
		ParticleManager:DestroyParticle(nCasterFX, true)
	end)
end


function spell_1(target)
	if thisEntity:IsAlive() then
		spell_1_CD = 15/CD_DIVISER
		local hCaster = thisEntity --We will always have Caster.
	    hCaster:Stop()
	    local hTarget = target
	    local vPoint = hTarget:GetAbsOrigin() --We will always have Vector for the point.
	    local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
	    local vtarget = vPoint
	    local nCasterFX = nil
	    hCaster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	    local time = 0
	    local vDiff = vtarget- vOrigin
		hCaster:MoveToPosition(hCaster:GetAbsOrigin() - hCaster:GetForwardVector())
		vDiff.z = 0
		local v_target = Vector(vDiff.x/vDiff:Length2D(),vDiff.y/vDiff:Length2D(),0)

		hCaster:SetForwardVector(v_target)
		hCaster:MoveToPosition(hCaster:GetAbsOrigin() - hCaster:GetForwardVector())

		local duration = 1.0 + (vDiff:Length2D()/6000)
	    local movement_x_per_frame = vDiff.x/(50*duration)
	    local movement_y_per_frame = vDiff.y/(50*duration)
	    hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
	    --create warning zone
	    Timers:CreateTimer(0.5,function()
	    	nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf",  PATTACH_ABSORIGIN_FOLLOW , hCaster )
	    	StartAnimation(hCaster, {duration=duration+1.5, activity=ACT_DOTA_RUN , rate=2.0})
	    end)
	    Timers:CreateTimer(0.5,function()
	    	if hCaster:IsAlive() then
	    		hCaster:SetForwardVector(v_target)
		    	time = time + 0.02
		    	hCaster:Stop()
		    	movement = Vector(movement_x_per_frame,movement_y_per_frame,0)
		    	hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + movement)
		    	if time >= duration then
		    		boss_state = "idle"
		    		hCaster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		    		hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
		    		ParticleManager:DestroyParticle(nCasterFX, true)
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
						LinkLuaModifier( "lua_modifier_stun", "modifiers/lua_modifier_stun.lua", LUA_MODIFIER_MOTION_NONE )
						v:AddNewModifier(hCaster, nil, "lua_modifier_stun", {duration = 0.5})
		    		end

		    	else
		    		return 0.02
		    	end
		    else
		    	ParticleManager:DestroyParticle(nCasterFX, true)
		    end
    	end)
	end
end

function spell_3(target)
	if thisEntity:IsAlive() then
		spell_3_CD = 15/CD_DIVISER
		local hCaster = thisEntity --We will always have Caster.
	    hCaster:Stop()
	    local hTarget = target
	    local vPoint = hTarget:GetAbsOrigin() --We will always have Vector for the point.
	    local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
	    local vtarget = vPoint

	    local time = 0
	    local vDiff = vtarget- vOrigin
		vDiff.z = 0
		local v_target = Vector(vDiff.x/vDiff:Length2D(),vDiff.y/vDiff:Length2D(),0)
		hCaster:SetForwardVector(v_target)

		local nTFX = ParticleManager:CreateParticle( "particles/impact_incoming.vpcf",  PATTACH_ABSORIGIN , hTarget )
		ParticleManager:SetParticleControl(nTFX, 7, vtarget)
		local duration = 1.3 + (vDiff:Length2D()/3000)
		ParticleManager:SetParticleControl(nTFX, 4, Vector(duration,0,0))
	    local movement_x_per_frame = vDiff.x/(50*duration)
	    local movement_y_per_frame = vDiff.y/(50*duration)
	    local movement_z_per_frame = (vDiff:Length2D()/2 + 500)/(50*duration)
	    hCaster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	    hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
	    --create warning zone
	    Timers:CreateTimer(1.0,function()
	    	nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf",  PATTACH_ABSORIGIN_FOLLOW , hCaster )
	    	StartAnimation(hCaster, {duration=duration+1, activity=ACT_DOTA_FLAIL , rate=0.5})
	    end)
	    Timers:CreateTimer(1.0,function()
	    	if hCaster:IsAlive() then
		    	time = time + 0.02
		    	hCaster:SetForwardVector(v_target)
		    	local z_movement = movement_z_per_frame * ((duration/2) - time)
		    	movement = Vector(movement_x_per_frame,movement_y_per_frame,z_movement)
		    	hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + movement)
		    	if time >= duration then
		    		boss_state = "idle"
		    		ParticleManager:DestroyParticle(nCasterFX, true)
		    		ParticleManager:DestroyParticle(nTFX, true)
		    		hCaster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		    		hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
		    		FindClearSpaceForUnit(hCaster, vtarget, false)
		    		StartAnimation(hCaster, {duration=2.5, activity=ACT_DOTA_SPAWN , rate=1.0})
		    		EmitSoundOn( "Hero_VengefulSpirit.NetherSwap", hCaster )
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
							damage = 15*(GameRules.difficulty^1.20),
							damage_type = DAMAGE_TYPE_PHYSICAL,
						}
						ApplyDamage(damageTable)
						EmitSoundOn( "Hero_Ursa.Earthshock", hCaster )
						LinkLuaModifier( "lua_modifier_stun", "modifiers/lua_modifier_stun.lua", LUA_MODIFIER_MOTION_NONE )
						v:AddNewModifier(hCaster, nil, "lua_modifier_stun", {duration = 2})

		    		end
		    	else
		    		return 0.02
		    	end
		    else
		    	ParticleManager:DestroyParticle(nTFX, true)
		    end
	    end)
	end
end

function found_lowest_hpp_ennemy(rand)
	enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	if rand == false then
		local lowest_hpp = 100
		local target = nil
		for k,v in pairs(enemy) do
			if v.agro == nil then v.agro = 0 end
			local hpp = (v:GetHealth()/v:GetMaxHealth())*100 - (v.agro * 5)
			if hpp <= lowest_hpp then
				lowest_hpp = hpp
				target = v
			end
		end
		if lowest_hpp == 100 then
			local target_id = math.random(1,#enemy)
			local id = 0
			for k,v in pairs(enemy) do
				id = id + 1
				if id == target_id then return v end
			end
		else
			return target
		end

	else
		local target_id = math.random(1,#enemy)
			local id = 0
			for k,v in pairs(enemy) do
				id = id + 1
				if id == target_id then return v end
			end
	end

end

function Is_Unit_Close(radius,origin)
	enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              origin,
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	if #enemy > 0 then
		return true
	else
		return false
	end
end
