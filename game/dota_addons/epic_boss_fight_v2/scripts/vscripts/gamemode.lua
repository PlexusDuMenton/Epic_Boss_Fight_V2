
--FOR NOW ITS STILL BAREBONE , I FOCUSED ON INVENTORY MANAGER FOR NOW
BAREBONES_DEBUG_SPEW = false 

if epic_boss_fight == nil then
    DebugPrint( 'created epic_boss_fight class (main gamemode script)' )
    _G.epic_boss_fight = class({})
end



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


XP_PER_LEVEL_TABLE = {} --creating xp for 200 level , may increase it later on
for i=1,200 do 
  XP_PER_LEVEL_TABLE[i] = math.floor(i*18 + (5*i^2) + (10 * i^1.5))
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

function epic_boss_fight:OnHeroLevelUp(event)
  print ("LEVEL UP !")
  local player = PlayerResource:GetPlayer(event.player - 1) 
  local hero = player:GetAssignedHero()
  local level = hero:GetLevel()
  local Primary = hero:GetPrimaryAttribute()
  hero:SetAbilityPoints(0) 
  hero.stats_points = hero.stats_points + 1
  if Primary == 0 then
      print (hero.hero_stats.hp)
      print (math.ceil((level^0.75)*5))
      hero.hero_stats.hp = hero.hero_stats.hp + math.ceil((level^0.75)*5)
      hero.hero_stats.str = hero.hero_stats.str + math.ceil((level^0.75))
      hero.hero_stats.hp_regen = hero.hero_stats.hp_regen + math.ceil((level^0.5)*0.1)
  else
      hero.hero_stats.hp = hero.hero_stats.hp + math.ceil((level^0.7)*3.5)
      hero.hero_stats.str = hero.hero_stats.str + math.ceil((level^0.5))
      hero.hero_stats.hp_regen = hero.hero_stats.hp_regen + math.ceil((level^0.25)*0.05)
  end
  if Primary == 2 then
      hero.hero_stats.mp = hero.hero_stats.mp + math.ceil((level^0.75)*5)
      hero.hero_stats.int = hero.hero_stats.int + math.ceil((level^0.75))
      hero.hero_stats.mp_regen = hero.hero_stats.mp_regen + math.ceil((level^0.5)*0.2)
  else
      hero.hero_stats.mp = hero.hero_stats.mp + math.ceil((hero:GetLevel()^0.7)*2)
      hero.hero_stats.int = hero.hero_stats.int + math.ceil((level^0.5))
      hero.hero_stats.mp_regen = hero.hero_stats.mp_regen + math.ceil((level^0.25)*0.1)
  end
  if Primary == 1 then
      hero.hero_stats.armor = hero.hero_stats.armor + math.ceil((level^0.5))
      hero.hero_stats.agi = hero.hero_stats.agi + math.ceil((level^0.75))
  else
      hero.hero_stats.armor = hero.hero_stats.armor + math.ceil((level^0.25))
      hero.hero_stats.agi = hero.hero_stats.agi + math.ceil((level^0.5))
  end



end


function epic_boss_fight:InitGameMode()
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  print ("TEST")
  GameRules.items = LoadKeyValues("scripts/kv/items.kv")
  GameRules.difficulty = 1
  GameRules.cheats = false
  GameRules.loot_multiplier = 1
  GameRules.round = 1
  --ebf_boss_manager:Start()
  GameMode = GameRules:GetGameModeEntity()
  GameMode:SetThink( "OnThink", self, "GlobalThink", 2 )

  GameMode:SetLoseGoldOnDeath(false)
  GameMode:SetBuybackEnabled(false)
  --GameMode:SetCameraDistanceOverride(2300)  
  GameMode:SetRecommendedItemsDisabled(true)
  GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
  GameMode:SetCustomGameForceHero( "npc_dota_hero_legion_commander" )
  GameMode:SetUseCustomHeroLevels ( true )
  GameMode:SetCustomHeroMaxLevel( 100 )

  GameMode:SetMaximumAttackSpeed(1000)
  GameMode:SetMinimumAttackSpeed(-100)
  GameMode:SetAlwaysShowPlayerInventory(true)

  GameRules:SetSameHeroSelectionEnabled(true)
  GameRules:SetGoldPerTick( 0 ) 
  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )

  ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(epic_boss_fight, "OnItemPickUp"), self)
  ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap( epic_boss_fight, "OnHeroLevelUp"), self )

  HeroSelection:Start()
  


  CustomGameEventManager:RegisterListener( "inventory_change_lua", Dynamic_Wrap(epic_boss_fight, 'inventory_change_lua'))
  CustomGameEventManager:RegisterListener( "load_player_data", Dynamic_Wrap(epic_boss_fight, 'load_player_data'))

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')

  Convars:RegisterCommand("ebf_give_item", function(...) return self:ebf_give_item( ... ) end, "send an item directly to inventory", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_drop_item", function(...) return self:ebf_drop_item( ... ) end, "drop an item from inventory", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_sell_item", function(...) return self:ebf_sell_item( ... ) end, "sell an item", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_use_item", function(...) return self:ebf_use_item( ... ) end, "Equip/Use an item", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_upgrade", function(...) return self:ebf_upgrade( ... ) end, "Upgrade your equiped weapon", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_unequip", function(...) return self:ebf_unequip( ... ) end, "Unequip an item", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_inventory", function(...) return self:print_inv_info( ... ) end, "display inventory slots", FCVAR_CHEAT )

  Convars:RegisterCommand("ebf_save", function(...) return self:save( ... ) end, "save your current character to a slot", FCVAR_CHEAT )
end

function epic_boss_fight:save(com_name,save_slot)
  local slot = tonumber( save_slot )
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
  save(hero,slot,false)
end

function epic_boss_fight:print_inv_info()
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
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
  print (item_name)
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
  Item = epic_boss_fight:_CreateItem(item_name,hero)
  for k,v in pairs(Item) do print(k,v) end
  inv_manager:Add_Item(hero,Item)
end

function epic_boss_fight:ebf_use_item(com_name,slot_num)
  local slot = tonumber( slot_num )
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
  inv_manager:Use_Item(hero,slot)
end

function epic_boss_fight:ebf_upgrade(com_name,stat)
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
  inv_manager:upgrade_weapon(hero,stat)
end

function epic_boss_fight:ebf_unequip(com_name,slot_name)
  local slot = slot_name
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
  inv_manager:Unequip(hero,slot)
end

function epic_boss_fight:ebf_drop_item(com_name,slot_num)
  local slot = tonumber( slot_num )
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
  inv_manager:drop_Item(hero,slot)
end

function epic_boss_fight:ebf_sell_item(com_name,slot_num)
  local slot = tonumber( slot_num )
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
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