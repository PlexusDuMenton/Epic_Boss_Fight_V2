MAX_LEVEL = 500


if epic_boss_fight == nil then
    DebugPrint( 'created epic_boss_fight class (main gamemode script)' )
    _G.epic_boss_fight = class({})
end

ISCHEATALLOWED = 0
--ISCHEATALLOWED = FCVAR_CHEAT

Difficulty_Vote_Score = 0
difficulty_vote = 0
DIFFICULTY_VOTE_IN_PROGRESS = false
PRE_GAME_TIME = 30

difficulty_multiplier = {}

difficulty_multiplier[0] = 1
difficulty_multiplier[1] = 1.5
difficulty_multiplier[2] = 2.0
difficulty_multiplier[3] = 3.0
difficulty_multiplier[4] = 5.0
difficulty_multiplier[5] = 10.0
difficulty_multiplier[6] = 25.0

loot_difficulty = {}

loot_difficulty[0] = 1.0
loot_difficulty[1] = 1.05
loot_difficulty[2] = 1.10
loot_difficulty[3] = 1.20
loot_difficulty[4] = 1.30
loot_difficulty[5] = 1.40
loot_difficulty[6] = 1.50


-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')

require('storageapi/json')
require('storageapi/storage')
Storage:SetApiKey("1a632e691765ceac74723d73de5d72abb6374146") -- TBD : load this from another file

--require ("save")
--require ("click_functions")



-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
--require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
--require('events')

--require('ebf_boss_manager')

function Get_Xp_To_Next_Level(Level)
  local xp = (math.floor(Level*40 + (1*Level^3.5) + (2 * Level^2)) - Level*3 )- (math.floor((Level-1)*40 + (1*(Level-1)^3.5) + (2 * (Level-1)^2)) - (Level-1)*3 )
  return xp
end

function epic_boss_fight:OnEntityKilled(event)
  local killed_unit = EntIndexToHScript( event.entindex_killed )
  if killed_unit:IsRealHero() and killed_unit:GetTeam()~=DOTA_TEAM_BADGUYS then
    local newItem = CreateItem( "item_tombstone", killed_unit, killed_unit )
    newItem:SetPurchaseTime( 0 )
    newItem:SetPurchaser( killed_unit )
    local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
    tombstone:SetContainedItem( newItem )
    tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
    FindClearSpaceForUnit( tombstone, killed_unit:GetAbsOrigin(), true )
  end
end

function epic_boss_fight:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")

end


function epic_boss_fight:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end


function epic_boss_fight:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end


function epic_boss_fight:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
end

function epic_boss_fight:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds
    end)
end

function epic_boss_fight:Check_Hero_lvlup(hero)
  while hero.XP >= Get_Xp_To_Next_Level(hero.Level) and hero.Level < MAX_LEVEL do
    hero.XP = hero.XP-Get_Xp_To_Next_Level(hero.Level)
    epic_boss_fight:OnHeroLevelUp(hero)
  end
end

function epic_boss_fight:Update_stat(hero,lvl)
  local level = 0
  local Primary = hero:GetPrimaryAttribute()
  if lvl ~= nil then
    hero.Level = lvl
    level = lvl
  else
    hero.Level = hero.Level + 1
    level = hero.Level
  end
   if Primary == 0 then
      hero.hero_stats.hp = math.ceil(100*(level^1.75)*5)/100
      hero.hero_stats.str = math.ceil(100*(level^1.1)*2)/100
      hero.hero_stats.agi = math.ceil(100*(0.2*level^0.025))/100
      hero.hero_stats.hp_regen = math.ceil(100*(level^0.2)*0.15)/100
  else
      hero.hero_stats.hp = math.ceil(100*(level^1.65)*4.5)/100
      hero.hero_stats.str = math.ceil(100*(level^0.9)*1.8)/100
      hero.hero_stats.hp_regen = math.ceil(100*(level^0.2)*0.10)/100
  end
  if Primary == 2 then
      hero.hero_stats.mp = math.ceil(100*(level^1.70)*5)/100
      hero.hero_stats.int = math.ceil(100*(level^1.1)*2)/100
      hero.hero_stats.mp_regen = math.ceil(100*(level^0.30)*0.15)/100
  else
      hero.hero_stats.mp = math.ceil(100*(level^1.60)*4)/100
      hero.hero_stats.int = math.ceil(100*(level^0.9)*1.8)/100
      hero.hero_stats.mp_regen = math.ceil(100*(level^0.20)*0.15)/100
  end
  if Primary == 1 then
      hero.hero_stats.armor = math.ceil(100*(level^1.15))/100
      hero.hero_stats.agi = math.ceil(100*(level^1.1)*2)/100
  else
      hero.hero_stats.armor = math.ceil(100*(level^1.05))/100
      hero.hero_stats.agi = math.ceil(100*(level^0.9)*1.8)/100
  end
  inv_manager:Calculate_stats(hero)
end

function epic_boss_fight:OnHeroLevelUp(hero)
  print ("LEVEL UP !")
  epic_boss_fight:Update_stat(hero)
  local lvlup_effect = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN  , hero)
  hero:EmitSound("sounds/ui/levelup_female.vsnd")
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(lvlup_effect, false)
  end)
  hero:SetAbilityPoints(0)
  hero.stats_points = hero.stats_points + 1


end




