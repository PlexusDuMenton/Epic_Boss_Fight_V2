if boss_manager == nil then
	boss_manager = class({})
end

MAINISDEAD = true
SECONDARYAREDEAD = true
NUMBER_OF_SPAWN_POINTS = 4
boss_manager.Alive_Ennemy = 0
require( "libraries/Timers" )
require("internal/util")

function boss_manager:Start()
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( boss_manager, "OnEntityKilled" ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( boss_manager, "OnSpawn" ), self )
	boss_manager.Boss_Info = LoadKeyValues("scripts/kv/boss_info.kv")
	local Boss_Tracked = nil
	Timers:CreateTimer(1.00,function()
		if GameRules.STATES ~= GAME_STATE_ENDSCREEN then
			if Boss_Tracked == nil or Boss_Tracked:IsNull() ~= false or Boss_Tracked:GetHealth() == 0 then
					local boss_to_track = nil
					if GameRules.STATES == GAME_STATE_FIGHT then
						local higgest_hp = 0
						local priority = "nul"
						for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
							if unit:GetHealth()>0 then
								if unit.Is_Main == true then
									if priority ~= "main" then
										priority = "main"
										higgest_hp = unit:GetMaxHealth()
										boss_to_track = unit
									else
										if unit:GetMaxHealth() > higgest_hp then
											higgest_hp = unit:GetMaxHealth()
											boss_to_track = unit
										end
									end
								elseif unit.Is_Secondary == true then
									if priority ~= "second" and priority ~= "main" then
										priority = "second"
										higgest_hp = unit:GetMaxHealth()
										boss_to_track = unit
									elseif priority == "second" then
										if unit:GetMaxHealth() > higgest_hp then
											higgest_hp = unit:GetMaxHealth()
											boss_to_track = unit
										end
									end
								else
									if priority ~= "second" and priority ~= "main" then
										if unit:GetMaxHealth() > higgest_hp then
											higgest_hp = unit:GetMaxHealth()
											boss_to_track = unit
										end
										if priority == "nul" then priority = "low" end
									end
								end
							end
						end
					end
					Boss_Tracked = boss_to_track
			end
			if GameRules.STATES == GAME_STATE_FIGHT then
				if Boss_Tracked ~= nil and Boss_Tracked:IsNull() == false and Boss_Tracked:GetHealth() > 0 then
					local cat
					if Boss_Tracked.Is_Main == true then 
						cat = "main"
					elseif Boss_Tracked.Is_Secondary == true then 
						cat = "second"
					else
						cat = nil
					end
					CustomNetTables:SetTableValue( "info","boss", {CAT = cat ,name = Boss_Tracked:GetUnitName() , HP = Boss_Tracked:GetHealth() , MAXHP = Boss_Tracked:GetMaxHealth() } )
				else
					print ("boss no longer exist or is null or simply dead without anyother boss alive")
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
	end)
	for i=0,PlayerResource:GetPlayerCount()-1 do
     	 local player = PlayerResource:GetPlayer(i)
      	local hero = player:GetAssignedHero()
      	if hero.Level < GameRules.Actual_Max_Level*0.95 - 10 then
      		hero.XP = hero.XP + (killed_unit.XP * (hero.Level/GameRules.Actual_Max_Level))
    	else
     		hero.XP = hero.XP + killed_unit.XP
    	end
    	if killed_unit.Is_Main == true or killed_unit.Is_Secondary == true then
      		hero:ModifyGold(killed_unit.Gold, true,  DOTA_ModifyGold_Unspecified ) 
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

function boss_manager:OnSpawn(event)
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit:IsCreature() or spawnedUnit:GetTeam()~=DOTA_TEAM_BADGUYS then
		return
	end
	local diff_mult = GameRules.difficulty
	spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth() * diff_mult^1.25 +10 )
	spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
	local damagemin = spawnedUnit:GetBaseDamageMin() * (diff_mult^1.05) - 2
	local damagemax = spawnedUnit:GetBaseDamageMax() * (diff_mult^1.25) - 3
	if damagemin <= 0 then damagemin = 1 end
	if damagemax <= 0 then damagemax = 1 end
	spawnedUnit:SetBaseDamageMin(damagemin )
	spawnedUnit:SetBaseDamageMax(damagemax )
	spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue()-1) *  (1+math.log(diff_mult)/math.log(2)))
	spawnedUnit:SetBaseHealthRegen((spawnedUnit:GetBaseHealthRegen()) * (diff_mult^0.8) - 1)
	spawnedUnit.XP = spawnedUnit:GetDeathXP()* (1+math.log(GameRules.loot_multiplier)/math.log(2))
	boss_manager.Alive_Ennemy = boss_manager.Alive_Ennemy + 1
	print(spawnedUnit:GetUnitName())
	if boss_manager.Boss_Info[spawnedUnit:GetUnitName()].Is_Main == 1 then
		spawnedUnit.Is_Main = true
		print ("boss is main")
		spawnedUnit.Gold = spawnedUnit:GetMaximumGoldBounty() * (1+math.log(  GameRules.loot_multiplier)/math.log(10))
		spawnedUnit:SetMaximumGoldBounty( 0 ) 
		spawnedUnit:SetMinimumGoldBounty( 0 ) 
	elseif boss_manager.Boss_Info[spawnedUnit:GetUnitName()].Is_Secondary == 1 then
		spawnedUnit.Is_Secondary = true
		spawnedUnit.Gold = spawnedUnit:GetMaximumGoldBounty() * (1+math.log(  GameRules.loot_multiplier)/math.log(10))
		print ("boss is secondary")
	else
		spawnedUnit.Gold = spawnedUnit:GetMaximumGoldBounty() * (1+math.log(  GameRules.loot_multiplier)/math.log(10))
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
		for i = 1 ,v.number do
			local boss = boss_manager:Spawn_Boss(k,nil,50)
		end
	end
	print(boss_manager.Alive_Ennemy)
	Timers:CreateTimer(1.00,function()
		round_manager.Round_Started = true
	end)
end