--(づ ͠° ͟ل͜ ͡°)づ Come here Little Boy (╯°□°)╯

require('libraries/timers')
require('libraries/animations')
THINK_TIME = 1.5
go_back_to_parent = false
CD_DIVISER = math.log(GameRules.difficulty+10)/math.log(10)
boss_state = "idle"
boss_target = nil
change_target_CD = 0
casting_spell = false

function Spawn( entityKeyValues )

	thisEntity:SetContextThink( "Boss_think", Boss_think, THINK_TIME )
	Timers:CreateTimer(5,function()
		go_back_to_parent = true
	end)
end

function heal_parent()
	local parent = thisEntity.parent
	parent:SetHealth(parent:GetHealth()+thisEntity:GetHealth())
	nTFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_life_stealer/life_stealer_infest_cast.vpcf",  PATTACH_ABSORIGIN , thisEntity )
	ParticleManager:SetParticleControl(nTFX, 0, thisEntity:GetAbsOrigin())
	ParticleManager:SetParticleControl(nTFX, 1, parent:GetAbsOrigin())
	thisEntity:ForceKill(true)
	thisEntity:AddNoDraw()
end

function Boss_think()
	if thisEntity:IsAlive() then -- verify if unity is not recently dead
		if go_back_to_parent == true and thisEntity.parent~= nil and thisEntity.parent:IsNull()~=true and thisEntity.parent:IsAlive()~=false then
			thisEntity:MoveToNPC(thisEntity.parent)
			if Is_parent_Close(250) == true then
				heal_parent()
			end
		else
			local position = thisEntity:GetAbsOrigin() + Vector(RandomInt(-500,500),RandomInt(-500,500),0) + thisEntity:GetForwardVector()*300
			thisEntity:MoveToPosition(position)
		end
		if thisEntity:IsAlive() then
			return THINK_TIME
		end
	end
end



function Is_parent_Close(max_distance)
	if max_distance == nil then max_distance = 200 end
	local Vparent = thisEntity.parent:GetAbsOrigin()
	local Vself = thisEntity:GetAbsOrigin()
	local Vdiff = Vself-Vparent
	local distance = Vdiff:Length2D()
	if distance <= max_distance then
		return true
	else
		return false
	end
end
