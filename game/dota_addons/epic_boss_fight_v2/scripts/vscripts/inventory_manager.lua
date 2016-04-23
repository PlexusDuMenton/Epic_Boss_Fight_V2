if inv_manager == nil then
    DebugPrint( 'created inv_manager' )
    inv_manager = class({})
    print ("CREATED INVENTORY MANAGER")
end

INVENTORY_SIZE = 30
INVENTORY_PASS_SIZE = 40

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

 --INVENTORY MANAGER IS WHAT MAKE ALL THE INVENTORY SYSTEM WORK , FROM CREATION OF ITEM  TO REPAIR ,UPGRADE, AND STATS CALCULATION

inv_manager.XP_Table = {}
inv_manager.XP_Table[0] = 0
for i=1,200 do
  inv_manager.XP_Table[i] = math.floor(i*19 + i^2) + inv_manager.XP_Table[i-1]
end

function inv_manager:save_inventory(hero)
    local inventory = {}
    local equipement = hero.equipement
    if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    for i=1,size do
        inventory[i]=hero.inventory[i]
        if inventory[i] ~= nil then
            inventory[i].as_upgrade = nil
            inventory[i].damage_upgrade = nil
            inventory[i].range_upgrade = nil
        end
    end

    if equipement.weapon ~= nil then 
        equipement.weapon.as_upgrade = nil
        equipement.weapon.damage_upgrade = nil
        equipement.weapon.range_upgrade = nil
    end
    CustomNetTables:SetTableValue( "inventory","player_"..hero:GetPlayerID(), {inventory = inventory,size = size,equipement=hero.equipement,item_bar = hero.item_bar} )
end

function inv_manager:to_inv(hero,inv_slot)
    local size = 0
    local inventory = hero.inventory
    if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    local item_bar = hero.item_bar
    local item = item_bar[inv_slot]
    for i=1,size do
            if item.stackable == true then
                if inventory[i]~= nil and inventory[i].Name== item.name then
                    print ("item was stacked with item bar")
                    hero.inventory[i].ammount = inventory[i].ammount + item.ammount
                    hero.item_bar[inv_slot] = nil
                    inv_manager:sort( hero )
                    inv_manager:save_inventory(hero)
                    return
                elseif i==size and #inventory<size+1 then 
                    print ("item added to inventory")
                    table.insert(hero.inventory,item)
                    hero.item_bar[inv_slot] = nil
                    inv_manager:sort( hero )
                    inv_manager:save_inventory(hero)
                    return
                elseif i==size and #inventory>=size+1 then 
                    print ("item bar is full")
                    Notifications:Bottom(hero:GetPlayerID(), {text="#NOSLOT_BAR",duration=2,style={color="red"}})
                    return
                end
            else
                if i==size and #inventory<size+1 then 
                    print ("item added to inventory")
                    table.insert(hero.inventory,item)
                    hero.item_bar[inv_slot] = nil
                    inv_manager:sort( hero )
                    inv_manager:save_inventory(hero)
                    return
                elseif i==size and #inventory>=size+1 then 
                    print ("item bar is full")
                    Notifications:Bottom(hero:GetPlayerID(), {text="#NOSLOT_BAR",duration=2,style={color="red"}})
                    return
                end
            end
    end
end

