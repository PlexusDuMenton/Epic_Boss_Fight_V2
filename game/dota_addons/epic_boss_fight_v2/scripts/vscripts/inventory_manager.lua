if inv_manager == nil then
    DebugPrint( 'created inv_manager' )
    inv_manager = class({})
    print ("CREATED INVENTORY MANAGER")
end

INVENTORY_SIZE = 30
INVENTORY_PASS_SIZE = 40
QUALITY_POWER  ={ }
QUALITY_POWER[0] = 4
QUALITY_POWER[1] = 10
QUALITY_POWER[2] = 60
QUALITY_POWER[3] = 130
QUALITY_POWER[4] = 450
QUALITY_POWER[5] = 1500
QUALITY_POWER[6] = 5000
QUALITY_POWER[7] = 10000
QUALITY_POWER[8] = 50000

function log10(number)
    if number <0 then print ("WTF") return number end
    number = math.log(number)/math.log(10)
    return number
end

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
    local inventory = hero.inventory
    --print ("YOLO TU ME VOIS ?" , dec_to_bin(42000))
    --DeepPrintTable(dec_to_bin(42000))
    local equipement = hero.equipement
    if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    CustomNetTables:SetTableValue( "inventory_player_"..hero:GetPlayerID(),"player_"..hero:GetPlayerID(), {inventory = inventory,size = size,equipement=hero.equipement,item_bar = hero.item_bar} )
end

function inv_manager:to_inv(hero,inv_slot)
    local size = 0
    local inventory = hero.inventory
    if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    local item_bar = hero.item_bar
    local item = item_bar[inv_slot]
    for i=1,size do
            if item.stackable == true then
                if inventory[i]~= nil and inventory[i].item_name== item.item_name then
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
                    Notifications:Inventory(hero:GetPlayerID(), {text="#NOSLOT_BAR",duration=2,color="FFAAAA"})
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
                    Notifications:Inventory(hero:GetPlayerID(), {text="#NOSLOT_BAR",duration=2,color="FFAAAA"})
                    return
                end
            end
            CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
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
                    if item_bar[i]~= nil and item_bar[i].item_name== item.item_name then
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
                        Notifications:Inventory(hero:GetPlayerID(), {text="#NOSLOT_BAR",duration=2,color="FFAAAA"})
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
                        Notifications:Inventory(hero:GetPlayerID(), {text="#NOSLOT_BAR",duration=2,color="FFAAAA"})
                        return
                    end
                end
            
        end
        CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
    end
end

function inv_manager:reforge(weapon)
    local item_list = GameRules.items
    local item_info = item_list[weapon.item_name]
    if item_info == nil then 
        print ("No kv file")
        return weapon
    end
    item = copy(weapon)


    if item.Equipement == true then
        if item.damage ~= nil then item.damage = math.ceil(item_info.damage + math.random(0,item_info.damage*0.2)) end
        if item.m_damage ~= nil then item.m_damage = math.ceil(item_info.m_damage + math.random(0,item_info.m_damage*0.2)) end
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
            item.Next_Level_XP = inv_manager.XP_Table[item.level]
            if item.reforgable == true then
                item.reforgable = nil
            else 
                item.XP = item.XP * 0.98
            end
        end
        return item

    else
        print ("this is not a piece of equipement")
        return weapon 
    end


end



