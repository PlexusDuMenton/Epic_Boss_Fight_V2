if lua_hero_effect_bleed_1 == nil then lua_hero_effect_bleed_1 = class({}) end
function lua_hero_effect_bleed_1:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
	end
end
function lua_hero_effect_bleed_1:IsHidden()
	return false
end


function lua_hero_effect_bleed_1:DeclareFunctions()
    local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED 
    }
    return funcs
end


function lua_hero_effect_bleed_1:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

function lua_hero_effect_bleed_1:OnAttackLanded(event)
	if IsServer() then
		local hero = self:GetParent()
		if event.attacker==self:GetParent() then
			local target = event.target
			local percent = 500
			local damage = (event.damage * (percent/100) )

			local damageTable = {
				victim = target,
				attacker = hero,
				damage = damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}
			if math.random(1,100) <= 5 then
				Fire_effect = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",  PATTACH_ABSORIGIN , target )
				
				EmitSoundOn("Hero_PhantomAssassin.CoupDeGrace", target)
				ApplyDamage(damageTable) 
			end
		end
	end
end