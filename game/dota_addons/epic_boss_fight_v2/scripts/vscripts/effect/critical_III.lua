if lua_hero_effect_critical_III == nil then lua_hero_effect_critical_III = class({}) end

LinkLuaModifier( "lua_hero_effect_critical_III_hit", "effect/critical_III_hit.lua", LUA_MODIFIER_MOTION_NONE )
function lua_hero_effect_critical_III:IsHidden()
	return false
end


function lua_hero_effect_critical_III:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_START
    }
    return funcs
end

function lua_hero_effect_critical_III:OnAttackStart( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
			local hero = self:GetParent()
 			hero:RemoveModifierByName("lua_hero_effect_critical_III_hit") 
			local target = params.target
			if target ~= nil then
				local rand_int = math.random(1,100)
				if rand_int <= 30 then
					hero:AddNewModifier(hero, nil, "lua_hero_effect_critical_III_hit", nil)
					ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",  PATTACH_ABSORIGIN , target )
					EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace", target)
				end
			end
		end
	end
 
	return 0
end


function lua_hero_effect_critical_III:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