function inv_manager:Create_Item(Item)
    local item = Item
    local item_list = GameRules.items
    local item_info = item_list[Item:GetName()]
    if item_info == nil then 
        print ("no kv file")
        return Item
    end
    item = copy(item_info)
    item.item_name = Item:GetName()
    if item.effect == nil then item.effect = {} end
    if item.stackable == 1 then item.stackable = true end
    if item.stackable == true then
        item.ammount = 1
    end
    if item.Equipement == 1 then item.Equipement = true else item.Equipement = nil end
    if item.ranged == 1 then item.ranged = true else item.ranged = nil end
    if item.magical == 1 then item.magical = true else item.magical = nil end
    if item.Soul == 1 then item.Soul = true else item.Soul = nil end
    if item.Soul == true then
        local power = math.floor((100 * (1+GameRules.loot_multiplier)^(log10(GameRules.loot_multiplier)^0.10 *0.85) ) * (0.5 + math.random()*(0.5))) * 0.01 + 1
        item.Ilevel = math.ceil((log10(power)*3)^2.75) - 1
        if item.Ilevel>MAX_LEVEL then item.Ilevel = MAX_LEVEL end
        local power_mult = 1
        if item.Ilevel>=250 then
            local random_number = math.random(10,(10000/log10(GameRules.loot_multiplier/5)))/10
            power = power*(1+math.floor(100 *(math.log(1 +((13/random_number))^10)/math.log(13)))/100)
            power_mult = (1+math.floor(100 *(math.log(1 +((13/random_number))^10)/math.log(13)))/100)

            if random_number == 1 then
                item.qualifier = "PERFECT"
            elseif random_number < 2 then
                item.qualifier = "immortal"
            elseif random_number < 4 then
                item.qualifier = "Ancient"
            elseif random_number < 10 then
                item.qualifier = "flawless"
            end
        end
        if power <= QUALITY_POWER[0] then
            item.quality = "Poor"
        elseif power <= QUALITY_POWER[1]  then
            item.quality = "Normal"
            power = power + QUALITY_POWER[0]
        elseif power <= QUALITY_POWER[2]  then
            item.quality = "Superior"
            power = power + QUALITY_POWER[1]
        elseif power <= QUALITY_POWER[3]  then
            power = power + QUALITY_POWER[2]
            item.quality = "Magic"
        elseif power <= QUALITY_POWER[4]  then
            item.quality = "Rare"
            power = power + QUALITY_POWER[3]
        elseif power <= QUALITY_POWER[5]  then
            item.quality = "Unique"
            power = power + QUALITY_POWER[4]
        elseif power <= QUALITY_POWER[6]  then
            item.quality = "Mystical"
            power = power + QUALITY_POWER[5]
        elseif power <= QUALITY_POWER[7]  then
            item.quality = "Legendary"
            power = power + QUALITY_POWER[6]
        elseif power <= QUALITY_POWER[8]  then
            item.quality = "Mythical"
            power = power + QUALITY_POWER[7]
        else 
            item.quality = "Godlike"
            power = power + QUALITY_POWER[8]
        end

        local rng = math.random() - (1/(10/power_mult)-0.1)
        if rng<0.63 then
            item.damage = math.floor(power *0.8* (0.4 + math.random()/1.667)* 3) 
            power = power - (item.damage/3)
        elseif rng < 0.8 then
            item.damage = math.ceil(power * (0.8 + math.random()/5)* 3)
            power = 0
        end
        if power >0 then
            rng = math.random() - (1/(10/power_mult)-0.1)
            if rng<0.63 then
                item.m_damage = math.floor(power *0.8* (0.4 + math.random()/1.667)* 3) 
                power = power - (item.m_damage/3)
            elseif rng < 0.8 then
                item.m_damage = math.ceil(power * (0.8 + math.random()/5)* 3)
                power = 0
            end
        end
        if power > 0 then
            rng = math.random() - (1/(10/power_mult)-0.1)
            if rng<0.63 then
                item.loh = math.ceil(power * 0.95* (0.4 + math.random()/1.667)* 2) 
                power = power - (item.loh/2)
            elseif rng < 0.8 then
                item.loh = math.ceil(power*(0.5 + math.random()/2)* 2)
                power = 0
            end
        end
        if power > 0 then
            rng = math.random() - (1/(10/power_mult)-0.1)
            if rng<0.63 then
                item.attack_speed = math.ceil(power * (0.4 + math.random()/1.667))
                power = power - (item.attack_speed)
            elseif rng < 0.8 then
                item.attack_speed = math.ceil(power * (0.4 + math.random()/1.667))
                power = 0
            end
        end
        if power > 0 then
            rng = math.random() - (1/(10/power_mult)-0.1)
            if rng<0.63 then
                item.range = math.ceil(power *0.9* ((0.4 + math.random()/1.667)))
                power = power - item.range
            elseif rng < 0.8 then
                item.range = math.ceil(power * (0.66 + math.random()/3))
                power = 0
            end
        end

        if power < 1 then 
            power = 0
            item.ls = 0
        else
            item.ls = (10.5 + log10(power)^2)  - math.ceil((10 + log10(power)^2)/((1+power)^0.1)) + math.random()
        end
        item.price = math.ceil((item.damage/3 + item.loh/2 + item.ls^3 + item.range + item.attack_speed)^0.666)
        if item.attack_speed == 0 then item.attack_speed = nil end
        if item.ls == 0 then item.ls = nil end
        if item.loh == 0 then item.loh = nil end
        if item.range == 0 then item.range = nil end
        if item.damage == 0 then item.damage = nil end
        if item.m_damage == 0 then item.m_damage = nil end
        

    end

    if item.Equipement == true then
        if item.damage ~= nil then item.damage = math.ceil(item_info.damage + math.random(0,item_info.damage*0.2)) end
        if item.m_damage ~= nil then item.m_damage = math.ceil(item_info.m_damage + math.random(0,item_info.m_damage*0.2)) end
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
            item.level = 1
            item.XP = 0
            item.reforgable = true
            item.upgrade_point = 0

            item.upgrade_level = 0

            item.Next_Level_XP = inv_manager.XP_Table[item.level]
        end
    end

    return item
end

function inv_manager:calc_damage_mutliplier(item_multiplier,hero_multiplier,hero)
    if item_multiplier == nil then item_multiplier = 0 end 
    if hero_multiplier == nil then hero_multiplier = 0 end
    hero.dmg_mult = hero_multiplier + item_multiplier + 100
end

