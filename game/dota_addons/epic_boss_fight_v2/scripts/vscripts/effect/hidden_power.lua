if lua_hero_effect_hidden_power == nil then lua_hero_effect_hidden_power = class({}) end

LinkLuaModifier( "lua_hero_effect_hidden_power_hit", "effect/hidden_power_hit.lua", LUA_MODIFIER_MOTION_NONE )
function lua_hero_effect_hidden_power:IsHidden()
	return false
end


function lua_hero_effect_hidden_power:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function lua_hero_effect_hidden_power:OnAttackStart( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			local hero = self:GetParent()
 			hero:RemoveModifierByName("lua_hero_effect_hidden_power_hit") 
			local target = params.target
			if target ~= nil then
				local rand_int = math.random(1,100)
				print(rand_int)
				if rand_int <= 11 then
					hero:AddNewModifier(hero, nil, "lua_hero_effect_hidden_power_hit", nil)
				end
			end
		end
	end
 
	return 0
end


function lua_hero_effect_hidden_power:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