function inv_manager:to_item_bar(hero,inv_slot,bar_slot)
    local size = 4
    local item_bar = hero.item_bar
    local item = hero.inventory[inv_slot]
    if bar_slot ~= nil then
        print (bar_slot)
        DeepPrintTable (item)
        hero.inventory[inv_slot] = item_bar[bar_slot]
        hero.item_bar[bar_slot] = item
        inv_manager:save_inventory(hero)
    else
        for i=1,size do
                if item.stackable == true then
                    if item_bar[i]~= nil and item_bar[i].Name== item.Name then
                        print ("item was stacked with item bar")
                        hero.item_bar[i].ammount = item_bar[i].ammount + item.ammount
                        hero.inventory[inv_slot] = nil
                        inv_manager:sort( hero )
                        inv_manager:save_inventory(hero)
                        return
                    elseif i==size and #item_bar<size+1 then 
                        print ("item added to item_bar")
                        table.insert(hero.item_bar,item)
                        hero.inventory[inv_slot] = nil
                        inv_manager:sort( hero )
                        inv_manager:save_inventory(hero)
                        return
                    elseif i==size and #item_bar>=size+1 then 
                        print ("item bar is full")
                        Notifications:Bottom(hero:GetPlayerID(), {text="#NOSLOT_BAR",duration=2,style={color="red"}})
                        return
                    end
                else
                    if i==size and #item_bar<size+1 then 
                        print ("item added to item_bar")
                        table.insert(hero.item_bar,item)
                        hero.inventory[inv_slot] = nil
                        inv_manager:sort( hero )
                        inv_manager:save_inventory(hero)
                        return
                    elseif i==size and #item_bar>=size+1 then 
                        print ("item bar is full")
                        Notifications:Bottom(hero:GetPlayerID(), {text="#NOSLOT_BAR",duration=2,style={color="red"}})
                        return
                    end
                end
            
        end
    end
end


function inv_manager:Create_Item(Item)
    local item = Item
    local item_list = GameRules.items
    local item_info = item_list[Item:GetName()]
    if item_info == nil then 
        print ("WHAT THE FUCK ARE YOU DOING KID , THERE IS NO KV FILE FOR THIS ITEM ARE YOU AN FUCKING LAZYBOY ?")
        return Item
    end
    item = copy(item_info)
    item.item_name = Item:GetName()
    if item.effect == nil then item.effect = {} end
    if item.stackable == 1 then item.stackable = true end
    if item.stackable == true then
        item.ammount = 1
    end
    if item.Equipement == 1 then item.Equipement = true end
    if item.Equipement == 0 then item.Equipement = false end
    if item.Equipement == true then

        if item.damage ~= nil then item.damage = math.ceil(item_info.damage + math.random(0,item_info.damage*0.2)) end
        if item.range ~= nil then item.range = math.ceil(item_info.range + math.random(0,item_info.range*0.2)) end
        if item.loh ~= nil then item.loh = math.ceil(item_info.loh + math.random(0,item_info.loh*0.2)) end
        if item.attack_speed ~= nil then item.attack_speed = math.ceil(item_info.attack_speed + math.random(0,item_info.attack_speed*0.2)) end
        if item.armor ~= nil then item.armor = math.ceil(item_info.armor + math.random(0,item_info.armor*0.2)) end
        if item.hp ~= nil then item.hp = math.ceil(item_info.hp + math.random(0,item_info.hp*0.2)) end
        if item.movespeed ~= nil then item.movespeed = math.ceil(item_info.movespeed + math.random(0,item_info.movespeed*0.2)) end
        if item.hp_regen ~= nil then item.hp_regen = math.ceil(item_info.hp_regen + math.random(0,item_info.hp_regen*0.2)) end
        if item.mp ~= nil then item.mp = math.ceil(item_info.mp + math.random(0,item_info.mp*0.2)) end
        if item.mp_regen ~= nil then item.mp_regen = math.ceil(item_info.mp_regen + math.random(0,item_info.mp_regen*0.2)) end

        if item.cat == "weapon" then
            item.durability = item.max_dur
            item.level = 1
            item.XP = 0
            item.upgrade_point = 0

            item.as_upgrade = {}
            for i=0,50 do 
                item.as_upgrade[i] = ((i/2))*item.as_mult + 2
            end
            item.as_lvl = 0
        
            item.range_upgrade = {}
            item.range_lvl = 0
            --if weapon is a ranged weapon then range upgrade GREATLY increase range , else it's slighty increase it (can be see as lenghten the weapon :) )
            if ranged == true then
                for i=0,50 do 
                    item.range_upgrade[i] = (1 + (i/5))*item.range_mult + 15
                end
            else
                for i=0,50 do 
                    item.range_upgrade[i] = item.range_mult
                end
            end

            item.damage_upgrade = {}
            for i=0,50 do 
                item.damage_upgrade[i] = (1 + (i/2))*item.dmg_mult + 2
            end
            item.dmg_lvl = 0
            item.Next_Level_XP = inv_manager.XP_Table[item.level]
        end
    end

    return item
