
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = keys.target_points[1]
	local dir = caster:GetCursorPosition() - caster:GetOrigin()
	if dir:Length2D() < 1 then
		dir = caster:GetForwardVector()
	end
	caster:SetForwardVector(dir:Normalized())
	local duration = ability:GetSpecialValueFor( "duration")
	local distance = ability:GetSpecialValueFor( "distance")
	local radius =  ability:GetSpecialValueFor( "radius")
	local collision_radius = ability:GetSpecialValueFor( "collision_radius")
	local projectile_speed = ability:GetSpecialValueFor( "speed")
	local right = caster:GetRightVector()
	local dummy = CreateUnitByName("npc_dummy_unit_Ver2",caster:GetAbsOrigin() ,false,caster,caster,caster:GetTeam())
	dummy:FindAbilityByName("majia"):SetLevel(1)
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=12})
	ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_invulnerable",{duration=12})
	caster.dummy = dummy

	casterLoc = keys.target_points[1] - dir:Normalized() * 300
	
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
				
				local velocityVec = Vector( forwardVec.x, forwardVec.y, 0 )
				
				-- Spawn projectiles
				local projectileTable = {
					Ability = ability,
					EffectName = "particles/item/wind.vpcf",
					vSpawnOrigin = spawn_location,
					fDistance = distance,
					fStartRadius = collision_radius,
					fEndRadius = collision_radius,
					Source = caster,
					bHasFrontalCone = false,
					bReplaceExisting = false,
					bProvidesVision = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					iUnitTargetFlags  = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
					vVelocity = velocityVec * projectile_speed
				}
				ProjectileManager:CreateLinearProjectile( projectileTable )
			end
			-- Check if the number of machines have been reached
			if sumtime >= duration then
				return nil
			else
				sumtime = sumtime + 0.125
				return 0.125
			end
		end)
end

function storm_break( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local dmg = ability:GetSpecialValueFor( "damage")
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              target:GetAbsOrigin(),
	                              nil,
	                              ability:GetLevelSpecialValueFor( "splash_radius", ability:GetLevel() - 1 ),
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) then
			if IsValidEntity(caster) and caster:IsAlive() then
				AMHC:Damage(caster.dummy, it, dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
			else
				AMHC:Damage(caster.dummy, it, dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
				caster.takedamage = caster.takedamage + dmg
				
				if (it:IsRealHero()) then
					caster.herodamage = caster.herodamage + dmg
				end
			end
		end
	end
end