function inv_manager:calc_stat_item(equipement,stats,hero)
    
    local eq_slot = copy(equipement)

    --[[i check if a value is nil , if it's the case i set it to 0, i prefer use this way than put in each item those basic value
    to gain some memory size (you know , optimisation (while this code must be the least optimised cheat cause i suck)) especialy when
    saving items
    ]]
    if eq_slot == nil then return stats end
    if not eq_slot.damage then eq_slot.damage = 0 end
    if not eq_slot.damage_mult then eq_slot.damage_mult = 0 end
    if not eq_slot.m_damage then eq_slot.m_damage = 0 end
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
    stats.damage_mult = stats.damage_mult + eq_slot.damage_mult
    stats.m_damage = stats.m_damage + eq_slot.m_damage
    stats.attack_speed = stats.attack_speed + eq_slot.attack_speed
    stats.range = stats.range + eq_slot.range

    if eq_slot.cat == "weapon" then


        if not eq_slot.bonus_damage then eq_slot.bonus_damage = 0 end
        if not eq_slot.upgrade_damage then eq_slot.upgrade_damage = 0 end

        if not eq_slot.bonus_m_damage then eq_slot.bonus_m_damage = 0 end
        if not eq_slot.upgrade_m_damage then eq_slot.upgrade_m_damage = 0 end

        if not eq_slot.bonus_loh then eq_slot.bonus_loh = 0 end
        if not eq_slot.upgrade_loh then eq_slot.upgrade_loh = 0 end

        if not eq_slot.bonus_ls then eq_slot.bonus_ls = 0 end
        if not eq_slot.upgrade_ls then eq_slot.upgrade_ls = 0 end

        if not eq_slot.bonus_range then eq_slot.bonus_range = 0 end
        if not eq_slot.upgrade_range then eq_slot.upgrade_range = 0 end

        if not eq_slot.bonus_attack_speed then eq_slot.bonus_attack_speed = 0 end
        if not eq_slot.upgrade_attack_speed then eq_slot.upgrade_attack_speed = 0 end



        if eq_slot.ranged ~= true then
            if stats.range > 500 then stats.range = 500 end
        end
    end
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
    if eq_slot.cat == "weapon" then
        local damage_multiplier = 1

        inv_manager:calc_damage_mutliplier( stats.damage_mult,hero.skill_bonus.damage_mult,hero)

        if hero ~= nil then damage_multiplier =  damage_multiplier * (hero.dmg_mult/100) end
        if eq_slot.ranged == true then damage_multiplier = damage_multiplier*0.8 end
        print (damage_multiplier," ",stats.damage ," ", eq_slot.damage ," ",eq_slot.upgrade_damage ," ", eq_slot.bonus_damage)
        if eq_slot.ranged == true then
            hero:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK) 
            if eq_slot.magical == true then
                if eq_slot.projectile_name == nil then eq_slot.projectile_name = "particles/units/heroes/hero_leshrac/leshrac_base_attack.vpcf" end
                hero:SetRangedProjectileName(eq_slot.projectile_name)
                stats.m_damage = (stats.damage + eq_slot.damage + eq_slot.upgrade_damage + eq_slot.bonus_damage ) * damage_multiplier
                stats.damage = 0
                eq_slot.damage = 0
            else
                if eq_slot.projectile_name == nil then eq_slot.projectile_name = "particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf" end
                hero:SetRangedProjectileName(eq_slot.projectile_name)
                stats.damage = (stats.damage + eq_slot.upgrade_damage + eq_slot.bonus_damage )* damage_multiplier
            end
        else
            hero:SetRangedProjectileName("")
            hero:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK) 
            stats.damage = (stats.damage + eq_slot.upgrade_damage + eq_slot.bonus_damage) * damage_multiplier
        end
        stats.m_damage = (stats.m_damage + eq_slot.m_damage + eq_slot.m_damage) * damage_multiplier
        stats.range  = stats.range  + eq_slot.upgrade_range + eq_slot.bonus_range
        stats.loh = stats.loh + eq_slot.upgrade_loh + eq_slot.bonus_loh
        stats.attack_speed = stats.attack_speed + eq_slot.upgrade_attack_speed + eq_slot.bonus_attack_speed
        stats.ls = stats.ls + eq_slot.upgrade_ls + eq_slot.bonus_ls
    end
    DeepPrintTable(stats)
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
    stats.damage_mult = 0
    stats.damage = 0
    stats.m_damage = 0
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

    stats = self:calc_stat_item(hero.equipement.chest_armor,stats)
    stats = self:calc_stat_item(hero.equipement.legs_armor,stats)
    stats = self:calc_stat_item(hero.equipement.helmet,stats)
    stats = self:calc_stat_item(hero.equipement.gloves,stats)
    stats = self:calc_stat_item(hero.equipement.boots,stats)

    --stats = self:calc_stat_item(hero.equipement.shield,stats) must be done later  , it'll have to check if weapon if 2 handed or not, need to fix some other bug before working on this ^^

    --stats = self:calc_stat_item(hero.equipement.necklace,stats)
    --stats = self:calc_stat_item(hero.equipement.earring1,stats)
    --stats = self:calc_stat_item(hero.equipement.earring2,stats)


    stats = self:calc_stat_item(hero.equipement.weapon,stats,hero) --put it at the end since it'll affect all magical damage and range 

    if hero.equipement.weapon == nil and stats.range > 500 then stats.range = 500 end

    hero.equip_stats = stats
    --to add : a function that add hero side stats (levels...) and apply them
    local key = "player_"..hero:GetPlayerID()
    inv_manager:save_inventory(hero)
    CustomNetTables:SetTableValue( "stats",key, {equip_stats = hero.equip_stats,skill_stats = hero.skill_bonus,hero_stats = hero.hero_stats,Name = hero:GetUnitName(),LVL = hero.Level,stats_points = hero.stats_points  } )
    CreateItem("item_void", hero, hero) 
    
