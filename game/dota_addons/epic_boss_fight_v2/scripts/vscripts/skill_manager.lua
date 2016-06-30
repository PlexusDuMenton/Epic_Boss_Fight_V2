--[[HOW TO MAKE SKILL TREE

	Skill tree : basic 
	2 (3) module type : 
	Active skill (can be equiped/unequiped , max 3 (+ 1 "ultimate")
	Passive : add a pasive skill , they ALL stack
		stats(sub passive) : increase stats
		all module can be upgraded


	Idea one : 
	1 main class where all module are 
	all module except 1 or 3 are disabled
	When a mudule is used (upgraded) it's unlock next module




	How to store module ?

	-in kv file : 
	ID of the module
	locked ?
	What ID must be unlocked
	what Level the ID must be unlocked
	if it's an active or not

	active : 
	name of spell
		: i'll use allready existing spell system to equip/unequip spell

	passive
	if it's add stats then which stats are added 
	if it's a passive, then what effect to it gave to character (similar to item's effect)



	so make a "create" function where it's create the main class and then read adapted kvfile , 


    ]]

if skill_manager == nil then
    DebugPrint( 'created skill_manager' )
    skill_manager = class({})
    print ("CREATED SKILL MANAGER")
end

function skill_manager:calc_stat_skill(skill_stats,skill_bonus)
	local skill = skill_stats



    if skill == nil then return stats end
    if skill.damage_mult ~= nil then skill_bonus.damage_mult = skill_bonus.damage_mult + skill.damage_mult[tostring(skill.lvl)] end
    if skill.attack_speed ~= nil then skill_bonus.attack_speed = skill_bonus.attack_speed + skill.attack_speed[tostring(skill.lvl)] end
    if skill.range ~= nil then skill_bonus.range = skill_bonus.range + skill.range[tostring(skill.lvl)] end
    if skill.armor ~= nil then 
    	skill_bonus.armor = skill_bonus.armor + skill.armor[tostring(skill.lvl)] 
    end
    if skill.m_ress ~= nil then skill_bonus.m_ress = 100*(1-((1 - 0.01*skill_bonus.m_ress) * (1 - 0.01*skill.m_ress[tostring(skill.lvl)]))) end
    if skill.dodge ~= nil then skill_bonus.dodge = skill_bonus.dodge + skill.dodge[tostring(skill.lvl)] end
    if skill.hp ~= nil then skill_bonus.hp = skill_bonus.hp + skill.hp[tostring(skill.lvl)] end
    if skill.hp_regen ~= nil then skill_bonus.hp_regen = skill_bonus.hp_regen + skill.hp_regen[tostring(skill.lvl)] end
    if skill.mp ~= nil then skill_bonus.mp = skill_bonus.mp + skill.mp[tostring(skill.lvl)]end
    if skill.mp_regen ~= nil then skill_bonus.mp_regen = skill_bonus.mp_regen + skill.mp_regen[tostring(skill.lvl)] end
    if skill.movespeed ~= nil then skill_bonus.movespeed = skill_bonus.movespeed + skill.movespeed[tostring(skill.lvl)] end
    if skill.ls ~= nil then skill_bonus.ls = skill_bonus.ls + skill.ls[tostring(skill.lvl)]  end
    if skill.loh ~= nil then skill_bonus.loh = skill_bonus.loh + skill.loh[tostring(skill.lvl)] end
    if skill.str ~= nil then 
    	skill_bonus.str = skill_bonus.str + skill.str[tostring(skill.lvl)] 
    end
    if skill.int ~= nil then skill_bonus.int = skill_bonus.int + skill.int[tostring(skill.lvl)] end
    if skill.agi ~=nil then skill_bonus.agi = skill_bonus.agi + skill.agi[tostring(skill.lvl)] end
    if skill.effect == nil then skill.effect = {} end
    
    --Merge effect of all skills
    skill_bonus.effect = tableMerge(skill_bonus.effect,skill.effect)

    return skill_bonus

end

