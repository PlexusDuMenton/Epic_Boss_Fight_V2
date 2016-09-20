require('libraries/timers')
require('libraries/animations')
THINK_TIME = 0.5
force_target = nil
CD_DIVISER = math.log(GameRules.difficulty+10)/math.log(10)
boss_state = "idle"
boss_target = nil
change_target_CD = 0


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

spell_1_CD = 0
spell_2_CD = 0
spell_3_CD = 0

function Boss_think()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then -- verify if unity is not recently dead
		spell_1_CD = reduce_CD(spell_1_CD)
		spell_2_CD = reduce_CD(spell_2_CD)
		spell_3_CD = reduce_CD(spell_3_CD)

		-- local hpp = thisEntity:GetHealth()/thisEntity:GetMaxHealth() --if you want this boss to only cast spell when his hp is below an certain percent
		-- local move_speed = math.log(GameRules.difficulty+10)/math.log(10) * 25 + 300
		-- thisEntity:SetBaseMoveSpeed(move_speed) --if you want the boss to have his movespeed scale with difficulty

		if spell_1_CD <= 0 then
			Spell_1()
		elseif spell_2_CD <= 0 then
			Spell_2()
		elseif spell_3_CD <= 0 then
			Spell_3()
		else
			thisEntity:MoveToTargetToAttack(boss_target)
		end
		if thisEntity:IsAlive() then
			return THINK_TIME
		end
	end
end
