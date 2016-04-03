--SAVING USING THE STORAGE LIB
--FINISHED , SLOT WORKS FINE , I WILL JUST ACTIVATE ANTI CHEAT WHEN LAUNCHING THE FINAL VERSION
function save(hero,slot,automatic)
		slot = tostring(slot)
		print(GameRules:IsCheatMode())
		--if GameRules:IsCheatMode() == false then --Check if this lobby cheated
			print("Saving")
			local data_table = {}
			Storage:Get( PlayerResource:GetSteamAccountID(hero:GetPlayerID()), function( resultTable, successBool )
				if successBool then
					data_table = resultTable
					print("result table above")
					print (slot)
					if slot == "2" then
						print ("slot 2")
						data_table["2"] = { hero_name = hero:GetClassname(),
									inventory = hero.inventory,
									equipement = hero.equipement,
									Level = hero.Level,
									XP = hero.XP,
									stats_points = hero.stats_points,
									gold = hero:GetGold() 
								}
					elseif slot == "3" then
						print ("slot 3")
						data_table["3"] = { hero_name = hero:GetClassname(),
								inventory = hero.inventory,
								equipement = hero.equipement,
								Level = hero.Level,
								XP = hero.XP,
								stats_points = hero.stats_points,
								gold = hero:GetGold() 
							}
					else
						print ("slot 1")
						data_table["1"] = { hero_name = hero:GetClassname(),
								inventory = hero.inventory,
								equipement = hero.equipement,
								level = hero.Level,
								XP = hero.XP,
								stats_points = hero.stats_points,
								gold = hero:GetGold() 
							}
					end
					print("data table under")
					--PASSING IT IN STORAGE
					Storage:Put( PlayerResource:GetSteamAccountID(hero:GetPlayerID()), data_table, function( resultTable, successBool )
						if successBool then
							--Notification
							print("Save completed")
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
					print ("step 1 failed")
					--Notification
					if automatic == false then
						Notifications:Bottom(hero:GetPlayerOwner(), {text="Save Failed, try again later",duration=2,style={color="red"}})
					else
						Notifications:Bottom(hero:GetPlayerOwner(), {text="AutoSave Failed",duration=2,style={color="red"}})
					end
				end
			end)
		--[[elseif GameRules.cheats == true then
			--Notification
			if automatic == false then
				Notifications:Bottom(hero:GetPlayerOwner(), {text="Save are disactivated when cheat is detected",duration=2,style={color="red"}})
			else
				Notifications:Bottom(hero:GetPlayerOwner(), {text="you can't save if you cheat :D",duration=2,style={color="red"}})
			end
		end]]--
	end

function load(pID,slot)
local player = PlayerResource:GetPlayer(pID)
local data_table = {}

  Storage:Get( PlayerResource:GetSteamAccountID(pID), function( resultTable, successBool )
    if successBool then
    	print ("acces granted")
    	print (resultTable)
    	DeepPrintTable(resultTable)
    	print (slot)
    	if slot == "2" then
    		print ("load slot 2")
    		data_table = resultTable["2"]
    	elseif slot == "3" then 
    		print ("load slot 3")
    		data_table = resultTable["3"]
    	else
    		print ("load slot 1")
    		data_table = resultTable["1"]
    	end
    elseif successBool == false then
      --Notification
      Notifications:Bottom(player:GetAssignedHero(), {text="acess to server failed, try again later",duration=2,style={color="red"}})
    end

    HeroSelection:load_hero(data_table,pID)
  end)
end