if lua_hero_effect_auto_canon_IV == nil then lua_hero_effect_auto_canon_IV = class({}) end
function lua_hero_effect_auto_canon_IV:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		Timers:CreateTimer(0.5, function()
			if hero:HasModifier("lua_hero_effect_auto_canon_IV") == true then
				local enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              hero:GetAbsOrigin(),
                              nil,
                              1600,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
				for k,v in pairs (enemy) do
					local distance = hero:GetAbsOrigin() - v:GetAbsOrigin()
					distance = distance:Length2D() 
					local damage = (hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2) * 2.0
					local damageTable = {
						victim = v,
						attacker = hero,
						damage = damage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
					}
					Timers:CreateTimer(distance/2000, function()
						ApplyDamage(damageTable) 
					end)
				end
				if enemy[1] ~= nil then
					EmitSoundOn("Hero_Gyrocopter.Attack", hero)
				end	
				return 1.0
			end
		end)

		
	end
end
function lua_hero_effect_auto_canon_IV:IsHidden()
	return false
end


function lua_hero_effect_auto_canon_IV:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end
