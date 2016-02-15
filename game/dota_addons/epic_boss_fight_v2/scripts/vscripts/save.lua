--SAVING USING THE STORAGE LIB
--WILL NEED SOME TESTING ONCE INV MANAGER FINISHED
function save(event,automatic)
if automatic == nil then automatic = false
local hero = event.caster
local heroID = hero:GetEntityIndex()
local slot = hero.slot
print(GameRules.cheats)
	if GameRules.cheats == false then --Check if this lobby cheated
		print("Saving")
		local data_table = {}
		Storage:Get( PlayerResource:GetSteamAccountID(hero:GetPlayerID()), function( resultTable, successBool )
			if successBool then
				data_table = resultTable
				data_table[slot] = { hero_name = hero:GetClassname(),
							inventory = hero.inventory,
							Level = hero:GetLevel(),
							XP = hero:GetCurrentXP(),
							ability_points = hero:GetAbilityPoints(),
							Gold = hero:GetGold() 
						}
				--PASSING IT IN STORAGE
				Storage:Put( PlayerResource:GetSteamAccountID(hero:GetPlayerID()), data_table, function( resultTable, successBool )
					if successBool then
						--Notification
						Notifications:Bottom(hero:GetPlayerOwner(), {text="Saved",duration=2,style={color="green",fontSize="65"}})
					elseif successBool == false then
						--Notification
						if automatic == false then
							Notifications:Bottom(hero:GetPlayerOwner(), {text="Save Failed, try again later",duration=2,style={color="red"}})
						else
							Notifications:Bottom(hero:GetPlayerOwner(), {text="AutoSave Failed",duration=2,style={color="red"}})
						end
					end
				end)
			elseif successBool == false then
				--Notification
				if automatic == false then
					Notifications:Bottom(hero:GetPlayerOwner(), {text="Save Failed, try again later",duration=2,style={color="red"}})
				else
					Notifications:Bottom(hero:GetPlayerOwner(), {text="AutoSave Failed",duration=2,style={color="red"}})
				end
			end
		end)
	elseif GameRules.cheats == true then
		--Notification
		if automatic == false then
			Notifications:Bottom(hero:GetPlayerOwner(), {text="Save are disactivated when cheat is detected",duration=2,style={color="red"}})
		else
			Notifications:Bottom(hero:GetPlayerOwner(), {text="you can't save if you cheat :D",duration=2,style={color="red"}})
		end
	end
end

function load(pID)
local player = PlayerResource:GetPlayer(pID)
local data_table = {}
  Storage:Get( PlayerResource:GetSteamAccountID(playerID), function( resultTable, successBool )
    if successBool then
      data_table = resultTable
      load_hero(data_table,pID)
    elseif successBool == false then
      --Notification
      Notifications:Bottom(player:GetAssignedHero(), {text="acess to server failed, try again later",duration=2,style={color="red"}})
    end
  end)
end

function load_hero(table,pID)
	--create and assign hero
end