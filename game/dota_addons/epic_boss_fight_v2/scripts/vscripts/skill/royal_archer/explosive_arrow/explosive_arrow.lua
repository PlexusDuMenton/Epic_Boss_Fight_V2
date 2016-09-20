
if explosive_arrow == nil then
	explosive_arrow = class({})
end

LinkLuaModifier( "explosive_arrow_modifier", "skill/royal_archer/explosive_arrow/explosive_arrow_modifier.lua", LUA_MODIFIER_MOTION_NONE )

function explosive_arrow:GetManaCost()
    return 15
end
-- still have to find sound and particle


function explosive_arrow:OnChannelFinish(interrupted)
	if IsServer() then
		if interrupted == true then return end
		local hero = self:GetCaster()
		--EmitSoundOn("Hero_Omniknight.GuardianAngel.Cast", hero)
		hero:AddNewModifier(hero, self, "explosive_arrow_modifier",{})
		--nCasterFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf",  PATTACH_ABSORIGIN_FOLLOW , hero )
		Timers:CreateTimer(self:GetSpecialValueFor( "duration" ),function()
			--ParticleManager:DestroyParticle(nCasterFX, true)
			hero:RemoveModifierByName("explosive_arrow_modifier")
		end)
	end
end
