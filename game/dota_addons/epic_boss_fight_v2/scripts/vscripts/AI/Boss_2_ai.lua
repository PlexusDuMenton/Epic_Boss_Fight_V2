require('libraries/timers')
require('libraries/animations')


function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "Boss_2_think", Boss_1_think, 0.25 )
	thisEntity:SetContextThink( "target_choose", target_choose, 0.2 )
end
CD_DIVISER = math.log(GameRules.difficulty+10)/math.log(10)
print(CD_DIVISER)
boss_state = "idle"
boss_target = nil
change_target_CD = 0
function change_target()
	boss_target = 
end

local form = 0


function Boss_2_think()
	if thisEntity:IsAlive() or not thisEntity:IsNull() then -- verify if unity is not recently dead
		local HPP = (thisEntity:GetHealth()/thisEntity:GetMaxHealth()) * 100

		if HPP < 25 and form == 0 then
			form = 1
			thisEntity:SetModel("models/items/lone_druid/true_form/form_of_the_atniw/form_of_the_atniw.vmdl") 
			thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetHealth(thisEntity:GetMaxHealth())
			thisEntity:SetBaseAttackTime(0.75)
		end
		return 0.5
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