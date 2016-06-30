if boss_manager == nil then
	boss_manager = class({})
end
XP_M = {}
XP_M[0] = 1
XP_M[1] = 1.2
XP_M[2] = 1.4
XP_M[3] = 1.6
XP_M[4] = 1.8
XP_M[5] = 2.0
XP_M[6] = 2.5

MAINISDEAD = true
SECONDARYAREDEAD = true
NUMBER_OF_SPAWN_POINTS = 4
boss_manager.Alive_Ennemy = 0
boss_manager.Core_Ennemy = 0
require( "libraries/Timers" )
require("internal/util")

function boss_manager:Start()
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( boss_manager, "OnEntityKilled" ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( boss_manager, "OnSpawn" ), self )
	boss_manager.Boss_Info = LoadKeyValues("scripts/kv/boss_info.kv")
	local Boss_Tracked = nil
	Timers:CreateTimer(1.00,function()
		if GameRules.STATES ~= GAME_STATE_ENDSCREEN then
					local higgest_hp_unit = nil
					local lowest_hp_unit = nil
					if GameRules.STATES == GAME_STATE_FIGHT then
						local higgest_hp = 0
						local lowest_hpp = 1.1
						local priority = "nul"
						for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
							if unit:GetHealth()>0 then
								if unit.Is_Main == true then
									if priority ~= "main" then
										priority = "main"
										higgest_hp = unit:GetMaxHealth() * unit.EHP_MULT
										lowest_hpp = unit:GetHealth()/unit:GetMaxHealth()
										higgest_hp_unit = unit
										lowest_hp_unit = unit
									else
										if unit:GetMaxHealth() * unit.EHP_MULT > higgest_hp then
											higgest_hp = unit:GetMaxHealth()
											higgest_hp_unit = unit
										end
										if unit:GetHealth()/unit:GetMaxHealth() < lowest_hpp and unit:GetHealth()<unit:GetMaxHealth() and unit:GetHealth()>0 then
											lowest_hpp = unit:GetHealth()/unit:GetMaxHealth()
											lowest_hp_unit = unit
										end
									end
								elseif unit.Is_Secondary == true then
									if priority ~= "second" and priority ~= "main" then
										priority = "second"
										higgest_hp = unit:GetMaxHealth() * unit.EHP_MULT
										lowest_hpp = unit:GetHealth()/unit:GetMaxHealth()
										higgest_hp_unit = unit
										lowest_hp_unit = unit
									elseif priority == "second" then
										if unit:GetMaxHealth() * unit.EHP_MULT > higgest_hp then
											higgest_hp = unit:GetMaxHealth() * unit.EHP_MULT
											higgest_hp_unit = unit
										end
										if unit:GetHealth()/unit:GetMaxHealth() < lowest_hpp and unit:GetHealth()<unit:GetMaxHealth() and unit:GetHealth()>0 then
											lowest_hpp = unit:GetHealth()/unit:GetMaxHealth()
											lowest_hp_unit = unit
										end
									end
								else
									if priority ~= "second" and priority ~= "main" then
										if unit:GetMaxHealth() * unit.EHP_MULT > higgest_hp then
											higgest_hp = unit:GetMaxHealth() * unit.EHP_MULT
											lowest_hpp = unit:GetHealth()/unit:GetMaxHealth()
											higgest_hp_unit = unit
										end
										if unit:GetHealth()/unit:GetMaxHealth() < lowest_hpp and unit:GetHealth()<unit:GetMaxHealth() and unit:GetHealth()>0 then
											lowest_hpp = unit:GetHealth()/unit:GetMaxHealth()
											lowest_hp_unit = unit
										end
										if priority == "nul" then priority = "low" end
									end
								end
							end
						end
					end
					if lowest_hp_unit == nil then
						Boss_Tracked = higgest_hp_unit
					else
						Boss_Tracked = lowest_hp_unit
					end
			if GameRules.STATES == GAME_STATE_FIGHT then
				if Boss_Tracked ~= nil and Boss_Tracked:IsNull() == false and Boss_Tracked:GetHealth() > 0 then
					local cat = nil
					if Boss_Tracked.Is_Main == true then 
						cat = "main"
					elseif Boss_Tracked.Is_Secondary == true then 
						cat = "second"
					end
					CustomNetTables:SetTableValue( "info","boss", {CAT = cat ,name = Boss_Tracked:GetUnitName() , HP = Boss_Tracked:GetHealth() , MAXHP = Boss_Tracked:GetMaxHealth() ,EHP_MULT = Boss_Tracked.EHP_MULT} )
				else
					CustomNetTables:SetTableValue( "info","boss", {HP = 0 } )
				end
			else
				CustomNetTables:SetTableValue( "info","boss", {HP = 0 } )
			end
			return 0.025
		end
	end)
