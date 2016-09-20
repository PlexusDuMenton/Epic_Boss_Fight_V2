
if arrows_rain == nil then
	arrows_rain = class({})
end

function arrows_rain:GetManaCost()
    return 15
end

function arrows_rain:OnChannelFinish(interrupted)
	if IsServer() then
		if interrupted == true then return end
		local hero = self:GetCaster()

	    local vPoint = self:GetCursorPosition() --We will always have Vector for the point.
	    local vOrigin = hero:GetAbsOrigin() --Our caster's location
	    local vtarget = vPoint
	    local time = 0




	    local total_damage = math.ceil((hero.effect_bonus.damage+hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2)  * self:GetSpecialValueFor( "damage_percent" ) * 0.01)
			local duration = self:GetSpecialValueFor( "duration" )
			local radius = self:GetSpecialValueFor( "radius" )
			local tick_seconds = 5
	    local damage  = total_damage/(duration*tick_seconds)

			-- CREATE THIS DAMN FUCKING PARTICLE !

    	local damageTable = {
							victim = nil,
							attacker = hero,
							damage = damage,
							damage_type = DAMAGE_TYPE_PHYSICAL,
						}

			Timers:CreateTimer(1/tick_seconds,function()

				time = time + 1/tick_seconds
				local enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
				                              vtarget,
				                              nil,
				                              radius,
				                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				                              DOTA_UNIT_TARGET_ALL,
				                              DOTA_UNIT_TARGET_FLAG_NONE,
				                              FIND_ANY_ORDER,
				                              false
				)
				print("tick ", time, " tack",#enemy)
				for k,v in pairs(enemy) do
					local Damage_Table = damageTable
					Damage_Table.victim = v
					print("dealt damage to unit called : ",v:GetUnitName())
					ApplyDamage(Damage_Table)
				end
			end)


	end
end
