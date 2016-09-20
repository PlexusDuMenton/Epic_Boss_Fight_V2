
if cluster_shot == nil then
	cluster_shot = class({})
end

function cluster_shot:GetManaCost()
    return 10
end



function cluster_shot:OnSpellStart(event)
	if IsServer() then
		local hero = self:GetCaster()

	    local vPoint = self:GetCursorPosition() --We will always have Vector for the point.
	    local vOrigin = hero:GetAbsOrigin() --Our caster's location
	    local vtarget = vPoint
	    local nCasterFX = nil
	    local time = 0
	    local vDiff = vtarget- vOrigin
	    local v_dir = vDiff/vDiff:Length2D()

	    local direction = RotatePosition(Vector(0,0,0), QAngle(0,-45,0), v_dir)



	    local damage_percent = self:GetSpecialValueFor( "damage_percent" )
	    local projectile_ammount = self:GetSpecialValueFor( "number_of_projectile" )
	    local time_between_fire = 0.5/projectile_ammount
	    local angle = 90/(projectile_ammount + 1)

	    local damage  = math.ceil((hero.effect_bonus.damage+hero.equip_stats.damage + hero.skill_bonus.str*1.5 +hero.hero_stats.str*1.5+ hero.equip_stats.str*1.5 + 2) * (damage_percent*0.01))
    	local damageTable = {
							victim = nil,
							attacker = hero,
							damage = damage,
							damage_type = DAMAGE_TYPE_PHYSICAL,
						}
    	local projectileTable = {
			        Ability = self,
			        EffectName = "particles/cluster_shot.vpcf",
			        vSpawnOrigin = hero:GetAbsOrigin(),
			        fDistance = 1500,
			        fStartRadius = 50,
			        fEndRadius = 50,
			        fExpireTime = GameRules:GetGameTime() + 5,
			        Source = hero,
			        bHasFrontalCone = true,
			        bReplaceExisting = false,
			        bProvidesVision = false,
			        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
			        bDeleteOnHit = false,
			        vVelocity = v_dir*1200,
	    	}

				print("projectile ammount : "..projectile_ammount)
	    	for i=1,projectile_ammount do
					print("shot projectile "..i)
	    		Timers:CreateTimer(time_between_fire*i,function()
	    			if self:IsChanneling() == true then
			    		direction = RotatePosition(Vector(0,0,0), QAngle(0,angle,0), direction)
			    		projectileTable.vVelocity = direction * 1200
			    		projectileTable.vSpawnOrigin = hero:GetAbsOrigin()
			    		projectileTable.fExpireTime = GameRules:GetGameTime() + 3 + (time_between_fire*i)
			    		create_projectile(projectileTable,DOTA_TEAM_BADGUYS,damageTable)
			    	end
		    	end)
	    	end
	end
end

function projectile_dectection(origin,speed,duration,origin_size,final_size,team,Damage_Table,modifier_name,bDeleteOnHit)
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
					if modifier_name ~= nil then
						LinkLuaModifier( modifier_name, "modifiers/"..modifier_name..".lua", LUA_MODIFIER_MOTION_NONE )
					end
					unit_touched[#unit_touched + 1] = v
					if bDeleteOnHit == true then
						enemy = {}
						time = duration + 1
					end
				end
			end
    		return 0.015
    	end
    end)
end

function create_projectile(Info,team,Damage_Table,modifier_name)
	ProjectileManager:CreateLinearProjectile( Info )
	local duration = 0
	print("create projectile")
	if (Info.fExpireTime - GameRules:GetGameTime()) > ((Info.fDistance)/(Info.vVelocity:Length2D())) then
		duration = (Info.fDistance)/(Info.vVelocity:Length2D())
	else
		duration = (Info.fExpireTime - GameRules:GetGameTime())
	end
	print(duration)
	projectile_dectection(Info.vSpawnOrigin,Info.vVelocity,duration,Info.fStartRadius,Info.fEndRadius,team,Damage_Table,modifier_name,Info.bDeleteOnHit)
end
