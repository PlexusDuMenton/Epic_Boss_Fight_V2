
if courage_call == nil then
	courage_call = class({})
end

LinkLuaModifier( "courage_call_modifier", "skill/legion_duelist/courage_call/modifier.lua", LUA_MODIFIER_MOTION_NONE )

function courage_call:GetManaCost()
    return 5
end

function courage_call:OnSpellStart(event)
	if IsServer() then
		local hero = self:GetCaster()
		local allies = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              hero:GetAbsOrigin(),
                              nil,
                              9999,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
		for k,v in pairs (allies) do
			v:AddNewModifier(hero, self, "courage_call_modifier",{})
			local nCasterFX = ParticleManager:CreateParticle( "particles/trail_call_of_courage.vpcf",  PATTACH_ABSORIGIN_FOLLOW , v )
			Timers:CreateTimer(self:GetSpecialValueFor( "duration" ),function()
				ParticleManager:DestroyParticle(nCasterFX, true)
				v:RemoveModifierByName("courage_call_modifier")
			end)
		end
	end
end
