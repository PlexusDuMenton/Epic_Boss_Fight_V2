GAME_STATE_LOADING = 0 --have no use for now
GAME_STATE_LOBBY = 1
GAME_STATE_PREPARE_TIME = 2
GAME_STATE_FIGHT = 3
GAME_STATE_REWARD = 4
GAME_STATE_ENDSCREEN = 5

ROUND_MAX = 0

for k,v in pairs(LoadKeyValues("scripts/kv/boss_round.kv")) do
	ROUND_MAX = ROUND_MAX + 1
end
print (ROUND_MAX)



LOBBY_VECTOR = Vector(2000,-5500,0)
ARENA_VECTOR = Vector(-1000,1750,0)

DEFAULT_COUNTDOWN_TIME = 12.5 --seconde
VOTE_TIME_REWARD = 10
ONTHING_REFRESH_TIME = 0.1

if round_manager == nil then
    DebugPrint( 'created Round Manager' )
    _G.round_manager = class({})
end



round_manager.countdown_10 = false
round_manager.countdown_3 = false
round_manager.Round_Started = false
round_manager.vote = false
round_manager.lobby_vote = false
round_manager.result_lobby = 0
round_manager.result_next = 0
round_manager.countdown = DEFAULT_COUNTDOWN_TIME
round_manager.round = 1

function round_manager:play_music_round(round)
	print("play another music")
	round = tostring(round)
	local music = LoadKeyValues("scripts/kv/round_music.kv")[round]
	if music == "Sound.Music.1" then
		local rand = math.random(1,3)
		if rand == 1 then
			music = "Sound.Music.1_alt_1"
		elseif rand == 2 then
			music = "Sound.Music.1_alt_2"
		end
	end
	CustomGameEventManager:Send_ServerToAllClients( "play_music", {music = music} )
end

function round_manager:OnThink()
	--if GameRules.STATES == GAME_STATE_LOADING then
		--do nothing , maybe later
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if GameRules.STATES == GAME_STATE_LOBBY then
			round_manager:Regen_Player()
			if round_manager.vote == false then
				round_manager.vote = true
				round_manager:Vote_next("lobby")
			end
		elseif GameRules.STATES == GAME_STATE_PREPARE_TIME then
			if round_manager.countdown <= 0 then
				round_manager.countdown_10 = false
				round_manager.countdown_3 = false
				round_manager:play_music_round(round_manager.round)
				GameRules.STATES = GAME_STATE_FIGHT
				round_manager.countdown = DEFAULT_COUNTDOWN_TIME
				boss_manager:Start_Round(round_manager.round)
				--spawn ennemy
			else
				round_manager.countdown = round_manager.countdown - ONTHING_REFRESH_TIME
				if round_manager.countdown <= 10 and round_manager.countdown_10 == false then
					round_manager.countdown_10 = true
					CustomGameEventManager:Send_ServerToAllClients("play_sound", {music = "Sound.Game.CountDown"} )
				end
				if round_manager.countdown <= 1 and round_manager.countdown_3 == false then
					round_manager.countdown_3 = true
					CustomGameEventManager:Send_ServerToAllClients("play_sound", {music = "Sound.Game.Prepare"} )
					epic_boss_fight:update_difficulty()
				end
				CustomNetTables:SetTableValue( "KVFILE","time", { countdown = round_manager.countdown } )
			end
			--set hp to max , revive if dead , update counter , when done , go into next round
		elseif GameRules.STATES == GAME_STATE_FIGHT then
			--check if deafeat , check if victory
			round_manager:Check_For_Victory()
			round_manager:Check_For_Defeat()
		elseif GameRules.STATES == GAME_STATE_REWARD then
			if round_manager.vote == false then
				round_manager:Regen_Player()
				round_manager.vote = true
				Timers:CreateTimer(5.00,function()
					round_manager:Vote_next("reward")
				end)
			end
		elseif GameRules.STATES == GAME_STATE_ENDSCREEN then
			return nil
		end
	end
	return ONTHING_REFRESH_TIME
end

