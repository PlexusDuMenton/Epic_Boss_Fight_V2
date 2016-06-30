if lua_hero_effect_cleave_I == nil then lua_hero_effect_cleave_I = class({}) end

function lua_hero_effect_cleave_I:IsHidden()
	return false
end


function lua_hero_effect_cleave_I:DeclareFunctions()
    local funcs = {
    	MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function lua_hero_effect_cleave_I:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) then
			if self:GetParent():PassivesDisabled() then
				return 0
			end
 
			local target = params.target
			if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
				local cleaveDamage = ( 20 * params.damage ) / 100.0
				DoCleaveAttack( self:GetParent(), target, self:GetAbility(), cleaveDamage, 400, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
			end
		end
	end
 
	return 0
end


function lua_hero_effect_cleave_I:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE 
end

