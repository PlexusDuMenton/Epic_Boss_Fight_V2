if lua_hero_effect_bersek_speed == nil then lua_hero_effect_bersek_speed = class({}) end
function lua_hero_effect_bersek_speed:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		local added_as = 0
		local added_move_speed = 0
		Timers:CreateTimer(0.01,function()
			if hero:HasModifier("lua_hero_effect_bersek_speed") == true then
				hero.effect_bonus.as =  hero.effect_bonus.as - added_as
				hero.effect_bonus.mp_regen = hero.effect_bonus.mp_regen - added_move_speed
				added_as = 0
				added_move_speed = 0
				local hpp = (hero:GetHealth() / hero:GetMaxHealth()) *100
				local percent_improvement = 200/hpp
				added_as = percent_improvement

				added_move_speed = percent_improvement

				hero.effect_bonus.as = hero.effect_bonus.as + added_as
				hero.effect_bonus.mp_regenmp_regen = hero.effect_bonus.mp_regen + added_move_speed
				return 0.7
			else
				hero.effect_bonus.damage = hero.effect_bonus.damage - added_as
				hero.effect_bonus.mp_regen = hero.effect_bonus.mp_regen - added_move_speed
			end
		end)
	end
end
function lua_hero_effect_bersek_speed:IsHidden()
	return false
end


function lua_hero_effect_bersek_speed:DeclareFunctions()
    local funcs = {
      MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			 MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
    return funcs
end


function lua_hero_effect_bersek_speed:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function lua_hero_effect_bersek_speed:GetModifierConstantHealthRegen()
	if IsServer() then
		local hero = self:GetParent()
		local hpp = (hero:GetHealth() / hero:GetMaxHealth()) *100
		local percent_improvement = 200/hpp
		return (hero.equip_stats.hp_regen+hero.hero_stats.hp_regen)*percent_improvement*0.01
	end
end

function lua_hero_effect_bersek_strength:GetModifierBaseAttack_BonusDamage()
	if IsServer() then
		local hero = self:GetParent()
		local hpp = (hero:GetHealth() / hero:GetMaxHealth()) *100
		local percent_improvement = 200/hpp
		return (hero.equip_stats.m_damage +hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2)*percent_improvement*0.01
	end
end
