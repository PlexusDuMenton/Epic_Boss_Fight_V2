if lua_hero_effect_Ice_IV == nil then lua_hero_effect_Ice_IV = class({}) end

LinkLuaModifier( "lua_hero_effect_Ice_IV_ennemy", "effect/Ice_IV_ennemy.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "lua_hero_effect_critical_V_hit", "effect/critical_IV_hit.lua", LUA_MODIFIER_MOTION_NONE )
function lua_hero_effect_Ice_IV:IsHidden()
	return false
end


function lua_hero_effect_Ice_IV:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function lua_hero_effect_Ice_IV:OnAttackStart( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			local hero = self:GetParent()

			local target = params.target
			if target ~= nil then
				local rand_int = math.random(1,100)
				if rand_int <= 35 then
					if	hero.equipement.chest_armor.item_name == "item_frost_lord_helmet"
						hero:AddNewModifier(hero, nil, "lua_hero_effect_critical_V_hit",nil)
					end
					target:AddNewModifier(hero, nil, "lua_hero_effect_Ice_IV_ennemy", {duration = 5})
				end
			end
		end
	end
 
	return 0
end


function lua_hero_effect_Ice_IV:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

