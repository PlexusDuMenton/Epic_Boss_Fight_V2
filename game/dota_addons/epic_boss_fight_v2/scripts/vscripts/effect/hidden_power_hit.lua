if lua_hero_effect_hidden_power_hit == nil then lua_hero_effect_hidden_power_hit = class({}) end


function lua_hero_effect_hidden_power_hit:IsHidden()
	return false
end


function lua_hero_effect_hidden_power_hit:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
    }
    return funcs
end



 



function lua_hero_effect_hidden_power_hit:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			return 1000
		end
	end
 
	return 0
end


function lua_hero_effect_hidden_power_hit:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

