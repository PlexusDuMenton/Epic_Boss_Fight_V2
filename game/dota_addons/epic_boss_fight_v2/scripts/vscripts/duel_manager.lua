GAME_STATE_LOADING = 0 --have no use for now
GAME_STATE_NORMAL = 1
GAME_STATE_PREPARE = 2
GAME_STATE_DUEL = 3

TIME_BETWEEN_DUEL = 300 --Temps entre les duels
TIME_BEFORE_INITIAL_DUEL = 600 --Temps avant les premier duels

ARENA_VECTOR = Vector(0,0,0) -- met les coodoné de ton arene ici (la 3iem valeur n'est pas important , c'est surtout les axe X/Y qui sont important)

DEFAULT_COUNTDOWN_TIME = 5 --Temps de preparation d'un duel (les duel ne commencera pas directement , un petit temps pour que le joueur le remarque)

RADIANT_TEAM = {}
DIRE_TEAM = {}

smaller_team_size = 0
Time_Left_Until_Next_event = TIME_BEFORE_INITIAL_DUEL

function update_team() -- fonction pour mettre a jours les équipes (combient de joueur par équipe qui ne sont pas déconnecté)
	for i=0,PlayerResource:GetPlayerCount()-1 do
	    local hero = PlayerResource:GetSelectedHeroEntity(i)
	    if hero~=nil then
		    if PlayerResource:GetConnectionState(i) == 2 then
		        if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		        	RADIANT_TEAM[#RADIANT_TEAM+1] = hero
		        elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		        	DIRE_TEAM[#DIRE_TEAM+1] = hero
		        end
		    end
	    end
	end
	if #RADIANT_TEAM < #DIRE_TEAM then
		smaller_team_size = #RADIANT_TEAM
	else
		smaller_team_size = #DIRE_TEAM
	end
end
if duel_manager == nil then
    DebugPrint( 'created Duel Manager' )
    _G.duel_manager = class({})
end


function start_duel_event() --La fonction qui fait commencer les duel (l'evenement)
	update_team()
	local RADIANT_TEAM_ORDER = order(RADIANT_TEAM)
	local DIRE_TEAM_ORDER = order(DIRE_TEAM)

	for i=0,PlayerResource:GetPlayerCount()-1 do
	    local hero = PlayerResource:GetSelectedHeroEntity(i)
	    if hero~=nil then
		    if PlayerResource:GetConnectionState(i) == 2 then
		        if hero:IsAlive() == false then
		        	hero:RespawnUnit()
		        end
		     	hero.before_duel_pos = hero:GetAbsOrigin()
		     	--add a modifier on all the team that make them invulnerable/and prevent them to move
		    end
	    end
	end

	next_duel_think()
end

function next_duel_think() -- pour verifier quand le prochain duel commence
	duel_number = 1
	Timers:CreateTimer(1, function()
		if duel_number<=smaller_team_size and duel_in_progress == false then
			start_duel(RADIANT_TEAM_ORDER[duel_number],DIRE_TEAM_ORDER[duel_number])
			duel_in_progress = true
			duel_number = duel_number + 1
		elseif duel_number<=smaller_team_size then
			return 0.5
		else
			end_duel_event
			return nil
		end
	end)
end

function end_duel_event() --Lance le timer pour lancer le prochain duel
	Time_Left_Until_Next_event = TIME_BETWEEN_DUEL
	Timers:CreateTimer(1, function()
		Time_Left_Until_Next_event = Time_Left_Until_Next_event - 1
		if Time_Left_Until_Next_event > 0 then
			return 1
		else
			start_duel_event()
			return nil
		end
	end)
end

function order(team) -- utiliser pour classer dans l'odre les joueur par rapport a leur niveau
	local level_order = {}
	for k,v in pairs(team) do
		if level_order[1] == nil then
			level_order[1] = v
		else
			for i = 1,#level_order do
				if v:GetLevel() > level_order[i] then
					for j = #level_order+1,i+1,-1 do
						level_order[j] = level_order[j-1]
					end
					level_order[i] = v
					break
				end
				if i == #level_order then
					level_order[#level_order+1] = v
				end
			end
		end
	end
	return level_order
end

function start_duel(hero_1,hero_2) --fonction qui fait commencer un duel (entre 2 hero)

end
