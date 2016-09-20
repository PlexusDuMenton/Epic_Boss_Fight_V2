require('libraries/timers')
require('libraries/animations')
THINK_TIME = 0.5
force_target = nil
CD_DIVISER = math.log(GameRules.difficulty+10)/math.log(10)
boss_state = "idle"
boss_target = nil
change_target_CD = 0
casting_spell = false

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "change_target", change_target, 2 )
	thisEntity:SetContextThink( "Boss_think", Boss_think, THINK_TIME )
end


function change_target()
	local target = nil
  enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
		if math.random(0,5) <= 3 then
	    local higgest_damage = 0
	    for k,v in pairs(enemy) do
				if v:IsHero() == true then
					if v.equip_stats ~= nil then
						local damage = v.equip_stats.damage + (v.equip_stats.str + v.hero_stats.str + v.skill_bonus.str)*1.5 + 2
						if damage > higgest_damage then
							higgest_damage = damage
							target = v
						end
					end
				elseif higgest_damage == 0 then
					target = v
				end
    	end
		else
			local target_id = math.random(1,#enemy)
			local id = 0
			for k,v in pairs(enemy) do
				id = id + 1
				if id == target_id then target = v end
			end
		end

		boss_target = target
end

function reduce_CD(cd)
	if cd~=0 then
		cd = cd - THINK_TIME
		if cd < 0 then cd = 0 end
	end
	return cd
end

spell_1_CD = 5
spell_2_CD = 15
spell_3_CD = 20
spell_4_CD = 15

function Boss_think()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then -- verify if unity is not recently dead
		spell_1_CD = reduce_CD(spell_1_CD)
		spell_2_CD = reduce_CD(spell_2_CD)
		spell_3_CD = reduce_CD(spell_3_CD)
		spell_4_CD = reduce_CD(spell_4_CD)
		local hpp = thisEntity:GetHealth()/thisEntity:GetMaxHealth() --if you want this boss to only cast spell when his hp is below an certain percent
		-- local move_speed = math.log(GameRules.difficulty+10)/math.log(10) * 25 + 300
		-- thisEntity:SetBaseMoveSpeed(move_speed) --if you want the boss to have his movespeed scale with difficulty

		if spell_2_CD <= 0 and Is_Unit_Close(900,thisEntity:GetAbsOrigin()) and casting_spell ~= true then
			Spell_2()
		elseif spell_4_CD <= 0 and hpp <= 0.5 and casting_spell ~= true then
			Spell_4()
		elseif spell_1_CD <= 0 and casting_spell ~= true then
			Spell_1()
		elseif spell_3_CD <= 0 and Is_Unit_Close(500,thisEntity:GetAbsOrigin()) and casting_spell ~= true then
			Spell_3()

		else
			thisEntity:MoveToTargetToAttack(boss_target)
		end
		if thisEntity:IsAlive() then
			return THINK_TIME
		end
	end
end

function Spell_4()
	if thisEntity:IsAlive() then
		print ('cast spell 4')
		casting_spell = true
		spell_4_CD = 30 + 40/CD_DIVISER
		local hCaster = thisEntity --We will always have Caster.
		hCaster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
		hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)

		local jump = 2 + math.ceil(CD_DIVISER) + math.ceil(GameRules.player_difficulty*0.6)
		if jump > 10 then jump = 10 end
		EmitSoundOn( "earthshaker_erth_anger_07", hCaster )
		for i = 1,jump do
			local nTFX = nil
			local hTarget = nil
			Timers:CreateTimer((1.5*i + 0.5),function()
				hTarget = boss_target
				nTFX = ParticleManager:CreateParticle( "particles/ground_marker_test.vpcf",  PATTACH_ABSORIGIN , hTarget )
				ParticleManager:SetParticleControl(nTFX, 2, Vector(200,20,1))
				ParticleManager:SetParticleControl(nTFX, 3, Vector(350,0,0))
			end)
			Timers:CreateTimer((2.0*i+1),function()
				local vPoint = hTarget:GetAbsOrigin() --We will always have Vector for the point.
			  local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
			  local vtarget = vPoint
				ParticleManager:SetParticleControl(nTFX, 0, vtarget)
				local time = 0
				local vDiff = vtarget- vOrigin
				vDiff.z = 0
				local v_target = Vector(vDiff.x/vDiff:Length2D(),vDiff.y/vDiff:Length2D(),0)
				hCaster:SetForwardVector(v_target)
				local rand_voice = math.random(0,4)
				if rand_voice == 1 or rand_voice == 2 then
					EmitSoundOn( "earthshaker_erth_anger_02", hCaster )
				elseif rand_voice == 2 or rand_voice == 3 then
					EmitSoundOn( "earthshaker_erth_anger_03", hCaster )
				else
					EmitSoundOn( "earthshaker_erth_anger_08", hCaster )
				end
				local duration = 1.0
				local movement_x_per_frame = vDiff.x/(50*duration)
				local movement_y_per_frame = vDiff.y/(50*duration)
				local movement_z_per_frame = 9000/(50*duration)
			  StartAnimation(hCaster, {duration=duration+1, activity=ACT_DOTA_CAST_ABILITY_2 , rate=0.4})
			  Timers:CreateTimer(0.1,function()
			  	if hCaster:IsAlive() then
				  	time = time + 0.02
						hCaster:Stop()
				  	hCaster:SetForwardVector(v_target)
				  	local z_movement = movement_z_per_frame * ((duration/2) - time)
				  	movement = Vector(movement_x_per_frame,movement_y_per_frame,z_movement)
				  	hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + movement)
				  	if time >= duration then
				  		boss_state = "idle"
				  		ParticleManager:DestroyParticle(nTFX, true)
				  		FindClearSpaceForUnit(hCaster, vtarget, false)
				  		EmitSoundOn( "Hero_EarthShaker.Fissure", hCaster )
							if i>=jump then
								hCaster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
					  		hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
								Timers:CreateTimer(1,function()
									casting_spell = true
								end)
							end
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
								damage = 5*(GameRules.difficulty^1.20),
								damage_type = DAMAGE_TYPE_PHYSICAL,
							}
							if rand_voice == 4 then damageTable.damage = damageTable.damage*2 end
								ApplyDamage(damageTable)
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
			end)
		end
	end