end

function inv_manager:Init_Hero_Stat()
    local stats = {}
    stats.damage_mult = 0
    stats.m_damage = 0
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
            item_name = item.item_name
            for i=1,size do
                if inventory[i]~= nil and inventory[i].item_name== item_name then
                    print ("item is stacked")
                    hero.inventory[i].ammount = inventory[i].ammount + item.ammount
                    inv_manager:save_inventory(hero)
                    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
                    return
                elseif inventory[i] == nil then
                    print ("item_added to inventory")
                    inv_manager:sort( hero )
                    table.insert(hero.inventory,item)
                    hero:RemoveItem(item)
                    inv_manager:save_inventory(hero)
                    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
                    return
                elseif i>=size then
                    print ("inventory is full")
                    inv_manager:drop(item,hero:GetOrigin())
                    hero:RemoveItem(item)
                    Notifications:Inventory(hero:GetPlayerID(), {text="#NOSLOT",duration=2,color="FFAAAA"})
                    inv_manager:save_inventory(hero)
                    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
                    return
                end
            end
        else
            for i=1,size do
                print (inventory[i])
                if inventory[i] == nil then
                    print ("item_added to inventory")
                    inventory[i]= item
                    inv_manager:sort( hero )
                    hero:RemoveItem(item)
                    inv_manager:save_inventory(hero)
                    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
                        return
                elseif i>=size then
                    print ("inventory is full")
                    inv_manager:drop(item,hero:GetOrigin())
                    hero:RemoveItem(item)
                    Notifications:Inventory(hero:GetPlayerID(), {text="#NOSLOT",duration=2,color="FFAAAA"})
                    inv_manager:save_inventory(hero)
                    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
                        return
                end
            end
        end
        
    else
        if item == nil then print ("item is nil")
        else print ("error , item not item (LOGIC BITCH)")
        end
    end

end


function inv_manager:sort( hero )
    if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then local size = INVENTORY_PASS_SIZE else size = INVENTORY_SIZE end
    for i=1,size do
        if hero.inventory[i] == nil then
            if i>#hero.inventory then return end
            local empty = true
            for j = 0,size-1 do
                if hero.inventory[size-j] ~= nil and empty ==true then
                    empty = false
                    hero.inventory[i] = hero.inventory[size-j] 
                    hero.inventory[size-j] = nil
                end
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
            if item.Equipement ~= true and item.Soul ~= true then
                inv_manager:drop(item,hero:GetOrigin())
            end
            if item.ammount ~= nil and item.ammount > 1 then
                hero.inventory[inv_slot].ammount = item.ammount - 1
            end
            hero.inventory[inv_slot] = nil
            inv_manager:sort( hero )
            inv_manager:save_inventory(hero)
            CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
        else
            Notifications:Inventory(hero:GetPlayerID(), {text="#EMPTY_SLOT",duration=2,color="FFAAAA"})
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
        CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
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
                if item.Ilevel == nil then 
                    print ("ilevel of weapon is nil , replace it by 0") 
                    item.Ilevel = 0
                end
                if item.Ilevel <= hero.Level then
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
                else 
                    print ("need more level")
                    Notifications:Inventory(hero:GetPlayerID(), {text="#NO_REQ_LEVEL",duration=2,color="FFAAAA"})

                end
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
            CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
            inv_manager:Calculate_stats(hero)
        else
            Notifications:Inventory(hero:GetPlayerID(), {text="#EMPTY_SLOT",duration=2,color="FFAAAA"})
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
                if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then
                    hero:SetHealth((hero:GetHealth() + (item.heal/(5*item.duration))*1.1 ))
                else
                    hero:SetHealth((hero:GetHealth() + (item.heal/(5*item.duration)) ))
                end
            end
            if item.heal_mana ~= nil then
                if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then
                    hero:SetMana((hero:GetMana() + (item.heal_mana/(5*item.duration))*1.1 ))
                else
                    hero:SetMana((hero:GetMana() + (item.heal_mana/(5*item.duration)) ))
                end
            end
            if item.heal_pct ~= nil then
                if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then
                    hero:SetHealth((hero:GetHealth() + ((item.heal_pct*hero:GetMaxHealth()*0.01)/(5*item.duration))*1.1 ))
                else
                    hero:SetHealth((hero:GetHealth() + ((item.heal_pct*hero:GetMaxHealth()*0.01)/(5*item.duration)) ))
                end
            end
            if item.heal_mana_pct ~= nil then
                if PlayerResource:HasCustomGameTicketForPlayerID( hero:GetPlayerID() ) == true then
                    hero:SetMana((hero:GetMana() + ((item.heal_mana_pct*hero:GetMaxMana()*0.01)/(5*item.duration))*1.1 ))
                else
                    hero:SetMana((hero:GetMana() + ((item.heal_mana_pct*hero:GetMaxMana()*0.01)/(5*item.duration)) ))
                end
            end
            return 0.2
        else
            return
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
                CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "clean_forge", {} )
                inv_manager:sort( hero )
                inv_manager:save_inventory(hero)
            else
                Notifications:Inventory(hero:GetPlayerID(), {text="#NOSHOP",duration=2,color="FFAAAA"})
            end
        else
            Notifications:Inventory(hero:GetPlayerID(), {text="#EMPTY_SLOT",duration=2,color="FFAAAA"})
        end
    else
        print ("Slot number is invalid or inventory don't exist")
    end
