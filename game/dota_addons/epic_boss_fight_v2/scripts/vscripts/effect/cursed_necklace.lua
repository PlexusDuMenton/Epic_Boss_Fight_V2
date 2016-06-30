if lua_hero_effect_cursed_necklace == nil then lua_hero_effect_cursed_necklace = class({}) end
function lua_hero_effect_cursed_necklace:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		hero.base_agro = hero.base_agro + 10
	end
end
function lua_hero_effect_cursed_necklace:OnDestroy()
	if IsServer() then
		local hero = self:GetParent()
		hero.base_agro = hero.base_agro - 10
	end
end

function lua_hero_effect_cursed_necklace:IsHidden()
	return false
end


function lua_hero_effect_cursed_necklace:DeclareFunctions()
    local funcs = {
    }
    return funcs
end


function lua_hero_effect_cursed_necklace:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

