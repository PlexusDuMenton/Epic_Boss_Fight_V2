if lua_hero_effect_heaven_talisman == nil then lua_hero_effect_heaven_talisman = class({}) end

local CD_Length = 5
local CD = 0

function lua_hero_effect_heaven_talisman:OnCreated()
	if IsServer() then
		Timers:CreateTimer(0.1, function()
			if CD > 0 then
				CD = CD - 0.1
				if CD <0 then CD = 0 end
			end
			return 0.1
		end)
	end
end

function lua_hero_effect_heaven_talisman:IsHidden()
	return false
end


function lua_hero_effect_heaven_talisman:DeclareFunctions()
    local funcs = {
		  MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end


function lua_hero_effect_heaven_talisman:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function lua_hero_effect_heaven_talisman:OnTakeDamage(event)
	local hero = self:GetParent()
	local reduction_prcnt	= event.reduction
  local damage =event.damage - math.floor( ( (event.damage / 100) * reduction_prcnt ) + 0.5 )

	if CD <= 0 then
		if damage>= hero:GetHealth() then
			CD = CD_Length
			caster:SetHealth(1 + damage )
	end
end
