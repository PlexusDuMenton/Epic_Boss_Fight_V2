
if lua_hero_stats == nil then
	lua_hero_stats = class({})
end

LinkLuaModifier( "lua_hero_stats_modifier", "equipement_stats/lua_hero_stats_modifier.lua", LUA_MODIFIER_MOTION_NONE )

function lua_hero_stats:GetIntrinsicModifierName()
	return "lua_hero_stats_modifier"
end