end
 
function inv_manager:make_evolution(hero,evolution_slot,slot)
    local item = nil
    if evolution_slot == nil then return end
    local inventory = hero.inventory
    if slot == nil then item = hero.equipement.weapon else item = inventory[slot] end
    DeepPrintTable(item)
    item = inv_manager:evolve_weapon(hero,item,evolution_slot)
    if slot ==nil then hero.equipement.weapon = item else hero.inventory[slot] = item end

    inv_manager:Calculate_stats(hero)
    inv_manager:save_inventory(hero)
end
--TBD : make an "evolve" option for weapon , allowing them to upgrade unto a supperior weapon tier, (may be unique weapon , or maybe dropable , IDK yet, should make a strowpoll for)
function inv_manager:evolve_weapon(hero,item,evolution_slot)
    if item.cat ~= "weapon" then print ("weapon isnot a weapon") return item end
    local weapon = item
    local evolution_name = nil
    local evolution = LoadKeyValues("scripts/kv/w_evolution.kv")[weapon.item_name]
    DeepPrintTable(evolution)
    for k,v in pairs(evolution) do
        if v.way == evolution_slot then print (k) evolution_name = k end
    end
    if evolution_name == nil then print ("no evolution on this way") return item end 
    if item.upgrade_level >= evolution[evolution_name].level and weapon.upgrade_damage >= evolution[evolution_name].damage and weapon.upgrade_m_damage >= evolution[evolution_name].m_damage and weapon.upgrade_range >= evolution[evolution_name].range and weapon.upgrade_loh >= evolution[evolution_name].loh and weapon.upgrade_attack_speed >= evolution[evolution_name].attack_speed and weapon.upgrade_ls >= evolution[evolution_name].ls then
        print ("evolveweapon")
        New_Weapon = epic_boss_fight:_CreateItem(evolution_name,hero)
        New_Weapon = inv_manager:item_checklevelup(New_Weapon)

        local bonus_damage = 0
        local bonus_m_damage = 0
        local bonus_loh = 0
        local bonus_ls = 0
        local bonus_range = 0
        local bonus_attack_speed = 0


        function add_stats (weapon_stats , stats)
            if weapon_stats ~= nil then 
                stats = weapon_stats + stats 
            end
            return stats
        end
        bonus_damage = add_stats(weapon.damage,bonus_damage)
        bonus_damage = add_stats(weapon.upgrade_damage,bonus_damage)
        bonus_damage = add_stats(weapon.bonus_damage,bonus_damage)

        bonus_m_damage = add_stats(weapon.m_damage,bonus_m_damage)
        bonus_m_damage = add_stats(weapon.upgrade_m_damage,bonus_m_damage)
        bonus_m_damage = add_stats(weapon.bonus_m_damage,bonus_m_damage)

        bonus_loh = add_stats(weapon.loh,bonus_loh)
        bonus_loh = add_stats(weapon.upgrade_loh,bonus_loh)
        bonus_loh = add_stats(weapon.bonus_loh,bonus_loh)

        bonus_ls = add_stats(weapon.ls,bonus_ls)
        bonus_ls = add_stats(weapon.upgrade_ls,bonus_ls)
        bonus_ls = add_stats(weapon.bonus_ls,bonus_ls)

        bonus_range = add_stats(weapon.range,bonus_range)
        bonus_range = add_stats(weapon.upgrade_range,bonus_range)
        bonus_range = add_stats(weapon.bonus_range,bonus_range)

        bonus_attack_speed = add_stats(weapon.attack_speed,bonus_attack_speed)
        bonus_attack_speed = add_stats(weapon.upgrade_attack_speed,bonus_attack_speed)
        bonus_attack_speed = add_stats(weapon.bonus_attack_speed,bonus_attack_speed)


        if bonus_damage ~= nil then
            New_Weapon.bonus_damage =  math.ceil(bonus_damage)*0.4
        end
        if bonus_m_damage ~= nil then
            New_Weapon.bonus_m_damage = math.ceil(bonus_m_damage)*0.4
        end
        if bonus_loh ~= nil then
            New_Weapon.bonus_loh = math.ceil(bonus_loh)*0.4
        end
        if bonus_ls ~= nil then
            New_Weapon.bonus_ls = math.ceil(bonus_ls)*0.4
        end
        if bonus_range ~= nil then
            New_Weapon.bonus_range = math.ceil(bonus_range)*0.4
        end
        if bonus_attack_speed ~= nil then
            New_Weapon.bonus_attack_speed = math.ceil(bonus_attack_speed)*0.4
        end
        return New_Weapon
    else Notifications:Inventory(hero:GetPlayerID(), {text="#DONT_HAVE_REQUIREMENT",duration=2,color="FFAAAA"}) return item end 
