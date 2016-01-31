if inv_manager == nil then
    DebugPrint( 'created inv_manager' )
    _G.inv_manager = class({})
end
 --INVENTORY MANAGER IS WHAT MAKE ALL THE INVENTORY SYSTEM WORK , FROM CREATION OF ITEM  TO REPAIR ,UPGRADE, AND STATS CALCULATION

inv_manager.XP_Table = {}
for i=1,200 do
  inv_manager.XP_Table[i] = math.floor(i*19 + i^2) + inv_manager.XP_Table[i-1]
end
 
require('libraries/notifications')

function inv_manager:calc_stat_item(equipement,stats)
    
    local eq_slot = equipement 

    --[[i check if a value is nil , if it's the case i set it to 0, i prefer use this way than put in each item those basic value
    to gain some memory size (you know , optimisation (while this code must be the least optimised cheat cause i suck)) especialy when
    saving items
    ]]
    if not eq_slot.damage then eq_slot.damage = 0 end
    if not eq_slot.attack_speed then eq_slot.attack_speed = 0 end
    if not eq_slot.range then eq_slot.range = 0 end
    if not eq_slot.armor then eq_slot.armor = 0 end
    if not eq_slot.m_ress then eq_slot.m_ress = 0 end
    if not eq_slot.hp then eq_slot.hp = 0 end
    if not eq_slot.hp_regen then eq_slot.hp_regen = 0 end
    if not eq_slot.mp then eq_slot.mp = 0 end
    if not eq_slot.mp_regen then eq_slot.mp_regen = 0 end
    if not eq_slot.ls then eq_slot.ls = 0 end
    if not eq_slot.loh then eq_slot.loh = 0 end
    if not eq_slot.effect then eq_slot.effect = {}


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
    stats.ls = stats.ls + eq_slot.ls --Life Steal (a percent of your current damage)
    stats.loh = stats.loh + eq_slot.loh --Life On Hit , each time you hit , you regain this ammount of Health
    --Merge effect of all object
    stats.effect = tableMerge(stats.effect,eq_slot.effect)


    return stats
end

function tableMerge(t1, t2)
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
    stats.ls = 0
    stats.loh = 0




    stats = self:calc_stat_item(hero.equipement.weapon,stats)
    stats = self:calc_stat_item(hero.equipement.chest_armor,stats)
    stats = self:calc_stat_item(hero.equipement.legs_armor,stats)
    stats = self:calc_stat_item(hero.equipement.helmet,stats)
    stats = self:calc_stat_item(hero.equipement.gloves,stats)
    stats = self:calc_stat_item(hero.equipement.boots,stats)

    --stats = self:calc_stat_item(hero.equipement.necklace,stats)
    --stats = self:calc_stat_item(hero.equipement.earring1,stats)
    --stats = self:calc_stat_item(hero.equipement.earring2,stats)

    hero.equip_stats = stats
    --to add : a function that add hero side stats (levels...) and apply them
    print (hero.equip_stats.damage,hero.equip_stats.range,hero.equip_stats.attack_speed,hero.equip_stats.armor)
end

  
function inv_manager:Create_Inventory(hero) -- call this when the hero entity is created
    hero.inventory = {}
    hero.equipement = {weapon = {} ,chest_armor = {} ,legs_armor = {} ,helmet = {} ,gloves = {} ,boots = {} }
end

function inv_manager:Create_Item(Item)
    local item = Item or return nil
    local item_list = GameRules.items
    local item_info = item_list[item:GetName()]
    if item_info == nil then 
        print ("WHAT THE FUCK ARE YOU DOING KID , THERE IS NO KV FILE FOR THIS ITEM ARE YOU AN FUCKING LAZYBOY ?")
        return item 
    end
    item = tableMerge(item_info,item)
    if item.stack == true then
        item.ammount = 1
    end
    if item.Equipement == true then
        if item.cat == "weapon" then
            item.durability = weapon.max_dur
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
    end
    return item
end


   --TBD : SUPPORT ITEM STACK
function inv_manager:Add_Item(hero,Item) --will be called when a item is purshased or picked up
    local inventory = hero.inventory
    if item ~= nil and item:IsItem() then
        if item.stackable == true then
            item_name = item:GetName()
            for i=0,19 do
                if inventory[i]~= nil and inventory[i]:GetName() = item_name then
                    hero.inventory[i].ammount = inventory[i].ammount + item.ammount
                end
        else
            if #inventory >= 20 then
                DropItemAtPositionImmediate(item,hero:GetOrigin())
            else
                table.sort(hero.inventory)
                table.insert(hero.inventory,item)
                hero:RemoveItem(item)
                Notifications:Bottom(hero:GetPlayerOwner(), {text="#NOSLOT",duration=2,style={color="red"}})
            end
        end
    end
end
      --TBD : SUPPORT ITEM STACK
