if explosive_arrow_modifier == nil then
	explosive_arrow_modifier = class({})
end



function explosive_arrow_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function explosive_arrow_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function explosive_arrow_modifier:IsHidden()
	return false
end

function explosive_arrow_modifier:IsDebuff()
	return false
end


function explosive_arrow_modifier:OnAttackLanded(event)
	if IsServer() then

		local hero = self:GetCaster()
		local target = event.target
		local damage = event.damage * self:GetAbility():GetSpecialValueFor( "damage_percent" ) * 0.01
		local area = self:GetAbility():GetSpecialValueFor( "area" )
		if event.attacker==self:GetParent() then
			local damageTable = {
							victim = nil,
							attacker = hero,
							damage = damage,
							damage_type = DAMAGE_TYPE_PHYSICAL,
						}
			local other_target = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
	                              target:GetAbsOrigin(),
	                              nil,
	                              area,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
			for k,v in pairs (other_target) do
				local dmg_table = damageTable
				dmg_table.victim = v
				ApplyDamage(dmg_table)
			end
		end
	end
end