end

function inv_manager:crystalyze_weapon(hero,item)
    if item.cat ~= "weapon" then return item end
    if item.level < 5 then Notifications:Inventory(hero:GetPlayerID(), {text="#NOT_LEVEL_5",duration=2,color="FFAAAA"}) return item end
    local weapon = item

    local bonus_damage = 0
        local bonus_m_damage = 0
        local bonus_loh = 0
        local bonus_ls = 0
        local bonus_range = 0
        local bonus_attack_speed = 0


        function add_stats (weapon_stats , stats)
            if weapon_stats ~= nil then 
                stats = weapon_stats + stats
            end
            return stats
        end
        bonus_damage = add_stats(weapon.damage,bonus_damage)
        bonus_damage = add_stats(weapon.upgrade_damage,bonus_damage)
        bonus_damage = add_stats(weapon.bonus_damage,bonus_damage)

        bonus_m_damage = add_stats(weapon.m_damage,bonus_m_damage)
        bonus_m_damage = add_stats(weapon.upgrade_m_damage,bonus_m_damage)
        bonus_m_damage = add_stats(weapon.bonus_m_damage,bonus_m_damage)

        bonus_loh = add_stats(weapon.loh,bonus_loh)
        bonus_loh = add_stats(weapon.upgrade_loh,bonus_loh)
        bonus_loh = add_stats(weapon.bonus_loh,bonus_loh)

        bonus_ls = add_stats(weapon.ls,bonus_ls)
        bonus_ls = add_stats(weapon.upgrade_ls,bonus_ls)
        bonus_ls = add_stats(weapon.bonus_ls,bonus_ls)

        bonus_range = add_stats(weapon.range,bonus_range)
        bonus_range = add_stats(weapon.upgrade_range,bonus_range)
        bonus_range = add_stats(weapon.bonus_range,bonus_range)

        bonus_attack_speed = add_stats(weapon.attack_speed,bonus_attack_speed)
        bonus_attack_speed = add_stats(weapon.upgrade_attack_speed,bonus_attack_speed)
        bonus_attack_speed = add_stats(weapon.bonus_attack_speed,bonus_attack_speed)

    soul = epic_boss_fight:_CreateItem("item_power_soul",hero)
    soul.Ilevel = weapon.Ilevel
    if bonus_damage ~= nil then
        soul.damage = math.ceil(bonus_damage*0.25)
    end
    if bonus_m_damage ~= nil then
        soul.m_damage = math.ceil(bonus_m_damage*0.25)
    end
    if bonus_loh ~= nil then
        soul.loh = math.ceil(bonus_loh*0.25)
    end
    if bonus_ls ~= nil then
        soul.ls = math.ceil(bonus_ls*0.25)
    end
    if bonus_range ~= nil then
        soul.range = math.ceil(bonus_range*0.25)
    end
    if bonus_attack_speed ~= nil then
        soul.attack_speed = math.ceil(bonus_attack_speed*0.25)
    end

    local power = 0
    if soul.damage ~= nil then
        power = power +soul.damage/3 
    end
    if soul.m_damage ~= nil then
        power = power +soul.m_damage/2
    end
    if soul.loh ~= nil then
        power = power +soul.loh/2 
    end
    if soul.ls ~= nil then
        power = power +soul.ls^3
    end
    if soul.range ~= nil then
        power = power +soul.range 
    end
    if soul.attack_speed ~= nil then
        power = power +soul.attack_speed 
    end
        if power <= QUALITY_POWER[0] then
            print (power)
            soul.quality = "Poor"
        elseif power <= QUALITY_POWER[1]  then
            soul.quality = "Normal"
        elseif power <= QUALITY_POWER[2]  then
            soul.quality = "Superior"
        elseif power <= QUALITY_POWER[3]  then
            soul.quality = "Magic"
        elseif power <= QUALITY_POWER[4]  then
            soul.quality = "Rare"
        elseif power <= QUALITY_POWER[5]  then
            soul.quality = "Unique"
        elseif power <= QUALITY_POWER[6]  then
            soul.quality = "Mystical"
        elseif power <= QUALITY_POWER[7]  then
            soul.quality = "Legendary"
        elseif power <= QUALITY_POWER[8]  then
            soul.quality = "Mythical"
        else 
            soul.quality = "Godlike"
        end
        print (power)
        soul.price = math.ceil(power^0.666)

    return soul