function skill_manager:update_skill_bonus(hero)
	local skill_bonus = {}
	skill_bonus.effect = {}
    skill_bonus.damage_mult = 0
    skill_bonus.attack_speed = 0
    skill_bonus.range = 0
    skill_bonus.armor = 0
    skill_bonus.m_ress = 0
    skill_bonus.hp = 0
    skill_bonus.hp_regen = 0
    skill_bonus.mp = 0
    skill_bonus.mp_regen = 0
    skill_bonus.movespeed = 0
    skill_bonus.dodge = 0
    skill_bonus.ls = 0
    skill_bonus.loh = 0
    skill_bonus.str = 0
    skill_bonus.agi = 0
    skill_bonus.int = 0

    for skillname,skill in pairs(hero.skill_tree) do 
    	if skill.lvl > 0 then
    		if skill.type == "passive" or skill.type == "stats" then
				skill_bonus = self:calc_stat_skill(skill,skill_bonus)
			end
		end
	end

	hero.skill_bonus = skill_bonus
	local key = "player_"..hero:GetPlayerID()
	CreateItem("item_void", hero, hero)
	CustomNetTables:SetTableValue( "stats",key, {equip_stats = hero.equip_stats,skill_stats = hero.skill_bonus,hero_stats = hero.hero_stats,Name = hero:GetUnitName(),LVL = hero.Level,stats_points = hero.stats_points } )
	CustomNetTables:SetTableValue( "skill",key, {active_skill = hero.active_list } )
	CustomNetTables:SetTableValue( "skill_tree",key, {skill_tree = hero.skill_tree } )
	inv_manager:Calculate_stats(hero)
end


function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function skill_manager:create_skill_tree (hero)
	hero.skill_tree = {}
	hero.active_list = {}
	hero.active_ability = 0
	local skill_list = LoadKeyValues("scripts/kv/skill/"..hero:GetName()..".kv")
	for skillname,skill in pairs(skill_list) do 
		skill_manager:create_node (skill,hero)
	end
	for skillname,skill in spairs(skill_list) do 
		if skill.ID >=0 then
			skill_manager:Order (skill,hero)
		end
	end
	skill_manager:skill_table (hero)
	for i = 1,5 do
		skill_manager:equip_skill (hero,-i,i)
	end
	skill_manager:update_skill_bonus(hero)
end

function skill_manager:load_skill_tree (hero,skill_tree,active_list)
	hero.skill_tree = {}
	hero.active_list = {}
	hero.active_ability = 0
	print ("J'en esrt marre de me faire ENCULER !")
	for k,v in pairs (skill_tree) do
		hero.skill_tree[tonumber(k)] = copy(v)
	end
	for i = 1,5 do
		skill_manager:equip_skill (hero,-i,i)
	end
	skill_manager:skill_table (hero)
	skill_manager:update_skill_bonus(hero)
end

function skill_manager:upgrade(hero,ID)
	if hero.stats_points < 1 then
		--tell the player he don't have any power point (lol nub)
		return
	end
	if hero.skill_tree[ID].unlocked == true then
		if hero.skill_tree[ID].lvl < hero.skill_tree[ID].max_lvl then
			if hero.Level >= (hero.skill_tree[ID].min_lvl + hero.skill_tree[ID].lvl*hero.skill_tree[ID].lvl_gap) then
				if hero.skill_tree[ID].active == false then 
					hero.skill_tree[ID].active = true 
					for k,U_ID in pairs(hero.skill_tree[ID].unlock_id) do 
						hero.skill_tree[U_ID].unlocked = true
						hero.skill_tree[U_ID].lvl = 0
					end
				end
				hero.skill_tree[ID].lvl = hero.skill_tree[ID].lvl + 1
				print (hero.skill_tree[ID].equip,hero.skill_tree[ID].slot)
				if hero.skill_tree[ID].equip == true and hero.skill_tree[ID].slot ~= nil then
					print ("upgrade active list level")
					hero.active_list[hero.skill_tree[ID].slot].lvl = hero.skill_tree[ID].lvl
					local ability = hero:FindAbilityByName(hero.active_list[hero.skill_tree[ID].slot].name)
					ability:SetLevel(hero.active_list[hero.skill_tree[ID].slot].lvl)
				end
				hero.stats_points = hero.stats_points - 1
				skill_manager:update_skill_bonus(hero)
			else 
				print ("too low level")
				--tell the player he's not high level enought
				return
			end
		else
			print ("ability at max level")
			--tell the player the ability is at max level
			return
		end
	else
		print ("ability is locked")
		return
	end
end

function skill_manager:unequip_skill (hero,slot)
	if slot ~= nil then 
				hero.active_ability = hero.active_ability - 1 
				local ID = hero.active_list[slot].ID
				hero.skill_tree[ID].slot = nil
				hero.skill_tree[ID].equip = false
				hero.active_list[slot] = hero.skill_tree[-slot]
				for i = 1,4 do
					hero:RemoveAbility(hero.active_list[i].name)
					hero:AddAbility(hero.active_list[i].name)
					local ability = hero:FindAbilityByName(hero.active_list[i].name)
					ability:SetLevel(hero.active_list[i].lvl)
				end
				skill_manager:update_skill_bonus(hero)
	end