end

function Spell_1()
	if thisEntity:IsAlive() then
		print ('cast spell 1')
		casting_spell = true
		spell_1_CD = 5 + 15/CD_DIVISER
		local hCaster = thisEntity --We will always have Caster.
		EmitSoundOn( "earthshaker_erth_anger_02", hCaster )
	  hCaster:Stop()
	  local hTarget = boss_target
	  local vPoint = hTarget:GetAbsOrigin() --We will always have Vector for the point.
	  local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
	  local vtarget = vPoint

	  local time = 0
	  local vDiff = vtarget- vOrigin
		vDiff.z = 0
		local v_target = Vector(vDiff.x/vDiff:Length2D(),vDiff.y/vDiff:Length2D(),0)
		hCaster:SetForwardVector(v_target)

		local nTFX = ParticleManager:CreateParticle( "particles/ground_marker_test.vpcf",  PATTACH_ABSORIGIN , hTarget )
		ParticleManager:SetParticleControl(nTFX, 0, vtarget)
		ParticleManager:SetParticleControl(nTFX, 2, Vector(200,20,1))
		ParticleManager:SetParticleControl(nTFX, 3, Vector(350,0,0))
		local duration = 1.0
	  local movement_x_per_frame = vDiff.x/(50*duration)
	  local movement_y_per_frame = vDiff.y/(50*duration)
	  local movement_z_per_frame = 9000/(50*duration)
	  hCaster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	  hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
	  --create warning zone
	  Timers:CreateTimer(1.0,function()
	  	StartAnimation(hCaster, {duration=duration+1, activity=ACT_DOTA_CAST_ABILITY_2 , rate=0.4})
	  end)
	  Timers:CreateTimer(1.0,function()
	  	if hCaster:IsAlive() then
		  	time = time + 0.02
				hCaster:Stop()
		  	hCaster:SetForwardVector(v_target)
		  	local z_movement = movement_z_per_frame * ((duration/2) - time)
		  	movement = Vector(movement_x_per_frame,movement_y_per_frame,z_movement)
		  	hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + movement)
		  	if time >= duration then
		  		boss_state = "idle"
		  		ParticleManager:DestroyParticle(nTFX, true)
					Timers:CreateTimer(1.0,function()
						casting_spell = false
					end)
		  		hCaster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		  		hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
		  		FindClearSpaceForUnit(hCaster, vtarget, false)
		  		EmitSoundOn( "Hero_EarthShaker.Fissure", hCaster )
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
						damage = 5*(GameRules.difficulty^1.20),
						damage_type = DAMAGE_TYPE_PHYSICAL,
					}
						ApplyDamage(damageTable)
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

