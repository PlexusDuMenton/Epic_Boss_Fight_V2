require('libraries/timers')
require('libraries/animations')

--spell 2 : 50% chance to slow of 50%
--spell 3 : take the farest ennemy and pull it toward him
--spell 5 : 50% chance to immobilise an ennemy

MOVE_SPEED = math.log(GameRules.difficulty+10)/math.log(10) * 25 + 200
function Spawn( entityKeyValues )
	thisEntity:SetBaseMoveSpeed(MOVE_SPEED)
	LinkLuaModifier( "immunity", "modifiers/immunity.lua", LUA_MODIFIER_MOTION_NONE )
	thisEntity:SetContextThink( "Boss_2_think", Boss_2_think, THINK_TIME )
	thisEntity:SetContextThink( "change_target", change_target, 2 )

	LinkLuaModifier( "slow", "modifiers/spell_2_boss_2.lua", LUA_MODIFIER_MOTION_NONE )
	thisEntity:AddNewModifier(thisEntity, nil, "slow", { })
end


function KnockBack(radius,center,distance,team,space)
	if space == nil then space = 150 end
	local enemy = FindUnitsInRadius(team,
                              center,
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	LinkLuaModifier( "knock_back", "modifiers/knock_back.lua", LUA_MODIFIER_MOTION_NONE )
	for k,v in pairs(enemy) do
		v:AddNewModifier(v, nil, "knock_back", {duration=0.5})
		local time = 0
		local duration = 0.5

		vDiff = v:GetAbsOrigin() - center
		local v_distance = 0
		if distance> 0 then
			v_distance = (radius - vDiff:Length2D()) + distance

		elseif distance == -1 then
			v_distance = -vDiff:Length2D() + space
			duration = - v_distance/2500
		else
			v_distance = distance
			duration = - v_distance/1500
		end

	    local movement_x_per_frame = ((vDiff.x/vDiff:Length2D())*v_distance)/(50*duration)
	    local movement_y_per_frame = ((vDiff.y/vDiff:Length2D())*v_distance)/(50*duration)
	    local movement_z_per_frame = (v_distance/2 + 800)/(50*duration)

	    v:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	    v:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
		Timers:CreateTimer(0.02,function()
	    	if v:IsAlive() then
		    	time = time + 0.02
		    	local z_movement = movement_z_per_frame * ((duration/2) - time)
		    	movement = Vector(movement_x_per_frame,movement_y_per_frame,z_movement)
		    	v:SetAbsOrigin(v:GetAbsOrigin() + movement)
		    	if time >= duration then
		    		v:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		    		v:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
		    		FindClearSpaceForUnit(v, v:GetAbsOrigin(), false)
		    	else
		    		return 0.02
		    	end
		    else
		    	ParticleManager:DestroyParticle(target_particle, true)
		    end
	    end)
	end
end

THINK_TIME = 0.5
force_target = nil
CD_DIVISER = math.log(GameRules.difficulty+10)/math.log(10)
boss_state = "idle"
boss_target = nil
change_target_CD = 0
function change_target()
	enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	local lowest_hp = -1
		local target = nil
		for k,v in pairs(enemy) do
			if v:IsAlive() then
				if v.agro == nil then v.agro = 0 end
				local hp = v:GetHealth()/(1+v.agro)
				if hp <= lowest_hp or lowest_hp== -1 then
					lowest_hp = hp
					target = v
				end
			end
		end
	if force_target == nil or force_target:IsAlive() == false then
		boss_target = target
	else
		boss_target = force_target
	end
	return 2
end

local form = 0



spell_1_CD = 6
spell_2_CD = 10
spell_4_CD = 5
spell_6_CD = 0

function projectile_dectection(origin,speed,duration,origin_size,final_size,team,Damage_Table,modifier_name)
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
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
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
					if modifier_name ~= nil then
						LinkLuaModifier( modifier_name, "modifiers/"..modifier_name..".lua", LUA_MODIFIER_MOTION_NONE )
					end
					unit_touched[#unit_touched + 1] = v
				end
			end
    		return 0.015
    	end
    end)
end

function create_projectile(Info,team,Damage_Table,modifier_name)
	ProjectileManager:CreateLinearProjectile( Info )
	projectile_dectection(Info.vSpawnOrigin,Info.vVelocity,Info.fExpireTime - GameRules:GetGameTime(),Info.fStartRadius,Info.fEndRadius,team,Damage_Table,modifier_name)
end

function reduce_CD(cd)
	if cd~=0 then
		cd = cd - THINK_TIME
		if cd < 0 then cd = 0 end
	end
	return cd
end

function spell_6()
	spell_6_CD = 20/CD_DIVISER + 5
	boss_state = "spell_6"
	thisEntity:Stop()
	thisEntity:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	thisEntity:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)

	StartAnimation(thisEntity, {duration=3.0, activity=ACT_DOTA_CAST_ABILITY_1 , rate=0.65})
	Timers:CreateTimer(1.8,function()
		KnockBack(2000,thisEntity:GetAbsOrigin()+thisEntity:GetForwardVector()*200,-1,DOTA_TEAM_GOODGUYS)
		EndAnimation(thisEntity)
		Timers:CreateTimer(0.07,function()
			StartAnimation(thisEntity, {duration=4.0, activity=ACT_DOTA_CAST_ABILITY_4 , rate=0.15})
		end)
		Timers:CreateTimer((1.8 + 0.7/CD_DIVISER),function()
			EmitSoundOn("n_creep_Thunderlizard_Big.Roar", thisEntity)
			local damageTable = {
							victim = nil,
							attacker = thisEntity,
							damage = 25*(GameRules.difficulty^1.2),
							damage_type = DAMAGE_TYPE_PHYSICAL,
						}
			local projectileTable = {
			        Ability = nil,
			        EffectName = "particles/scream_wave.vpcf",
			        vSpawnOrigin = thisEntity:GetAbsOrigin()+thisEntity:GetForwardVector()*200,
			        fDistance = 1200,
			        fStartRadius = 50,
			        fEndRadius = 400,
			        fExpireTime = GameRules:GetGameTime() + 1.1,
			        Source = thisEntity,
			        bHasFrontalCone = true,
			        bReplaceExisting = false,
			        bProvidesVision = false,
			        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
			        bDeleteOnHit = false,
			        vVelocity = thisEntity:GetForwardVector() * 1100,
	    	}

			create_projectile(projectileTable,DOTA_TEAM_GOODGUYS,damageTable)
			Timers:CreateTimer(0.5,function()
				thisEntity:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		    	thisEntity:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
				EndAnimation(thisEntity)
				boss_state = "idle"
			end)

	    end)
			--damage all player who are in front of him
	end)