function round_manager:Check_For_Defeat()
	if GameRules.STATES ~= GAME_STATE_FIGHT then
		return
	end
	local Lose = true
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:GetConnectionState(nPlayerID) == 2 then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero~= nil and hero:IsAlive() then
					Lose = false
				end
			end
		end
	end
	if Lose == true then
		CustomGameEventManager:Send_ServerToAllClients("play_sound", {music = "Sound.Game.Defeated"} )
		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then

					local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
					if PlayerResource:GetConnectionState(nPlayerID) == 2 then
						if hero~= nil then
							if PlayerResource:HasCustomGameTicketForPlayerID( nPlayerID ) == false then
								hero.XP = hero.XP-(Get_Xp_To_Next_Level(hero.Level)*0.02)
							else
								hero.XP = hero.XP-(Get_Xp_To_Next_Level(hero.Level)*0.01)
							end
							FindClearSpaceForUnit(hero, LOBBY_VECTOR, true)
							statCollection:submitRound(DOTA_TEAM_BADGUYS,false)
							Timers:CreateTimer(0.1,function()
								CustomGameEventManager:Send_ServerToAllClients("center_on_hero", {} )
							end)
							round_manager.Round_Started = false
							round_manager:Regen_Player()
							for _,unit in pairs ( Entities:FindAllByName( "npc_dota_creature")) do
								if unit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
									unit.XP = 0
									unit.Gold = math.ceil(unit.Gold/3)
									unit.Spawn_Unit_On_Death = false
									unit.On_Death = nil
									unit:ForceKill(true)
								end
							end
							--kill all bosses/ennemies
							round_manager.round = 1
							GameRules.STATES = GAME_STATE_LOBBY
							round_manager:play_music_round("lobby")
							FindClearSpaceForUnit(hero,LOBBY_VECTOR, true)
							Timers:CreateTimer(0.1,function()
								CustomGameEventManager:Send_ServerToAllClients("center_on_hero", {} )
							end)
						end
					end
				end
		end
	end
end

function round_manager:Check_For_Victory()
	if GameRules.STATES ~= GAME_STATE_FIGHT then
		return
	end
	if boss_manager.Alive_Ennemy == 0 and round_manager.Round_Started == true and boss_manager.Core_Ennemy == 0 then
		round_manager:Regen_Player()
		round_manager.Round_Started = false
		print ("Round is finished")
		if round_manager.round >= ROUND_MAX then
			GameRules.STATES = GAME_STATE_LOBBY
			round_manager:play_music_round("lobby")
			statCollection:submitRound(DOTA_TEAM_GOODGUYS,false)
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:GetConnectionState(nPlayerID) == 2 then
					local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
					if hero~= nil then
						FindClearSpaceForUnit(hero, LOBBY_VECTOR, true)
						Timers:CreateTimer(0.1,function()
							CustomGameEventManager:Send_ServerToAllClients("center_on_hero", {} )
						end)
					end
				end
			end
			round_manager.round = 1
			CustomGameEventManager:Send_ServerToAllClients("play_sound", {music = "Sound.Game.Victory"} )
			round_manager:reward_final()
		else
			GameRules.STATES = GAME_STATE_REWARD
			CustomGameEventManager:Send_ServerToAllClients("play_sound", {music = "Sound.Game.Victory_round"} )
			round_manager:reward()
		end
	end
end

function round_manager:Regen_Player()
	if GameRules.STATES == GAME_STATE_FIGHT then
		return
	end
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetConnectionState(nPlayerID) == 2 then
			local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
			if hero~= nil then
				if not hero:IsAlive() then
					hero:RespawnHero(false, false, false)
				end
				hero:SetHealth( hero:GetMaxHealth() )
				hero:SetMana( hero:GetMaxMana() )
			end
		end
	end
end


