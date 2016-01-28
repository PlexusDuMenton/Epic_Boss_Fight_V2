if SelectHero == nil then
	SelectHero = {}
	SelectHero.__index = SelectHero
end

function SelectHero:Start()
	--Figure out which players have to pick
	SelectHero.playerPicks = {}
	SelectHero.HeroAmmount= 0
	for pID = 0, DOTA_MAX_PLAYERS -1 do
		if PlayerResource:IsValidPlayer( pID ) then
			SelectHero.HeroAmmount = self.HeroAmmount + 1
		end
	end

	CustomGameEventManager:RegisterListener( "select_hero", SelectHero.AssignHero )
	CustomGameEventManager:RegisterListener( "load_hero", SelectHero.Load_Hero )
end



function HeroSelection:AssignHero( table )
	local playerID = table.ID
	local player = PlayerResource:GetPlayer(playerID)
	local oldhero = player:GetAssignedHero()
	local newhero = PlayerResource:ReplaceHeroWith( playerID, table.class, 0, 0 )
	newhero.normal_spawn = 1

	--Configure a new hero
	local stringID = tostring(newhero:GetEntityIndex())
	--BUILD A NET TABLE TO ACCES IT WITH JS
	local inv = LoadKeyValues("scripts/kv/inventory.kv")
	--give starting items
	inv["WEAPON"] = GameRules.items["rust_dagger"]

	CustomNetTables:SetTableValue( "inventory", stringID, inv );
	--CONFIGURE HERO LAYOUT
	newhero.class = GameRules.classes[newhero:GetClassname()]
	newhero.Base_Stat = {}
	newhero.Base_Stat["DMG"] = 2
	newhero.Base_Stat["ASPEED"] = 100
	newhero.Base_Stat["RANGE"] = 100
	newhero.Base_Stat["ARMOR"] = 0
	newhero.Base_Stat["MRESS"] = 10
	newhero.Base_Stat["HP"] = 20
	newhero.Base_Stat["MANA"] = 0
	newhero.Base_Stat["STR"] = 0
	newhero.Base_Stat["AGI"] = 0
	newhero.Base_Stat["INT"] = 0
	newhero.Base_Stat["EVASION"] = 0
	newhero.Base_Stat["CHANCE"] = 1
	newhero.Base_Stat["CRIT"] = 150

	local Bonus_item = {}
  Bonus_item["DMG"] = 0
  Bonus_item["ASPEED"] = 0
  Bonus_item["RANGE"] = 0
  Bonus_item["ARMOR"] = 0
  Bonus_item["MRESS"] = 0
  Bonus_item["HP"] = 0
  Bonus_item["MANA"] = 0
  Bonus_item["STR"] = 0
  Bonus_item["AGI"] = 0
  Bonus_item["INT"] = 0
  Bonus_item["EVASION"] = 0
  Bonus_item["CHANCE"] = 0
  Bonus_item["CRIT"] = 0

  newhero.equip_bonuses = Bonus_item

	--give modifiers
	newhero:AddNewModifier(newhero, nil, "modifier_equip", {})
	--teleport (will have to change place where it appear)
	FindClearSpaceForUnit(newhero, Vector(-500,7000,1024), false)
	PlayerResource:SetCameraTarget(playerID, newhero)
	PlayerResource:SetCameraTarget(playerID, nil)

	local data_table = {}
	data_table["1"] = newhero:GetEntityIndex()
	data_table["2"] = newhero.slot
	write_in_slot(data_table)
end

