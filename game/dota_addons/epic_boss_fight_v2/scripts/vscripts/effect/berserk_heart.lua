if lua_hero_effect_berserk_heart == nil then lua_hero_effect_berserk_heart = class({}) end
function lua_hero_effect_berserk_heart:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		Timers:CreateTimer(0.1, function()
			local hpp = hero:GetHealth()/hero:GetMaxHealth() * 100
			if hpp > 10 then hero:SetHealth(hero:GetMaxHealth()*0.1) end
			return 0.1
		end)
	end
end

function lua_hero_effect_berserk_heart:IsHidden()
	return false
end


function lua_hero_effect_berserk_heart:DeclareFunctions()
    local funcs = {
		 MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end


function lua_hero_effect_berserk_heart:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function lua_hero_effect_berserk_heart:GetModifierIncomingDamage_Percentage()
	return -80
end