function round_manager:Vote_next(context)
	if context == "lobby" then
		CustomGameEventManager:Send_ServerToAllClients("Ready_Votes", {} )
		--check if half+1 players are ready : statscountdown from 60 sec , each player ready decrease the countdown
	end
	if context == "reward" then
		round_manager.round = round_manager.round +1
		if round_manager.round > ROUND_MAX then
			Timers:CreateTimer(1.00,function()
				CustomGameEventManager:Send_ServerToAllClients("Hide_Reward", {} )
				round_manager.round = 1
				GameRules.STATES = GAME_STATE_LOBBY
				round_manager:play_music_round("lobby")
				FindClearSpaceForUnit(hero,LOBBY_VECTOR, true)
				Timers:CreateTimer(0.1,function()
					CustomGameEventManager:Send_ServerToAllClients("center_on_hero", {} )
					end)
			end)
		else
			CustomGameEventManager:Send_ServerToAllClients("next_votes", {} )
				round_manager.vote_time = VOTE_TIME_REWARD
				round_manager.result_lobby = 0
				round_manager.result_next = 0
				CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = round_manager.vote_time } )
				Timers:CreateTimer(1.00,function()
					round_manager.vote_time = round_manager.vote_time - 1
					CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = round_manager.vote_time } )
					if round_manager.vote_time <= 0 then
				    	CustomGameEventManager:Send_ServerToAllClients("Stop_Vote", {} )
				    	CustomGameEventManager:Send_ServerToAllClients("Hide_Reward", {} )
				    	round_manager.vote = false
				    	--hide reward screen
				    	if round_manager.result_lobby >= round_manager.result_next then
				    		for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
								if PlayerResource:GetConnectionState(nPlayerID) == 2 then
										local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
										if hero~= nil then
											FindClearSpaceForUnit(hero,LOBBY_VECTOR, true)
											Timers:CreateTimer(0.1,function()
												CustomGameEventManager:Send_ServerToAllClients("center_on_hero", {} )
												end)
										end
								end
							end
							GameRules.STATES = GAME_STATE_LOBBY
							round_manager:play_music_round("lobby")
						else
							for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
								if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
									if PlayerResource:GetConnectionState(nPlayerID) == 2 then
										local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
										if hero~= nil then
											FindClearSpaceForUnit(hero,ARENA_VECTOR, true)
											Timers:CreateTimer(0.1,function()
												CustomGameEventManager:Send_ServerToAllClients("center_on_hero", {} )
												end)
										end
									end
								end
							end
							print ("going to prepare time from vote why dont you play other sound §")
							GameRules.STATES = GAME_STATE_PREPARE_TIME
						end
						CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = nil } )
						return
				    end
				    return 1
				end)
		end
		--after 45 sec , a vote menu apear to either continue or going to lobby , vote are counted after 45 sec if not all had voted , if no one has voted , the game will return to lobby , if the both are voted half/half , game will go to lobby
	end
end

function round_manager:Get_potion_Reward(Max_Chance,Table)
	local item_chance = math.random(1,Max_Chance)
	local chance = 0
	for k,v in pairs(Table) do
			if item_chance <= (v+chance) then
				return k
			else
				chance = v + chance
			end
	end
	print ("Error in function Get_Reward : ",Max_Chance , " Max change , ",Table," table")
end

function round_manager:Get_Reward(Table)
	DeepPrintTable(Table)
	local Max_Chance = 0
	for k,v in pairs(Table) do
			Max_Chance = v.chance + Max_Chance
	end
	local item_chance = math.random(1,Max_Chance)
	local chance = 0
	for k,v in pairs(Table) do
			if item_chance <= (v.chance+chance) then
				return k
			else
				chance = v.chance + chance
			end
	end
	print ("Error in function Get_Reward : ",Max_Chance , " Max change , ",Table," table")
end

