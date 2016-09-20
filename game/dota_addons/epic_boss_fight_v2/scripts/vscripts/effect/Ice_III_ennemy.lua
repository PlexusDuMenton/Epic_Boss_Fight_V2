if lua_hero_effect_Ice_III_ennemy == nil then lua_hero_effect_Ice_III_ennemy = class({}) end


function lua_hero_effect_Ice_III_ennemy:IsHidden()
	return false
end


function lua_hero_effect_Ice_III_ennemy:DeclareFunctions()
    local funcs = {
    	MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE 
    }
    return funcs
end



 



function lua_hero_effect_Ice_III_ennemy:GetModifierMoveSpeedBonus_Percentage( params )
	if IsServer() then
		if params.attacker ~= self:GetParent() then
			return -30
		end
	end
 
	return 0
end


function lua_hero_effect_Ice_III_ennemy:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

