if ebf_boss_manager == nil then
	ebf_boss_manager = class({})
end
require( "libraries/Timers" )
require("internal/util")

function ebf_boss_manager:Start()
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( ebf_boss_manager, "OnEntityKilled" ), self ),
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameMode, "OnSpawn" ), self )
end

function ebf_boss_manager:OnEntityKilled(event)
	local killed_unit = EntIndexToHScript( event.entindex )
end

function ebf_boss_manager:OnSpawn(event)
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit:IsCreature() or spawnedUnit:GetTeamNumber() ~= DOTA_TEAM_BADGUYS then
		return
	end
	local diff_mult = GameRules.difficulty
	spawnedUnit:SetMaxHealth(spawnedUnit:GetMaxHealth() * diff_mult )
	spawnedUnit:SetHealth(spawnedUnit:GetMaxHealth())
	spawnedUnit:SetBaseDamageMin((spawnedUnit:GetBaseDamageMin()) * (diff_mult*0.5 + 0.5) )
	spawnedUnit:SetBaseDamageMax((spawnedUnit:GetBaseDamageMax()) * (diff_mult*0.5 + 0.5) )
	spawnedUnit:SetPhysicalArmorBaseValue((spawnedUnit:GetPhysicalArmorBaseValue()-1 + diff_mult) * (diff_mult*0.5 + 0.5))

end