-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require("inventory_manager")
require("skill_manager")
require('libraries/notifications')
require('storageapi/storage')
require("selecthero")
require("boss_manager")
require("round_manager")
require('gamemode')
require('save')
require("statcollection/init")

function Precache( context )
--[[
  for sure in your game and that will not be precached by hero selection.  When a hero
  This function is used to precache resources/units/items/abilities that will be needed
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed

  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle_folder", "particles/units/heroes/hero_legion_commander", context)
  PrecacheResource( "model", "models/development/invisiblebox.vmdl", context )

  PrecacheResource( "particle", "particles/units/heroes/hero_legion_commander/legion_weapon_blurc.vpcf", context )

  PrecacheResource( "particle", "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", context )
  PrecacheResource( "particle", "particles/frozen_flame_effect.vpcf", context )
  PrecacheResource( "particle", "particles/dragon_flame_effect.vpcf", context )

  PrecacheResource( "particle", "particles/impact_incoming.vpcf", context )
  PrecacheResource( "particle", "particles/scream_wave.vpcf", context )
  PrecacheResource( "particle", "particles/ground_marker_test.vpcf", context )
  PrecacheResource( "particle", "particles/boss_4_aoe.vpcf", context )
  PrecacheResource( "particle", "particles/boss_5_grow.vpcf", context )

  PrecacheResource( "particle", "particles/cluster_shot.vpcf", context )
  PrecacheResource( "particle", "particles/focused_shot.vpcf", context )

  PrecacheResource( "particle", "particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf", context)
  PrecacheResource( "soundfile", "soundevents/game_sounds_creeps.vsndevts", context )
  PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_earthshaker.vsndevts", context )

  PrecacheResource( "particle", "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", context )
  PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ursa.vsndevts", context )
  PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", context )
  PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context )
  PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context )
  PrecacheResource( "soundfile", "soundevents/game_sounds_roshan_halloween.vsndevts", context )
  PrecacheResource( "soundfile", "soundevents/game_sounds.vsndevts", context )

  PrecacheResource( "soundfile", "soundevents/game_sounds_custom.vsndevts", context )


  --next i'll precache all particle used by weapons :
  PrecacheResource( "particle", "particles/units/heroes/hero_leshrac/leshrac_base_attack.vpcf", context )
  PrecacheResource( "particle", "particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf", context )

  local items = LoadKeyValues("scripts/kv/items.kv")
  for k,v in pairs(items) do
    if v.projectile_name ~= nil then
      PrecacheResource( "particle", v.projectile_name, context )
    end
  end

end

-- Create the game mode when we activate
function Activate()
  GameRules.epic_boss_fight = epic_boss_fight()
  epic_boss_fight:InitGameMode()
end
