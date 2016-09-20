--SAVING USING THE STORAGE LIB
--FINISHED , SLOT WORKS FINE , I WILL JUST ACTIVATE ANTI CHEAT WHEN LAUNCHING THE FINAL VERSION

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function delete_save(PID,slot)
			Storage:Get( PlayerResource:GetSteamAccountID(PID), function( resultTable, successBool )
				if successBool then
					local data_table = {}
					data_table.data = {}
					if resultTable	~= nil then
						data_table = resultTable
					end
					data_table.data[tostring(slot)] = nil
					Storage:Put( PlayerResource:GetSteamAccountID(PID), data_table, function( resultTable, successBool )
					end)
				end
			end)
	end

function save(hero,retry)

			if hero.trading == true then
	      inv_manager:cancel_trade(hero,hero.trade_with)
	    end
			Storage:Get( PlayerResource:GetSteamAccountID(hero:GetPlayerID()), function( resultTable, successBool )
				if successBool then
					local data_table = {}
					data_table.data = {}
					if resultTable	~= nil and resultTable.data	~= nil then
						data_table = resultTable
					end
					if hero.slot == nil then hero.slot = 1 end
					print(hero.slot)
					DeepPrintTable(data_table)
					data_table.data[tostring(hero.slot)] = {
							hero_name = hero:GetClassname(),
								unlocked_skill = hero.unlocked_skill,
								inventory = hero.inventory,
								item_bar = hero.item_bar,
								active_list = hero.active_list,
								equipement = hero.equipement,
								level = hero.Level,
								xp = hero.XP,
								max_xp = Get_Xp_To_Next_Level(hero.Level),
								stats_points = hero.stats_points,
								gold = hero.gold,
								skill_tree = hero.skill_tree,
							}
					--PASSING IT IN STORAGE
					Storage:Put( PlayerResource:GetSteamAccountID(hero:GetPlayerID()), data_table, function( resultTable, successBool )
						if successBool then
							print("Save sucessfull")
							Notifications:Save(hero:GetPlayerID(), {text="Saved",duration=2,color="00FF22"})
						elseif successBool == false then
							--Notification
							print("Save failled")
						end
					end)
				elseif successBool == false then
					print ("step 1 failed")
					if retry == false then
						Notifications:Save(hero:GetPlayerID(), {text="Save Failed,another attempt will be done",duration=2,color="FF2222"})
						Timers:CreateTimer(2, save(hero,true))
					end
				end
			end)
	end

function load(pID,slot)
local player = PlayerResource:GetPlayer(pID)
local data_table = {}

  Storage:Get( PlayerResource:GetSteamAccountID(pID), function( resultTable, successBool )
    if successBool then
    	print ("acces granted")
    	print ("load slot "..slot)
    	if resultTable ~= nil then
    		data_table = resultTable.data[tostring(slot)]
    	end
    elseif successBool == false then
      --Notification
      Notifications:Save(pID, {text="acess to server failed, try again later",duration=3,color="FF2222"})
    end
    HeroSelection:load_hero(data_table,pID,slot)
  end)
end