function round_manager:reward_final()
	for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( i ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( i ) then
		        local hero = PlayerResource:GetSelectedHeroEntity(i)
		        if hero~=nil then
		          if hero.inventory ~= nil then
		            if PlayerResource:GetConnectionState(i) == 2 then
		              	GameRules.PlayerAmmount = 1 + GameRules.PlayerAmmount
										local item_reward = nil
										local loot_multiplier = GameRules.loot_multiplier * 3
										if hero.Level < GameRules.Actual_Max_Level*0.95 - 10 then
											loot_multiplier = math.ceil(loot_multiplier * (hero.Level/GameRules.Actual_Max_Level)^1.4)
										end
										local round = round_manager.round
										local ammount = math.ceil(0.5*(math.random(1,10)) + 1)
										local potion_table = LoadKeyValues("scripts/kv/drop_table.kv")["potions"]
										local potion_list = nil
										for k,v in pairs(potion_table) do
											print(k)
											if loot_multiplier>=tonumber(k) then
												potion_list = v
											end
										end
										local max_chance = 0
										for k,v in pairs(potion_list) do
											max_chance = v + max_chance
										end
										item_reward_1 = round_manager:Get_potion_Reward(max_chance,potion_list) --name
										local item_table = LoadKeyValues("scripts/kv/drop_table.kv")["equipement"]
										local item_table_alt = LoadKeyValues("scripts/kv/drop_table.kv")[round_manager.round]
										local item_list = {}
										for k,v in pairs(item_table) do
												if loot_multiplier >= v.LM and v.LM >= (loot_multiplier*0.50 - 7)  then
													print (k,loot_multiplier,v.LM,(loot_multiplier*0.50 - 7))
													item_list[k] = v
												end
											end
											if item_table_alt ~= nil then
												for k,v in pairs(item_table_alt) do
													if loot_multiplier >= v.LM then
															item_list[k] = v
													end
												end
											end
											local list_size = 0
											for k,v in pairs(item_list) do
												list_size = list_size +1
											end
											if list_size == 0 then
												for k,v in pairs(item_table) do
													if loot_multiplier >= v.LM then
														item_list[k] = v
													end
												end
											end
										item_reward_2 = round_manager:Get_Reward(item_list) --name
										item_reward_3 = "item_power_soul"

										print (item_reward_1)
										print (item_reward_2)
										print (item_reward_3)
										item_handle_1 = epic_boss_fight:_CreateItem(item_reward_1,hero)
										inv_manager:Add_Item(hero,item_handle_1)
										item_handle_2 = epic_boss_fight:_CreateItem(item_reward_2,hero)
										inv_manager:Add_Item(hero,item_handle_2)
										item_handle_3 = epic_boss_fight:_CreateItem(item_reward_3,hero)
										inv_manager:Add_Item(hero,item_handle_3)
										save(hero)
										CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "super_reward", {item_1=item_handle_1,item_2=item_handle_2,item_3=item_handle_3} )

										--display 3-reward panel
									end
		          end
		        end
		    end
		end
	end
end


function round_manager:reward()
	for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( i ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( i ) then
		        local hero = PlayerResource:GetSelectedHeroEntity(i)
		        if hero~=nil then
		          if hero.inventory ~= nil then
		            if PlayerResource:GetConnectionState(i) == 2 then
		              	GameRules.PlayerAmmount = 1 + GameRules.PlayerAmmount

									local item_reward = nil
									local loot_multiplier = GameRules.loot_multiplier
									if hero.Level < GameRules.Actual_Max_Level*0.95 - 10 then
										loot_multiplier = math.ceil(loot_multiplier * (hero.Level/GameRules.Actual_Max_Level)^1.4)
									end
									local round = round_manager.round
									local loot_number = math.random(1,100)
									if loot_number >= 80 then --potion stack
										local ammount = math.ceil(0.5*(loot_number -90) + 1)
										local potion_table = LoadKeyValues("scripts/kv/drop_table.kv")["potions"]
										local potion_list = nil
										for k,v in pairs(potion_table) do
											print(k)
											if loot_multiplier>=tonumber(k) then
												potion_list = v
											end
										end
										local max_chance = 0
										for k,v in pairs(potion_list) do
											max_chance = v + max_chance
										end
										item_reward = round_manager:Get_potion_Reward(max_chance,potion_list) --name

									elseif loot_number >= 20 then --normal equipement
										local item_table = LoadKeyValues("scripts/kv/drop_table.kv")["equipement"]
										local item_table_alt = LoadKeyValues("scripts/kv/drop_table.kv")[round_manager.round]
										local item_list = {}
										for k,v in pairs(item_table) do
											if loot_multiplier >= v.LM and v.LM >= (loot_multiplier*0.50 - 7)  then
												print (k,loot_multiplier,v.LM,(loot_multiplier*0.50 - 7))
												item_list[k] = v
											end
										end
										if item_table_alt ~= nil then
											for k,v in pairs(item_table_alt) do
												if loot_multiplier >= v.LM then
														item_list[k] = v
												end
											end
										end
										local list_size = 0
										for k,v in pairs(item_list) do
											list_size = list_size +1
										end
										if list_size == 0 then
											for k,v in pairs(item_table) do
												if loot_multiplier >= v.LM then
													item_list[k] = v
												end
											end
										end
										item_reward = round_manager:Get_Reward(item_list) --name
									else --power souls
										item_reward = "item_power_soul"
									end

									print (item_reward)
									item_handle = epic_boss_fight:_CreateItem(item_reward,hero)
									inv_manager:Add_Item(hero,item_handle)
									save(hero)
									CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "reward", {item=item_handle} )
								end
		          end
		        end
		    end
		end
	end
end
