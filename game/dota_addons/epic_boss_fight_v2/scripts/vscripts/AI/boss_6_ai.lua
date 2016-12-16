
--CUT CUT CUT CUT CUT CUT CUT CUT CUT CUT --

--spell 1 : seach for tree arround each player(search from higgest hpp to lowest hpp), if there is tree close enought , he will use timber chain to this tree damagin player btw
-- if health of the boss are <50% he'll use timber chain 3 time in a row except if he don't find tree
--spell 2 : Dance of Blade - Launch Timber Blade all around him , dancing along with him (if players are found arround)
--Spell 3 : Sniper Saw - Focus for 1 second, then release an deadly saw going at a high to a predicted player (random) position
--Spell 4 : Grow !Grow !little trees !!! - TimberSaw like to cut tree, so do he plant tree to cut more !! (instantly regrow all tree) -- ONLY ONE DO DONE YET (should be easy)


--special spell : if player keep geting away from tree, timber get angry and full the map with tree , tree maintain position for 30 seconds

--CUT CUT CUT CUT CUT CUT CUT CUT CUT CUT --

function _isUnitClose(radius,origin)
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



function _damagePercentAOE(origin,radius,percent,team,damageType,attacker)
	targets = FindUnitsInRadius(team,
												origin,
												nil,
												radius,
												DOTA_UNIT_TARGET_TEAM_ENEMY,
												DOTA_UNIT_TARGET_ALL,
												DOTA_UNIT_TARGET_FLAG_NONE,
												FIND_ANY_ORDER,
												false)

	for k,v in pairs(targets) do
		local damageTable = {
			victim = v,
			attacker = attacker,
			damage = v:GetMaxHealth()*(0.01*percent),
			damage_type = damageType,
		}
		ApplyDamage(damageTable)
	end
end

function _damageAOE(origin,radius,damage,team,damageType,attacker)
	targets = FindUnitsInRadius(team,
												origin,
												nil,
												radius,
												DOTA_UNIT_TARGET_TEAM_ENEMY,
												DOTA_UNIT_TARGET_ALL,
												DOTA_UNIT_TARGET_FLAG_NONE,
												FIND_ANY_ORDER,
												false)

	for k,v in pairs(targets) do
		local damageTable = {
			victim = v,
			attacker = attacker,
			damage = damage,
			damage_type = damageType,
		}
		ApplyDamage(damageTable)
	end
end

function _predictPlayerPos(player,projectile_time)


	--if player:IsMoving() then   -- THIS IS SUPPOSED TO WORK Y U HATE ME SO MUCH ?!
		local playerPos = player:GetAbsOrigin()
		local playerAdditionalMovement = player:GetForwardVector()*player:GetBaseMoveSpeed()*projectile_time

		return playerPos + playerAdditionalMovement
	--else
	--	return player:GetAbsOrigin()
	--end
end




function _timberSnipe(hTarget,reactionTime,radius)
	local updateTime = 0.03
	local vPosTarget = _predictPlayerPos(hTarget,reactionTime)
	local bladeEntity = boss_manager:Spawn_Boss("blade_1",thisEntity:GetAbsOrigin(),10)
	bladeEntity:SetAbsOrigin(thisEntity:GetAbsOrigin())
	local nTFX = ParticleManager:CreateParticle( "particles/shredder_chakram_ice.vpcf",  PATTACH_ABSORIGIN_FOLLOW   , bladeEntity )
	local vDiff = vPosTarget - bladeEntity:GetAbsOrigin()
	local time = 0
	Timers:CreateTimer(updateTime,function()
		if time<reactionTime*2 then
			local vMovement = ((vDiff/reactionTime) * updateTime) + ((((vDiff/vDiff:Length2D())*50)/reactionTime) * updateTime)
			bladeEntity:SetAbsOrigin(bladeEntity:GetAbsOrigin()+vMovement)
			_damagePercentAOE(bladeEntity:GetAbsOrigin(),radius,350*updateTime,DOTA_TEAM_BADGUYS,DAMAGE_TYPE_PHYSICAL,thisEntity)
			GridNav:DestroyTreesAroundPoint(bladeEntity:GetAbsOrigin(),radius,false)
			return updateTime
		else
			ParticleManager:DestroyParticle(nTFX,true)
			bladeEntity:SetRenderMode(10)
			bladeEntity:ForceKill(true)
		end
	end)
end

