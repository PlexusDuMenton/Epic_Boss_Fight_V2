if inv_manager == nil then
    DebugPrint( 'created inv_manager' )
    inv_manager = class({})
    print ("CREATED INVENTORY MANAGER")
end

 --INVENTORY MANAGER IS WHAT MAKE ALL THE INVENTORY SYSTEM WORK , FROM CREATION OF ITEM  TO REPAIR ,UPGRADE, AND STATS CALCULATION

inv_manager.XP_Table = {}
inv_manager.XP_Table[0] = 0
for i=1,200 do
  inv_manager.XP_Table[i] = math.floor(i*19 + i^2) + inv_manager.XP_Table[i-1]
end
 
require('libraries/notifications')


function inv_manager:Create_Item(Item)
    local item = Item
    local item_list = GameRules.items
    local item_info = item_list[item:GetName()]
    if item_info == nil then 
        print ("WHAT THE FUCK ARE YOU DOING KID , THERE IS NO KV FILE FOR THIS ITEM ARE YOU AN FUCKING LAZYBOY ?")
        return item 
    end
    item = merge_item(item,item_info)
    print ("item merged with his info")
    if item.stack == 1 then item.stack = true end
    if item.stack == true then
        item.ammount = 1
    end
    if item.Equipement == 1 then item.Equipement = true end
    if item.Equipement == true then
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
    stats.m_ress = stats.m_ress + eq_slot.m_ress
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
    print ("damage :", hero.equip_stats.damage,"range :",hero.equip_stats.range,"attack speed :",hero.equip_stats.attack_speed,"armor :",hero.equip_stats.armor) -- just some print to check if value are indeed modified
    
end

  
function inv_manager:Create_Inventory(hero) -- call this when the hero entity is created
    hero.inventory = {}
    hero.equipement = {weapon = {} ,chest_armor = {} ,legs_armor = {} ,helmet = {} ,gloves = {} ,boots = {} }
    inv_manager:Calculate_stats(hero)
end

function inv_manager:Add_Item(hero,item) --will be called when a item is purshased or picked up
    local inventory = hero.inventory
    if item ~= nil then
        print ("item is added")
        if item.stackable == true then
            print ("item is stackable")
            item_name = item.Name
            for i=1,20 do
                if inventory[i]~= nil and inventory[i].Name== item_name then
                    print ("item is stacked")
                    hero.inventory[i].ammount = inventory[i].ammount + item.ammount
                elseif i==20 and #inventory<21 then 
                    print ("item_added to inventory")
                    table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                    table.insert(hero.inventory,item)
                    hero:RemoveItem(item)
                elseif i==20 and #inventory>=21 then 
                    print ("inventory is full")
                    inv_manager:drop(item,hero:GetOrigin())
                    hero:RemoveItem(item)
                    Notifications:Bottom(hero:GetPlayerOwner(), {text="#NOSLOT",duration=2,style={color="red"}})
                end
            end
        else
            if #inventory >= 21 then
                print ("inventory is full")
                inv_manager:drop(item,hero:GetOrigin())
                hero:RemoveItem(item)
                Notifications:Bottom(hero:GetPlayerOwner(), {text="#NOSLOT",duration=2,style={color="red"}})
            else
                print ("item_added to inventory")
                table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                table.insert(hero.inventory,item)
                hero:RemoveItem(item)
            end
        end
    else
        if item == nil then print ("item is nil")
        else print ("error , item not item (LOGIC BITCH)")
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
    if inv_slot >= 0 and inv_slot < 20 then
        local item = inventory[inv_slot]
        if item ~= nil then
            inv_manager:drop(item,hero:GetOrigin())
            hero.inventory[inv_slot] = nil
            table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
        else
            Notifications:Bottom(hero:GetPlayerOwner(), {text="#EMPTY_SLOT",duration=2,style={color="red"}})
        end
    else
        print ("Slot number is invalid or inventory don't exist")
    end