function inv_manager:drop_Item(hero,inv_slot) --will be called when player want to put an item on the ground
    local inventory = hero.inventory
    if inv_slot >= 0 and inv_slot < 20 then
        local item = inventory[inv_slot]
        if item ~= nil then
            DropItemAtPositionImmediate(item,hero:GetOrigin())
            hero.inventory[inv_slot] == nil
            table.sort(hero.inventory)
        else
            Notifications:Bottom(hero:GetPlayerOwner(), {text="#EMPTY_SLOT",duration=2,style={color="red"}})
        end
    else
        print ("Slot number is invalid or inventory don't exist")
    end
end
  --TBD : SUPPORT ITEM STACK
function inv_manager:Use_Item(hero,inv_slot) --also equip item
    local inventory = hero.inventory
    if inv_slot >= 0 and inv_slot < 20 then
        local item = inventory[inv_slot]
        if item ~= nil then
            if item.Equipement == true then
                if item.cat == "weapon" then
                    if hero.equipement.weapon == nil then
                        hero.equipement.weapon = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory)
                    else
                        hero.inventory[inv_slot] = hero.equipement.weapon
                        hero.equipement.weapon = item
                    end
                end
                if item.cat == "chest" then
                    if hero.equipement.chest_armor == nil then
                        hero.equipement.chest_armor = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory)
                    else
                        hero.inventory[inv_slot] = hero.equipement.chest_armor
                        hero.equipement.chest_armor = item
                    end
                end
                if item.cat == "legs" then
                    if hero.equipement.legs_armor == nil then
                        hero.equipement.legs_armor = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory)
                    else
                        hero.inventory[inv_slot] = hero.equipement.legs_armor
                        hero.equipement.legs_armor = item
                    end
                end
                if item.cat == "helmet" then
                    if hero.equipement.helmet == nil then
                        hero.equipement.helmet = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory)
                    else
                        hero.inventory[inv_slot] = hero.equipement.helmet
                        hero.equipement.helmet = item
                    end
                end
                if item.cat == "gloves" then
                    if hero.equipement.gloves == nil then
                        hero.equipement.gloves = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory)
                    else
                        hero.inventory[inv_slot] = hero.equipement.gloves
                        hero.equipement.gloves = item
                    end
                end
                if item.cat == "boots" then
                    if hero.equipement.boots == nil then
                        hero.equipement.boots = item
                        hero.inventory[inv_slot] = nil
                        table.sort(hero.inventory)
                    elses
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
                    table.sort(hero.inventory)
                end
            end
        else
            Notifications:Bottom(hero:GetPlayerOwner(), {text="#EMPTY_SLOT",duration=2,style={color="red"}})
        end
    else
        print ("Slot number is invalid or inventory don't exist")
    end
end

  --TBD : SUPPORT ITEM STACK
function inv_manager:Sell_Item(hero,inv_slot) --sell item if the player is in a shop
    local inventory = hero.inventory
    if inv_slot >= 0 and inv_slot < 20 then
        local item = inventory[inv_slot]
        if item ~= nil then
            if hero.Isinshop then
                if item.stack == true then
                    ModifyGold(hero:GetPlayerID() , item.price*item.ammount , true, 0)
                else
                    ModifyGold(hero:GetPlayerID() , item.price , true, 0)
                end
                hero.inventory[inv_slot] = nil
                table.sort(hero.inventory)
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
 
function inv_manager:upgrade_weapon(hero,stat) --will be called when a weapon is upgraded with a smith
    local weapon = hero.equipement.weapon
    if weapon ~= nil then
        if weapon.upgrade_point > 0 then
            if stat = "damage" then
                if weapon.damage_upgrade > 0 and weapon.dmg_lvl < 51 then --limit weapon damage upgrade , similar stuff will be add to other upgrades
                    hero.equipement.weapon.damage = weapon.damage + weapon.damage_upgrade[weapon.dmg_lvl]
                    hero.equipement.weapon.dmg_lvl = weapon.dmg_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerOwner(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat = "attack_speed" then
                if weapon.AS_upgrade > 0 and weapon.as_lvl < 51 then
                    hero.equipement.weapon.attack_speed = weapon.attack_speed + weapon.as_upgrade[weapon.as_lvl]
                    hero.equipement.weapon.as_lvl = weapon.as_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerOwner(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat = "range" then
                if weapon.range_upgrade > 0 and weapon.range_lvl < 51 then
                    hero.equipement.weapon.range = weapon.range + weapon.range_upgrade[weapon.range_lvl]
                    hero.equipement.weapon.range_lvl = weapon.range_lvl + 1
                    hero.equipement.weapon.upgrade_point = weapon.upgrade_point - 1
                else
                    Notifications:Bottom(hero:GetPlayerOwner(), {text="#CANT_UPGRADE",duration=2,style={color="red"}})
                end
            elseif stat = "durability" then
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
    while hero.equipement.weapon.XP >= hero.equipement.weapon.XP_Table[hero.equipement.weapon.LVL] then
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
        if inv_slot >= 0 and inv_slot < 20 then
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