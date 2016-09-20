if lua_hero_effect_Ice_III == nil then lua_hero_effect_Ice_III = class({}) end

LinkLuaModifier( "lua_hero_effect_Ice_III_ennemy", "effect/Ice_III_ennemy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_hero_effect_critical_III_hit", "effect/critical_III_hit.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_hero_effect_critical_IV_hit", "effect/critical_IV_hit.lua", LUA_MODIFIER_MOTION_NONE )
function lua_hero_effect_Ice_III:IsHidden()
	return false
end


function lua_hero_effect_Ice_III:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function lua_hero_effect_Ice_III:OnAttackStart( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			local hero = self:GetParent()

			local target = params.target
			if target ~= nil then
				local rand_int = math.random(1,100)
				if rand_int <= 30 then
					if hero.equipement.chest_armor.item_name == "item_frost_general_helmet" then
						hero:AddNewModifier(hero, nil, "lua_hero_effect_critical_III_hit",nil) 
					elseif	hero.equipement.chest_armor.item_name == "item_frost_lord_helmet"
						hero:AddNewModifier(hero, nil, "lua_hero_effect_critical_IV_hit",nil)
					end
					target:AddNewModifier(hero, nil, "lua_hero_effect_Ice_III_ennemy", {duration = 5})
				end
			end
		end
	end
 
	return 0
end


function lua_hero_effect_Ice_III:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