end

function inv_manager:calc_stat_item(equipement,stats)
    
    local eq_slot = equipement 

    --[[i check if a value is nil , if it's the case i set it to 0, i prefer use this way than put in each item those basic value
    to gain some memory size (you know , optimisation (while this code must be the least optimised cheat cause i suck)) especialy when
    saving items
    ]]
    if eq_slot == nil then return stats end
    if not eq_slot.damage then eq_slot.damage = 0 end
    if not eq_slot.attack_speed then eq_slot.attack_speed = 0 end
    if not eq_slot.range then eq_slot.range = 0 end
    if not eq_slot.armor then eq_slot.armor = 0 end
    if not eq_slot.m_ress then eq_slot.m_ress = 0 end
    if not eq_slot.dodge then eq_slot.dodge = 0 end
    if not eq_slot.hp then eq_slot.hp = 0 end
    if not eq_slot.hp_regen then eq_slot.hp_regen = 0 end
    if not eq_slot.mp then eq_slot.mp = 0 end
    if not eq_slot.mp_regen then eq_slot.mp_regen = 0 end
    if not eq_slot.movespeed then eq_slot.movespeed = 0 end
    if not eq_slot.ls then eq_slot.ls = 0 end
    if not eq_slot.loh then eq_slot.loh = 0 end
    if not eq_slot.effect then eq_slot.effect = {} end


    --weapon main stats
    stats.damage = stats.damage + eq_slot.damage
    stats.attack_speed = stats.attack_speed + eq_slot.attack_speed
    stats.range = stats.range + eq_slot.range
    --Armor/magic ress
    
    stats.armor = stats.armor + eq_slot.armor
    stats.m_ress = 100*(1-((1 - 0.01*stats.m_ress) * (1 - 0.01*eq_slot.m_ress)))
    stats.dodge = stats.dodge + eq_slot.dodge
    --casual HP/MP
    stats.hp = stats.hp + eq_slot.hp
    stats.hp_regen = stats.hp_regen + eq_slot.hp_regen
    stats.mp = stats.mp + eq_slot.mp
    stats.mp_regen = stats.mp_regen + eq_slot.mp_regen
    --Special Stats
    stats.movespeed = stats.movespeed + eq_slot.movespeed
    stats.ls = stats.ls + eq_slot.ls --Life Steal (a percent of your current damage)
    stats.loh = stats.loh + eq_slot.loh --Life On Hit , each time you hit , you regain this ammount of Health
    --Merge effect of all object
    stats.effect = tableMerge(stats.effect,eq_slot.effect)

    return stats
end

function have_effect (tab, val)
    for index, value in pairs (tab) do
        if value == val then
            return true
        end
    end

    return false
end


