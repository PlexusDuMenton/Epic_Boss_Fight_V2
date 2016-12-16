if lua_hero_effect_bersek_mind == nil then lua_hero_effect_bersek_mind = class({}) end
function lua_hero_effect_bersek_mind:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		local added_m_damage = 0
		local added_mp_regen = 0
		Timers:CreateTimer(0.01,function()
			if hero:HasModifier("lua_hero_effect_bersek_mind") == true then
				hero.effect_bonus.magical_damage =  hero.effect_bonus.magical_damage - added_m_damage
				hero.effect_bonus.mp_regen = hero.effect_bonus.mp_regen - added_mp_regen
				added_m_damage = 0
				added_mp_regen = 0
				local hpp = (hero:GetHealth() / hero:GetMaxHealth()) *100
				local percent_improvement = 200/hpp
				added_m_damage = (hero.equip_stats.m_damage +hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2)*percent_improvement*0.01

				added_mp_regen = (hero.equip_stats.mp_regen+hero.hero_stats.mp_regen)*percent_improvement*0.01

				hero.effect_bonus.magical_damage = hero.effect_bonus.magical_damage + added_m_damage
				hero.effect_bonus.mp_regenmp_regen = hero.effect_bonus.mp_regen + added_mp_regen
				return 0.7
			else
				hero.effect_bonus.magical_damage = hero.effect_bonus.magical_damage - added_m_damage
				hero.effect_bonus.mp_regen = hero.effect_bonus.mp_regen - added_mp_regen
			end
		end)
	end
end
function lua_hero_effect_bersek_mind:IsHidden()
	return false
end


function lua_hero_effect_bersek_mind:DeclareFunctions()
    local funcs = {
     MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
    return funcs
end


function lua_hero_effect_bersek_mind:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function lua_hero_effect_bersek_mind:GetModifierConstantManaRegen(event)
	if IsServer() then
		local hero = self:GetParent()
		local hpp = (hero:GetHealth() / hero:GetMaxHealth()) *100
		local percent_improvement = 200/hpp
		return (hero.equip_stats.mp_regen+hero.hero_stats.mp_regen)*percent_improvement*0.01
	end
end
