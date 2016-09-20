
if unshakable_charge == nil then
	unshakable_charge = class({})
end

LinkLuaModifier( "unshakable_charge_modifier", "skill/legion_duelist/unshakable_charge/modifier.lua", LUA_MODIFIER_MOTION_NONE )

function unshakable_charge:GetManaCost()
    return 5
end



function unshakable_charge:OnSpellStart(event)
	if IsServer() then
		local hero = self:GetCaster()
		hero:AddNewModifier(hero, self, "unshakable_charge_modifier",{})

	    local vPoint = self:GetCursorPosition() --We will always have Vector for the point.
	    local vOrigin = hero:GetAbsOrigin() --Our caster's location
	    local vtarget = vPoint
	    local nCasterFX = nil
	    local time = 0
	    local vDiff = vtarget- vOrigin
	    EmitSoundOn( "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", hCaster )

	    if vDiff:Length2D() < (self:GetSpecialValueFor( "distance" )*0.5) then
	    	print (vDiff:Length2D(),(self:GetSpecialValueFor( "distance" )*0.5),((self:GetSpecialValueFor( "distance" )*0.5)/vDiff:Length2D()))
	    	vDiff = vDiff * ((self:GetSpecialValueFor( "distance" )*0.5)/vDiff:Length2D())
	    end

		hero:MoveToPosition(hero:GetAbsOrigin() - hero:GetForwardVector())
		vDiff.z = 0
		local v_target = Vector(vDiff.x/vDiff:Length2D(),vDiff.y/vDiff:Length2D(),0)

		hero:SetForwardVector(v_target)
		hero:MoveToPosition(hero:GetAbsOrigin() - hero:GetForwardVector())

		local duration = 0.5 + (vDiff:Length2D()/6000)
	    local movement_x_per_frame = vDiff.x/(50*duration)
	    local movement_y_per_frame = vDiff.y/(50*duration)
	    StartAnimation(hero, {duration=duration+1.5, activity=ACT_DOTA_RUN , rate=1.0})
	    Timers:CreateTimer(0.01,function()
	    	if hero:IsAlive() then
	    		hero:SetForwardVector(v_target)
		    	time = time + 0.02
		    	movement = Vector(movement_x_per_frame,movement_y_per_frame,0)
		    	hero:SetAbsOrigin(hero:GetAbsOrigin() + movement)
		    	hero:SetAbsOrigin(Vector(hero:GetAbsOrigin().x,hero:GetAbsOrigin().y,GetGroundHeight(hero:GetAbsOrigin(),nil)))
		    	if time >= duration then
		    		FindClearSpaceForUnit(hero, hero:GetAbsOrigin(), false)
		    		EndAnimation(hero)
		    		hero:RemoveModifierByName("unshakable_charge_modifier")
		    		hero:Stop()
		    	else
		    		return 0.02
		    	end
		    else
		    	ParticleManager:DestroyParticle(nCasterFX, true)
		    end
    	end)
	    local damage_percent = self:GetSpecialValueFor( "damage_percent" )
	    local damage  = math.ceil((hero.effect_bonus.damage+hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2) * (damage_percent*0.01))
    	local damageTable = {
							victim = nil,
							attacker = hero,
							damage = damage,
							damage_type = DAMAGE_TYPE_PHYSICAL,
						}


    	local projectileTable = {
			        Ability = self,
			        EffectName = "",
			        vSpawnOrigin = hero:GetAbsOrigin(),
			        fDistance = vDiff:Length2D(),
			        fStartRadius = 200,
			        fEndRadius = 200,
			        fExpireTime = GameRules:GetGameTime() + 10,
			        Source = hero,
			        bHasFrontalCone = true,
			        bReplaceExisting = false,
			        bProvidesVision = false,
			        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
			        bDeleteOnHit = false,
			        vVelocity = Vector(movement_x_per_frame,movement_y_per_frame,0)*50,
	    	}

			create_projectile(projectileTable,DOTA_TEAM_BADGUYS,damageTable)


	end
end

function projectile_dectection(origin,speed,duration,origin_size,final_size,team,Damage_Table,modifier_name)
	print(duration)
	local time = 0
	local unit_touched = {}
	Timers:CreateTimer(0.015,function()
	   	time = time + 0.015
	    if time <= duration then
	    	local location = origin + speed * time
			local size = origin_size + ((final_size-origin_size)*(time/duration))
			local enemy = FindUnitsInRadius(team,
                              location,
                              nil,
                              size,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
			for k,v in pairs(enemy) do
				local f_is_allready = false
				for j,p in pairs(unit_touched) do
					if v == p then
						f_is_allready = true
					end
				end
				if f_is_allready == false then
					Damage_Table.victim = v
					ApplyDamage(Damage_Table)
					print(Damage_Table.damage)
					if modifier_name ~= nil then
						LinkLuaModifier( modifier_name, "modifiers/"..modifier_name..".lua", LUA_MODIFIER_MOTION_NONE )
					end
					unit_touched[#unit_touched + 1] = v
				end
			end
    		return 0.015
    	end
    end)
end

function create_projectile(Info,team,Damage_Table,modifier_name)
	ProjectileManager:CreateLinearProjectile( Info )
	local duration = 0
	if (Info.fExpireTime - GameRules:GetGameTime()) > ((Info.fDistance)/(Info.vVelocity:Length2D())) then
		duration = (Info.fDistance)/(Info.vVelocity:Length2D())
	else
		duration = (Info.fExpireTime - GameRules:GetGameTime())
	end
	projectile_dectection(Info.vSpawnOrigin,Info.vVelocity,duration,Info.fStartRadius,Info.fEndRadius,team,Damage_Table,modifier_name)
end
