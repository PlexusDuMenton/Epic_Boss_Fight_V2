if lua_hero_effect_poison_1 == nil then lua_hero_effect_poison_1 = class({}) end
print ("test modifier")
function lua_hero_effect_poison_1:OnCreated()
	if IsServer() then
		local hero = self:GetParent()
		print ("MODIFIER !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",hero)
	end
end
function lua_hero_effect_poison_1:IsHidden()
	return false
end


function lua_hero_effect_poison_1:DeclareFunctions()
    local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED 
    }
    return funcs
end


function lua_hero_effect_poison_1:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

function lua_hero_effect_poison_1:OnAttackLanded(event)
	if IsServer() then
		local hero = self:GetParent()
		print ("test")
		if event.attacker==self:GetParent() then
			local target = event.target
			local percent = 100
			local duration = 3
			local ticktime = 0.2
			local tick = duration/ticktime
			local damage = (event.damage * (percent/100) )/tick
			local timer = 0

			local damageTable = {
				victim = target,
				attacker = hero,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
			Timers:CreateTimer(0.2, function()
				timer = timer + 0.2
				if timer <= duration then
					ApplyDamage(damageTable) 
					return 0.2
				end
		    end)
		end
	end
end