function Spell_2()
	spell_2_CD = 15 + 15/CD_DIVISER
	casting_spell = true
	local hCaster = thisEntity
	local vPoint = hCaster:GetAbsOrigin() --We will always have Vector for the point.
	local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
	local vtarget = vPoint
	EmitSoundOn( "earthshaker_erth_ability_fissure_03", hCaster )
	StartAnimation(hCaster, {duration=1.8, activity=ACT_DOTA_CAST_ABILITY_4 , rate=0.4})
	local nTFX = ParticleManager:CreateParticle( "particles/ground_marker_test.vpcf",  PATTACH_ABSORIGIN , hCaster )
	ParticleManager:SetParticleControl(nTFX, 0, vtarget)
	ParticleManager:SetParticleControl(nTFX, 2, Vector(200,20,1))
	ParticleManager:SetParticleControl(nTFX, 3, Vector(1200,0,0))

	Timers:CreateTimer(1.7,
			function()
					casting_spell = false
					ParticleManager:DestroyParticle(nTFX, true)
					local particle = ParticleManager:CreateParticle("particles/boss_4_aoe.vpcf", PATTACH_ABSORIGIN, hCaster)

					ParticleManager:SetParticleControl(particle, 0, vtarget)
					ParticleManager:SetParticleControl(particle, 1, vtarget)
					ParticleManager:SetParticleControl(particle, 3, Vector(5, 0, 0))
					ParticleManager:SetParticleControl(particle, 3, Vector(1200, 0, 0))

					local obstructions = {}
					local amount = 100

					for i = 0, amount - 1 do
							local angle = math.rad(360 / amount * i)
							local offset = Vector(math.cos(angle), math.sin(angle), 0) * 1200
							local pso = SpawnEntityFromTableSynchronous("point_simple_obstruction", {
									origin = vtarget + offset,
							})

							table.insert(obstructions, pso)
					end

					EmitSoundOn( "Hero_EarthShaker.Fissure", hCaster )

					Timers:CreateTimer(5,
							function()
									ParticleManager:DestroyParticle(particle, true)
									EmitSoundOn("Hero_EarthShaker.FissureDestroy", hCaster)
									for _, pso in ipairs(obstructions) do
											pso:RemoveSelf()
									end
							end
					)
			end
	)
end

	function Spell_3()
		if thisEntity:IsAlive() then
			casting_spell = true
			spell_3_CD = 12 + 10/CD_DIVISER
			local hCaster = thisEntity --We will always have Caster.
		    hCaster:Stop()
				EmitSoundOn( "earthshaker_erth_ability_echo_03", hCaster )
		    local vPoint = hCaster:GetAbsOrigin() --We will always have Vector for the point.
		    local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
		    local vtarget = vPoint + hCaster:GetForwardVector()

		    local time = 0
		    local vDiff = vtarget- vOrigin
			vDiff.z = 0
			local v_target = Vector(vDiff.x/vDiff:Length2D(),vDiff.y/vDiff:Length2D(),0)
			hCaster:SetForwardVector(v_target)

			local nTFX = ParticleManager:CreateParticle( "particles/ground_marker_test.vpcf",  PATTACH_ABSORIGIN , hCaster )
			ParticleManager:SetParticleControl(nTFX, 0, vtarget)
			ParticleManager:SetParticleControl(nTFX, 2, Vector(200,20,1))
			ParticleManager:SetParticleControl(nTFX, 3, Vector(450,0,0))
			local duration = 1.5
				hCaster:Stop()
		    local movement_x_per_frame = 0
		    local movement_y_per_frame = 0
		    local movement_z_per_frame = 12000/(50*duration)
		    hCaster:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
		    hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
		    --create warning zone
		    Timers:CreateTimer(1.0,function()
		    	StartAnimation(hCaster, {duration=duration+1, activity=ACT_DOTA_CAST_ABILITY_2 , rate=0.3})
		    end)
		    Timers:CreateTimer(1.0,function()
		    	if hCaster:IsAlive() then
			    	time = time + 0.02
						hCaster:Stop()
			    	hCaster:SetForwardVector(v_target)
			    	local z_movement = movement_z_per_frame * ((duration/2) - time)
			    	movement = Vector(movement_x_per_frame,movement_y_per_frame,z_movement)
			    	hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + movement)
			    	if time >= duration then
			    		boss_state = "idle"
							casting_spell = false
			    		ParticleManager:DestroyParticle(nTFX, true)
			    		hCaster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
			    		hCaster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
							EmitSoundOn( "Hero_EarthShaker.EchoSlam", hCaster )
			    		enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
			                              hCaster:GetAbsOrigin(),
			                              nil,
			                              450,
			                              DOTA_UNIT_TARGET_TEAM_ENEMY,
			                              DOTA_UNIT_TARGET_ALL,
			                              DOTA_UNIT_TARGET_FLAG_NONE,
			                              FIND_ANY_ORDER,
			                              false)
			    		for k,v in pairs(enemy) do
			    			local damageTable = {
								victim = v,
								attacker = hCaster,
								damage = 20*(GameRules.difficulty^1.20),
								damage_type = DAMAGE_TYPE_PHYSICAL,
							}
								ApplyDamage(damageTable)
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
