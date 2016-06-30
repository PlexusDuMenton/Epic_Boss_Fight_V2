if lua_hero_effect_auto_canon_I == nil then lua_hero_effect_auto_canon_I = class({}) end
function lua_hero_effect_auto_canon_I:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		Timers:CreateTimer(0.5, function()
			if hero:HasModifier("lua_hero_effect_auto_canon_I") == true then
				local enemy = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              hero:GetAbsOrigin(),
                              nil,
                              800,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
				local target = enemy[1]
				if target ~= nil then
					local distance = hero:GetAbsOrigin() - target:GetAbsOrigin()
					distance = distance:Length2D() 
					local damage = (hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2) * 1.0
					local damageTable = {
						victim = target,
						attacker = hero,
						damage = damage,
						damage_type = DAMAGE_TYPE_PHYSICAL,
					}
					EmitSoundOn("Hero_Gyrocopter.Attack", hero)
					Timers:CreateTimer(distance/2000, function()
						ApplyDamage(damageTable) 
					end)
				end
				return 1.0
			end
		end)

		
	end
end
function lua_hero_effect_auto_canon_I:IsHidden()
	return false
end


function lua_hero_effect_auto_canon_I:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end