function inv_manager:update_effect (hero)
    Timers:CreateTimer(1, function()
        hero.total_effect = {}
        local order = 0
        --self:GetCaster().equip_stats.effect
        --self:GetCaster().skill_bonus.effect
        if hero.equip_stats.effect ~= nil then
            for k,v in pairs(hero.equip_stats.effect) do
                hero.total_effect[order] = v
                order = order + 1
            end
        end
        if hero.skill_bonus.effect ~= nil then
            for k,v in pairs(hero.skill_bonus.effect) do
                hero.total_effect[order] = v
                order = order + 1
            end
        end 

        for k,v in pairs(hero.total_effect) do
            LinkLuaModifier( "lua_hero_effect_"..v, "effect/"..v..".lua", LUA_MODIFIER_MOTION_NONE )
            if hero:HasModifier("lua_hero_effect_"..v) == false then
                hero:AddNewModifier(hero, nil, "lua_hero_effect_"..v, nil)
                Timers:CreateTimer(1, function()
                    if have_effect(hero.total_effect,v) == false then
                        hero:RemoveModifierByName("lua_hero_effect_"..v) 
                    else
                        return 1.0 -- Rerun this timer every 30 game-time seconds 
                    end
                end)
            end
        end

        --then add modifier for each effect

        return 1.0 -- Rerun this timer every 30 game-time seconds 
    end)


end

function merge_item (item,item_info)
    for k,v in pairs(item_info) do
        item[k] = item_info[k]
    end
    return item
end

function tableMerge(t2, t1)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            print (t1)
            t1[k] = v
        end
    end
    return t1
    
end

function inv_manager:Calculate_stats(hero) -- call this when equipement is modified (equip new item , load caracter , weapon broke down)
    local stats= {}
    stats.effect = {} --here goes every effect an item/equipement add (every modifier on hit ie : chance to stun on hit , modifier )
    stats.damage = 0
    stats.attack_speed = 0
    stats.range = 0
    stats.armor = 0
    stats.m_ress = 0
    stats.hp = 0
    stats.hp_regen = 0
    stats.mp = 0
    stats.mp_regen = 0
    stats.movespeed = 0
    stats.dodge = 0
    stats.ls = 0
    stats.loh = 0

    stats = self:calc_stat_item(hero.equipement.weapon,stats)
    stats = self:calc_stat_item(hero.equipement.chest_armor,stats)
    stats = self:calc_stat_item(hero.equipement.legs_armor,stats)
    stats = self:calc_stat_item(hero.equipement.helmet,stats)
    stats = self:calc_stat_item(hero.equipement.gloves,stats)
    stats = self:calc_stat_item(hero.equipement.boots,stats)

    --stats = self:calc_stat_item(hero.equipement.shield,stats) must be done later  , it'll have to check if weapon if 2 handed or not, need to fix some other bug before working on this ^^

    --stats = self:calc_stat_item(hero.equipement.necklace,stats)
    --stats = self:calc_stat_item(hero.equipement.earring1,stats)
    --stats = self:calc_stat_item(hero.equipement.earring2,stats)

    hero.equip_stats = stats
    --to add : a function that add hero side stats (levels...) and apply them
    local key = "player_"..hero:GetPlayerID()
    inv_manager:save_inventory(hero)
    CustomNetTables:SetTableValue( "stats",key, {equip_stats = hero.equip_stats,skill_stats = hero.skill_bonus,hero_stats = hero.hero_stats,Name = hero:GetUnitName(),LVL = hero.Level,stats_points = hero.stats_points } )
    CreateItem("item_void", hero, hero) 
    
end

function inv_manager:Init_Hero_Stat()
    local stats = {}
    stats.damage = 0
    stats.attack_speed = 0
    stats.range = 0
    stats.armor = 0
    stats.m_ress = 0
    stats.hp = 0
    stats.hp_regen = 0
    stats.mp = 0
    stats.mp_regen = 0
    stats.movespeed = 0
    stats.dodge = 0
    stats.ls = 0
    stats.loh = 0
    stats.str = 0
    stats.agi = 0
    stats.int = 0

    return stats
end

function inv_manager:Create_Inventory(hero) -- call this when the hero entity is created
    hero.inventory = {}
    hero.equipement = {}
    hero.item_bar = {}
    hero.Level = 1
    hero.stats_points = 0
    hero.XP = 0
    hero.CD = 0
    inv_manager:update_effect (hero)
    inv_manager:Calculate_stats(hero)
    hero.hero_stats = inv_manager:Init_Hero_Stat()
    inv_manager:Calculate_stats(hero)
    inv_manager:save_inventory(hero)
    

