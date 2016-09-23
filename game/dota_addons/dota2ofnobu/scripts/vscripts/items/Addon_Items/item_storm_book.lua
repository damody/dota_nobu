
function Shock( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = keys.target_points[1]
	local dir = caster:GetCursorPosition() - caster:GetOrigin()
	caster:SetForwardVector(dir:Normalized())
	
	local distance = 1000
	local radius =  600
	local collision_radius = ability:GetLevelSpecialValueFor( "collision_radius", ability:GetLevel() - 1 )
	local projectile_speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
	local right = caster:GetRightVector()
	caster:AddSpeechBubble(1,"今天的風兒有點囂張~",3.0,0,-50)

	--casterLoc = keys.target_points[1] - right:Normalized() * 300
	
	-- Find forward vector
	local forwardVec = targetLoc - casterLoc
	forwardVec = forwardVec:Normalized()
	
	-- Find backward vector
	local backwardVec = casterLoc - targetLoc
	backwardVec = backwardVec:Normalized()
	
	-- Find middle point of the spawning line
	local middlePoint = casterLoc + ( radius * backwardVec )
	
	-- Find perpendicular vector
	local v = middlePoint - casterLoc
	local dx = -v.y
	local dy = v.x
	local perpendicularVec = Vector( dx, dy, v.z )
	perpendicularVec = perpendicularVec:Normalized()

	local sumtime = 0
	-- Create timer to spawn projectile
	Timers:CreateTimer( function()
			-- Get random location for projectile
			for c = 1,4 do
				local random_distance = RandomInt( -radius, radius )
				local spawn_location = middlePoint + perpendicularVec * random_distance
				
				local velocityVec = Vector( forwardVec.x, forwardVec.y, 0 ):Normalized()*1500
				
				local sumtime = 0
				local flame = ParticleManager:CreateParticle("particles/item/tornado_a.vpcf", PATTACH_ABSORIGIN, caster)
				local step = 0.01
				Timers:CreateTimer(step, function ()
					sumtime = sumtime + step
					local point = spawn_location+velocityVec*sumtime
					ParticleManager:SetParticleControl(flame, 0, point)
					local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
			          point,
			          nil,
			          150,
			          DOTA_UNIT_TARGET_TEAM_ENEMY,
			          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			          0,
			          0,
			          false)
					local isend = false
					for _,target in pairs(direUnits) do
						if not target:IsBuilding() then
							AMHC:Damage(caster,target,66,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
							isend = true
						end
					end
					if (sumtime < 1.2 and not isend) then
						return step
					else
						ParticleManager:DestroyParticle(flame, false)
						return nil
					end
				end)
			end
			-- Check if the number of machines have been reached
			if sumtime >= 10 then
				return nil
			else
				sumtime = sumtime + 0.25
				return 0.25
			end
		end)
end


