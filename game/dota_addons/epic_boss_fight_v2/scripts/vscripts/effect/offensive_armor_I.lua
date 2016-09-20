if lua_hero_effect_offensive_armor_I == nil then lua_hero_effect_offensive_armor_I = class({}) end
function lua_hero_effect_offensive_armor_I:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		local added_damage = 0
		local added_as = 0
		Timers:CreateTimer(0.01,function()
			if hero:HasModifier("lua_hero_effect_offensive_armor_I") == true then
				hero.effect_bonus.damage = hero.effect_bonus.damage - added_damage
				added_damage = 0
				added_damage = (hero.equip_stats.armor hero.hero_stats.armor + hero.skill_bonus.armor)*0.2
				hero.effect_bonus.damage = hero.effect_bonus.damage + added_damage
				return 0.7
			else
				hero.effect_bonus.damage = hero.effect_bonus.damage - added_damage
			end
		end)
	end
end
function lua_hero_effect_offensive_armor_I:IsHidden()
	return false
end


function lua_hero_effect_offensive_armor_I:DeclareFunctions()
    local funcs = {
    MODIFIER_PROPERTY_EVASION_CONSTANT,
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end


function lua_hero_effect_offensive_armor_I:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function lua_hero_effect_offensive_armor_I:GetModifierBaseAttack_BonusDamage(event)
	if IsServer() then
		local hero = self:GetParent()
		if hero.equipement.weapon ~= nil then
			if hero.equipement.weapon.ranged ~= true then
				return (hero.equip_stats.armor hero.hero_stats.armor + hero.skill_bonus.armor)*0.2
			else
				return 0
			end
		end
	end
end

function lua_hero_effect_offensive_armor_I:GetModifierEvasion_Constant(event)
	if IsServer() then
		return 20
	end
end
