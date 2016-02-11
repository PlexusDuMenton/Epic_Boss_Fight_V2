
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
  XP_PER_LEVEL_TABLE[i] = math.floor(i*18 + i^2 + i^1.5)
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
  ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( epic_boss_fight, "OnHeroPick"), self )

  CustomGameEventManager:RegisterListener( "inventory_change_lua", Dynamic_Wrap(epic_boss_fight, 'inventory_change_lua'))
  CustomGameEventManager:RegisterListener( "load_player_data", Dynamic_Wrap(epic_boss_fight, 'load_player_data'))

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')

  Convars:RegisterCommand("ebf_give_item", function(...) return self:ebf_give_item( ... ) end, "send an item directly to inventory", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_drop_item", function(...) return self:ebf_drop_item( ... ) end, "drop an item from inventory", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_sell_item", function(...) return self:ebf_sell_item( ... ) end, "sell an item", FCVAR_CHEAT )
  Convars:RegisterCommand("ebf_inventory", function(...) return self:print_inv_info( ... ) end, "display inventory slots", FCVAR_CHEAT )
end
function epic_boss_fight:OnHeroPick (event)

  local hero = EntIndexToHScript(event.heroindex)
  inv_manager:Create_Inventory(hero)
end


function epic_boss_fight:print_inv_info()
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
  for i=1,20 do
    print ("slot :" ,i)
    if hero.inventory[i] ~= nil then
      print("       ",hero.inventory[i].Name)
    else print ('       Empty')
    end
    
  end
  if hero.equipement.weapon.name== nil then
    print ("Weapon : Empty")
  else
    print ("Weapon : ",hero.equipement.weapon.name)
  end
  if hero.equipement.chest_armor.name== nil then
    print ("Weapon : Empty")
  else
  print ("Chest : ",hero.equipement.chest_armor.name)
  end
  if hero.equipement.legs_armor.name== nil then
  print ("Weapon : Empty")
  else
  print ("Legs : ",hero.equipement.legs_armor.name)
  end
  if hero.equipement.helmet.name== nil then
  print ("Weapon : Empty")
  else
  print ("Head : ",hero.equipement.helmet.name)
  end
  if hero.equipement.gloves.name== nil then
  print ("Weapon : Empty")
  else
  print ("Hands : ",hero.equipement.gloves.name)
  end
  if hero.equipement.boots.name== nil then
  print ("Weapon : Empty")
  else
  print ("Feets: : ",hero.equipement.boots.name)
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