function HeroSelection:Load_Hero(table)
	local playerID = table.playerID
	local player = PlayerResource:GetPlayer(playerID)

	--Cleanup
	local oldhero = player:GetAssignedHero()
	if oldhero ~= nil and oldhero:IsNull() == false then
		oldhero:RemoveSelf()
	end
	local newhero = PlayerResource:ReplaceHeroWith(playerID, table.class, table.gold, 0)
	newhero.normal_spawn = 1
	newhero.slot = table.slot
	--------------CONFIGURE HERO LAYOUT
	local inv_layout = LoadKeyValues("scripts/kv/inventory.kv")
	newhero.class = GameRules.classes[newhero:GetClassname()]

	newhero.Base_Stat = {}
	newhero.Base_Stat["DMG"] = 2
	newhero.Base_Stat["ASPEED"] = 100
	newhero.Base_Stat["RANGE"] = 100
	newhero.Base_Stat["ARMOR"] = 0
	newhero.Base_Stat["MRESS"] = 10
	newhero.Base_Stat["HP"] = 20
	newhero.Base_Stat["MANA"] = 0
	newhero.Base_Stat["STR"] = 0
	newhero.Base_Stat["AGI"] = 0
	newhero.Base_Stat["INT"] = 0
	newhero.Base_Stat["EVASION"] = 0
	newhero.Base_Stat["CHANCE"] = 1
	newhero.Base_Stat["CRIT"] = 150

	------------------------------------
	for i=1,table.level-1 do
		newhero:HeroLevelUp(true)
	end
	newhero:AddExperience(table.XP, false, false)
	newhero:FindAbilityByName(newhero.class["ability_1"]):SetLevel(table.ability1)
	newhero:FindAbilityByName(newhero.class["ability_2"]):SetLevel(table.ability2)
	newhero:FindAbilityByName(newhero.class["ability_3"]):SetLevel(table.ability3)
	newhero:FindAbilityByName(newhero.class["ability_4"]):SetLevel(table.ability4)
	newhero:FindAbilityByName(newhero.class["ability_5"]):SetLevel(table.ability5)
	newhero:FindAbilityByName(newhero.class["ability_6"]):SetLevel(table.ability6)
	newhero:SetAbilityPoints(table.ability_points)

	newhero.stat_level["STR"] = table.Stat_STR
	

	newhero.stat_level["DMG"] = table.Stat_DMG
	newhero.stat_level["ASPEED"] = table.Stat_ASPEED
	newhero.stat_level["HP"] = table.Stat_HP
	newhero.stat_level["MANA"] = table.Stat_MANA
	newhero.stat_level["STR"] = table.Stat_STR
	newhero.stat_level["AGI"] = table.Stat_AGI
	newhero.stat_level["INT"] = table.Stat_INT
	newhero.stat_level["MRESS"] = table.Stat_MRESS
	newhero.stat_level["ARMOR"] = table.Stat_ARMOR

	--Load items by the name references
	for k,v in pairs(table.inventory) do
		local name = table.inventory[k]["NAME"]
		if name ~= nil then
			if GR_ITEMS[name] ~= nil then
				--insert the item
				local item = GR_ITEMS[name]
				local quantity = table.inventory[k]["QUANTITY"]
				table.inventory[k] = item

				if table.inventory[k]["QUANTITY"] ~= nil then
					if quantity ~= nil then
						table.inventory[k]["QUANTITY"] = quantity
					end
				end
			end
		elseif name == nil then
			--If the slot contains only the string name **was used in a previous verison of this code
			--So load the default item from kv base
			name = table.inventory[k]
			table.inventory[k] = GameRules.items[name]
		end
	end

	for k,v in pairs(table.inventory) do
		inv_layout[k] = table.inventory[k]
	end
	CustomNetTables:SetTableValue( "inventory", tostring(newhero:GetEntityIndex()), inv_layout );
	inventory_change( player )
	print("Loaded hero")

	--give modifiers
	newhero:AddNewModifier(newhero, nil, "modifier_equip", {})
	--teleport
	local entity = Entities:FindByClassname(nil,"info_player_start_goodguys")
	local position = entity:GetAbsOrigin()
	EmitSoundOn("hometown_scroll_end", newhero)
	FindClearSpaceForUnit(newhero, position, false)
	newhero:Stop()
	PlayerResource:SetCameraTarget(playerID, newhero)
	PlayerResource:SetCameraTarget(playerID, nil)
end

function write_in_slot(table)
local sv_cheats = Convars:GetBool("sv_cheats")
	if sv_cheats == false or io then --Check if cheats are enabled or if i'm in tools mode
		print("Saving")
		local heroID = table["1"]
		local slot = table["2"]
		local hero = EntIndexToHScript(heroID)
		local data_table = {}
		Storage:Get( PlayerResource:GetSteamAccountID(hero:GetPlayerID()), function( resultTable, successBool )
			if successBool then
				data_table = resultTable
				data_table[slot] = { class = hero:GetClassname(),
								level = hero:GetLevel(),
								XP = hero:GetCurrentXP(),
								ability_points = hero:GetAbilityPoints(),
								ability1 = hero:FindAbilityByName(hero.class["ability_1"]):GetLevel(),
								ability2 = hero:FindAbilityByName(hero.class["ability_2"]):GetLevel(),
								ability3 = hero:FindAbilityByName(hero.class["ability_3"]):GetLevel(),
								ability4 = hero:FindAbilityByName(hero.class["ability_4"]):GetLevel(),
								ability5 = hero:FindAbilityByName(hero.class["ability_5"]):GetLevel(),
								ability6 = hero:FindAbilityByName(hero.class["ability_6"]):GetLevel(),

								Stat_DMG = hero.stat_level["DMG"]
								Stat_ASPEED = hero.stat_level["ASPEED"]
								Stat_HP = hero.stat_level["HP"] 
								Stat_MANA = hero.stat_level["MANA"]
								Stat_STR = hero.stat_level["STR"]
								Stat_AGI = hero.stat_level["AGI"]
								Stat_INT = hero.stat_level["INT"]
								Stat_MRESS = hero.stat_level["MRESS"]
								Stat_ARMOR = hero.stat_level["ARMOR"]
								gold = PlayerResource:GetGold(hero:GetPlayerID()),
								inventory = {},
							}
			--Save only name references of the items
			table = CustomNetTables:GetTableValue("inventory", tostring(heroID))
			for k,v in pairs(table) do
				local name = table[k]["NAME"]
				table[k] = name
			end
			data_table[slot].inventory = table
			--PASSING IT IN STORAGE
			Storage:Put( PlayerResource:GetSteamAccountID(hero:GetPlayerID()), data_table, function( resultTable, successBool )
				if successBool then
					--Notification
					Notifications:Bottom(hero:GetPlayerOwner(), {text="Saved",duration=2,style={color="green"}})
				elseif successBool == false then
					--Notification
					Notifications:Bottom(hero:GetPlayerOwner(), {text="No access to data server, try later",duration=2,style={color="red"}})
				end
			end)
			end
		end)
	elseif sv_cheats == true then
		--Notification
		Notifications:Bottom(hero:GetPlayerOwner(), {text="you can't save when cheat is active",duration=2,style={color="red"}})
	end
end