-------------------------------------------------------------------  MULTIPLIER CALCULATOR
function epic_boss_fight:Calculate_Multiplier() --Will calculate difficulty based on all player level and
  Timers:CreateTimer(2,function()
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_PRE_GAME then
      local difficulty = 1
      local Actual_Max_Level = 0
      local player_ammount = 0
      local hero_pool = {}
      for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetTeam( i ) == DOTA_TEAM_GOODGUYS then
          if PlayerResource:HasSelectedHero( i ) then
            local hero = PlayerResource:GetSelectedHeroEntity(i)
            if hero~=nil then
              if hero.inventory ~= nil then
                if PlayerResource:GetConnectionState(i) == 2 then
                  player_ammount = player_ammount +1
                  hero_pool[player_ammount-1] = hero
                  if hero.Level > Actual_Max_Level then
                    Actual_Max_Level = hero.Level
                  end
                end
              end
            end
          end
        end
      end
      GameRules.hero_pool = hero_pool
      difficulty = (0.85*Actual_Max_Level) ^1.33 * (player_ammount^0.1)
      if difficulty < 1 then difficulty = 1 end
      if type(difficulty) ~= "number" then difficulty = 1 end
      GameRules.Actual_Max_Level = Actual_Max_Level
      if difficulty_multiplier[GameRules.player_difficulty] == nil then
        if GameRules.player_difficulty < 0 then GameRules.player_difficulty = 0
        else
          difficulty_multiplier[GameRules.player_difficulty] = (GameRules.player_difficulty-1)^2
        end
      end
      GameRules.difficulty = difficulty * difficulty_multiplier[GameRules.player_difficulty]
      if loot_difficulty[GameRules.player_difficulty] == nil then
        if GameRules.player_difficulty < 0 then GameRules.player_difficulty = 0
        else
          loot_difficulty[GameRules.player_difficulty] = (GameRules.player_difficulty)*1.5
        end
      end


      GameRules.loot_multiplier = math.floor(GameRules.Actual_Max_Level^1.6 * round_manager.round^0.1) * loot_difficulty[GameRules.player_difficulty] + 1

    end
  return 2
  end)
end











