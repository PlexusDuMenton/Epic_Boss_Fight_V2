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

function update_skill_bonus(hero)
	local skill_bonus = {}
	skill_bonus.effect = {} --here goes every effect an passive skill give out
    skill_bonus.damage = 0
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
end

function skill_manager:create_skill_tree (hero)
	hero.skill_tree = {}

	local skill_list = LoadKeyValues("scripts/kv/"..hero:GetName()..".kv")
	for skill, in pairs(skill_list) do 
		skill_manager:create_node (skill,hero)
	end
end

function skill_manager:create_node (skill,hero)
	local skill_result = {}
	skill_result.ID = skill.ID
	skill_result.active = false
	if skill.type == "Active" then


	elseif skill.type == "passive" then

		if skill_result.unlocked == true then skill_result.active = true end
	elseif skill.type == "stats" then

		if skill_result.unlocked == true then skill_result.active = true end
	end
	hero.skill_tree[skill.ID] = skill_result
end