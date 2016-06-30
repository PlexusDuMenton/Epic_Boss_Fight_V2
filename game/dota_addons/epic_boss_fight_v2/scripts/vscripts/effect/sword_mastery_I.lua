if lua_hero_effect_sword_mastery_I == nil then lua_hero_effect_sword_mastery_I = class({}) end
function lua_hero_effect_sword_mastery_I:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		local added_damage = 0
		local added_as = 0
		Timers:CreateTimer(0.01,function()
			if hero:HasModifier("lua_hero_effect_sword_mastery_I") == true then
				hero.effect_bonus.damage = hero.effect_bonus.damage - added_damage
				hero.effect_bonus.as = hero.effect_bonus.as - added_as
				added_damage = 0
				added_as = 0
				if hero.equipement.weapon ~= nil then
					if hero.equipement.weapon.ranged ~= true then
						DeepPrintTable(hero.equip_stats)
						DeepPrintTable(hero.skill_bonus)
						added_damage = (hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2)*0.1
						added_as = 50
					end
				end
				hero.effect_bonus.damage = hero.effect_bonus.damage + added_damage
				hero.effect_bonus.as = hero.effect_bonus.as + added_as
				return 0.7
			else
				hero.effect_bonus.damage = hero.effect_bonus.damage - added_damage
				hero.effect_bonus.as = hero.effect_bonus.as - added_as
			end
		end)
	end
end
function lua_hero_effect_sword_mastery_I:IsHidden()
	return false
end


function lua_hero_effect_sword_mastery_I:DeclareFunctions()
    local funcs = {
    MODIFIER_PROPERTY_EVASION_CONSTANT,
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
    return funcs
end


function lua_hero_effect_sword_mastery_I:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

function lua_hero_effect_sword_mastery_I:GetModifierBaseAttack_BonusDamage(event)
	if IsServer() then
		local hero = self:GetParent()
		if hero.equipement.weapon ~= nil then
			if hero.equipement.weapon.ranged ~= true then
				return (hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2)*0.1
			else
				return 0
			end
		end
	end
end
function lua_hero_effect_sword_mastery_I:GetModifierAttackSpeedBonus_Constant(event)
	if IsServer() then
		if hero.equipement.weapon ~= nil then
			if hero.equipement.weapon.ranged ~= true then
				return 50
			else
				return 0
			end
		end
	end
end
function lua_hero_effect_sword_mastery_I:GetModifierEvasion_Constant(event)
	if IsServer() then
		return 20
	end
end