end

HEAL_AMMOUNT = 0
function spell_4()
	print("do spell 4")
	spell_4_CD = 40/CD_DIVISER + 20 + HEAL_AMMOUNT * 60
	boss_state = "spell_4"
	local x = -6400
	local y = -200
	local found_safe = false
	local base_HPR = thisEntity:GetBaseHealthRegen()
	found_safe = true
	thisEntity:Stop()
	StartAnimation(thisEntity, {duration=999, activity=ACT_DOTA_DEFEAT , rate=0.25})
	thisEntity:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	thisEntity:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
	nCasterFX = ParticleManager:CreateParticle( "particles/healing_ring.vpcf",  PATTACH_ABSORIGIN , thisEntity )
	KnockBack(800,thisEntity:GetAbsOrigin(),500,DOTA_TEAM_GOODGUYS)
	thisEntity:SetBaseHealthRegen(thisEntity:GetMaxHealth()/15)
	thisEntity:AddNewModifier(thisEntity, nil, "immunity", {})
	Timers:CreateTimer(1.5,function()
		thisEntity:RemoveModifierByName("immunity")
	end)
	Timers:CreateTimer(1.5,function()
		if Is_Unit_Close(500,thisEntity:GetAbsOrigin()) or thisEntity:GetHealth() >= thisEntity:GetMaxHealth()*(0.9 - HEAL_AMMOUNT/5) then
			EndAnimation(thisEntity)
			ParticleManager:DestroyParticle(nCasterFX, false)
			thisEntity:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		    thisEntity:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
			thisEntity:SetBaseHealthRegen(base_HPR)
			boss_state = "idle"
		else
			return 0.25
		end
	end)
	HEAL_AMMOUNT = HEAL_AMMOUNT + 1
end

