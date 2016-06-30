if lua_hero_effect_cleave_II == nil then lua_hero_effect_cleave_II = class({}) end


function lua_hero_effect_cleave_II:IsHidden()
	return false
end


function lua_hero_effect_cleave_II:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function lua_hero_effect_cleave_II:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
 
			local target = params.target
			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
				local cleaveDamage = ( 35 * params.damage ) / 100.0
				DoCleaveAttack( self:GetParent(), target, self:GetAbility(), cleaveDamage, 600, "particles/cleave_2.vpcf" )
			end
		end
	end
 
	return 0
end


function lua_hero_effect_cleave_II:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