end

function inv_manager:Add_Item(hero,item) --will be called when a item is purshased or picked up
    local inventory = hero.inventory
    if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    if item ~= nil then
        item.metatable = nil
        local item = copy(item)
        print ("item is added")
        if item.stackable == true then
            print ("item is stackable")
            item_name = item.Name
            for i=1,size do
                if inventory[i]~= nil and inventory[i].Name== item_name then
                    print ("item is stacked")
                    hero.inventory[i].ammount = inventory[i].ammount + item.ammount
                    inv_manager:save_inventory(hero)
                    return
                elseif i==size and #inventory<size+1 then 
                    print ("item_added to inventory")
                    inv_manager:sort( hero )
                    table.insert(hero.inventory,item)
                    hero:RemoveItem(item)
                    inv_manager:save_inventory(hero)
                    return
                elseif i==size and #inventory>=size+1 then 
                    print ("inventory is full")
                    inv_manager:drop(item,hero:GetOrigin())
                    hero:RemoveItem(item)
                    Notifications:Bottom(hero:GetPlayerID(), {text="#NOSLOT",duration=2,style={color="red"}})
                    inv_manager:save_inventory(hero)
                    return
                end
            end
        else
            if #inventory >= size+1 then
                print ("inventory is full")
                inv_manager:drop(item,hero:GetOrigin())
                hero:RemoveItem(item)
                Notifications:Bottom(hero:GetPlayerID(), {text="#NOSLOT",duration=2,style={color="red"}})
                inv_manager:save_inventory(hero)
                    return
            else
                print ("item_added to inventory")
                table.insert(hero.inventory,item)
                inv_manager:sort( hero )
                hero:RemoveItem(item)
                inv_manager:save_inventory(hero)
                    return
            end
        end
        
    else
        if item == nil then print ("item is nil")
        else print ("error , item not item (LOGIC BITCH)")
        end
    end

end


