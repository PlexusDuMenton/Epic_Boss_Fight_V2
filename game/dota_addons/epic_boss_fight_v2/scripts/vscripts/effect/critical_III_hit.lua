if lua_hero_effect_critical_III_hit == nil then lua_hero_effect_critical_III_hit = class({}) end


function lua_hero_effect_critical_III_hit:IsHidden()
	return false
end


function lua_hero_effect_critical_III_hit:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
    }
    return funcs
end



 



function lua_hero_effect_critical_III_hit:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			return 300
		end
	end
 
	return 0
end


function lua_hero_effect_critical_III_hit:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