end

function skill_manager:equip_skill (hero,ID,slot)
	if slot > 5 or slot < 1 then slot = nil end
	if slot == nil and hero.active_ability < 4 then
		if hero.skill_tree[ID].lvl > 0 and hero.skill_tree[ID].equip == false and hero.skill_tree[ID].type == "active" or hero.skill_tree[ID].type == "ultimate" then
			print ("equip a skill")
			hero.skill_tree[ID].equip = true
			hero.active_ability = hero.active_ability + 1 
			hero.active_list[hero.active_ability] = hero.skill_tree[ID]
			hero.skill_tree[ID].slot = hero.active_ability
			hero:AddAbility( hero.skill_tree[ID].name ) 
			local ability = hero:FindAbilityByName(hero.skill_tree[ID].name)
			ability:SetLevel(hero.skill_tree[ID].lvl)
			skill_manager:update_skill_bonus(hero)
		end
	elseif slot ~= nil then 
		if slot == 5 and hero.skill_tree[ID].type ~= "ultimate" then 
			print ("not ultimate ability")
			return
		end
		print ("try to equip a skill",ID,hero.skill_tree[ID],hero.skill_tree[-1],type(ID),type(-1))
		if hero.skill_tree[ID].lvl > 0 and hero.skill_tree[ID].equip == false and hero.skill_tree[ID].type == "active" or hero.skill_tree[ID].type == "ultimate" then
			print ("equip a skill")
			if ID > 0 then
				hero:RemoveAbility(hero.active_list[slot].name)
				hero.skill_tree[hero.active_list[slot].ID].slot = nil
				hero.skill_tree[hero.active_list[slot].ID].equip = false
			end
			hero.skill_tree[ID].equip = true
			hero.active_ability = hero.active_ability + 1  
			hero.active_list[slot] = hero.skill_tree[ID]
			hero.skill_tree[ID].slot = slot
			for i = 1,5 do
				if hero.active_list[i] ~= nil then
					hero:RemoveAbility(hero.active_list[i].name)
					hero:AddAbility(hero.active_list[i].name)
					local ability = hero:FindAbilityByName(hero.active_list[i].name)
					ability:SetLevel(hero.active_list[i].lvl)
				end
			end
			skill_manager:update_skill_bonus(hero)
		end
	end
end

function skill_manager:create_node (skill,hero)
	local skill_result = skill
	skill_result.lvl = 0
	if skill_result.unlocked == "true" then skill_result.unlocked = true else skill_result.unlocked = false end
	skill_result.active = false
	if skill.ID == 0 then skill_result.Lvl_Position = 0 end
	if skill.type == "active" or skill.type == "ultimate" then
		skill_result.equip = false
		if skill.ID < 0 then 
			skill_result.active = true 
			skill_result.lvl = 1
		end
	elseif skill.type == "passive" then

	elseif skill.type == "stats" then

	end
	hero.skill_tree[skill.ID] = skill_result
end

function skill_manager:Order (skill,hero)
	print (skill.ID , " level is : ",skill.Lvl_Position)
	if skill.unlock_id~= nil then
		for k,U_ID in pairs(skill.unlock_id) do 
			print (skill.ID,"Unlock Number : ",k," Is : ",U_ID)
			hero.skill_tree[U_ID].unloked_by = skill.ID
			hero.skill_tree[U_ID].Lvl_Position = skill.Lvl_Position + 1
		end
	end
end

function skill_manager:skill_table (hero)
	local max_level = 0
	for k,skill in pairs(hero.skill_tree) do 
		if skill.ID >=0 then
			print (skill.ID,skill.Lvl_Position)
			if skill.Lvl_Position > max_level then max_level = skill.Lvl_Position end
		end
	end
	hero.node_level = max_level
	local table = {}
	for i=0,hero.node_level do
		table[i]= {}
	end
	for k,skill in pairs(hero.skill_tree) do 
		if skill.ID >= 0 then
			local lvl_pos = skill.Lvl_Position
			table[lvl_pos][#table[lvl_pos]+1]=skill.ID
		end
	end
	local key = "player_"..hero:GetPlayerID()
	CustomNetTables:SetTableValue( "skill_table",key, {skill_table = table } )

end
--skill ID -1 , -2 , -3 and -4 are just empty skills :)