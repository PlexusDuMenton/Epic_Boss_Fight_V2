if lua_equipement_modifier == nil then
	lua_equipement_modifier = class({})
end

function lua_equipement_modifier:DeclareFunctions()
	local funcs = {
MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE --[[,

MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
MODIFIER_PROPERTY_HEALTH_BONUS,
MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
MODIFIER_PROPERTY_MANA_BONUS,
MODIFIER_PROPERTY_MANA_REGEN_CONSTANT

]]
	}
	return funcs
end

function lua_equipement_modifier:IsHidden()
	return true
end

function lua_equipement_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end


function lua_equipement_modifier:GetModifierPreAttack_BonusDamage()
	local id = self:GetParent():GetPlayerID()
	print (id)
end

function lua_equipement_modifier:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster().equip_stats ~= nil then
	return self:GetCaster().equip_stats.attack_speed
	end
end

function lua_equipement_modifier:GetModifierAttackRangeBonus()
	if self:GetCaster().equip_stats ~= nil then
	return self:GetCaster().equip_stats.range
	end
end

function lua_equipement_modifier:GetModifierPhysicalArmorBonus()
	if self:GetCaster().equip_stats ~= nil then
	return self:GetCaster().equip_stats.armor
	end
end

function lua_equipement_modifier:GetModifierMagicalResistanceBonus()
	if self:GetCaster().equip_stats ~= nil then
	return self:GetCaster().equip_stats.m_ress
	end
end

function lua_equipement_modifier:GetModifierHealthBonus()
	if self:GetCaster().equip_stats ~= nil then
	return self:GetCaster().equip_stats.hp
	end
end

function lua_equipement_modifier:GetModifierConstantHealthRegen()
	if self:GetCaster().equip_stats ~= nil then
	return self:GetCaster().equip_stats.hp_regen
	end
end

function lua_equipement_modifier:GetModifierManaBonus()
	if self:GetCaster().equip_stats ~= nil then
	return self:GetCaster().equip_stats.mp
	end
end

function lua_equipement_modifier:GetModifierConstantManaRegen()
	if self:GetCaster().equip_stats ~= nil then
	return self:GetCaster().equip_stats.mp_regen
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
