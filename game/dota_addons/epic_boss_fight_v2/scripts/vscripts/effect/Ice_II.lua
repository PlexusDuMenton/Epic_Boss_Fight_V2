if lua_hero_effect_Ice_II == nil then lua_hero_effect_Ice_II = class({}) end

LinkLuaModifier( "lua_hero_effect_Ice_II_ennemy", "effect/Ice_II_ennemy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_hero_effect_critical_III_hit", "effect/critical_III_hit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_hero_effect_critical_IV_hit", "effect/critical_IV_hit.lua", LUA_MODIFIER_MOTION_NONE )
function lua_hero_effect_Ice_II:IsHidden()
	return false
end


function lua_hero_effect_Ice_II:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function lua_hero_effect_Ice_II:OnAttackStart( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			local hero = self:GetParent()
			hero:RemoveModifierByName("lua_hero_effect_critical_III_hit") 
			hero:RemoveModifierByName("lua_hero_effect_critical_IV_hit")

			local target = params.target
			if target ~= nil then
				local rand_int = math.random(1,100)
				if rand_int <= 20 then
					if hero.equipement.chest_armor.item_name == "item_frost_legion_armor" then
						hero:AddNewModifier(hero, nil, "lua_hero_effect_critical_III_hit",nil) 
					elseif	hero.equipement.chest_armor.item_name == "item_frost_general_armor"
						hero:AddNewModifier(hero, nil, "lua_hero_effect_critical_IV_hit",nil)
					end
					target:AddNewModifier(hero, nil, "lua_hero_effect_Ice_II_ennemy", {duration = 5})
				end
			end
		end
	end
 
	return 0
end


function lua_hero_effect_Ice_II:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

