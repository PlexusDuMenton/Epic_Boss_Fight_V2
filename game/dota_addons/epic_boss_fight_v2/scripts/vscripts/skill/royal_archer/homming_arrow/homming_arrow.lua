
if homming_arrow == nil then
	homming_arrow = class({})
end


function homming_arrow:GetManaCost()
    return 5
end

function choose_rand_target(target_list)
	local target = nil
	if #target_list > 0 then
		local target_id = math.random(1,#target_list)
		target = target_list[target_id]
	end
	return target
end

function homming_arrow:launch_arrow(hero,target)
	if target ~= nil then
		hero:PerformAttack(target,true,true,true,true,true)
	end
end

function homming_arrow:OnSpellStart()
	if IsServer() then
		local hero = self:GetCaster()

		local arrows_ammount = self:GetSpecialValueFor( "arrows_ammount" )
		local duration = self:GetSpecialValueFor( "duration" )
		local range = self:GetSpecialValueFor("range")
		local delay_between_arrows = duration/arrows_ammount
		Timers:CreateTimer(delay_between_arrows,function()
			if self:IsChanneling() == true then
				local target_list = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
																	hero:GetAbsOrigin(),
																	nil,
																	range,
																	DOTA_UNIT_TARGET_TEAM_ENEMY,
																	DOTA_UNIT_TARGET_ALL,
																	DOTA_UNIT_TARGET_FLAG_NONE,
																	FIND_ANY_ORDER,
																	false)
				local target = choose_rand_target(target_list)
				homming_arrow:launch_arrow(hero,target)
				return delay_between_arrows
			end
		end)

	end
end
