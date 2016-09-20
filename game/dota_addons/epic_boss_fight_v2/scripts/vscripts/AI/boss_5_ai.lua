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
	boss_manager.Core_Ennemy = boss_manager.Core_Ennemy + 3
	thisEntity:SetContextThink( "change_target", change_target, 0.1 )
	thisEntity:SetContextThink( "Boss_think", Boss_think, THINK_TIME )
end


function change_target(force)
	if thisEntity:IsAlive() then
		local target = nil
		print("geting an target")
	  enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
	                              Vector(0, 0, 0),
	                              nil,
	                              FIND_UNITS_EVERYWHERE,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		if math.random(0,5) <= 3 or boss_target == nil or force == true then--3 chance on 5 to change target
			local target_id = math.random(1,#enemy)
			target = enemy[target_id]
			boss_target = target
		end
		return 3
	end
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

function jump_trajectory(table,exec_function)
	if not table then return end
	if not table.entity then return end
	if not table.delay then table.delay = 0 end
	if table.entity:IsAlive() then
		local hCaster = table.entity --We will always have Caster.
		if table.sound_file~= nil then
			EmitSoundOn( table.sound_file, hCaster )
		end
		if table.duration_distance_mult == nil then table.duration_distance_mult = 0 end
		if table.heigh == nil then table.heigh = 32 end
	  hCaster:Stop()
	  local vOrigin = hCaster:GetAbsOrigin() --Our caster's location
	  local vtarget = table.target_pos

	  local time = 0
	  local vDiff = vtarget- vOrigin
		vDiff.z = 0
		local v_target = Vector(vDiff.x/vDiff:Length2D(),vDiff.y/vDiff:Length2D(),0)
		if vDiff:Length2D() ~= 0 then
			hCaster:SetForwardVector(v_target)
		end
		if table.ground_effect == nil then table.ground_effect = "particles/ground_marker_test.vpcf" end
		local nTFX = ParticleManager:CreateParticle( table.ground_effect,  PATTACH_ABSORIGIN , table.entity )
		ParticleManager:SetParticleControl(nTFX, 0, vtarget)
		ParticleManager:SetParticleControl(nTFX, 2, Vector(200,20,1))
		ParticleManager:SetParticleControl(nTFX, 3, Vector(table.radius,0,0))
		local duration = table.duration + (table.duration_distance_mult * vDiff:Length2D())

	  local movement_x_per_frame = (vDiff.x)/(50*duration)
	  local movement_y_per_frame = (vDiff.y)/(50*duration)
	  local movement_z_per_frame = (table.heigh)/(50*duration)

		print(vDiff.x,vDiff.y,table.heigh)
		print(movement_x_per_frame,movement_y_per_frame,movement_z_per_frame)
	  --create warning zone
		Timers:CreateTimer(table.delay,function()
			StartAnimation(hCaster, {duration=duration, activity=ACT_DOTA_FLAIL , rate=0.5})
		end)
	  Timers:CreateTimer(table.delay,function()
	  	if hCaster:IsAlive() then
		  	time = time + 0.02
				hCaster:Stop()
				if vDiff:Length2D() ~= 0 then
					hCaster:SetForwardVector(v_target)
				end
		  	local z_movement = movement_z_per_frame * ((duration/2) - time)
		  	movement = Vector(movement_x_per_frame,movement_y_per_frame,z_movement)
		  	hCaster:SetAbsOrigin(hCaster:GetAbsOrigin() + movement)
		  	if time >= duration then
		  		ParticleManager:DestroyParticle(nTFX, true)
		  		FindClearSpaceForUnit(hCaster, vtarget, false)
					if type(exec_function) == 'function' then
						exec_function(table)
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


function Spell_1()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then
		print("cast spell 1")
		casting_spell = true
		spell_1_CD =  5 + 10/CD_DIVISER
		local rock = boss_manager:Spawn_Boss("rock_prop",thisEntity:GetAbsOrigin(),10)
		LinkLuaModifier( "immunity", "modifiers/immunity.lua", LUA_MODIFIER_MOTION_NONE )
		rock:AddNewModifier(rock, nil, "immunity", {})
		local function function_to_exe(table)
			nTFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_tiny/tiny_toss_impact.vpcf",  PATTACH_ABSORIGIN , thisEntity )
			ParticleManager:SetParticleControl(nTFX, 0, table.entity:GetAbsOrigin())
			enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
															table.entity:GetAbsOrigin(),
															nil,
															table.radius,
															DOTA_UNIT_TARGET_TEAM_ENEMY,
															DOTA_UNIT_TARGET_ALL,
															DOTA_UNIT_TARGET_FLAG_NONE,
															FIND_ANY_ORDER,
															false)
			for k,v in pairs(enemy) do
			 local damageTable = {
				victim = v,
				attacker = table.entity,
				damage = 5*(GameRules.difficulty^1.16),
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
				ApplyDamage(damageTable)
				LinkLuaModifier( "lua_modifier_stun", "modifiers/lua_modifier_stun.lua", LUA_MODIFIER_MOTION_NONE )
				v:AddNewModifier(hCaster, nil, "lua_modifier_stun", {duration = 1})
			end
			table.entity:ForceKill(true)
			table.entity:AddNoDraw()
		end
		StartAnimation(thisEntity, {duration=0.5, activity=ACT_TINY_TOSS , rate=0.5})
		thisEntity:Stop()
		local timer = 0
		local function l_p()
			local projectileTable = {
			        Ability = nil,
			        EffectName = "",
			        vSpawnOrigin = thisEntity:GetAbsOrigin(),
			        fDistance =  (thisEntity:GetAbsOrigin() - boss_target:GetAbsOrigin()):Length2D(),
			        fStartRadius = 100,
			        fEndRadius = 100,
			        fExpireTime = GameRules:GetGameTime() + 5,
			        Source = thisEntity,
			        bHasFrontalCone = true,
			        bReplaceExisting = false,
			        bProvidesVision = false,
			        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
			        bDeleteOnHit = false,
			        vVelocity = (thisEntity:GetAbsOrigin() - boss_target:GetAbsOrigin()),
	    	}
				Timers:CreateTimer(0.5,function()
					local damageTable = {
	 				victim = nil,
	 				attacker = table.entity,
	 				damage = 5*(GameRules.difficulty^1.16),
	 				damage_type = DAMAGE_TYPE_PHYSICAL,
	 			}
	    		create_projectile(projectileTable,DOTA_TEAM_BADGUYS,damageTable,"lua_modifier_stun")
				end)
		end
		Timers:CreateTimer(0.03,function()
			timer = timer + 0.03
			if timer <= 0.5 then
				thisEntity:Stop()
				return 0.03
			else
				casting_spell = false
			end
		end)
		if boss_target == nil then
			Timers:CreateTimer(0.1,function()
				local info_table = {entity = rock,target_pos = boss_target:GetAbsOrigin(),duration = 1,heigh = 500,delay = 0.5,effect_name = nil,sound_file = nil,ground_effect = nil,duration_distance_mult = nil,radius = 150}
				jump_trajectory(info_table,function_to_exe,info_2)
				l_p()
			end)
		else
			local info_table = {entity = rock,target_pos = boss_target:GetAbsOrigin(),duration = 1,heigh = 500,delay = 0.5,effect_name = nil,sound_file = nil,ground_effect = nil,duration_distance_mult = nil,radius = 150}
			jump_trajectory(info_table,function_to_exe,info_2)
			l_p()
		end
	end
end





function Spell_2()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then
		spell_2_CD = 3 + 5/CD_DIVISER
		casting_spell = true

		local function function_to_exe(table)
			nTFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_tiny/tiny_toss_impact.vpcf",  PATTACH_ABSORIGIN , thisEntity )
			ParticleManager:SetParticleControl(nTFX, 0, table.entity:GetAbsOrigin())
			enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
															table.entity:GetAbsOrigin(),
															nil,
															table.radius,
															DOTA_UNIT_TARGET_TEAM_ENEMY,
															DOTA_UNIT_TARGET_ALL,
															DOTA_UNIT_TARGET_FLAG_NONE,
															FIND_ANY_ORDER,
															false)
			for k,v in pairs(enemy) do
			 local damageTable = {
				victim = v,
				attacker = table.entity,
				damage = 5*(GameRules.difficulty^1.20),
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
				ApplyDamage(damageTable)
				LinkLuaModifier( "lua_modifier_stun", "modifiers/lua_modifier_stun.lua", LUA_MODIFIER_MOTION_NONE )
				v:AddNewModifier(hCaster, nil, "lua_modifier_stun", {duration = 1})
			end
			table.entity:ForceKill(true)
			table.entity:AddNoDraw()
		end

		local rocks = 1 + math.floor(GameRules.player_difficulty*0.3)

		if rocks > 3 then rocks = 3 end

		local duration = rocks*0.75
		StartAnimation(thisEntity, {duration=duration, activity=ACT_TINY_TOSS , rate=0.5})
		thisEntity:Stop()
		local timer = 0

		Timers:CreateTimer(0.03,function()
			timer = timer + 0.03
			if timer <= duration then
				thisEntity:Stop()
				return 0.03
			end
		end)

		local count_rock = 0

		Timers:CreateTimer(0.1,function()

			if count_rock < rocks then

				local rock = boss_manager:Spawn_Boss("rock_prop",thisEntity:GetAbsOrigin(),10)
				LinkLuaModifier( "immunity", "modifiers/immunity.lua", LUA_MODIFIER_MOTION_NONE )
				local offset_vector = Vector(RandomInt(-200,200)*(rocks-count_rock),RandomInt(-200,200)*(rocks-count_rock),0)
				rock:AddNewModifier(rock, nil, "immunity", {})

				if boss_target == nil then

					Timers:CreateTimer(0.1,function()
						local info_table = {entity = rock,target_pos = boss_target:GetAbsOrigin() + offset_vector,duration = 1,heigh = 5500,delay = 0.5,effect_name = nil,sound_file = nil,ground_effect = nil,duration_distance_mult = nil,radius = 150}
						jump_trajectory(info_table,function_to_exe,info_2)
					end)

				else

					local info_table = {entity = rock,target_pos = boss_target:GetAbsOrigin() + offset_vector,duration = 1,heigh = 5500,delay = 0.5,effect_name = nil,sound_file = nil,ground_effect = nil,duration_distance_mult = nil,radius = 150}
					jump_trajectory(info_table,function_to_exe,info_2)

				end
				count_rock = count_rock + 1
				return 0.75
			end

		end)

		Timers:CreateTimer(duration,function()
			casting_spell = false
		end)

	end
end

function Spell_3()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then
		local hero_to_launch = boss_target
		spell_3_CD = 8 + 15/CD_DIVISER
		casting_spell = true
		local function function_to_exe(table)
			nTFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_tiny/tiny_toss_impact.vpcf",  PATTACH_ABSORIGIN , thisEntity )
			ParticleManager:SetParticleControl(nTFX, 0, table.entity:GetAbsOrigin())
			enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
															table.entity:GetAbsOrigin(),
															nil,
															table.radius,
															DOTA_UNIT_TARGET_TEAM_ENEMY,
															DOTA_UNIT_TARGET_ALL,
															DOTA_UNIT_TARGET_FLAG_NONE,
															FIND_ANY_ORDER,
															false)
			for k,v in pairs(enemy) do
			 local damageTable = {
				victim = v,
				attacker = table.entity,
				damage = 7*(GameRules.difficulty^1.15),
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
				ApplyDamage(damageTable)
				LinkLuaModifier( "lua_modifier_stun", "modifiers/lua_modifier_stun.lua", LUA_MODIFIER_MOTION_NONE )
				v:AddNewModifier(hCaster, nil, "lua_modifier_stun", {duration = 1})
			end
		end
		change_target(true)
		local duration = 0.5
		StartAnimation(thisEntity, {duration=duration, activity=ACT_TINY_TOSS , rate=0.5})
		thisEntity:Stop()
		local timer = 0
		Timers:CreateTimer(0.03,function()
			timer = timer + 0.03
			if timer <= duration then
				thisEntity:Stop()
				return 0.03
			end
		end)
		local offset_vector = Vector(RandomInt(-400,400),RandomInt(-400,400),0)
		if boss_target == nil then
			Timers:CreateTimer(0.1,function()
				local info_table = {entity = hero_to_launch,target_pos = boss_target:GetAbsOrigin() + offset_vector,duration = 1,heigh = 5500,delay = 0.5,effect_name = nil,sound_file = nil,ground_effect = nil,duration_distance_mult = nil,radius = 150}
				jump_trajectory(info_table,function_to_exe,info_2)
			end)
		else
			local info_table = {entity = hero_to_launch,target_pos = boss_target:GetAbsOrigin() + offset_vector,duration = 1,heigh = 5500,delay = 0.5,effect_name = nil,sound_file = nil,ground_effect = nil,duration_distance_mult = nil,radius = 150}
			jump_trajectory(info_table,function_to_exe,info_2)
		end
		Timers:CreateTimer(duration,function()
			casting_spell = false
		end)
	end
end






function spawn_next_form()
	EmitSoundOn( "RoshanDT.Scream2", thisEntity )
	print("a new form has born !")
	thisEntity:AddNoDraw()
	nTFX = ParticleManager:CreateParticle( "particles/boss_5_grow.vpcf",  PATTACH_ABSORIGIN , thisEntity )
	ParticleManager:SetParticleControl(nTFX, 0, thisEntity:GetAbsOrigin())
	boss_manager:Spawn_Boss("boss_5_2",thisEntity:GetAbsOrigin(),0)
end

function Boss_think()
	if thisEntity:IsAlive() then -- verify if unity is not recently dead
		spell_1_CD = reduce_CD(spell_1_CD)
		spell_2_CD = reduce_CD(spell_2_CD)
		spell_3_CD = reduce_CD(spell_3_CD)
		local hpp = thisEntity:GetHealth()/thisEntity:GetMaxHealth() --if you want this boss to only cast spell when his hp is below an certain percent
		-- local move_speed = math.log(GameRules.difficulty+10)/math.log(10) * 25 + 300
		-- thisEntity:SetBaseMoveSpeed(move_speed) --if you want the boss to have his movespeed scale with difficulty

		if spell_1_CD <= 0 and casting_spell == false then
			Spell_1()
		elseif spell_2_CD <= 0 and casting_spell == false then
			Spell_2()
		elseif spell_3_CD <= 0 and casting_spell == false and (thisEntity:GetAbsOrigin()-boss_target:GetAbsOrigin()):Length2D() <= 400  then
			Spell_3()
		else
			thisEntity:MoveToTargetToAttack(boss_target)
		end
		if thisEntity:IsAlive() then
			return THINK_TIME
		else
			spawn_next_form()
		end
	else
		spawn_next_form()
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

function projectile_dectection(origin,speed,duration,origin_size,final_size,team,Damage_Table,modifier_name,duration,bDeleteOnHit)
	print(duration)
	local time = 0
	local unit_touched = {}
	Timers:CreateTimer(0.015,function()
	   	time = time + 0.015
	    if time <= duration then
	    	local location = origin + speed * time
			local size = origin_size + ((final_size-origin_size)*(time/duration))
			local enemy = FindUnitsInRadius(team,
                              location,
                              nil,
                              size,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
			for k,v in pairs(enemy) do
				local f_is_allready = false
				for j,p in pairs(unit_touched) do
					if v == p then
						f_is_allready = true
					end
				end
				if f_is_allready == false then
					Damage_Table.victim = v
					ApplyDamage(Damage_Table)
					print(Damage_Table.damage)
					if modifier_name ~= nil then
						LinkLuaModifier( modifier_name, "modifiers/"..modifier_name..".lua", LUA_MODIFIER_MOTION_NONE )
						if duration == nil then duration = 1 end
						v:AddNewModifier(thisEntity, nil, modifier_name, {duration = duration})
					end
					unit_touched[#unit_touched + 1] = v
					if bDeleteOnHit == true then
						enemy = {}
						time = duration + 1
					end
				end
			end
    		return 0.015
    	end
    end)
end

function create_projectile(Info,team,Damage_Table,modifier_name,duration)
	ProjectileManager:CreateLinearProjectile( Info )
	local duration = 0
	if (Info.fExpireTime - GameRules:GetGameTime()) > ((Info.fDistance)/(Info.vVelocity:Length2D())) then
		duration = (Info.fDistance)/(Info.vVelocity:Length2D())
	else
		duration = (Info.fExpireTime - GameRules:GetGameTime())
	end
	projectile_dectection(Info.vSpawnOrigin,Info.vVelocity,duration,Info.fStartRadius,Info.fEndRadius,team,Damage_Table,modifier_name,duration,Info.bDeleteOnHit)
end