end

function boss_manager:OnEntityKilled(event)
	print ("entity killed")
	local killed_unit = EntIndexToHScript( event.entindex_killed )
	if not killed_unit:IsCreature() or killed_unit:GetTeam()~=DOTA_TEAM_BADGUYS then
		return
	end
	Timers:CreateTimer(1.00,function()
		boss_manager.Alive_Ennemy = boss_manager.Alive_Ennemy - 1
		if killed_unit.Is_Main == true then
			boss_manager.Core_Ennemy = boss_manager.Core_Ennemy - 1
		end
		print(boss_manager.Alive_Ennemy,boss_manager.Core_Ennemy)
	end)
	for i=0,PlayerResource:GetPlayerCount()-1 do
     	 local player = PlayerResource:GetPlayer(i)
      	local hero = player:GetAssignedHero()
      	if hero.Level < GameRules.Actual_Max_Level*0.95 - 10 then
      		local xp_to_gain = killed_unit.XP * (hero.Level/(GameRules.Actual_Max_Level^1.57))
      		hero.XP = hero.XP + xp_to_gain
    	else
     		hero.XP = hero.XP + killed_unit.XP
    	end
    	if killed_unit.Is_Main == true or killed_unit.Is_Secondary == true then
    		hero.gold = math.ceil(hero.gold + killed_unit.Gold)
    	end
    	epic_boss_fight:Check_Hero_lvlup(hero)
    end
    if killed_unit.Spawn_Unit_On_Death == true then
    	for k,v in pairs (killed_unit.On_Death) do
    		for i = 1,v.number do
    			boss_manager:Spawn_Boss(k,killed_unit:GetAbsOrigin(),500)
    		end
    	end
    end
    if killed_unit:IsRealHero() then
    	local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
		newItem:SetPurchaseTime( 0 )
		newItem:SetPurchaser( killedUnit )
		local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
		tombstone:SetContainedItem( newItem )
		tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
		FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )	
	end
end

function simualteHP(EHP_GOAL,HP) --you enter the current HP
	local Bonus_Armor = (EHP_GOAL/(HP)-1)/0.06
	return Bonus_Armor
end