end

function inv_manager:crystalyze(hero,slot_weap)
    local weapon = nil
    if slot_weap ~= nil then 
        weapon = hero.inventory[slot_weap] 
    else 
        return 
    end

    if weapon ~= nil then
        weapon = inv_manager:crystalyze_weapon(hero,weapon)
    end

    hero.inventory[slot_weap] = weapon
    inv_manager:sort( hero )
    inv_manager:save_inventory(hero)
end

function inv_manager:upgrade_weapon(hero,weapon,soul) --will be called when a weapon is upgraded with a smith
                weapon.upgrade_level = weapon.upgrade_level + 1
                if soul.damage ~= nil then
                    if weapon.upgrade_damage == nil then weapon.upgrade_damage = 0 end
                    weapon.upgrade_damage = weapon.upgrade_damage + soul.damage
                end

                if soul.m_damage ~= nil  then
                    if weapon.upgrade_m_damage == nil then weapon.upgrade_m_damage = 0 end
                    weapon.upgrade_m_damage = weapon.upgrade_m_damage + soul.m_damage
                end

                if soul.range ~= nil  then
                    if weapon.upgrade_range == nil then weapon.upgrade_range = 0 end
                    weapon.upgrade_range = weapon.upgrade_range + soul.range
                end

                if soul.loh ~= nil  then 
                if weapon.upgrade_loh == nil then weapon.upgrade_loh = 0 end  
                    weapon.upgrade_loh = weapon.upgrade_loh + soul.loh
                end

                if soul.attack_speed ~= nil  then
                    if weapon.upgrade_attack_speed == nil then weapon.upgrade_attack_speed = 0 end
                    weapon.upgrade_attack_speed = weapon.upgrade_attack_speed + soul.attack_speed
                end
                if soul.ls ~= nil  then
                    if weapon.upgrade_ls == nil then weapon.upgrade_ls = 0 end
                    weapon.upgrade_ls = weapon.upgrade_ls + soul.ls
                end
                weapon.upgrade_point = weapon.upgrade_point - 1
    return weapon
end
 
function inv_manager:up_weapon(hero,soul_slot,weapon_slot)
    local soul = nil 
    local weapon =  nil
    if soul_slot == nil then return end
    soul = hero.inventory[soul_slot]
    if soul == nil then return end
    if soul.Soul ~= true then print ("soul is not a soul") return end
    if weapon_slot ~= nil then 
        weapon = hero.inventory[weapon_slot]
    else
        weapon = hero.equipement.weapon
    end
    if weapon == nil then return end
    if weapon.cat ~= "weapon" then print ("weapon is not a weapon") return end

    if weapon.upgrade_point > 0 then
        if soul.Ilevel <= math.floor(weapon.Ilevel*1.1) then
            weapon = inv_manager:upgrade_weapon(hero,weapon,soul)
            hero.inventory[soul_slot] = nil
        else
            Notifications:Inventory(hero:GetPlayerID(), {text="#SOUL_TOO_HIGH_LEVEL",duration=2,color="FFAAAA"})
        end
    else
        Notifications:Inventory(hero:GetPlayerID(), {text="#WEAPON_NO_UPGRADE_SLOT",duration=2,color="FFAAAA"})
    end

    if weapon_slot ~= nil then 
        hero.inventory[weapon_slot] = weapon
    else
        hero.equipement.weapon = weapon
    end 
    inv_manager:Calculate_stats(hero)
    inv_manager:save_inventory(hero)
end

function inv_manager:item_checklevelup(item)
    if item.XP >= item.Next_Level_XP then
        item.level = item.level + 1
        item.upgrade_point = item.upgrade_point + 1
        if item.damage == nil and item.dmg_grow ~= nil and item.dmg_grow > 0  then item.damage=0 end
        if item.damage ~= nil then
            item.damage = item.damage + item.dmg_grow
        end
        if item.m_damage == nil and item.m_dmg_grow ~= nil and item.m_dmg_grow > 0  then item.m_damage=0 end
        if item.m_damage ~= nil then
            item.m_damage = item.m_damage + item.m_dmg_grow
        end
        if item.attack_speed == nil and item.as_grow ~= nil and item.as_grow > 0  then item.attack_speed=0 end
        if item.attack_speed ~= nil then
            item.attack_speed = item.attack_speed + item.as_grow
        end
        if item.range == nil and item.range_grow ~= nil and item.range_grow > 0  then item.range=0 end
        if item.range ~= nil then
            item.range = item.range + item.range_grow
        end
        item.Next_Level_XP = inv_manager.XP_Table[item.level]
        item.reforgable = true
        item = inv_manager:item_checklevelup(item)
        return item
        --up stats
    else
        return item
    end
