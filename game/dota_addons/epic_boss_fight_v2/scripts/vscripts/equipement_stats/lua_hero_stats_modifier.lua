if lua_hero_stats_modifier == nil then
	lua_hero_stats_modifier = class({})
end
function lua_hero_stats_modifier:DeclareFunctions()
	local funcs = {
MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE ,
MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
MODIFIER_PROPERTY_HEALTH_BONUS,
MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
MODIFIER_PROPERTY_MANA_BONUS,
MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
MODIFIER_PROPERTY_EVASION_CONSTANT,
MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE,
MODIFIER_PROPERTY_CAST_RANGE_BONUS
	}
	return funcs
end

function lua_hero_stats_modifier:IsHidden()
	return true
end


function lua_hero_stats_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end


function lua_hero_stats_modifier:GetModifierMagicDamageOutgoing_Percentage()
	if IsServer() then
		return self:GetCaster().hero_stats.int
	end
end

function lua_hero_stats_modifier:GetModifierCastRangeBonus()
	if IsServer() then
		return self:GetCaster().hero_stats.int*0.2
	end
end

function lua_hero_stats_modifier:GetModifierBaseAttack_BonusDamage()
	if IsServer() then
		return (self:GetCaster().hero_stats.damage + self:GetCaster().hero_stats.str*1.5)
	end
end

function lua_hero_stats_modifier:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		return self:GetCaster().hero_stats.attack_speed + self:GetCaster().hero_stats.agi*0.33
	end
end

function lua_hero_stats_modifier:GetModifierAttackRangeBonus()
	if IsServer() then
		return self:GetCaster().hero_stats.range
	end
end

function lua_hero_stats_modifier:GetModifierPhysicalArmorBonus()
	if IsServer() then
		return self:GetCaster().hero_stats.armor
	end
end

function lua_hero_stats_modifier:GetModifierMagicalResistanceBonus()
	if IsServer() then
		return self:GetCaster().hero_stats.m_ress
	end
end

function lua_hero_stats_modifier:GetModifierHealthBonus()
	print("ok")
	if IsServer() then
		return self:GetCaster().hero_stats.hp
	end
end

function lua_hero_stats_modifier:GetModifierConstantHealthRegen()
	if IsServer() then
		return self:GetCaster().hero_stats.hp_regen
	end
end

function lua_hero_stats_modifier:GetModifierManaBonus()
	if IsServer() then
		return self:GetCaster().hero_stats.mp
	end
end

function lua_hero_stats_modifier:GetModifierConstantManaRegen()
	if IsServer() then
		return self:GetCaster().hero_stats.mp_regen
	end
end

function lua_hero_stats_modifier:GetModifierMoveSpeedBonus_Constant()
	if IsServer() then
		return self:GetCaster().hero_stats.movespeed
	end
end

function lua_hero_stats_modifier:GetModifierEvasion_Constant()
	if IsServer() then
		return self:GetCaster().hero_stats.dodge
	end
end

--to do : Life On Hit (Hp regen on each hit) and Life Steal (% of damage) , Also effects

--[[
everything which get modified by items
    equip_stats.damage = 0
    equip_stats.attack_speed = 0
    equip_stats.range = 0
    equip_stats.armor = 0
    equip_stats.m_ress = 0
    equip_stats.hp = 0
    equip_stats.hp_regen = 0
    equip_stats.mp = 0
    equip_stats.mp_regen = 0
    equip_stats.ls = 0
    equip_stats.loh = 0
]]