end
function inv_manager:Unequip(hero,slot_name) --also equip item
    local inventory = hero.inventory
    if #inventory< 21 then
        if slot_name == "weapon" then
            table.insert(hero.inventory,hero.equipement.weapon)
            table.sort(hero.inventory,
                        function (v1, v2)
                        if v2.Name~= nil and v1.Name ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
            hero.equipement.weapon= nil
            print (hero.inventory.weapon)
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "chest" then
            table.insert(hero.inventory,hero.equipement.chest_armor)
            table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
            hero.equipement.chest_armor= nil
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "legs" then
            table.insert(hero.inventory,hero.equipement.legs_armor)
            table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
            hero.equipement.legs_armor = nil
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "gloves" then
            table.insert(hero.inventory,hero.equipement.gloves)
            table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
            hero.equipement.gloves= nil
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "boots" then
            table.insert(hero.inventory,hero.equipement.boots)
            table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
            hero.equipement.boots= nil
            inv_manager:Calculate_stats(hero)

        elseif slot_name == "helmet" then
            table.insert(hero.inventory,hero.equipement.helmet)
            table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
            hero.equipement.helmet= nil
            inv_manager:Calculate_stats(hero)

        else
            print ("Invalid Slot name given ;Valid item slot are : 'weapon' 'chest' 'helmet' legs' 'gloves' 'boots' ")
        end
    else
        print ("Your inventory is full")
    end
end
function inv_manager:Use_Item(hero,inv_slot) --also equip item
    local inventory = hero.inventory
    if inv_slot > 0 and inv_slot <= 20 then
        local item = inventory[inv_slot]
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
                        table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                    else
                        hero.inventory[inv_slot] = hero.equipement.weapon
                        hero.equipement.weapon = item
                    end
                end
                if item.cat == "chest" then
                    if hero.equipement.chest_armor == nil then
                        hero.equipement.chest_armor = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                    else
                        hero.inventory[inv_slot] = hero.equipement.chest_armor
                        hero.equipement.chest_armor = item
                    end
                end
                if item.cat == "legs" then
                    if hero.equipement.legs_armor == nil then
                        hero.equipement.legs_armor = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                    else
                        hero.inventory[inv_slot] = hero.equipement.legs_armor
                        hero.equipement.legs_armor = item
                    end
                end
                if item.cat == "helmet" then
                    if hero.equipement.helmet == nil then
                        hero.equipement.helmet = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                    else
                        hero.inventory[inv_slot] = hero.equipement.helmet
                        hero.equipement.helmet = item
                    end
                end
                if item.cat == "gloves" then
                    if hero.equipement.gloves == nil then
                        hero.equipement.gloves = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                    else
                        hero.inventory[inv_slot] = hero.equipement.gloves
                        hero.equipement.gloves = item
                    end
                end
                if item.cat == "boots" then
                    if hero.equipement.boots == nil then
                        hero.equipement.boots = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                    else
                        hero.inventory[inv_slot] = hero.equipement.boots
                        hero.equipement.boots = item
                    end
                end
            elseif item.consommable == true then
                if item.ammount > 1 then
                    item:use(hero)
                    hero.inventory[inv_slot].ammount = item.ammount - 1
                else
                    item:use(hero)
                    hero.inventory[inv_slot] = nil
                    table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
                end
            end
            inv_manager:Calculate_stats(hero)
        else
            Notifications:Bottom(hero:GetPlayerOwner(), {text="#EMPTY_SLOT",duration=2,style={color="red"}})
        end
    else
        print ("Slot number is invalid or inventory don't exist")
    end
end

  --TBD : SUPPORT ITEM STACK
function inv_manager:Sell_Item(hero,inv_slot,ammount) --sell item if the player is in a shop
    local inventory = hero.inventory
    if ammount ~= nil and ammount<0 then ammount = nil end
    if inv_slot > 0 and inv_slot <= 20 then
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

                table.sort(hero.inventory,
                        function (v1, v2)
                        if v2~= nil and v1 ~= nil then
                            return v1.Name < v2.Name
                        end
                       end )
            else
                Notifications:Bottom(hero:GetPlayerOwner(), {text="#NOSHOP",duration=2,style={color="red"}})
            end
        else
            Notifications:Bottom(hero:GetPlayerOwner(), {text="#EMPTY_SLOT",duration=2,style={color="red"}})
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
                if weapon.damage_upgrade > 0 and weapon.dmg_lvl < 51 then --limit weapon damage upgrade , similar stuff will be add to other upgrades
                    hero.equipement.weapon.damage = weapon.damage + weapon.damage_upgrade[weapon.dmg_lvl]
                    hero.equipement.weapon.dmg_lvl = weapon.dmg_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerOwner(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat == "attack_speed" then
                if weapon.AS_upgrade > 0 and weapon.as_lvl < 51 then
                    hero.equipement.weapon.attack_speed = weapon.attack_speed + weapon.as_upgrade[weapon.as_lvl]
                    hero.equipement.weapon.as_lvl = weapon.as_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerOwner(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat == "range" then
                if weapon.range_upgrade > 0 and weapon.range_lvl < 51 then
                    hero.equipement.weapon.range = weapon.range + weapon.range_upgrade[weapon.range_lvl]
                    hero.equipement.weapon.range_lvl = weapon.range_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerOwner(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat == "durability" then
                if weapon.range_upgrade > 0 then
                    hero.equipement.weapon.max_dur = weapon.max_dur + weapon.dur_upgrade
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerOwner(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            else
                print ("invalid upgrade")
            end
        else
            print ("No points to upgrade a stat")
        end
    end
end
 
function inv_manager:weapon_checklevelup(hero)
    while hero.equipement.weapon.XP >= hero.equipement.weapon.XP_Table[hero.equipement.weapon.LVL] do
        hero.equipement.weapon.LVL = hero.equipement.weapon.LVL + 1
        hero.equipement.weapon.upgrade_point = hero.equipement.weapon.upgrade_point + 1
        hero.equipement.weapon.damage = hero.equipement.weapon.damage + hero.equipement.weapon.dmg_grow
        hero.equipement.weapon.attack_speed = hero.equipement.weapon.attack_speed + hero.equipement.weapon.as_grow
        hero.equipement.weapon.range = hero.equipement.weapon.range + hero.equipement.weapon.range_grow
        --up stats
    end
end

 
function inv_manager:repair_weapon(hero) --will be called when a weapon is repaired
    if hero ~= nil then
        price = (hero.equipement.weapon.LVL/50 + hero.equipement.weapon.repair_cost_base) * (hero.equipement.weapon.max_dur - hero.equipement.weapon.durability)
        if hero.equipement.weapon ~= nil then
            if hero:GetGold() >= price then
                hero.equipement.weapon.durability = hero.equipement.weapon.max_dur
                hero:ModifyGold(-price, false, 0) --may no work , idk if modify gold love negative value (i guess it's okay , but you know, volvo...)
            else
                Notifications:Bottom(hero:GetPlayerOwner(), {text="#NO_GOLD",duration=2,style={color="red"}})
            end
        else
            Notifications:Bottom(hero:GetPlayerOwner(), {text="#NO_WEAPON",duration=2,style={color="red"}})
        end
    end
end

function inv_manager:transmute_weapon(hero,inv_slot) --will be called when a weapon is upgraded with a smith
    local inventory = hero.inventory
    if hero.equipement.weapon ~= nil then
        if inv_slot > 0 and inv_slot <= 20 then
            local item = inventory[inv_slot]
            if item.cat == "weapon" then
                hero.equipement.weapon.XP = hero.equipement.weapon.XP + (item.XP/2) + 10*item.LVL
                inv_manager:weapon_checklevelup(hero)
                inventory[inv_slot] = nil
            else
                Notifications:Bottom(hero:GetPlayerOwner(), {text="IS_NOT_WEAPON",duration=2,style={color="red"}})
            end
        else
            print ("Slot number is invalid or inventory don't exist")
        end
    else
        Notifications:Bottom(hero:GetPlayerOwner(), {text="#NO_WEAPON",duration=2,style={color="red"}})
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
        effect = {"effect1","effect2"} 
        effect will be read , i'll make a function thas add a modifier depend on effect name 
        
        hp = 0
        mp = 0
        hp_regen = 0 
        mp_regen = 0
        armor = 0
        m_ress = 0
        movespeed = 0

        if a value is 0 , just don't write it , game will automaticaly set it to 0



    WEAPON ONLY :
        max_dur = 200
        dur_upgrade = 50

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