end
    
function inv_manager:weapon_checklevelup(hero)
    hero.equipement.weapon = inv_manager:item_checklevelup(hero.equipement.weapon)
    inv_manager:Calculate_stats(hero)
    inv_manager:save_inventory(hero)
    --up stats
end


function inv_manager:transmute_weapon(hero,transmuted,weapon) --will be called when a weapon is upgraded with a smith
    local bonus_damage = 0
        local bonus_m_damage = 0
        local bonus_loh = 0
        local bonus_ls = 0
        local bonus_range = 0
        local bonus_attack_speed = 0


        function add_stats (weapon_stats , stats)
            if weapon_stats ~= nil then 
                stats = weapon_stats + stats 
            end
            return stats
        end
        bonus_damage = add_stats(transmuted.damage,bonus_damage)
        bonus_damage = add_stats(transmuted.upgrade_damage,bonus_damage)
        bonus_damage = add_stats(transmuted.bonus_damage,bonus_damage)

        bonus_m_damage = add_stats(transmuted.m_damage,bonus_m_damage)
        bonus_m_damage = add_stats(transmuted.upgrade_m_damage,bonus_m_damage)
        bonus_m_damage = add_stats(transmuted.bonus_m_damage,bonus_m_damage)

        bonus_loh = add_stats(transmuted.loh,bonus_loh)
        bonus_loh = add_stats(transmuted.upgrade_loh,bonus_loh)
        bonus_loh = add_stats(transmuted.bonus_loh,bonus_loh)

        bonus_ls = add_stats(transmuted.ls,bonus_ls)
        bonus_ls = add_stats(transmuted.upgrade_ls,bonus_ls)
        bonus_ls = add_stats(transmuted.bonus_ls,bonus_ls)

        bonus_range = add_stats(transmuted.range,bonus_range)
        bonus_range = add_stats(transmuted.upgrade_range,bonus_range)
        bonus_range = add_stats(transmuted.bonus_range,bonus_range)

        bonus_attack_speed = add_stats(transmuted.attack_speed,bonus_attack_speed)
        bonus_attack_speed = add_stats(transmuted.upgrade_attack_speed,bonus_attack_speed)
        bonus_attack_speed = add_stats(transmuted.bonus_attack_speed,bonus_attack_speed)
        print (math.ceil(2+ bonus_m_damage * 2),(2+bonus_damage * 2) , (2+bonus_range * 0.2) , (2+bonus_attack_speed) , (2+bonus_loh), (2+bonus_ls^1.5))
    local xp = math.ceil(transmuted.XP/3 + ( log10(2 + transmuted.XP/2) + 5*transmuted.level^1.2) * ( 1 + (0.1*(0.1 + log10(2+ bonus_m_damage * 2)+ log10(2+bonus_damage * 2) + log10(2+bonus_range * 0.2) + log10(2+bonus_attack_speed) + log10(2+bonus_loh) + log10(2+bonus_ls^1.5) * 10) )) )
    weapon.XP = math.ceil(weapon.XP + xp)
    weapon = inv_manager:item_checklevelup(weapon)
    return weapon
end

function inv_manager:transmutation(hero,transmuted_slot,weapon_slot)
    local transmuted = nil 
    local weapon =  nil
    if transmuted_slot == nil then return end
    transmuted = hero.inventory[transmuted_slot]

    if weapon_slot ~= nil then 
        weapon = hero.inventory[weapon_slot]
    else
        weapon = hero.equipement.weapon
    end
    if weapon.cat ~= "weapon" or transmuted.cat ~= "weapon" then print ("either trandmuted or upgraded are not weapon") return end
    if weapon ~= nil and transmuted ~= nil then
        if transmuted.cat == "weapon" and weapon.cat == "weapon" and transmuted.Ilevel <= math.floor(weapon.Ilevel*1.1) then
            weapon = inv_manager:transmute_weapon(hero,transmuted,weapon)
            hero.inventory[transmuted_slot] = nil
        elseif transmuted.Ilevel*0.5 > weapon.Ilevel then
            print ("weapon too high level")
            Notifications:Inventory(hero:GetPlayerID(), {text="#WEAPON_TOO_HIGH_LEVEL",duration=2,color="FFAAAA"})
        else
            print ("not weapon")
            Notifications:Inventory(hero:GetPlayerID(), {text="#IS_NOT_WEAPON",duration=2,color="FFAAAA"})
        end
    else
        print ("no weapon")
        Notifications:Inventory(hero:GetPlayerID(), {text="#NO_WEAPON",duration=2,color="FFAAAA"})
    end

    if weapon_slot ~= nil then 
        hero.inventory[weapon_slot] = weapon
    else
        hero.equipement.weapon = weapon
    end 
    inv_manager:Calculate_stats(hero)
    inv_manager:save_inventory(hero)
end
