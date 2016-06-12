if lua_equipement_modifier == nil then
	lua_equipement_modifier = class({})
end
function lua_equipement_modifier:DeclareFunctions()
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
MODIFIER_EVENT_ON_ATTACK_LANDED,
MODIFIER_PROPERTY_CAST_RANGE_BONUS
	}
	return funcs
end

function log10(number)
    if number <0 then print ("WTF") return number end
    number = math.log(number)/math.log(10)
    return number
end

function lua_equipement_modifier:OnAttackLanded(event)
	if IsServer() then
		local hero = self:GetCaster()
		local target = event.target
		if event.attacker==self:GetParent() then
			local heal = hero.equip_stats.loh
			hero:SetHealth(hero:GetHealth() + heal)
			local damage = event.damage 
			local life_steal = hero.equip_stats.ls * damage * 0.01
			hero:SetHealth(hero:GetHealth() + life_steal)

			if hero.equipement.weapon ~= nil then
				hero.equipement.weapon.XP = ((math.random(1,3)+ math.ceil(log10(damage)^3) )*0.25) + hero.equipement.weapon.XP
				inv_manager:weapon_checklevelup(hero)
				inv_manager:save_inventory(hero)
			end
			if self:GetCaster().equip_stats.m_damage >0 then
				local damageTable = {
					victim = target,
					attacker = hero,
					damage = self:GetCaster().equip_stats.m_damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
				}
				ApplyDamage(damageTable)
			end
		end
	end
end



function lua_equipement_modifier:IsHidden()
	return true
end


function lua_equipement_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end


function lua_equipement_modifier:GetModifierBaseAttack_BonusDamage()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
			return self:GetCaster().equip_stats.damage + self:GetCaster().equip_stats.str
		end
	end
end

function lua_equipement_modifier:GetModifierCastRangeBonus()
	if IsServer() then
		return self:GetCaster().equip_stats.int *0.2
	end
end

function lua_equipement_modifier:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.attack_speed + self:GetCaster().equip_stats.agi*0.33
		end
	end
end

function lua_equipement_modifier:GetModifierAttackRangeBonus()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.range
		end
	end
end

function lua_equipement_modifier:GetModifierPhysicalArmorBonus()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.armor
		end
	end
end

function lua_equipement_modifier:GetModifierMagicalResistanceBonus()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.m_ress
		end
	end
end

function lua_equipement_modifier:GetModifierHealthBonus()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.hp * (math.log(self:GetCaster().equip_stats.str+self:GetCaster().hero_stats.str+self:GetCaster().skill_bonus.str +10)/math.log(10))
		end
	end
end

function lua_equipement_modifier:GetModifierConstantHealthRegen()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.hp_regen
		end
	end
end

function lua_equipement_modifier:GetModifierManaBonus()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.mp
		end
	end
end

function lua_equipement_modifier:GetModifierConstantManaRegen()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.mp_regen
		end
	end
end

function lua_equipement_modifier:GetModifierMoveSpeedBonus_Constant()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.movespeed
		end
	end
end

function lua_equipement_modifier:GetModifierEvasion_Constant()
	if IsServer() then
		if self:GetCaster().equip_stats ~= nil then
		return self:GetCaster().equip_stats.dodge
		end
	end
end

--to do : effects (i'll make modifier)

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