function _timberDance(bladeAmmount,radius,distance,duration)
	local partOneDuration = duration/5
	local partTwoDuration = duration/5 * 3
	local updateTime = 0.03
	for i=1,bladeAmmount do
			local time = 0
			local angleBlade = math.rad(360 / bladeAmmount * i)

			local bladeEntity = boss_manager:Spawn_Boss("blade_1",thisEntity:GetAbsOrigin(),10)

			local nTFX = ParticleManager:CreateParticle( "particles/shredder_chakram_ice.vpcf",  PATTACH_ABSORIGIN_FOLLOW   , bladeEntity )

			LinkLuaModifier( "immunity", "modifiers/immunity.lua", LUA_MODIFIER_MOTION_NONE )
			bladeEntity:AddNewModifier(bladeEntity, nil, "immunity", {duration = duration+1})
			startingPosition = thisEntity:GetAbsOrigin() + Vector(math.cos(angleBlade), math.sin(angleBlade), 0) * 50+Vector(0,0,50)
			bladeEntity:SetAbsOrigin(startingPosition)


			newAngleBlade = angleBlade
			Timers:CreateTimer(updateTime,function()
				if time <= duration then
					_damagePercentAOE(bladeEntity:GetAbsOrigin(),radius,30*updateTime,DOTA_TEAM_BADGUYS,DAMAGE_TYPE_PHYSICAL,thisEntity)
					GridNav:DestroyTreesAroundPoint(bladeEntity:GetAbsOrigin(),radius,false)
					return updateTime
				end
			end)


			--Part 1 movement
			Timers:CreateTimer(updateTime,function()
				time = time + updateTime
				newAngleBlade = math.rad(360 / bladeAmmount * i + 720*(time/duration) )

				if time <= partOneDuration then
					bladeEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(math.cos(newAngleBlade), math.sin(newAngleBlade), 0) * (distance*(time/partOneDuration)) + Vector(0,0,50))
					return updateTime
				elseif time <= partTwoDuration then
					bladeEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(math.cos(newAngleBlade), math.sin(newAngleBlade), 0) * (distance)+Vector(0,0,50))
					return updateTime
				elseif time <= duration then
					bladeEntity:SetAbsOrigin(thisEntity:GetAbsOrigin() + Vector(math.cos(newAngleBlade), math.sin(newAngleBlade), 0) * (distance + distance*(-0.5)*((time-partTwoDuration)/partOneDuration))+Vector(0,0,50))
					return updateTime
				else
					print("time destroy : " , time)
					ParticleManager:DestroyParticle(nTFX,true)
					bladeEntity:SetRenderMode(10)
					bladeEntity:ForceKill(true)
				end
			end)
	end

end

function updatePos(Entities,vectorMovement)
   Entities:SetAbsOrigin(Entities:GetAbsOrigin()+vectorMovement)
end

function _timberChain(targetPos,speed,radius)
	local vDiff = targetPos-thisEntity:GetAbsOrigin()
	local distance = vDiff:Length2D()
	local duration = distance/speed
	local updateTime = 0.03
	local percentPerUpdate = duration * 1/updateTime
	local time = 0

-- PLAY SOUND

	Timers:CreateTimer(updateTime,function()
		time = time + updateTime
		if time <= duration then
			local vectorMovement = vDiff/percentPerUpdate
			updatePos(thisEntity,vectorMovement)
			_damagePercentAOE(thisEntity:GetAbsOrigin(),radius,40*updateTime,DOTA_TEAM_BADGUYS,DAMAGE_TYPE_PHYSICAL,thisEntity)
			GridNav:DestroyTreesAroundPoint(thisEntity:GetAbsOrigin(),radius,false)
			return updateTime
		else
			FindClearSpaceForUnit(thisEntity, targetPos, false)
		end
  end)

	return duration
end


function _growRandomTree()
	local playersList = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              Vector(0, 0, 0),
                              nil,
                              FIND_UNITS_EVERYWHERE,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
	for k,v in pairs(playersList) do
		for i=0,20 do
				local playerPos = v:GetAbsOrigin()
				local offsetVector = Vector(RandomInt(-50,50)*(0.5i+0.5),RandomInt(-50,50)*(0.5i+0.5),0)
				CreateTempTree(playerPos+offsetVector, 6)
		end
	end
end