function inv_manager:sort( hero )
    for i=1,#hero.inventory do
        if hero.inventory[i] == nil then
            if i<#hero.inventory then 
                hero.inventory[i] = hero.inventory[#hero.inventory] 
                hero.inventory[#hero.inventory] = nil
           end
        end
    end
end


function inv_manager:drop(item,pos)

            local Item = CreateItem(item.item_name, owner, owner) 
            local drop = CreateItemOnPositionForLaunch(pos, Item )
            pos = pos+RandomVector(RandomFloat(150,200))
            Item:LaunchLoot(false, 200, 0.75,pos)
end
      --TBD : SUPPORT ITEM STACK
function inv_manager:drop_Item(hero,inv_slot) --will be called when player want to put an item on the ground
    local inventory = hero.inventory
     if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    if inv_slot > 0 and inv_slot <= size then
        local item = inventory[inv_slot]
        if item ~= nil then
            if item.Equipement ~= true then
                inv_manager:drop(item,hero:GetOrigin())
            end
            if item.ammount ~= nil and item.ammount > 1 then
                hero.inventory[inv_slot].ammount = item.ammount - 1
            end
            hero.inventory[inv_slot] = nil
            inv_manager:sort( hero )
            inv_manager:save_inventory(hero)
        else
            Notifications:Bottom(hero:GetPlayerID(), {text="#EMPTY_SLOT",duration=2,style={color="red"}})
        end
    else
        print ("Slot number is invalid or inventory don't exist")
    end
end
function inv_manager:Unequip(hero,slot_name) --also equip item
    local inventory = hero.inventory
     if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    if #inventory< size+1 then
        if slot_name == "weapon" then
            table.insert(hero.inventory,hero.equipement.weapon)
            inv_manager:sort( hero )
            hero.equipement.weapon= nil
            print (hero.inventory.weapon)
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "chest" then
            table.insert(hero.inventory,hero.equipement.chest_armor)
            inv_manager:sort( hero )
            hero.equipement.chest_armor= nil
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "legs" then
            table.insert(hero.inventory,hero.equipement.legs_armor)
            inv_manager:sort( hero )
            hero.equipement.legs_armor = nil
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "gloves" then
            table.insert(hero.inventory,hero.equipement.gloves)
            inv_manager:sort( hero )
            hero.equipement.gloves= nil
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "boots" then
            table.insert(hero.inventory,hero.equipement.boots)
            inv_manager:sort( hero )
            hero.equipement.boots= nil
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "helmet" then
            table.insert(hero.inventory,hero.equipement.helmet)
            inv_manager:sort( hero )
            hero.equipement.helmet= nil
            inv_manager:Calculate_stats(hero)

        else
            print ("Invalid Slot name given ;Valid item slot are : 'weapon' 'chest' 'helmet' legs' 'gloves' 'boots' ")
        end
        inv_manager:save_inventory(hero)
    else
        print ("Your inventory is full")
    end
end
function inv_manager:Use_Item(hero,inv_slot,IB) --also equip item
    if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    if inv_slot == nil then return end
    local item = nil
    if hero.CD == nil then hero.CD = 0 end
    if IB == 1 then
        print ("ok")
        item = hero.item_bar[inv_slot]
    else
        item = hero.inventory[inv_slot] 
    end
    if inv_slot > 0 and inv_slot <= size then
        if item ~= nil then
            print ("equip/use item")
            print (item.Equipement)
            if item.Equipement == true then
                print ("equip item")
                if item.cat == "weapon" then
                    print ("equip weapon")
                    if hero.equipement.weapon == nil then
                        hero.equipement.weapon = item
                        hero.inventory[inv_slot] = nil
                    else
                        local item_to_eq = hero.inventory[inv_slot]
                        hero.inventory[inv_slot] = hero.equipement.weapon
                        hero.equipement.weapon = item_to_eq
                    end
                end
                if item.cat == "chest" then
                    if hero.equipement.chest_armor == nil then
                        hero.equipement.chest_armor = item
                        hero.inventory[inv_slot] = nil
                    else
                        hero.inventory[inv_slot] = hero.equipement.chest_armor
                        hero.equipement.chest_armor = item
                    end
                end
                if item.cat == "legs" then
                    if hero.equipement.legs_armor == nil then
                        hero.equipement.legs_armor = item
                        hero.inventory[inv_slot] = nil
                    else
                        hero.inventory[inv_slot] = hero.equipement.legs_armor
                        hero.equipement.legs_armor = item
                    end
                end
                if item.cat == "helmet" then
                    if hero.equipement.helmet == nil then
                        hero.equipement.helmet = item
                        hero.inventory[inv_slot] = nil
                    else
                        hero.inventory[inv_slot] = hero.equipement.helmet
                        hero.equipement.helmet = item
                    end
                end
                if item.cat == "gloves" then
                    if hero.equipement.gloves == nil then
                        hero.equipement.gloves = item
                        hero.inventory[inv_slot] = nil
                    else
                        hero.inventory[inv_slot] = hero.equipement.gloves
                        hero.equipement.gloves = item
                    end
                end
                if item.cat == "boots" then
                    if hero.equipement.boots == nil then
                        hero.equipement.boots = item
                        hero.inventory[inv_slot] = nil
                    else
                        hero.inventory[inv_slot] = hero.equipement.boots
                        hero.equipement.boots = item
                    end
                end
                inv_manager:sort( hero )
            elseif item.cat == "consumable" then
                print ('item is consumable')
                if hero.CD > 0 then
                    print (hero.CD)
                    return
                end
                if item.ammount > 1 then
                    inv_manager:Use_consumable(hero,item)
                    if IB == 1 then
                        hero.item_bar[inv_slot].ammount = item.ammount - 1
                    else
                        hero.inventory[inv_slot].ammount = item.ammount - 1
                    end
                else
                    inv_manager:Use_consumable(hero,item)
                    if IB == 1 then
                        hero.item_bar[inv_slot] = nil
                    else
                        hero.inventory[inv_slot] = nil
                    end
                    inv_manager:sort( hero )
                end
            end
            inv_manager:save_inventory(hero)
            inv_manager:Calculate_stats(hero)
        else
            Notifications:Bottom(hero:GetPlayerID(), {text="#EMPTY_SLOT",duration=2,style={color="red"}})
        end
    else
        print ("Slot number is invalid or inventory don't exist")
    end
end

function inv_manager:Use_consumable(hero,item)   
    print ("TEST")
    local time = 0
    hero.CD = 15
    Timers:CreateTimer(0.25,function()
            if hero.CD > 0 then
                hero.CD = hero.CD -0.25
                return 0.25
            end
        end)
    if item.duration == 0 or item.duration == nil then item.duration = 0.2 end
    Timers:CreateTimer(0.2,function()
        if time <= item.duration then
            time = time + 0.2
            if item.heal ~= nil then
                hero:SetHealth((hero:GetHealth() + (item.heal/(5*item.duration)) ))
            end
            if item.heal_mana ~= nil then
                hero:SetMana((hero:GetMana() + (item.heal_mana/(5*item.duration)) ))
            end
            return 0.2
        else

        end
    end)
end

  --TBD : SUPPORT ITEM STACK
function inv_manager:Sell_Item(hero,inv_slot,ammount) --sell item if the player is in a shop
    local inventory = hero.inventory
     if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    if ammount ~= nil and ammount<0 then ammount = nil end
    if inv_slot > 0 and inv_slot <= size then
        local item = inventory[inv_slot]
        if item ~= nil then
            if hero.Isinshop == true then   --will be seen later...
                if item.stack == true then
                    if ammount == nil or ammount >= item.ammount then
                        PlayerResource:ModifyGold(hero:GetPlayerID() , item.price*item.ammount*0.75 , true, 6)
                        hero.inventory[inv_slot] = nil
                    else
                        PlayerResource:ModifyGold(hero:GetPlayerID() , item.price*ammount*0.75 , true, 6)
                        hero.inventory[inv_slot].ammount = item.ammount - ammount
                    end
                else
                    PlayerResource:ModifyGold(hero:GetPlayerID() , item.price*0.75, true, 6)
                    hero.inventory[inv_slot] = nil
                end

                inv_manager:sort( hero )
                inv_manager:save_inventory(hero)
            else
                Notifications:Bottom(hero:GetPlayerID(), {text="#NOSHOP",duration=2,style={color="red"}})
            end
        else
            Notifications:Bottom(hero:GetPlayerID(), {text="#EMPTY_SLOT",duration=2,style={color="red"}})
        end
    else
        print ("Slot number is invalid or inventory don't exist")
    end
end
 
--TBD : make an "evolve" option for weapon , allowing them to upgrade unto a supperior weapon tier, (may be unique weapon , or maybe dropable , IDK yet, should make a strowpoll for)
function inv_manager:evolve_weapon(hero,way)
    local weapon = hero.equipement.weapon
    if way > #weapon.evolution then return weapon end
end



function inv_manager:upgrade_weapon(hero,stat) --will be called when a weapon is upgraded with a smith
    local weapon = hero.equipement.weapon
    if weapon ~= nil then
        if weapon.upgrade_point > 0 then
            if stat == "damage" then
                if weapon.damage_upgrade[weapon.dmg_lvl] > 0 and weapon.dmg_lvl < 51 then --limit weapon damage upgrade , similar stuff will be add to other upgrades
                    hero.equipement.weapon.damage = weapon.damage + weapon.damage_upgrade[weapon.dmg_lvl]
                    hero.equipement.weapon.dmg_lvl = weapon.dmg_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerID(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat == "attack_speed" then
                if weapon.as_upgrade[weapon.as_lvl] > 0 and weapon.as_lvl < 51 then
                    hero.equipement.weapon.attack_speed = weapon.attack_speed + weapon.as_upgrade[weapon.as_lvl]
                    hero.equipement.weapon.as_lvl = weapon.as_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerID(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat == "range" then
                if weapon.range_upgrade[weapon.range_lvl] > 0 and weapon.range_lvl < 51 then
                    hero.equipement.weapon.range = weapon.range + weapon.range_upgrade[weapon.range_lvl]
                    hero.equipement.weapon.range_lvl = weapon.range_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerID(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat == "durability" then
                if weapon.range_upgrade > 0 then
                    hero.equipement.weapon.max_dur = weapon.max_dur + weapon.dur_upgrade
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerID(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            else
                print ("invalid upgrade name , valud one are :'damage','attack_speed','range','durability'")
            end
            inv_manager:save_inventory(hero)
        else
            print ("No points to upgrade a stat")
        end
    end
end
 
function inv_manager:weapon_checklevelup(hero)
    while hero.equipement.weapon.XP >= hero.equipement.weapon.Next_Level_XP do
        hero.equipement.weapon.level = hero.equipement.weapon.level + 1
        hero.equipement.weapon.upgrade_point = hero.equipement.weapon.upgrade_point + 1
        hero.equipement.weapon.damage = hero.equipement.weapon.damage + hero.equipement.weapon.dmg_grow
        hero.equipement.weapon.attack_speed = hero.equipement.weapon.attack_speed + hero.equipement.weapon.as_grow
        hero.equipement.weapon.range = hero.equipement.weapon.range + hero.equipement.weapon.range_grow
        hero.equipement.weapon.Next_Level_XP = inv_manager.XP_Table[hero.equipement.weapon.level]
        inv_manager:Calculate_stats(hero)
        inv_manager:save_inventory(hero)
        print ("Weapon Level up!")
        --up stats
    end
end


function inv_manager:transmute_weapon(hero,inv_slot) --will be called when a weapon is upgraded with a smith
    local inventory = hero.inventory
     if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    if hero.equipement.weapon ~= nil then
        if inv_slot > 0 and size <= 20 then
            local item = inventory[inv_slot]
            if item.cat == "weapon" then
                hero.equipement.weapon.XP = hero.equipement.weapon.XP + (item.XP/2) + 10*item.level
                inv_manager:weapon_checklevelup(hero)
                inventory[inv_slot] = nil
                inv_manager:sort( hero )
            else
                Notifications:Bottom(hero:GetPlayerID(), {text="IS_NOT_WEAPON",duration=2,style={color="red"}})
            end
        else
            print ("Slot number is invalid or inventory don't exist")
        end
        inv_manager:save_inventory(hero)
    else
        Notifications:Bottom(hero:GetPlayerID(), {text="#NO_WEAPON",duration=2,style={color="red"}})
    end
end

--[[
        Here will go to the KV files for each item

    EQUIPEMENT ONLY
        Equipement = true
        cat = weapon
        damage = 5
        attack_speed = 100
        loh = 0
        ls = 0
        effect = {
        "1" "effect1"} 
        effect will be read , i'll make a function that add a modifier depend on effect name 
        
        hp = 0
        mp = 0
        hp_regen = 0 
        mp_regen = 0
        armor = 0
        m_ress = 0
        movespeed = 0

        if a value is 0 , just don't write it , game will automaticaly set it to 0



    WEAPON ONLY :

        dmg_mult = 1
        as_mult = 0.75
        range_mult = 1

        repair_cost_base = 0.05

        range = 40
        ranged = False

        dmg_grow = 2
        range_grow = 1
        as_grow = 5

        
        



        

    
        -Here is set in lua when an item is created to keep KV file as small as possible 

        

]]
