if lua_hero_effect_Ice_I == nil then lua_hero_effect_Ice_I = class({}) end

LinkLuaModifier( "lua_hero_effect_Ice_I_ennemy", "effect/Ice_I_ennemy.lua", LUA_MODIFIER_MOTION_NONE )
function lua_hero_effect_Ice_I:IsHidden()
	return false
end


function lua_hero_effect_Ice_I:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function lua_hero_effect_Ice_I:OnAttackStart( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			local hero = self:GetParent()

			local target = params.target
			if target ~= nil then
				local rand_int = math.random(1,100)
				if rand_int <= 20 then
					target:AddNewModifier(hero, nil, "lua_hero_effect_Ice_I_ennemy", {duration = 3})
				end
			end
		end
	end
 
	return 0
end


function lua_hero_effect_Ice_I:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