function spell_2()
	print("do spell 2")
	spell_2_CD = 10/CD_DIVISER + 7.5
	local enemy = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                              thisEntity:GetAbsOrigin(),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_FARTHEST,
                              false)
	local target = enemy[1]
	force_target = target

		local time = 0
		local duration = 0.5

		vDiff = target:GetAbsOrigin() - thisEntity:GetAbsOrigin()
		v_distance = -vDiff:Length2D()
		duration = - v_distance/2500
		target:AddNewModifier(thisEntity, nil, "knock_back", {duration=duration})

	    local movement_x_per_frame = ((vDiff.x/vDiff:Length2D())*v_distance)/(50*duration)
	    local movement_y_per_frame = ((vDiff.y/vDiff:Length2D())*v_distance)/(50*duration)
	    local movement_z_per_frame = (v_distance/2 + 800)/(50*duration)

	    target:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
	    target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
		Timers:CreateTimer(0.02,function()
	    	if target:IsAlive() then
		    	time = time + 0.02
		    	local z_movement = movement_z_per_frame * ((duration/2) - time)
		    	movement = Vector(movement_x_per_frame,movement_y_per_frame,z_movement)
		    	target:SetAbsOrigin(target:GetAbsOrigin() + movement)
		    	if time >= duration then
		    		target:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		    		target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
		    		FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
		    	else
		    		return 0.02
		    	end
		    else
		    	ParticleManager:DestroyParticle(target_particle, true)
		    end
	    end)




end


function spell_1()
	print("do spell 1")
	spell_1_CD = 5/CD_DIVISER + 5
	thisEntity:SetBaseMoveSpeed(MOVE_SPEED*2)
	local nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf",  PATTACH_POINT , thisEntity )
	Timers:CreateTimer(3,function()
		thisEntity:SetBaseMoveSpeed(MOVE_SPEED)
		ParticleManager:DestroyParticle(nCasterFX, true)
	end)
end
imobilize = false
function Boss_2_think()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then -- verify if unity is not recently dead
		local HPP = (thisEntity:GetHealth()/thisEntity:GetMaxHealth()) * 100
		if form == 0 then
			spell_1_CD = reduce_CD(spell_1_CD)
		end
		if form == 0 then
			spell_2_CD = reduce_CD(spell_2_CD)
		end
		if form == 1 then
			spell_4_CD = reduce_CD(spell_4_CD)
		end
		spell_6_CD = reduce_CD(spell_6_CD)


		if boss_state == "idle" then
			if form == 0 then
				local rand = math.random(0,10)
				if spell_1_CD == 0 and Is_Unit_Close(400,thisEntity:GetAbsOrigin()) == false and Is_Unit_Close(1500,thisEntity:GetAbsOrigin()) == true then -- and spell requirement
					spell_1()
				elseif spell_2_CD == 0 then -- and spell requirement
					spell_2()
				else
					thisEntity:MoveToTargetToAttack(boss_target)
				end
			else
					if HPP <25 and spell_4_CD == 0 then
						spell_4()
					elseif HPP < 90 and spell_6_CD == 0 then
						spell_6()
					else
						thisEntity:MoveToTargetToAttack(boss_target)
					end
			end
		end
		if HPP < 25 and form == 0 then
			StartAnimation(thisEntity, {duration=50, activity=ACT_DOTA_FLAIL , rate=0.25})
			local time = 0
			form = 1
			thisEntity:Stop()
			thisEntity:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
			thisEntity:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
			nCasterFX = ParticleManager:CreateParticle( "particles/healing_ring.vpcf",  PATTACH_ABSORIGIN , thisEntity )
			LinkLuaModifier( "immunity", "modifiers/immunity.lua", LUA_MODIFIER_MOTION_NONE )
			thisEntity:AddNewModifier(thisEntity, nil, "immunity", {})
			LinkLuaModifier( "immobilize", "modifiers/spell_5_boss_2.lua", LUA_MODIFIER_MOTION_NONE )
			thisEntity:AddNewModifier(thisEntity, nil, "immobilize", {})
			boss_state = "transform"
			Timers:CreateTimer(0.02,function()
			    	time = time + 0.02
			    	local z_movement =  10 * ((1) - time)
			    	local movement = Vector(0,0,z_movement)
			    	thisEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + movement)
			    	if time >= 1 then
			    		LinkLuaModifier( "transform", "modifiers/transform.lua", LUA_MODIFIER_MOTION_NONE )
						thisEntity:AddNewModifier(thisEntity, nil, "transform", {})
			    	end
			    	if time >= 2 then
			    		EndAnimation(thisEntity)
			    		thisEntity:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
			    		thisEntity:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
			    		FindClearSpaceForUnit(thisEntity, thisEntity:GetAbsOrigin(), false)
			    		ParticleManager:DestroyParticle(nCasterFX, false)
			    		boss_state = "idle"
			    		thisEntity:RemoveModifierByName("immunity")
						thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
						thisEntity:SetHealth(thisEntity:GetMaxHealth())
						thisEntity:SetBaseAttackTime(0.75)
			    	else
			    		return 0.02
			    	end
		    end)

		end
		return THINK_TIME
	end
end


function Is_Unit_Close(radius,origin)
	local enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
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
