require('libraries/timers')
require('libraries/animations')
THINK_TIME = 0.5
force_target = nil
CD_DIVISER = math.log(GameRules.difficulty+10)/math.log(10)
boss_state = "idle"
boss_target = nil
change_target_CD = 0
behavior = 1
invisible = false
cur_pos = 0
WAY_POINTS_AMMOUNT = 31
block_cd = false
reach_waypoints = true
immunity = false
total_wolf = 0
MAX_WOLF = 12 + math.ceil(math.log(GameRules.difficulty+10)/math.log(10))

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "Boss_3_think", Boss_3_think, THINK_TIME )
	thisEntity:SetContextThink( "change_target", change_target, 2 )
end

function count_wolf()
	local wolf = 0
	allies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
															Vector(0, 0, 0),
															nil,
															FIND_UNITS_EVERYWHERE,
															DOTA_UNIT_TARGET_TEAM_ENEMY,
															DOTA_UNIT_TARGET_ALL,
															DOTA_UNIT_TARGET_FLAG_NONE,
															FIND_ANY_ORDER,
															false)
	for k,v in pairs(allies) do
		if v:IsAlive() then
			if v:GetUnitName() == "boss_3_sub" then
					wolf = wolf + 1
				break
			end
		end
	end
	total_wolf = wolf
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
  local target_id = math.random(1,#enemy)
    local id = 0
    for k,v in pairs(enemy) do
      id = id + 1
      if id == target_id then
				target = v
				break
			end
    end
		boss_target = target
end

function reduce_CD(cd)
	if block_cd == false then
		if cd~=0 then
			cd = cd - THINK_TIME
			if cd < 0 then cd = 0 end
		end
	end
	return cd
end

function Spell_1()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then
		spell_1_CD = 10
		local ammount = 1 + math.ceil(GameRules.player_difficulty*0.3)
		if ammount > 4 then ammount = 4 end
		for i = 1,ammount do
			Timers:CreateTimer(i*0.75,function()
				if total_wolf < MAX_WOLF then
					boss_manager:Spawn_Boss("boss_3_sub",thisEntity:GetAbsOrigin(),500)
				end
			end)
		end
	end
end

function Spell_2()
	spell_4_CD = 15 + (10/CD_DIVISER)
	LinkLuaModifier( "immunity", "modifiers/immunity.lua", LUA_MODIFIER_MOTION_NONE )
	thisEntity:AddNewModifier(thisEntity, nil, "immunity", {})
	immunity = true
	Timers:CreateTimer(3,function()
		immunity = false
		thisEntity:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		thisEntity:RemoveModifierByName("immunity")
	end)
end

function Spell_3()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then
		spell_3_CD = 30
		LinkLuaModifier( "boss_3_invisible", "modifiers/boss_3_invisible.lua", LUA_MODIFIER_MOTION_NONE )
		thisEntity:AddNewModifier(thisEntity, nil, "boss_3_invisible", {})
		block_cd = true
		local ammount = 3 + math.ceil(GameRules.player_difficulty*0.5)
		if ammount > 7 then ammount = 7 end
		for i = 1,ammount do
			Timers:CreateTimer(i*0.25,function()
				if total_wolf < MAX_WOLF then
					boss_manager:Spawn_Boss("boss_3_sub",thisEntity:GetAbsOrigin(),750)
				end
			end)
		end
		Timers:CreateTimer(2,function()
			if total_wolf > 0 then
				return 0.5
			else
				block_cd = false
				thisEntity:RemoveModifierByName("boss_3_invisible")
			end
		end)
	end
end

spell_1_CD = 3 -- spawn 1-4 wolfs that attack player (depend on his HP and on difficulty level)
spell_4_CD = 10 -- can't be attacked and can't attack , only happen when in his first behavior

spell_3_CD = 25 -- Spawn 3-7 additional wold and is Invisible until all wolf are killed

function Boss_3_think()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then -- verify if unity is not recently dead
		print("CD SPELL : ",spell_4_CD)
		count_wolf()
		if invisible == false then
			spell_1_CD = reduce_CD(spell_1_CD)
		end
		if behavior == 1 then
			spell_4_CD = reduce_CD(spell_4_CD)
		end
		print("CD SPELL : ",spell_4_CD)
		spell_3_CD = reduce_CD(spell_3_CD)

		if spell_1_CD <= 0 and invisible == false then
			Spell_1()
		elseif spell_4_CD <= 0 and behavior == 1 and invisible == false then
			print("CD SPELL : ",spell_4_CD)
			Spell_2()
		elseif spell_3_CD <= 0 and immunity == false then
			Spell_3()
		end
		local hpp = thisEntity:GetHealth()/thisEntity:GetMaxHealth()
		local move_speed = math.log(GameRules.difficulty+10)/math.log(10) * 25+ (300/hpp) + 200
		if move_speed > 500 then move_speed = 500 end
		move_speed = move_speed - 150
		thisEntity:SetBaseMoveSpeed(move_speed)
		if hpp >= 0.25 and behavior == 1 then
			if reach_waypoints == true then
				join_next_point()
			else
				local V_Dif = Get_Next_Points()-thisEntity:GetAbsOrigin()
				if V_Dif:Length2D() <= 200 then
					reach_waypoints = true
				end
			end
		elseif hpp <= 0.25 and behavior == 1 then
			behavior = 2
			LinkLuaModifier( "boss_3_boost", "modifiers/boss_3_boost.lua", LUA_MODIFIER_MOTION_NONE )
			thisEntity:AddNewModifier(thisEntity, nil, "boss_3_boost", {})
			thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*0.5)
			thisEntity:SetHealth(thisEntity:GetMaxHealth())
			thisEntity:MoveToTargetToAttack(boss_target)
		else
			thisEntity:MoveToTargetToAttack(boss_target)
		end
		if thisEntity:IsAlive() then
			return THINK_TIME
		end
	end
end





function Get_Next_Points()
	local waypoints = Entities:FindByName( nil, "track_1_"..cur_pos )
	local waypoints_pos = waypoints:GetAbsOrigin()
	return waypoints_pos
end


function join_next_point()
	cur_pos = cur_pos + 1
	if cur_pos > WAY_POINTS_AMMOUNT then cur_pos = 1 end
	if math.random(1,5) == 1 then
		cur_pos = cur_pos + 1
		if cur_pos > WAY_POINTS_AMMOUNT then cur_pos = 1 end
	end
	waypoints_pos = Get_Next_Points()
	thisEntity:MoveToPosition(waypoints_pos)
	reach_waypoints = false
end
