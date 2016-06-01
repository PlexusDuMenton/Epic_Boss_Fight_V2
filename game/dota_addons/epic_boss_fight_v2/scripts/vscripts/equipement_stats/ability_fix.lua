
if ability_fix == nil then
	ability_fix = class({})
end

print("im getting crazy ? right ?!")

LinkLuaModifier( "hp_fix", "modifiers/hp_fix.lua", LUA_MODIFIER_MOTION_NONE )

function ability_fix:GetIntrinsicModifierName()
	return "hp_fix"
end