function _getRandomTreeNearPos(Position,radius)
 	local nearbyTree = 	GridNav:GetAllTreesAroundPoint(Position, radius, true)
	if #nearbyTree == 0 then
		return
	end
	return nearbyTree[math.random(0, #nearbyTree-1)]
end




require('libraries/timers')
require('libraries/animations')
THINK_TIME = 0.5
force_target = nil
CD_DIVISER = math.log(GameRules.difficulty+10)/math.log(10)
boss_state = "idle"
boss_target = nil
change_target_CD = 0

_noPlayerNearbyTreeTime = 0

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "change_target", change_target, 0.5 )
	thisEntity:SetContextThink( "Boss_think", Boss_think, THINK_TIME )
end


function change_target()
	change_target_CD = change_target_CD - 0.5
	if change_target_CD <=0 or boss_target ==nil or boss_target:IsAlive() == false then
		change_target_CD = math.random(5,10)
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

spell_1_CD = 10
spell_2_CD = 10
spell_3_CD = 0
spell_4_CD = 40
block_cd = false

function Spell_1(hpp)
	--timber chain
	spell_1_CD = 10
	if hpp >0.5 then
		local timberchainPos = _getRandomTreeNearPos(boss_target:GetAbsOrigin(),300)
		if timberchainPos ~= nil then
			timberchainPos = timberchainPos:GetAbsOrigin()
			_timberChain(timberchainPos,1200,400)
		end
	else
		targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
	                              Vector(0, 0, 0),
	                              nil,
	                              FIND_UNITS_EVERYWHERE,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		for k,target in pairs(targets) do
			if math.random(1, 2) == 1 then
				targets[k] = nil
			end
		end
		for k,target in pairs(targets) do
			if target ~= nil then
				Timers:CreateTimer(k*1,function()
					local timberchainPos = _getRandomTreeNearPos(target:GetAbsOrigin(),300):GetAbsOrigin()
					if timberchainPos ~= nil then
						timberchainPos = timberchainPos:GetAbsOrigin()
						local vDiff = timberchainPos - thisEntity:GetAbsOrigin()
						local fDiff = vDiff:Length2D()
						_timberChain(timberchainPos,vDiff,400)
					end
				end)
			end
		end

	end

end

function Spell_2(hpp)

	_timberDance(3 + math.floor((1-hpp)*10),250,800,3)
	spell_2_CD = 20

end

function Spell_3(hpp)

	spell_3_CD = 10

	if hpp >0.33 then
		_timberSnipe(boss_target,1.0,250)

	else
		targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
	                              Vector(0, 0, 0),
	                              nil,
	                              FIND_UNITS_EVERYWHERE,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		for k,target in pairs(targets) do
			if math.random(1, 3) == 1 then
				targets[k] = nil
			end
		end
		for k,target in pairs(targets) do
			if target ~= nil then
				Timers:CreateTimer(k*0.5,function()
					_timberSnipe(target:GetAbsOrigin(),1.0,250)
				end)
			end
		end

	end

end


function Spell_4()
	spell_4_CD = 60
	GridNav:RegrowAllTrees()
end

speCD = 0
function Boss_think()
	if thisEntity:IsAlive() or not thisEntity:IsNull() and boss_target then -- verify if unity is not recently dead
		spell_1_CD = reduce_CD(spell_1_CD)
		spell_2_CD = reduce_CD(spell_2_CD)
		spell_3_CD = reduce_CD(spell_3_CD)
		spell_4_CD = reduce_CD(spell_4_CD)

		speCD = reduce_CD(speCD)

		 local hpp = thisEntity:GetHealth()/thisEntity:GetMaxHealth() --if you want this boss to only cast spell when his hp is below an certain percent
		-- local move_speed = math.log(GameRules.difficulty+10)/math.log(10) * 25 + 300
		-- thisEntity:SetBaseMoveSpeed(move_speed) --if you want the boss to have his movespeed scale with difficulty
		if speCD <= 0 and _noPlayerNearbyTreeTime >= 5 then
			speCD = 20
			spell_1_CD = 0
			_growRandomTree()
		elseif spell_1_CD <= 0 then
			Spell_1(hpp)
		elseif spell_2_CD <= 0 and _isUnitClose(800,thisEntity:GetAbsOrigin()) then
			Spell_2(hpp)
		elseif spell_3_CD <= 0 then
			Spell_3(hpp)
		elseif spell_4_CD <= 0 then
			Spell_4()
		else
			thisEntity:MoveToTargetToAttack(boss_target)
		end
		if thisEntity:IsAlive() then
			return THINK_TIME
		end
	end
end
