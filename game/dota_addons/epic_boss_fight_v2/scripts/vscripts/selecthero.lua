if HeroSelection == nil then
	HeroSelection = {}
	HeroSelection.__index = HeroSelection
end

function HeroSelection:Start()
	--Figure out which players have to pick
	HeroSelection.playerPicks = {}
	HeroSelection.HeroAmmount = 0
	for pID = 0, DOTA_MAX_PLAYERS -1 do
		if PlayerResource:IsValidPlayer( pID ) then
			HeroSelection.HeroAmmount = self.HeroAmmount + 1
		end
	end

	CustomGameEventManager:RegisterListener("New_Hero", Dynamic_Wrap( HeroSelection, 'NewHero'))
	CustomGameEventManager:RegisterListener("Load_Hero", Dynamic_Wrap( HeroSelection, 'Load'))
end



function HeroSelection:NewHero(table)
	print ("create_hero")
	local player = PlayerResource:GetPlayer(table.PID)
	local slot = table.Slot
	local hero = PlayerResource:ReplaceHeroWith( table.PID, table.Hero_Name, 0, 0 )
	hero.slot = slot
	local heroent = player:GetAssignedHero()
	if heroent == nil then
		Timers:CreateTimer(0.5,function()
			HeroSelection:NewHero(table)
		end)
	else
		inv_manager:Create_Inventory(heroent)
		skill_manager:create_skill_tree(heroent)

		hero:AddAbility('lua_equipement')
		hero:AddAbility('lua_hero_stats')


		PlayerResource:SetCameraTarget(table.PID, hero)
		PlayerResource:SetCameraTarget(table.PID, nil)
		save(hero)
		CustomGameEventManager:Send_ServerToPlayer(player,"Display_Bar", {})
	end
end

function HeroSelection:Load(table)
	load(table.PID,table.Slot)
end

function HeroSelection:load_hero(table,PID,slot)
	print ('load hero')

	local player = PlayerResource:GetPlayer(PID)
	if table == nil or table.inventory == nil then
		CustomGameEventManager:Send_ServerToPlayer(player,"load_fail", {})
		Notifications:Save(PID, {text="#Empty",duration=2,color="FF2222"})
		return
	end
	local oldhero = player:GetAssignedHero()
	local Hero_Name = table.hero_name
	local hero = PlayerResource:ReplaceHeroWith( PID, Hero_Name, 0, 0 )
	hero.slot = slot
	inv_manager:Create_Inventory(hero)
	hero.stats_points = table.stats_points
	skill_manager:load_skill_tree(hero,table.skill_tree,table.active_list)
	hero.inventory = table.inventory
	hero.equipement = table.equipement
	epic_boss_fight:Update_stat(hero,table.level)
	hero.unlocked_skill = {}
	for k,v in pairs (table.unlocked_skill) do
		hero.unlocked_skill[tonumber(k)] = copy(v)
	end
	hero.XP = table.xp
	hero.item_bar = table.item_bar

	hero.gold = table.gold
	inv_manager:update_effect (hero)
	hero:AddAbility('lua_equipement')
	hero:AddAbility('lua_hero_stats')
	CustomGameEventManager:Send_ServerToPlayer(player,"Display_Bar", {})

end
