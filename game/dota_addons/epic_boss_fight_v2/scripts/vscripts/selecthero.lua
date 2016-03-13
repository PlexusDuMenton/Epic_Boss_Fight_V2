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
	local hero = PlayerResource:ReplaceHeroWith( table.PID, table.Hero_Name, 0, 0 )
	local heroent = player:GetAssignedHero()
	inv_manager:Create_Inventory(heroent)

	hero:AddAbility('lua_equipement')
	hero:AddAbility('lua_hero_stats')


	PlayerResource:SetCameraTarget(table.PID, hero)
	PlayerResource:SetCameraTarget(table.PID, nil)
	CustomGameEventManager:Send_ServerToPlayer(player,"Display_Bar", {}) 
end

function HeroSelection:Load(table)
	load(table.PID,table.Slot)
end

function HeroSelection:load_hero(table,PID)
	print ('load hero')
	local player = PlayerResource:GetPlayer(PID)
	if table == nil or table.inventory == nil then 
		CustomGameEventManager:Send_ServerToPlayer(player,"load_empty", {}) 
		print ("load slot is empty or corrupted , back to hero selection menu")
		return
	end
	CustomGameEventManager:Send_ServerToPlayer(player,"Display_Bar", {}) 
	local oldhero = player:GetAssignedHero()
	local Hero_Name = table.hero_name
	local hero = PlayerResource:ReplaceHeroWith( PID, Hero_Name, 0, 0 )
	hero.inventory = table.inventory
	hero.equipement = table.equipement
	hero:AddExperience(table.XP,0, false,false) 
	PlayerResource:SetGold(PID, table.gold, true)
	hero.stats_points = table.stats_points
end