function boss_manager:OnSpawn(event)
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit:IsCreature() or spawnedUnit:GetTeam()~=DOTA_TEAM_BADGUYS then
		return
	end
	local diff_mult = GameRules.difficulty
	local damagemin = spawnedUnit:GetBaseDamageMin() * (diff_mult^1.15) - 1
	local damagemax = spawnedUnit:GetBaseDamageMax() * (diff_mult^1.25) - 1
	if damagemin <= 0 then damagemin = 1 end
	if damagemax <= 0 then damagemax = 1 end
	spawnedUnit:SetBaseDamageMin(damagemin )
	spawnedUnit:SetBaseDamageMax(damagemax )

	local EHP = (spawnedUnit:GetMaxHealth() * diff_mult^1.25 +10 )
	if EHP > 999999 then
		spawnedUnit:SetMaxHealth(999999)
		local armor = simualteHP(EHP,999999)
		spawnedUnit:SetPhysicalArmorBaseValue(armor)
		spawnedUnit.EHP_MULT = (EHP/999999)
		local Mag_Ress = 1 - ((1-spawnedUnit:GetBaseMagicalResistanceValue())/(EHP/999999)) 
		spawnedUnit:SetBaseMagicalResistanceValue(Mag_Ress)
	else
		spawnedUnit:SetMaxHealth(EHP)
		spawnedUnit.EHP_MULT = 1
		spawnedUnit:SetPhysicalArmorBaseValue(0)
	end
	spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())

	spawnedUnit:SetBaseHealthRegen((spawnedUnit:GetBaseHealthRegen()) * (diff_mult^0.8) - 1)
	spawnedUnit.XP = math.floor(((spawnedUnit:GetDeathXP() *(GameRules.loot_multiplier*0.5) * XP_M[GameRules.player_difficulty])^1.1)/1.34)
	print (spawnedUnit.XP,GameRules.loot_multiplier)
	boss_manager.Alive_Ennemy = boss_manager.Alive_Ennemy + 1
	if boss_manager.Boss_Info[spawnedUnit:GetUnitName()].Is_Main == 1 then
		spawnedUnit.Is_Main = true
		spawnedUnit.Gold = math.ceil(spawnedUnit:GetMaximumGoldBounty() * (1+math.log(  GameRules.loot_multiplier)/math.log(10)))
		spawnedUnit:SetMaximumGoldBounty( 0 ) 
		spawnedUnit:SetMinimumGoldBounty( 0 ) 
	elseif boss_manager.Boss_Info[spawnedUnit:GetUnitName()].Is_Secondary == 1 then
		spawnedUnit.Is_Secondary = true
		spawnedUnit.Gold = math.ceil(spawnedUnit:GetMaximumGoldBounty() * (1+math.log(  GameRules.loot_multiplier)/math.log(10)))
	else
		spawnedUnit.Gold = math.ceil(spawnedUnit:GetMaximumGoldBounty() * (1+math.log(  GameRules.loot_multiplier)/math.log(10)))
		spawnedUnit:SetMaximumGoldBounty( 0 ) 
		spawnedUnit:SetMinimumGoldBounty( 0 ) 
	end
	local INFO = LoadKeyValues("scripts/kv/boss_round.kv")[tostring(round_manager.round)][spawnedUnit:GetUnitName()]
		if INFO ~= nil and INFO.On_Death ~= nil then 
			spawnedUnit.Spawn_Unit_On_Death = true
			spawnedUnit.On_Death = INFO.On_Death
		end
	spawnedUnit:SetDeathXP(0) 

end

function boss_manager:Spawn_Boss(boss_name,origin,radius)
	if radius == nil then radius = 400 end
	if origin == nil then origin = boss_manager:Set_Spawn_Point() end
	if boss_name == nil then 
		print ("Boss Name is not defined")
		return nil
	end
    print   ("spawn unit : "..boss_name)
    PrecacheUnitByNameAsync( boss_name, function() 
	    CreateUnitByName( boss_name ,origin + RandomVector(RandomInt(radius,radius)), true, nil, nil, DOTA_TEAM_BADGUYS ) 
	    end,
    nil)
end

function boss_manager:Set_Spawn_Point()
	local spawn_number = math.random(1,NUMBER_OF_SPAWN_POINTS)
	local spawnerent = Entities:FindByName( nil, "spawner"..spawn_number )
	print ("spawn number : ",spawn_number)
	return spawnerent:GetAbsOrigin()
end


function boss_manager:Start_Round(Round_Number)
	local round_table = LoadKeyValues("scripts/kv/boss_round.kv")[tostring(Round_Number)]
	for k,v in pairs(round_table) do
		local number = v.number
		if v.cap ~= nil then
			if GameRules.difficulty > v.cap then number = v.cap_ammount end
		end
		boss_manager.Core_Ennemy = boss_manager.Core_Ennemy + number
		for i = 1 ,number do
			Timers:CreateTimer((i-1)*v.timer,function()
				if GameRules.STATES == GAME_STATE_FIGHT and Round_Number == round_manager.round then
					local boss = boss_manager:Spawn_Boss(k,nil,50)
				end
			end)
		end
	end
	Timers:CreateTimer(1.00,function()
		round_manager.Round_Started = true
	end)
end