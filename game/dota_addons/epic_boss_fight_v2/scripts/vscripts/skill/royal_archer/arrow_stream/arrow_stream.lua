
if arrow_stream == nil then
	arrow_stream = class({})
end

function arrow_stream:GetManaCost()
    return 15
end

function arrow_stream:OnSpellStart()
	if IsServer() then
		local hero = self:GetCaster()
		local target = self:GetCursorTarget()

		local arrows_ammount = self:GetSpecialValueFor( "arrows_ammount" )
		local duration = self:GetSpecialValueFor( "duration" )
		local range = self:GetSpecialValueFor( "range" )

		local delay_between_arrows = duration/arrows_ammount
		Timers:CreateTimer(0,function()
			if self:IsChanneling() == true then
				self:GetCaster():PerformAttack(target,true,true,true,true,true)
				return delay_between_arrows
			end
		end)
	end
end