function epic_boss_fight:InitGameMode()
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  print ("TEST")

  math.randomseed( Time() )
  math.random()
  math.randomseed( math.random() )
  math.random(); math.random(); math.random()
  GameRules.items = LoadKeyValues("scripts/kv/items.kv")
  GameRules.difficulty = 1
  GameRules.player_difficulty = 0
  GameRules.cheats = false
  GameRules.loot_multiplier = 1
  epic_boss_fight:Calculate_Multiplier()
  GameRules.PlayerAmmount = 0
  GameRules.STATES = 1
  GameRules:SetPreGameTime(PRE_GAME_TIME)
  --ebf_boss_manager:Start()
  GameMode = GameRules:GetGameModeEntity()
  GameMode:SetThink( "OnThink", self, "GlobalThink", 2 )
  GameRules.Actual_Max_Level = 0

  GameRules.hero_pool = {}

  GameMode:SetFogOfWarDisabled(true)
  GameMode:SetLoseGoldOnDeath(false)
  GameMode:SetBuybackEnabled(false)
  --GameMode:SetCameraDistanceOverride(2300)
  GameMode:SetRecommendedItemsDisabled(true)
  GameMode:SetCustomGameForceHero( "npc_dota_hero_wisp" )
  GameMode:SetUseCustomHeroLevels ( true )

  GameMode:SetMaximumAttackSpeed(1000)
  GameMode:SetMinimumAttackSpeed(-100)
  GameMode:SetAlwaysShowPlayerInventory(true)


  GameRules:SetSameHeroSelectionEnabled(true)
  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 6 )
  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
  GameRules:SetHeroRespawnEnabled(false)
  GameRules:SetGoldPerTick(0)
  GameRules:SetFirstBloodActive(false)
  GameRules:SetHideKillMessageHeaders(true)
  GameRules:SetStartingGold(0)
  boss_manager:Start()

  ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(epic_boss_fight, "OnItemPickUp"), self)
  ListenToGameEvent( "entity_killed", Dynamic_Wrap( epic_boss_fight, "OnEntityKilled" ), self )

  HeroSelection:Start()
  item_list_init = {}
  Timers:CreateTimer(0.05,function()
    for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetTeam( i ) == DOTA_TEAM_GOODGUYS then
            if PlayerResource:GetConnectionState(i) == 2 then
              local hero = PlayerResource:GetSelectedHeroEntity(i)
              if hero~= nil then
                epic_boss_fight:update_net_table(hero,i)
              end
            end
        end
    end
    return 0.025
  end)
  local key = "init"
  local weapon_list = {}
  for k,v in pairs (LoadKeyValues("scripts/kv/items.kv")) do
    if v.cat == "weapon" then
      weapon_list[k] = v
      weapon_list[k].item_name = k
      weapon_list[k].upgrade_point = 0
      weapon_list[k].level = 0
      if weapon_list[k].effect == nil then weapon_list[k].effect = {} end
     weapon_list[k].Equipement = true
      if weapon_list[k].ranged == 1 then weapon_list[k].ranged = true else weapon_list[k].ranged = false end
      if weapon_list[k].magical == 1 then weapon_list[k].magical = true else weapon_list[k].magical = false end
      weapon_list[k].Soul = false
      weapon_list[k].dmg_grow = nil
      weapon_list[k].m_dmg_grow = nil
      weapon_list[k].range_grow = nil
      weapon_list[k].as_grow = nil
      if weapon_list[k].damage == nil then weapon_list[k].damage = 0 end
      if weapon_list[k].m_damage == nil then weapon_list[k].m_damage = 0 end
      if weapon_list[k].range == nil then weapon_list[k].range = 0 end
      if weapon_list[k].loh == nil then weapon_list[k].loh = 0 end
      if weapon_list[k].attack_speed == nil then weapon_list[k].attack_speed = 0 end
      if weapon_list[k].ls == nil then weapon_list[k].ls = 0 end
      weapon_list[k].upgrade_damage = 0
      weapon_list[k].upgrade_m_damage = 0
      weapon_list[k].upgrade_range = 0
      weapon_list[k].upgrade_loh = 0
      weapon_list[k].upgrade_attack_speed = 0
      weapon_list[k].upgrade_ls = 0
      weapon_list[k].bonus_damage = 0
      weapon_list[k].bonus_m_damage = 0
      weapon_list[k].bonus_range = 0
      weapon_list[k].bonus_loh = 0
      weapon_list[k].bonus_attack_speed = 0
      weapon_list[k].bonus_ls = 0
    end
  end
  item_list_init = { weapon_evolution = LoadKeyValues("scripts/kv/w_evolution.kv") , weapon_list = weapon_list }

  CustomGameEventManager:RegisterListener( "Use_Item", Dynamic_Wrap(epic_boss_fight, 'Use_Item'))
  CustomGameEventManager:RegisterListener( "Unequip_Item", Dynamic_Wrap(epic_boss_fight, 'Unequip_Item'))
  CustomGameEventManager:RegisterListener( "Drop_Item", Dynamic_Wrap(epic_boss_fight, 'Drop_Item'))
  CustomGameEventManager:RegisterListener( "Sell_Item", Dynamic_Wrap(epic_boss_fight, 'Sell_Item'))
  CustomGameEventManager:RegisterListener( "Buy_Item", Dynamic_Wrap(epic_boss_fight, 'Buy_Item'))
  CustomGameEventManager:RegisterListener( "load_player_data", Dynamic_Wrap(epic_boss_fight, 'load_player_data'))
  CustomGameEventManager:RegisterListener( "to_item_bar", Dynamic_Wrap(epic_boss_fight, 'inv_to_bar'))
  CustomGameEventManager:RegisterListener( "to_inventory", Dynamic_Wrap(epic_boss_fight, 'bar_to_inv'))
  CustomGameEventManager:RegisterListener( "Vote_Round", Dynamic_Wrap(epic_boss_fight, 'Get_Vote'))
  CustomGameEventManager:RegisterListener( "infuse_soul", Dynamic_Wrap(epic_boss_fight, 'infuse_soul'))
  CustomGameEventManager:RegisterListener( "transmute_weapon", Dynamic_Wrap(epic_boss_fight, 'transmute_weapon'))
  CustomGameEventManager:RegisterListener( "crystalize_weapon", Dynamic_Wrap(epic_boss_fight, 'crystalize_weapon'))
  CustomGameEventManager:RegisterListener( "evolve_weapon", Dynamic_Wrap(epic_boss_fight, 'evolve_weapon'))

  CustomGameEventManager:RegisterListener( "reforge", Dynamic_Wrap(epic_boss_fight, 'reforge'))
  CustomGameEventManager:RegisterListener( "reforge_equipement", Dynamic_Wrap(epic_boss_fight, 'reforge_equipement'))


  CustomGameEventManager:RegisterListener( "skill_bar", Dynamic_Wrap(epic_boss_fight, 'open_skill_bar'))

  CustomGameEventManager:RegisterListener( "respec", Dynamic_Wrap(epic_boss_fight, 'respec'))

  CustomGameEventManager:RegisterListener( "Upgrade_skill", Dynamic_Wrap(epic_boss_fight, 'Upgrade_skill'))
  CustomGameEventManager:RegisterListener( "Unequip_skill", Dynamic_Wrap(epic_boss_fight, 'unset_skill'))
  CustomGameEventManager:RegisterListener( "add_skill", Dynamic_Wrap(epic_boss_fight, 'add_skill'))


  -- TRADDING LISTENER :
  CustomGameEventManager:RegisterListener( "ask_trading", Dynamic_Wrap(epic_boss_fight, 'ask_trading'))
  CustomGameEventManager:RegisterListener( "accept_trading", Dynamic_Wrap(epic_boss_fight, 'accept_trading'))
  CustomGameEventManager:RegisterListener( "refuse_trading", Dynamic_Wrap(epic_boss_fight, 'refuse_trading'))
  CustomGameEventManager:RegisterListener( "set_trade_gold", Dynamic_Wrap(epic_boss_fight, 'set_trade_gold'))

  CustomGameEventManager:RegisterListener( "add_to_trade", Dynamic_Wrap(epic_boss_fight, 'add_to_trade'))
  CustomGameEventManager:RegisterListener( "remove_from_trade", Dynamic_Wrap(epic_boss_fight, 'remove_from_trade'))

  CustomGameEventManager:RegisterListener( "send_confirmation", Dynamic_Wrap(epic_boss_fight, 'send_confirmation'))

  CustomGameEventManager:RegisterListener( "cancel_confirmation", Dynamic_Wrap(epic_boss_fight, 'cancel_confirmation'))
  CustomGameEventManager:RegisterListener( "accept_confirmation", Dynamic_Wrap(epic_boss_fight, 'accept_confirmation'))
  CustomGameEventManager:RegisterListener( "cancel_trading", Dynamic_Wrap(epic_boss_fight, 'cancel_trading'))

  CustomGameEventManager:RegisterListener( "Change_Difficulty_Vote", Dynamic_Wrap(epic_boss_fight, 'Change_Difficulty_Vote'))
  CustomGameEventManager:RegisterListener( "Get_Diff_Vote", Dynamic_Wrap(epic_boss_fight, 'Get_Diff_Vote'))


  CustomGameEventManager:RegisterListener( "get_save", Dynamic_Wrap(epic_boss_fight, 'get_save'))
  CustomGameEventManager:RegisterListener( "delete_slot", Dynamic_Wrap(epic_boss_fight, 'delete_slot'))




  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')

  Convars:RegisterCommand("ebf_give_item", function(...) return self:ebf_give_item( ... ) end, "send an item directly to inventory", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_drop_item", function(...) return self:ebf_drop_item( ... ) end, "drop an item from inventory", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_sell_item", function(...) return self:ebf_sell_item( ... ) end, "sell an item", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_use_item", function(...) return self:ebf_use_item( ... ) end, "Equip/Use an item", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_set_loot_multiplier", function(...) return self:ebf_set_loot_multiplier( ... ) end, "Equip/Use an item", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_set_difficulty", function(...) return self:ebf_dfficulty( ... ) end, "Change the difficulty level of the game", ISCHEATALLOWED )


  Convars:RegisterCommand("ebf_upgrade", function(...) return self:ebf_upgrade( ... ) end, "Upgrade a weapon with a power soul", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_transmute", function(...) return self:ebf_transmute_weapon( ... ) end, "Upgrade a weapon xp with another", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_crystalize", function(...) return self:ebf_crystalize_weapon( ... ) end, "create a powersoul from a weapon", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_evolve", function(...) return self:ebf_evolve_weapon( ... ) end, "evolve a weapon to another one", ISCHEATALLOWED )

  Convars:RegisterCommand("test_http",function(...) return self:httptest(...) end, "test an http request to local", ISCHEATALLOWED)

  Convars:RegisterCommand("ebf_unequip", function(...) return self:ebf_unequip( ... ) end, "Unequip an item", ISCHEATALLOWED )

  Convars:RegisterCommand("ebf_up_skill", function(...) return self:up_skill( ... ) end, "upgrade a skill", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_equip_skill", function(...) return self:equip_skill( ... ) end, "equip a skill", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_unequip_skill", function(...) return self:unequip_skill( ... ) end, "unequip a skill", ISCHEATALLOWED )

  Convars:RegisterCommand("ebf_Level_up", function(...) return self:Level_UP( ... ) end, "Level up", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_Reward", function(...) return self:reward( ... ) end, "Give Reward", ISCHEATALLOWED )

  Convars:RegisterCommand("ebf_skills", function(...) return self:ebf_skills( ... ) end, "Display Skills", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_skill_list", function(...) return self:ebf_skill_list( ... ) end, "Display Skills", ISCHEATALLOWED )
  Convars:RegisterCommand("ebf_inventory", function(...) return self:print_inv_info( ... ) end, "display inventory slots", ISCHEATALLOWED )

  Convars:RegisterCommand("ebf_info", function(...) return self:print_info( ... ) end, "display inventory slots", ISCHEATALLOWED )

  Convars:RegisterCommand("ebf_save", function(...) return self:save( ... ) end, "save your current character to a slot", 0)
  --disabled Save for now
  Timers:CreateTimer(1,function()
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
      GameRules.PlayerAmmount = 0
      for i=0,PlayerResource:GetPlayerCount()-1 do
        local hero = PlayerResource:GetSelectedHeroEntity(i)
        if hero~=nil then
          if hero.inventory ~= nil then
            if PlayerResource:GetConnectionState(i) == 2 then
              GameRules.PlayerAmmount = 1 + GameRules.PlayerAmmount
            end
          end
        end
      end
    end
    return 1
  end)

  GameRules:GetGameModeEntity():SetThink( "OnThink", round_manager, 0.025 )
end

function epic_boss_fight:Get_Diff_Vote(data)
  Difficulty_Vote_Score = Difficulty_Vote_Score + data.Vote
end

function epic_boss_fight:update_difficulty()
  print("Vote ended",DIFFICULTY_VOTE_IN_PROGRESS,Difficulty_Vote_Score)
  if DIFFICULTY_VOTE_IN_PROGRESS == true and Difficulty_Vote_Score>0 then
    DIFFICULTY_VOTE_IN_PROGRESS = false
    GameRules.player_difficulty = tonumber(difficulty_vote)
    CustomGameEventManager:Send_ServerToPlayer(player,"Update_Difficulty_HUD", {difficulty = difficulty_vote})
  end
end

function epic_boss_fight:Change_Difficulty_Vote(data)
    local PID = data.PlayerID
    local hero = PlayerResource:GetPlayer(PID)
    print("why soo much hate ?",data.difficulty)
    if GameRules.PlayerAmmount>1 then
      if DIFFICULTY_VOTE_IN_PROGRESS == false and hero.vote_CD_Diff ~=true and GameRules.STATES == GAME_STATE_LOBBY then
        hero.vote_CD_Diff = true
        DIFFICULTY_VOTE_IN_PROGRESS = true
        Difficulty_Vote_Score = 0
        Timers:CreateTimer(3,function()
          if DIFFICULTY_VOTE_IN_PROGRESS == true then
            Difficulty_Vote_Score = Difficulty_Vote_Score + 1
          end
        end)
        Timers:CreateTimer(60,function()
          hero.vote_CD_Diff = false
        end)
        difficulty_vote = data.difficulty
        CustomGameEventManager:Send_ServerToPlayer(player,"Send_Vote_Diff", {difficulty = difficulty_vote,voter_ID = PID})
        Timers:CreateTimer(20,function()
          epic_boss_fight:update_difficulty()
        end)
      else
        if hero.vote_CD_Diff==true then
          Notifications:Inventory(hero:GetPlayerID(), {text="#WAIT_60_AFTER_VOTE",duration=2,color="FFFFFF"})
        elseif DIFFICULTY_VOTE_IN_PROGRESS == true then
          Notifications:Inventory(hero:GetPlayerID(), {text="#DIFF_VOTE_IN_PROGRESS",duration=2,color="FFFFFF"})
        elseif GameRules.STATES ~= GAME_STATE_LOBBY then
          Notifications:Inventory(hero:GetPlayerID(), {text="#CANT_VOTE_IN_FIGHT",duration=2,color="FFFFFF"})
        end
    	end
    else
      DIFFICULTY_VOTE_IN_PROGRESS = false
      difficulty_vote = data.difficulty
      GameRules.player_difficulty = tonumber(difficulty_vote)
      CustomGameEventManager:Send_ServerToPlayer(player,"Update_Difficulty_HUD", {difficulty = difficulty_vote})
    end
end

function epic_boss_fight:delete_slot(data)
    local PID = data.PlayerID
    local slot = data.Slot
		delete_save(PID,slot)
  end

function epic_boss_fight:save_mute(data)
  local PID = data.PlayerID
  Storage:Get( PlayerResource:GetSteamAccountID(PID), function( resultTable, successBool )
    if successBool then
      local data_table = {}
      data_table.data = {}
      if resultTable	~= nil and resultTable.data	~= nil then
        data_table = resultTable
      end
      data_table.data["option"] = {
            mute_music = data.mute
          }
      Storage:Put( PlayerResource:GetSteamAccountID(PID), data_table, function( resultTable, successBool )
      end)
    end
  end)
end

function epic_boss_fight:get_save(data)
    local PID = data.PlayerID
		local data_table = {}
		Storage:Get( PlayerResource:GetSteamAccountID(PID), function( resultTable, successBool )
			if successBool then
				if resultTable ~= nil then
					data_table = resultTable.data
				end
			elseif successBool == false then
				Notifications:Save(PID, {text="acess to server failed",duration=3,color="FF2222"})
			end
		end)
    local player = PlayerResource:GetPlayer(PID)
    if data_table ~= nil and data_table["option"] ~= nil then
      if data_table["option"].mute_music == true then
        CustomGameEventManager:Send_ServerToPlayer(player,"mute_music", {})
      end
      data_table["option"] = nil
    end


    local hero_list = LoadKeyValues("scripts/kv/hero_list.kv")
		CustomGameEventManager:Send_ServerToPlayer(player,"update_slot", {data = data_table,hero_list = hero_list})
  end


function epic_boss_fight:set_trade_gold(data)
    local PID = data.PlayerID
    local ammount = tonumber(data.gold)
    if ammount == nil then ammount = 0 end
    local hero = PlayerResource:GetSelectedHeroEntity( PID )
    inv_manager:Set_trade_gold(hero,ammount)

  end

function epic_boss_fight:send_confirmation(data)
    local PID = data.PlayerID
    local contactPID = data.trading_with
    local player_TW = PlayerResource:GetPlayer(contactPID)
    CustomGameEventManager:Send_ServerToPlayer(player_TW,"enter_confirmation", {ask_ID = data.PlayerID })
  end

  function epic_boss_fight:cancel_confirmation(data)
    local PID = data.PlayerID
    local contactPID = data.trading_with
    local player_TW = PlayerResource:GetPlayer(contactPID)
    CustomGameEventManager:Send_ServerToPlayer(player_TW,"stop_confirmation", {ask_ID = data.PlayerID })
    local hero_1 = PlayerResource:GetSelectedHeroEntity( PID )
    local hero_2 = PlayerResource:GetSelectedHeroEntity( contactPID )
    Timers:CreateTimer(0.2,function()
      hero_1.confirm_trade = nil
      hero_2.confirm_trade = nil
    end)
  end

  function epic_boss_fight:accept_confirmation(data)
    local PID = data.PlayerID
    local contactPID = data.trading_with
    local hero_1 = PlayerResource:GetSelectedHeroEntity(PID)
    hero_1.confirm_trade = true
    local hero_2 = PlayerResource:GetSelectedHeroEntity( contactPID )
    if hero_2.confirm_trade == true then
      inv_manager:accept_trade(hero_1,hero_2)
      hero_1.confirm_trade = nil
      hero_2.confirm_trade = nil
      local player_1 = PlayerResource:GetPlayer(PID)
      local player_2 = PlayerResource:GetPlayer(contactPID)
      CustomGameEventManager:Send_ServerToPlayer(player_1,"stop_trading", {})
      CustomGameEventManager:Send_ServerToPlayer(player_2,"stop_trading", {})
    end
  end

  function epic_boss_fight:cancel_trading(data)
    local PID = data.PlayerID
    local contactPID = data.trading_with
    local hero = PlayerResource:GetSelectedHeroEntity(PID)
    local hero_2 = PlayerResource:GetSelectedHeroEntity( contactPID )
    inv_manager:cancel_trade(hero,hero_2)
  end

function epic_boss_fight:ask_trading(data)
  local PID = data.PlayerID
  local contactPID = data.trading_with
  local player_TW = PlayerResource:GetPlayer(contactPID)
  CustomGameEventManager:Send_ServerToPlayer(player_TW,"asked_trading", {ask_ID = data.PlayerID })
end
function epic_boss_fight:accept_trading(data)
  local PID_2 = data.PlayerID
  local PID_1 = data.trading_with
  local hero_1 = PlayerResource:GetSelectedHeroEntity( PID_1 )
  local hero_2 = PlayerResource:GetSelectedHeroEntity( PID_2 )
  local player_1 = PlayerResource:GetPlayer(PID_1)
  local player_2 = PlayerResource:GetPlayer(PID_2)
  hero_1.trading = true
  hero_1.trading_with = hero_2
  hero_2.trading = false
  hero_2.trading_with = hero_1
  local key1 = "trade_player_"..PID_1
    CustomNetTables:SetTableValue( "info",key1, {trade_gold = hero_1.trade_gold , trade = hero_1.trade} )
  local key2 = "trade_player_"..PID_2
  CustomNetTables:SetTableValue( "info",key2, {trade_gold = hero_2.trade_gold , trade = hero_2.trade} )
  inv_manager:save_inventory(hero_1)
  inv_manager:save_inventory(hero_2)

  save(hero_1)
  save(hero_2)

  CustomGameEventManager:Send_ServerToPlayer(player_1,"start_trading", {ask_ID = PID_2 })
  CustomGameEventManager:Send_ServerToPlayer(player_2,"start_trading", {ask_ID = PID_1 })
end

function epic_boss_fight:refuse_trading(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  local PID = hero:GetPlayerID()
  local contactPID = data.trading_with

  Notifications:Player_interaction(contactPID, {PID = PID,text="#REFUSE_TRADE",duration=2,color="FFFFFF  "})
end
function epic_boss_fight:add_to_trade(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  local item_slot = data.Slot
  local ammount = tonumber(data.ammount)
  if ammount == nil then ammount = 1 end
  if ammount <= 0 then ammount = 9999999 end
  inv_manager:Send_trading(hero,item_slot,ammount,hero.trading_with)
end
function epic_boss_fight:remove_from_trade(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  local item_slot = data.Slot
  local ammount = tonumber(data.ammount)
  if ammount == nil then ammount = 1 end
  if ammount <= 0 then ammount = 9999999 end
  inv_manager:withdraw_trading(hero,item_slot,ammount)
end



function epic_boss_fight:Get_Vote(param)
  DeepPrintTable(param)
  if param.context == "lobby" then
    print ("get vote from lobby")
    if round_manager.lobby_vote == false then
      print ("Started a new vote")
      round_manager.lobby_vote = true
      if GameRules.PlayerAmmount>1 then
        round_manager.vote_time = 60
        CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = round_manager.vote_time } )
      else
        round_manager.vote_time = 5
        CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = round_manager.vote_time } )
      end
      Timers:CreateTimer(1.00,function()
            round_manager.vote_time = round_manager.vote_time - 1
            print(round_manager.vote_time)
            CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = round_manager.vote_time } )
            if round_manager.vote_time <= 0 then
              Timers:CreateTimer(1.00,function()
                round_manager.lobby_vote = false
              end)
              round_manager.vote = false
              CustomGameEventManager:Send_ServerToAllClients("Stop_Vote", {} )
              for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
              if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
                if PlayerResource:HasSelectedHero( nPlayerID ) then
                  if PlayerResource:GetConnectionState(nPlayerID) == 2 then
                    local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                    if hero~= nil then
                      FindClearSpaceForUnit(hero,ARENA_VECTOR, true)
                      Timers:CreateTimer(0.1,function()
                        CustomGameEventManager:Send_ServerToAllClients("center_on_hero", {} )
                      end)
                      PlayerResource:SetCameraTarget(nPlayerID, hero)
                      PlayerResource:SetCameraTarget(nPlayerID, nil)
                    end
                  end
                end
              end
            end
            CustomNetTables:SetTableValue( "KVFILE","time", { vote_time = nil } )
            round_manager.countdown = DEFAULT_COUNTDOWN_TIME
            GameRules.STATES = GAME_STATE_PREPARE_TIME
            return
            end
          return 1
      end)
    else
      print ("reduced time from"..round_manager.vote_time .."to".. round_manager.vote_time - (round_manager.vote_time/(GameRules.PlayerAmmount-1) ) )
      round_manager.vote_time = round_manager.vote_time - (round_manager.vote_time/(GameRules.PlayerAmmount-1) )
    end
  elseif param.context == "reward" then
    print ("shoudl display")
    if param.vote == "lobby" then round_manager.result_lobby = round_manager.result_lobby + 1 print ("vote for lobby") end
    if param.vote == "next" then round_manager.result_next = round_manager.result_next + 1 print ("vote for next round") end

  end
end


function epic_boss_fight:reward(com_name)
  round_manager:reward()
end

function epic_boss_fight:httptest(com_name)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  local SteamID = PlayerResource:GetSteamAccountID(hero:GetPlayerID())
  local data = {hero = "ok"}
end

function epic_boss_fight:ebf_dfficulty (com_name,difficulty)
  GameRules.player_difficulty = tonumber(difficulty)
end

function epic_boss_fight:up_skill (com_name,ID)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  hero.stats_points = hero.stats_points + 1
  ID = tonumber(ID)
  skill_manager:upgrade(hero,ID)
end
function epic_boss_fight:equip_skill (com_name,ID,slot)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  ID = tonumber(ID)
  if slot ~= nil then slot = tonumber(slot) end
  skill_manager:equip_skill(hero,ID,slot)
end

function epic_boss_fight:unequip_skill (com_name,slot)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  slot = tonumber(slot)
  skill_manager:unequip_skill (hero,slot)
end

function epic_boss_fight:Level_UP (com_name,level)
  if level == nil then level = 1 end
  local hero = Convars:GetCommandClient():GetAssignedHero()
  for i=1,level do
    print (hero.Level,MAX_LEVEL)
    if hero.Level < MAX_LEVEL then
      epic_boss_fight:OnHeroLevelUp(hero)
    else
      return
    end
  end
end

function epic_boss_fight:ebf_set_loot_multiplier (com_name,loot_multiplier)
  local loot_multiplier = tonumber(loot_multiplier)
  GameRules.loot_multiplier = loot_multiplier
end


function epic_boss_fight:infuse_soul(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  weapon_slot = tonumber( data.main_slot )
  soul_slot = tonumber( data.secondary_slot )
  inv_manager:up_weapon(hero,soul_slot,weapon_slot)
end

function epic_boss_fight:transmute_weapon(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  weapon_slot = tonumber( data.main_slot )
  transmuted_slot = tonumber( data.secondary_slot )
  inv_manager:transmutation(hero,transmuted_slot,weapon_slot)
end

function epic_boss_fight:crystalize_weapon(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  weapon_slot = tonumber( data.main_slot )
  print (weapon_slot)
  inv_manager:crystalyze(hero,weapon_slot)
end

function epic_boss_fight:evolve_weapon(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  slot_weap = tonumber( data.main_slot )
  evolution_way = tonumber( data.way )
  inv_manager:make_evolution(hero,evolution_way,slot_weap)
end


function epic_boss_fight:reforge(data)
  print ("why ?T.T ?")
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  slot = tonumber( data.Slot )
  inv_manager:reforge_com(hero,slot)
end

function epic_boss_fight:reforge_equipement(data)
  print ("wtf ?")
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  slot = data.Slot
  inv_manager:reforge_equipement(hero,slot)
end

function epic_boss_fight:ebf_transmute_weapon(com_name,transmuted_slot,weapon_slot)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  inv_manager:transmutation(hero,tonumber( transmuted_slot),tonumber( weapon_slot))
end
function epic_boss_fight:ebf_crystalize_weapon(com_name,slot_weap)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  inv_manager:crystalyze(hero,tonumber(slot_weap))
end
function epic_boss_fight:ebf_evolve_weapon(com_name,evolution_way,slot_weap)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  inv_manager:make_evolution(hero,tonumber(evolution_way),tonumber(slot_weap))
end

function epic_boss_fight:ebf_skills()
  local hero = Convars:GetCommandClient():GetAssignedHero()
  DeepPrintTable(hero.skill_tree)
  DeepPrintTable(hero.skill_bonus)
end

function epic_boss_fight:ebf_skill_list()
  local hero = Convars:GetCommandClient():GetAssignedHero()
  DeepPrintTable(hero.active_list)
end

function epic_boss_fight:open_skill_bar (data)
  local player = PlayerResource:GetPlayer(data.PlayerID)
  CustomGameEventManager:Send_ServerToPlayer(player,"open_skill_bar", {})
end

function epic_boss_fight:respec (data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  if hero.stats_points == hero.Level - 1 then
    Notifications:Inventory(hero:GetPlayerID(), {text="#RESPEC_USELESS",duration=2,color="FFAAAA"})
  else
    if hero.XP >= 0 then
      hero.stats_points = hero.Level - 1
      for i=1,5 do
        skill_manager:unequip_skill (hero,i)
      end
      if PlayerResource:HasCustomGameTicketForPlayerID( data.PlayerID ) == false then
        hero.XP = hero.XP-math.ceil(Get_Xp_To_Next_Level(hero.Level)*0.05)
      end
      skill_manager:create_skill_tree(hero)
    else
      Notifications:Inventory(hero:GetPlayerID(), {text="#NEGATIVE_XP",duration=2,color="FFAAAA"})
    end
  end
end

function epic_boss_fight:add_skill (data)
  local ID = tonumber( data.skillid )
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  local slot = tonumber( data.slot )
  skill_manager:equip_skill(hero,ID,slot)
end

function epic_boss_fight:unset_skill (data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  local slot = tonumber( data.slot )
  skill_manager:unequip_skill (hero,slot)
end

function epic_boss_fight:Upgrade_skill (data)
  local skill_id = tonumber( data.skillid )
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  skill_manager:upgrade(hero,skill_id)
end




function epic_boss_fight:inv_to_bar (data)
  local slot = tonumber( data.Slot )
  local bar_slot = tonumber( data.Bar_Slot )
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  inv_manager:to_item_bar(hero,slot,bar_slot)
end

function epic_boss_fight:bar_to_inv (data)
  local slot = tonumber( data.Slot )
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  inv_manager:to_inv(hero,slot)
end

function epic_boss_fight:save(com_name,save_slot)
  local slot = save_slot
  local hero = Convars:GetCommandClient():GetAssignedHero()
  save(hero)
end

function epic_boss_fight:print_info(com_name,advanced)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  if advanced == nil then
    DeepPrintTable (hero)
  end
  print ('=====================================================================================================================================================================================================================================================')
  if advanced ~= nil then
    for k,v in pairs(hero:FindAllModifiers()) do
      print(k)
      if v~= nil then
        print(v:GetName())
      end
    end
    print ('=====================================================================================================================================================================================================================================================')
    for i = 0,hero:GetAbilityCount() do
      print(i)
      print(hero:GetAbilityByIndex(i):GetName())
      print ('=====================================================================================================================================================================================================================================================')
    end
  end
end


function epic_boss_fight:print_inv_info()
  local hero = Convars:GetCommandClient():GetAssignedHero()
  for i=1,4 do
    print ("slot bar:" ,i)
    if hero.item_bar[i] ~= nil then
      if hero.item_bar[i].level ~= nil then
        print("       ",hero.item_bar[i].Name," Level : ",hero.item_bar[i].level)
      else
        print("       ",hero.item_bar[i].Name)
      end
    else
      print ('       Empty')
    end
  end
  for i=1,20 do
    print ("slot :" ,i)
    if hero.inventory[i] ~= nil then
      if hero.inventory[i].level ~= nil then
        print("       ",hero.inventory[i].Name," Level : ",hero.inventory[i].level)
      else
        print("       ",hero.inventory[i].Name)
      end
    else
      print ('       Empty')
    end
  end

  if hero.equipement.weapon == nil or hero.equipement.weapon.Name == nil then
    print ("Weapon : Empty")
  else
    print ("Weapon : ",hero.equipement.weapon.Name," Level : ",hero.equipement.weapon.level)
  end
  if hero.equipement.chest_armor == nil or hero.equipement.chest_armor.Name == nil then
    print ("Chest : Empty")
  else
  print ("Chest : ",hero.equipement.chest_armor.Name)
  end
  if hero.equipement.legs_armor == nil or hero.equipement.legs_armor.Name == nil then
  print ("Legs : Empty")
  else
  print ("Legs : ",hero.equipement.legs_armor.Name)
  end
  if hero.equipement.helmet == nil or hero.equipement.helmet.Name == nil then
  print ("Head : Empty")
  else
  print ("Head : ",hero.equipement.helmet.Name)
  end
  if hero.equipement.gloves == nil or hero.equipement.gloves.Name == nil then
  print ("Gloves : Empty")
  else
  print ("Gloves : ",hero.equipement.gloves.Name)
  end
  if hero.equipement.boots == nil or hero.equipement.boots.Name == nil then
  print ("Boots : Empty")
  else
  print ("Boots : ",hero.equipement.boots.Name)
  end
end

function epic_boss_fight:ebf_give_item(com_name,item_name)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  Item = epic_boss_fight:_CreateItem(item_name,hero)
  inv_manager:Add_Item(hero,Item)
end

function epic_boss_fight:ebf_use_item(com_name,slot_num)
  local slot = tonumber( slot_num )
  local hero = Convars:GetCommandClient():GetAssignedHero()
  inv_manager:Use_Item(hero,slot)
end

function epic_boss_fight:Sell_Item(data)
  local slot = tonumber( data.Slot )
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  local ammount = tonumber(data.ammount)
  if ammount == nil then ammount = 1 end
  if ammount <= 0 then ammount = 99999 end
  inv_manager:Sell_Item(hero,slot,ammount)
end

function epic_boss_fight:Buy_Item(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  Item = epic_boss_fight:_CreateItem(data.name,hero)
  local ammount = data.ammount
  if ammount == "max" then
    ammount = math.floor(hero.gold/data.price)
  else
    ammount = tonumber(data.ammount)
    if ammount == nil then ammount = 1 end
    if ammount <= 0 then ammount = 1 end
  end

  if hero.trading == true then
        Notifications:Inventory(hero:GetPlayerID(), {text="#IN_TRADING",duration=2,color="FFAAAA"})
  else
    if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    if Item.stackable == false and #hero.inventory == size then
      Notifications:Inventory(hero:GetPlayerID(), {text="#NOSLOT",duration=2,color="FFAAAA"})
    else
      if Item.stackable == true then
        if hero.gold>= data.price*ammount then
          hero.gold = hero.gold - (data.price*ammount)
          Item.ammount = ammount
          inv_manager:Add_Item(hero,Item)
        else
          Notifications:Inventory(hero:GetPlayerID(), {text="#NOGOLD",duration=2,color="FFAAAA"})
        end
      else
        if hero.gold>= data.price then
          hero.gold = hero.gold - (data.price)
          inv_manager:Add_Item(hero,Item)
        else
          Notifications:Inventory(hero:GetPlayerID(), {text="#NOGOLD",duration=2,color="FFAAAA"})
        end
      end
    end
  end
end


function epic_boss_fight:Use_Item(data)
  local slot = tonumber( data.Slot )
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  inv_manager:Use_Item(hero,slot,data.item_bar)
end

function epic_boss_fight:Drop_Item(data)
  local slot = tonumber( data.Slot )
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  inv_manager:drop_Item(hero,slot)
end

function epic_boss_fight:Unequip_Item(data)
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )

  inv_manager:Unequip(hero,data.Slot)
end

function epic_boss_fight:ebf_upgrade(com_name,soul_slot,weapon_slot)
  local hero = Convars:GetCommandClient():GetAssignedHero()
  soul_slot = tonumber( soul_slot )
  weapon_slot = tonumber( weapon_slot )
  inv_manager:up_weapon(hero,soul_slot,weapon_slot)
end

function epic_boss_fight:ebf_unequip(com_name,slot_name)
  local slot = slot_name
  local hero = Convars:GetCommandClient():GetAssignedHero()
  inv_manager:Unequip(hero,slot)
end

function epic_boss_fight:ebf_drop_item(com_name,slot_num)
  local slot = tonumber( slot_num )
  local hero = Convars:GetCommandClient():GetAssignedHero()
  inv_manager:drop_Item(hero,slot)
end

function epic_boss_fight:ebf_sell_item(com_name,slot_num)
  local slot = tonumber( slot_num )
  local hero = Convars:GetCommandClient():GetAssignedHero()
  inv_manager:Sell_Item(hero,slot)
end


function epic_boss_fight:OnThink( )
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS or GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
    for k,item in pairs( Entities:FindAllByClassname( "dota_item_drop" ) ) do
      if GameRules:GetGameTime()-item:GetCreationTime() >= 60 then
        UTIL_RemoveImmediate( item )
      end
    end
    for i=1,PlayerResource:GetPlayerCount() do
      local player = PlayerResource:GetPlayer(i-1)
      local hero = player:GetAssignedHero()
    end
  elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
      return
  end
  return 0.1
end

function epic_boss_fight:_CreateItem(item_name,owner) --a function to create an item from name , will be used over "CreateItem" because
  --it'll make the change we need on items
  print("step 2")
  Item = CreateItem(item_name, owner, owner)
  Item = inv_manager:Create_Item(Item)
  return Item
end

function epic_boss_fight:OnItemPickUp(event)
  pID = event.PlayerID
  local player = PlayerResource:GetPlayer(pID)
  local hero = player:GetAssignedHero()
  for itemSlot = 0, 5, 1 do
    local Item = hero:GetItemInSlot( itemSlot )
    if Item ~= nil and Item:IsItem() then
      local item = epic_boss_fight:_CreateItem(Item:GetName(),hero)
      inv_manager:Add_Item(hero,item)
      hero:RemoveItem(Item)
    end
  end
end

function epic_boss_fight:update_net_table(hero,ID)
  local key = "player_"..hero:GetPlayerID()
  if PlayerResource:GetConnectionState(ID) ~= 2 then
    CustomNetTables:SetTableValue( "info",key, {} )
    if hero.trading == true then
      inv_manager:cancel_trade(hero,hero.trade_with)
    end
  else
    local modifierList = {}
    local listSize = 0
    --yes I know i could use #modifierList but for no reason i had issue with
    if hero:GetUnitName()~= "npc_dota_hero_wisp" then
      for k,v in pairs(hero:FindAllModifiers()) do
        local modifierName = v:GetName()
        local modifier = hero:FindModifierByName(modifierName)
        if modifier:IsHidden() ~= nil then
          if not modifier:IsHidden() then
            local modifierTable = {}
            modifierTable.name = modifierName
            modifierTable.debuff = modifier:IsDebuff()
            modifierList[listSize] = modifierTable
            listSize = listSize+1
          end
        end
      end
    end
    local current_XP = hero.XP
    if hero.equipement~=nil then
      if hero.equipement.weapon ~= nil then
        CustomNetTables:SetTableValue( "info",key, {damage_mult = hero.final_damage_multiplier,admin = hero.admin,gold = math.floor(hero.gold) ,CD = hero.CD,Name = hero:GetUnitName(),inforge = hero.Isinforge,inshop = hero.Isinshop,LVL = hero.Level ,WName = hero.equipement.weapon.item_name, WLVL = hero.equipement.weapon.level ,HP = hero:GetHealth(),MAXHP = hero:GetMaxHealth(),MP = hero:GetMana(),MAXMP = hero:GetMaxMana(),HXP =current_XP,MAXHXP = Get_Xp_To_Next_Level(hero.Level),WXP = hero.equipement.weapon.XP,MAXWXP = hero.equipement.weapon.Next_Level_XP  } )
      else
        CustomNetTables:SetTableValue( "info",key, {damage_mult = hero.final_damage_multiplier,admin = hero.admin,gold = math.floor(hero.gold) ,CD = hero.CD,Name = hero:GetUnitName(),inforge = hero.Isinforge,inshop = hero.Isinshop,LVL = hero.Level ,WName = "Fist", WLVL = 0 ,HP = hero:GetHealth(),MAXHP = hero:GetMaxHealth(),MP = hero:GetMana(),MAXMP = hero:GetMaxMana(),HXP = current_XP,MAXHXP = Get_Xp_To_Next_Level(hero.Level),WXP = 0,MAXWXP = 0  } )
      end
      CustomNetTables:SetTableValue( "KVFILE","modifier_"..key, {modifier_list = modifierList} )
    end
  end
end
