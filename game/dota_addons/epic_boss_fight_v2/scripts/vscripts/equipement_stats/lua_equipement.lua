
if lua_equipement == nil then
	lua_equipement = class({})
end

LinkLuaModifier( "lua_equipement_modifier", "equipement_stats/lua_equipement_modifier.lua", LUA_MODIFIER_MOTION_NONE )

function lua_equipement:GetIntrinsicModifierName()
	return "lua_equipement_modifier"
end