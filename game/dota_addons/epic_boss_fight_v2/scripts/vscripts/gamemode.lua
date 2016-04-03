MAX_LEVEL = 500 --level higger than 99 seam to bug a bit

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

XP_PER_LEVEL_TABLE = {} 
REAL_XP_TABLE = {}
for i=0,MAX_LEVEL do 
  XP_PER_LEVEL_TABLE[i] = math.floor(i*40 + (1*i^3) + (2 * i^2)) - i*3
  if i > 0 then
    REAL_XP_TABLE[i] = XP_PER_LEVEL_TABLE[i] - XP_PER_LEVEL_TABLE[i-1]
  end
end
REAL_XP_TABLE[0] = 0



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
  while hero.XP >= REAL_XP_TABLE[hero.Level] do
    hero.XP = hero.XP-REAL_XP_TABLE[hero.Level]
    hero.Level = hero.Level + 1
    epic_boss_fight:OnHeroLevelUp(hero)
  end
end

function epic_boss_fight:OnHeroLevelUp(hero)
  print ("LEVEL UP !")
  local level = hero.Level
  local Primary = hero:GetPrimaryAttribute()
  local lvlup_effect = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN  , hero)
  hero:EmitSound("sounds/ui/levelup_female.vsnd")
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(lvlup_effect, false)
  end)
  hero:SetAbilityPoints(0) 
  hero.stats_points = hero.stats_points + 1
  if Primary == 0 then
      hero.hero_stats.hp = hero.hero_stats.hp + math.ceil(100*(level^0.75)*5)/100
      hero.hero_stats.str = hero.hero_stats.str + math.ceil(100*(level^0.75))/100
      hero.hero_stats.agi = hero.hero_stats.agi +  math.ceil(100*(0.2*level^0.05))/100
      hero.hero_stats.hp_regen = hero.hero_stats.hp_regen + math.ceil(100*(level^0.2)*0.15)/100
  else
      hero.hero_stats.hp = hero.hero_stats.hp + math.ceil(100*(level^0.7)*3.5)/100
      hero.hero_stats.str = hero.hero_stats.str + math.ceil(100*(level^0.5))/100
      hero.hero_stats.hp_regen = hero.hero_stats.hp_regen + math.ceil(100*(level^0.1)*0.10)/100
  end
  if Primary == 2 then
      hero.hero_stats.mp = hero.hero_stats.mp + math.ceil(100*(level^0.75)*5)/100
      hero.hero_stats.int = hero.hero_stats.int + math.ceil(100*(level^0.75))/100
      hero.hero_stats.mp_regen = hero.hero_stats.mp_regen + math.ceil(100*(level^0.25)*0.03)/100
  else
      hero.hero_stats.mp = hero.hero_stats.mp + math.ceil(100*(level^0.7)*2)/100
      hero.hero_stats.int = hero.hero_stats.int + math.ceil(100*(level^0.5))/100
      hero.hero_stats.mp_regen = hero.hero_stats.mp_regen + math.ceil(100*(level^0.15)*0.15)/100
  end
  if Primary == 1 then
      hero.hero_stats.armor = hero.hero_stats.armor + math.ceil(100*(level^0.5))/100
      hero.hero_stats.agi = hero.hero_stats.agi + math.ceil(100*(level^0.75))/100
  else
      hero.hero_stats.armor = hero.hero_stats.armor + math.ceil(100*(level^0.25))/100
      hero.hero_stats.agi = hero.hero_stats.agi + math.ceil(100*(level^0.5))/100
  end
  inv_manager:Calculate_stats(hero)

end


function epic_boss_fight:InitGameMode()
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  print ("TEST")
  GameRules.items = LoadKeyValues("scripts/kv/items.kv")
  print (GameRules.items)
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
  GameMode:SetCustomHeroMaxLevel(MAX_LEVEL) 
  GameMode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE) 
  GameMode:SetCustomGameForceHero( "npc_dota_hero_legion_commander" )
  GameMode:SetUseCustomHeroLevels ( true )

  GameMode:SetMaximumAttackSpeed(1000)
  GameMode:SetMinimumAttackSpeed(-100)
  GameMode:SetAlwaysShowPlayerInventory(true)

  GameRules:SetSameHeroSelectionEnabled(true)
  GameRules:SetGoldPerTick( 0 ) 
  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
  GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
  ebf_boss_manager:Start()

  ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(epic_boss_fight, "OnItemPickUp"), self)


  HeroSelection:Start()

  Timers:CreateTimer(0.05,function()
    for i=0,PlayerResource:GetPlayerCount()-1 do
      local hero = PlayerResource:GetSelectedHeroEntity(i) 
      if hero~=nil then
        epic_boss_fight:update_net_table(hero)
      end
    end
    return 0.025
  end)

  CustomGameEventManager:RegisterListener( "Use_Item", Dynamic_Wrap(epic_boss_fight, 'Use_Item'))
  CustomGameEventManager:RegisterListener( "Unequip_Item", Dynamic_Wrap(epic_boss_fight, 'Unequip_Item'))
  CustomGameEventManager:RegisterListener( "Drop_Item", Dynamic_Wrap(epic_boss_fight, 'Drop_Item'))
  CustomGameEventManager:RegisterListener( "Sell_Item", Dynamic_Wrap(epic_boss_fight, 'Sell_Item'))
  CustomGameEventManager:RegisterListener( "load_player_data", Dynamic_Wrap(epic_boss_fight, 'load_player_data'))
  CustomGameEventManager:RegisterListener( "to_item_bar", Dynamic_Wrap(epic_boss_fight, 'inv_to_bar'))
  CustomGameEventManager:RegisterListener( "to_inventory", Dynamic_Wrap(epic_boss_fight, 'bar_to_inv'))

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
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
  save(hero,slot,false)
end


function epic_boss_fight:print_inv_info()
  local hero = PlayerResource:GetSelectedHeroEntity( 0 )
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

function epic_boss_fight:Sell_Item(data)
  local slot = tonumber( data.Slot )
  local hero = PlayerResource:GetSelectedHeroEntity( data.PlayerID )
  inv_manager:Sell_Item(hero,slot)
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

function epic_boss_fight:update_net_table(hero)
  local key = "player_"..hero:GetPlayerID()
  
  local current_XP = hero.XP
  if hero.equipement~=nil then
    if hero.equipement.weapon ~= nil then  
      CustomNetTables:SetTableValue( "info",key, {CD = hero.CD,Name = hero:GetUnitName(),inshop = hero.Isinshop,LVL = hero.Level ,WName = hero.equipement.weapon.Name, WLVL = hero.equipement.weapon.level ,HP = hero:GetHealth(),MAXHP = hero:GetMaxHealth(),MP = hero:GetMana(),MAXMP = hero:GetMaxMana(),HXP =current_XP,MAXHXP = REAL_XP_TABLE[hero.Level],WXP = hero.equipement.weapon.XP,MAXWXP = hero.equipement.weapon.Next_Level_XP  } )
    else
      CustomNetTables:SetTableValue( "info",key, {CD = hero.CD,Name = hero:GetUnitName(),inshop = hero.Isinshop,LVL = hero.Level ,WName = "Fist", WLVL = 0 ,HP = hero:GetHealth(),MAXHP = hero:GetMaxHealth(),MP = hero:GetMana(),MAXMP = hero:GetMaxMana(),HXP = current_XP,MAXHXP = REAL_XP_TABLE[hero.Level],WXP = 0,MAXWXP = 0  } )
    end
  end
end