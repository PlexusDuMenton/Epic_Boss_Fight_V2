if lua_modifier_stun == nil then
	lua_modifier_stun = class({})
end
 
--------------------------------------------------------------------------------
 
function lua_modifier_stun:IsDebuff()
	return true
end
 
--------------------------------------------------------------------------------
 
function lua_modifier_stun:IsStunDebuff()
	return true
end
 
--------------------------------------------------------------------------------
 
function lua_modifier_stun:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
 
--------------------------------------------------------------------------------
 
function lua_modifier_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
 
--------------------------------------------------------------------------------
 
function lua_modifier_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
 
	return funcs
end
 
--------------------------------------------------------------------------------
 
function lua_modifier_stun:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end
 

function lua_modifier_stun:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}
 
	return state
end

