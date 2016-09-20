if lua_hero_effect_critical_II_hit == nil then lua_hero_effect_critical_II_hit = class({}) end


function lua_hero_effect_critical_II_hit:IsHidden()
	return false
end


function lua_hero_effect_critical_II_hit:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE
    }
    return funcs
end

function lua_hero_effect_critical_II_hit:OnAttackLanded(event)
 	if IsServer() then
		local hero = self:GetCaster()
		local target = event.target
		if event.attacker==self:GetParent() then
			hero:RemoveModifierByName("lua_hero_effect_critical_II_hit") 
		end
	end
end 




function lua_hero_effect_critical_II_hit:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			return 250
		end
	end
 
	return 0
end


function lua_hero_effect_critical_II_hit:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

