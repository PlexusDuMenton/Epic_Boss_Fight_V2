
if shield_faith == nil then
	shield_faith = class({})
end

LinkLuaModifier( "shield_faith_modifier", "skill/legion_duelist/shield_faith/shield_faith_modifier.lua", LUA_MODIFIER_MOTION_NONE )

function shield_faith:GetManaCost()
    return 15
end

function shield_faith:OnSpellStart(event)
	if IsServer() then
		local hero = self:GetCaster()
		EmitSoundOn("Hero_Omniknight.GuardianAngel.Cast", hero)
		hero:AddNewModifier(hero, self, "shield_faith_modifier",{})
		nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf",  PATTACH_ABSORIGIN_FOLLOW , hero )
		Timers:CreateTimer(self:GetSpecialValueFor( "duration" ),function()
			ParticleManager:DestroyParticle(nCasterFX, true)
			hero:RemoveModifierByName("shield_faith_modifier")
		end)
	end
end
