-- 平手政秀 by Nian Chen
-- 2017.5.10

function A10D_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	local distance = ability:GetSpecialValueFor("max_range")
	local duration = ability:GetSpecialValueFor("duration")

	if (point - caster:GetAbsOrigin()):Length() > distance then
		point = (point - caster:GetAbsOrigin()):Normalized() * distance + caster:GetAbsOrigin()
	end

	local particle = ParticleManager:CreateParticle( "particles/econ/events/ti6/blink_dagger_start_ti6_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( particle , 0 , origin )
	FindClearSpaceForUnit( caster , point , true )
	ability:ApplyDataDrivenModifier( caster , caster , "modifier_A10D_timer" , { duration = duration } )
	caster:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.01 } )
	ParticleManager:CreateParticle( "particles/econ/events/ti6/blink_dagger_end_ti6_lvl2.vpcf", PATTACH_ABSORIGIN, caster )

	caster.A10D_timer = Timers:CreateTimer( duration , function()
		local particle2 = ParticleManager:CreateParticle( "particles/econ/events/ti6/blink_dagger_start_ti6_lvl2.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( particle2 , 0 , caster:GetAbsOrigin() )
		FindClearSpaceForUnit( caster , origin , true )
		caster:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.01 } )
		ParticleManager:CreateParticle( "particles/econ/events/ti6/blink_dagger_end_ti6_lvl2.vpcf", PATTACH_ABSORIGIN, caster )
		EmitSoundOn( "Hero_QueenOfPain.Blink_in" , caster )
		caster.A10D_timer = nil
	end)
end

function modifier_A10D_timer_OnDeath( keys )
	local caster = keys.caster
	if caster.A10D_timer then
		Timers:RemoveTimer(caster.A10D_timer)
		caster.A10D_timer = nil
	end
end

LinkLuaModifier( "modifier_A10W_stop", "heroes/A_Oda/A10.lua",LUA_MODIFIER_MOTION_NONE )
modifier_A10W_stop = class({})

function modifier_A10W_stop:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
	return funcs
end

function modifier_A10W_stop:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

function modifier_A10W_stop:GetOverrideAnimationRate()
	return 0
end

function modifier_A10W_stop:IsHidden() 
	return true
end

function modifier_A10W_stop:IsPurgable()
	return false
end

function A10W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	local damage = ability:GetSpecialValueFor("damage")
	local heal = ability:GetSpecialValueFor("heal")
	ability:ApplyDataDrivenModifier( caster , target , "modifier_A10W_stop" , { duration = duration } )
	ability:ApplyDataDrivenModifier( caster , target , "modifier_stunned" , { duration = duration+0.1 } )
	ability:ApplyDataDrivenModifier( caster , target , "modifier_A10W" , { duration = duration } )

	EmitSoundOn( "Hero_Rubick.Telekinesis.Target" , target )

	caster.A10W_timer = Timers:CreateTimer( duration + 0.05 , function()
		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			ApplyDamage({
				victim = target,
				attacker = caster,
				ability = ability,
				damage = damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			})
		else
			target:Heal( heal , ability )
		end
		caster.A10W_timer = nil
	end)
end

function modifier_A10W_OnCreated( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = 1,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
end

function modifier_A10W_OnDestroy( keys )
	local caster = keys.caster
	Timers:CreateTimer( 0.2 , function()
		if caster.A10W_timer then
			Timers:RemoveTimer(caster.A10W_timer)
			caster.A10W_timer = nil
		end
	end)
end

function A10E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = ability:GetCursorPosition()
	local forwardVec = (targetLoc - casterLoc):Normalized()
	if forwardVec:Length() < 1 then
		forwardVec = caster:GetForwardVector()
	end
	A10E_FireProjectile( casterLoc, forwardVec, caster, ability )
end

function A10E_FireProjectile( vOrigin, vForwardVector, hCaster, hSourceAbility )
	local caster = hCaster
	local ability = caster:FindAbilityByName("A10E")
	local distance = ability:GetSpecialValueFor("distance")
	local radius = ability:GetSpecialValueFor("radius")
	local collision_radius = ability:GetSpecialValueFor("collision_radius")
	local projectile_speed = ability:GetSpecialValueFor("speed")
	local mount_persec = ability:GetSpecialValueFor("mount_persec")
	local duration = ability:GetSpecialValueFor("duration")
	local forwardVec = vForwardVector
	local backwardVec = Vector( -forwardVec.x, -forwardVec.y, forwardVec.z )
	local rightVec = Vector( forwardVec.y, -forwardVec.x, -forwardVec.z )
	
	-- Find middle point of the spawning line
	local middlePoint = vOrigin + ( radius * 2 * backwardVec )
	StartSoundEventFromPosition( "Hero_Slark.ShadowDance" , vOrigin )
	if hSourceAbility:GetAbilityName() == "A10E" then
		-- Create timer to spawn projectile
		for i=1,duration do
			for j=1,mount_persec do
				Timers:CreateTimer( (i-1) + RandomFloat( 0.0, 1.0 ) , function()
					local random_distance = RandomInt( -radius, radius )
					local spawn_location = middlePoint + rightVec * random_distance
					-- Spawn projectiles
					local projectileTable = {
						Ability = hSourceAbility,
						EffectName = "particles/a10e/a10e.vpcf",
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
						iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE,
						vVelocity = forwardVec * projectile_speed
					}
					ProjectileManager:CreateLinearProjectile( projectileTable )
				end)
			end
		end
	else
		for i=1,duration do
			for j=1,mount_persec do
				Timers:CreateTimer( (i-1) + RandomFloat( 0.0, 1.0 ) , function()
					local random_distance = RandomInt( -radius, radius )
					local spawn_location = middlePoint + rightVec * random_distance
					-- Spawn projectiles
					local projectileTable = {
						Ability = hSourceAbility,
						EffectName = "particles/a10e/a10e_2.vpcf",
						vSpawnOrigin = spawn_location,
						fDistance = distance,
						fStartRadius = collision_radius * 2/3,
						fEndRadius = collision_radius * 2/3,
						Source = caster,
						bHasFrontalCone = false,
						bReplaceExisting = false,
						bProvidesVision = false,
						iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
						iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
						iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE,
						vVelocity = forwardVec * projectile_speed
					}
					ProjectileManager:CreateLinearProjectile( projectileTable )
				end)
			end
		end
	end
end

function A10E_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local A10E = caster:FindAbilityByName("A10E")
	local target = keys.target
	local splash_radius = A10E:GetSpecialValueFor("splash_radius")
	local damageMultiplier = 1
	if ability:GetAbilityName() ~= "A10E" then
		damageMultiplier = 0.666
	end
	local ifx = ParticleManager:CreateParticle( "particles/a10e/a10e_hitalliance_explosion.vpcf", PATTACH_ABSORIGIN, target )
	local direUnits = FindUnitsInRadius( caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
										 DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _,unit in pairs(direUnits) do
		if unit:IsMagicImmune() then
			AMHC:Damage( caster, unit, A10E:GetSpecialValueFor("damage") * 0.5 * damageMultiplier , AMHC:DamageType("DAMAGE_TYPE_PURE"))
		else
			AMHC:Damage( caster, unit, A10E:GetSpecialValueFor("damage") * damageMultiplier, AMHC:DamageType("DAMAGE_TYPE_PURE"))
		end
	end
end

function modifier_A10E_passive_OnAbilityExecuted( keys )
	local caster = keys.caster
	local ability = keys.event_ability
	local abilityName = ability:GetAbilityName()
	if abilityName == "A10W" then
		local point = keys.target:GetAbsOrigin()
		local forwardVec = Vector( 0.707107 , 0.707107 )
		A10E_FireProjectile( point, forwardVec, caster, ability )
	elseif abilityName == "A10R" then
		local point = keys.target:GetAbsOrigin()
		local forwardVec = ( caster:GetAbsOrigin() - point ):Normalized()
		if forwardVec:Length() < 1 then
			forwardVec = caster:GetForwardVector()
			forwardVec = Vector( -forwardVec.x, -forwardVec.y, forwardVec.z )
		end
		A10E_FireProjectile( point, forwardVec, caster, ability )
	elseif abilityName == "A10T" then
		local point = ability:GetCursorPosition()
		local forwardVec = ( caster:GetAbsOrigin() - point ):Normalized()
		if forwardVec:Length() < 1 then
			forwardVec = caster:GetForwardVector()
			forwardVec = Vector( -forwardVec.x, -forwardVec.y, forwardVec.z )
		end
		A10E_FireProjectile( point, forwardVec, caster, ability )
	elseif abilityName == "A10D" then
		local point = ability:GetCursorPosition()
		local distance = ability:GetSpecialValueFor("max_range")
		if (point - caster:GetAbsOrigin()):Length() > distance then
			point = (point - caster:GetAbsOrigin()):Normalized() * distance + caster:GetAbsOrigin()
		end
		local forwardVec = ( caster:GetAbsOrigin() - point ):Normalized()
		if forwardVec:Length() < 1 then
			forwardVec = caster:GetForwardVector()
			forwardVec = Vector( -forwardVec.x, -forwardVec.y, forwardVec.z )
		end
		A10E_FireProjectile( point, forwardVec, caster, ability )
	end
end

function A10R_OnAbilityPhaseStart( keys )
	local caster = keys.caster
	local target = keys.target
	if _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] or target == caster then
		caster:Interrupt()
	end
end
function A10W_old_OnAbilityPhaseStart( keys )
	local caster = keys.caster
	local target = keys.target
	if _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] or target == caster then
		caster:Interrupt()
	end
end
function A10R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	ability:ApplyDataDrivenModifier( caster , target , "modifier_A10R" , { duration = 0.1 } )

	caster.A10R_timer = Timers:CreateTimer( 0.05 , function()
		local target_pos = target:GetAbsOrigin()
		local caster_pos = caster:GetAbsOrigin()
		FindClearSpaceForUnit( caster , target_pos , true )
		FindClearSpaceForUnit( target , caster_pos , true )
		caster:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.01 } )
		target:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.01 } )
		EmitSoundOn( "Hero_WarlockGolem.PreAttack" , caster )
		EmitSoundOn( "Hero_WarlockGolem.PreAttack" , target )
		caster.A10R_timer = nil
	end)
end

function modifier_A10R_OnCreated( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
end

function modifier_A10R_OnDestroy( keys )
	local caster = keys.caster
	if caster.A10R_timer then
		Timers:RemoveTimer(caster.A10R_timer)
		caster.A10R_timer = nil
	end
end

function A10T_OnUpgrade( keys )
	local caster = keys.caster
	local ability = keys.ability
	local A10D = caster:FindAbilityByName("A10D")
	A10D:SetLevel( ability:GetLevel() + 1 )
end

function A10T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	caster.A10T_dummy = CreateUnitByName( "npc_dummy_unit" , point , false , caster , caster , caster:GetTeamNumber() )
	caster.A10T_dummy:SetOwner( caster )
	caster.A10T_dummy:AddAbility( "majia" ):SetLevel( 1 )
	ability:ApplyDataDrivenModifier( caster , caster.A10T_dummy , "modifier_A10T_Aura" , nil )
	EmitSoundOn( "Hero_ElderTitan.EarthSplitter.Cast" , caster.A10T_dummy )

	caster.A10T_particleTimer = Timers:CreateTimer( function()
		if caster:IsChanneling() then
			AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 300, 1, false)
    		AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 300, 1, false)
			local random_int = RandomInt( 10 , 15 )
			for i=1,random_int do
				Timers:CreateTimer( RandomFloat( 0 , 0.4 ) , function()
					local particle = ParticleManager:CreateParticle( "particles/a10t/a10t.vpcf", PATTACH_CUSTOMORIGIN, nil )
					ParticleManager:SetParticleControl( particle , 0 , point + RandomVector( RandomInt( radius/10 , 9*radius/10 ) ) )
				end)
			end
			return 0.5
		else
			caster.A10T_particleTimer = nil
			return nil
		end
	end)
	
	caster.A10T_soundTimer = Timers:CreateTimer( function()
		if caster:IsChanneling() then
			EmitSoundOn( "Hero_ElderTitan.EarthSplitter.Cast" , caster.A10T_dummy )
			return 1
		else
			caster.A10T_soundTimer = nil
			return nil
		end
	end)
end

function A10T_OnChannelFinish( keys )
	local caster = keys.caster
	if caster.A10T_dummy then
		local A10T_Aura = caster.A10T_dummy:FindModifierByName("modifier_A10T_Aura")
		if A10T_Aura then
			A10T_Aura:Destroy()
		end
		caster.A10T_dummy:ForceKill( false )
		caster.A10T_dummy = nil
	end
	if caster.A10T_soundTimer then
		Timers:RemoveTimer(caster.A10T_soundTimer)
		caster.A10T_soundTimer = nil
	end
	if caster.A10T_particleTimer then
		Timers:RemoveTimer(caster.A10T_particleTimer)
		caster.A10T_particleTimer = nil
	end
end

function modifier_A10T_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")
	if target:IsBuilding() then
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
end

function A10W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local stunDuration = ability:GetSpecialValueFor("stun_duration")
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then 
		target:AddNewModifier( caster , ability , "modifier_stunned" , { duration = stunDuration } )
	end
	ability:ApplyDataDrivenModifier( caster , target , "modifier_A10W_old" , { duration = 0.1 } )

	caster.A10W_old_timer = Timers:CreateTimer( 0.05 , function()
		local target_pos = target:GetAbsOrigin()
		local caster_pos = caster:GetAbsOrigin()
		FindClearSpaceForUnit( caster , target_pos , true )
		FindClearSpaceForUnit( target , caster_pos , true )
		caster:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.01 } )
		target:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.01 } )
		EmitSoundOn( "Hero_WarlockGolem.PreAttack" , caster )
		EmitSoundOn( "Hero_WarlockGolem.PreAttack" , target )
		caster.A10W_old_timer = nil
	end)
end

function modifier_A10W_old_OnCreated( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
end

function modifier_A10W_old_OnDestroy( keys )
	local caster = keys.caster
	if caster.A10W_old_timer then
		Timers:RemoveTimer(caster.A10W_old_timer)
		caster.A10W_old_timer = nil
	end
end

function A10E_old_OnSpellStart( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local distance = ability:GetSpecialValueFor("distance")
	local radius = ability:GetSpecialValueFor("radius")
	local collision_radius = ability:GetSpecialValueFor("collision_radius")
	local projectile_speed = ability:GetSpecialValueFor("speed")
	local mount_persec = ability:GetSpecialValueFor("mount_persec")
	local duration = ability:GetSpecialValueFor("duration")
	local pertime = ability:GetSpecialValueFor("pertime_mount")
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = ability:GetCursorPosition()
	local forwardVec = (targetLoc - casterLoc):Normalized()
	if forwardVec:Length() < 1 then
		forwardVec = caster:GetForwardVector()
	end
	local backwardVec = Vector( -forwardVec.x, -forwardVec.y, forwardVec.z )
	local rightVec = Vector( forwardVec.y, -forwardVec.x, -forwardVec.z )
	
	-- Find middle point of the spawning line
	local middlePoint = casterLoc + ( radius * 2 * backwardVec )
	EmitSoundOn( "Hero_ElderTitan.EarthSplitter.Projectile" , caster )
	-- Create timer to spawn projectile
	caster.A10E_old_Timer = Timers:CreateTimer( function()
		-- Get random location for projectile
		local random_distance = RandomInt( -radius, radius )
		local spawn_location = middlePoint + rightVec * random_distance
		--local spawn_location = Vector( spawn_location2.x, spawn_location2.y, 0)
		local velocityVec = Vector( forwardVec.x, forwardVec.y, 0)
		-- Spawn projectiles
		local random_projectile = math.random(1,5)
		if random_projectile == 1 then
			random_projectile = "particles/a10e_old/a10e_old.vpcf"
		elseif random_projectile == 2 then
			random_projectile = "particles/a10e_old/a10e_old_2.vpcf"
		elseif random_projectile == 3 then
			random_projectile = "particles/a10e_old/a10e_old_3.vpcf"
		elseif random_projectile == 4 then
			random_projectile = "particles/a10e_old/a10e_old_4.vpcf"
		elseif random_projectile == 5 then
			random_projectile = "particles/a10e_old/a10e_old_5.vpcf"
		end
		local projectileTable = {
			Ability = ability,
			EffectName = random_projectile,
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
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			vVelocity = velocityVec * projectile_speed
		}
		ProjectileManager:CreateLinearProjectile( projectileTable )

		-- Check if the number of machines have been reached
		if caster:IsChanneling() then
			return 1/pertime
		else
			return nil
		end
	end)
end

function A10E_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local splash_radius = ability:GetSpecialValueFor("splash_radius")
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, splash_radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _,it in pairs(direUnits) do
		if it:IsMagicImmune() then
			--AMHC:Damage(caster,it, ability:GetSpecialValueFor("damage")*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			AMHC:Damage(caster,it, ability:GetSpecialValueFor("damage"),AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		else
			AMHC:Damage(caster,it, ability:GetSpecialValueFor("damage"),AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end
	end
end

function A10E_old_OnChannelFinish( keys )
	local caster = keys.caster
	if caster.A10E_old_Timer then
		Timers:RemoveTimer(caster.A10E_old_Timer)
		caster.A10E_old_Timer = nil
	end
end

function modifier_A10R_old_passive_OnDeath( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius2")
	local duration = ability:GetSpecialValueFor("duration")
	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
										 DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										 FIND_ANY_ORDER, false)
	for _,unit in pairs(units) do
		ability:ApplyDataDrivenModifier( caster , unit , "modifier_A10R_old" , { duration = duration } )
	end
end

function modifier_A10R_old_passive_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
										 DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
										 FIND_ANY_ORDER, false)
	for _,unit in pairs(units) do
		ability:ApplyDataDrivenModifier( caster , unit , "modifier_A10R_old" , { duration = duration } )
	end
end

function modifier_A10R_old_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damage")
	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
	})
end

function A10T_old_OnAbilityPhaseStart( keys )
	local caster = keys.caster
	local target = keys.target
	if _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] or target == caster then
		caster:Interrupt()
	end
end

function A10T_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local particle = ParticleManager:CreateParticle( "particles/econ/events/ti5/blink_dagger_start_lvl2_ti5.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( particle , 0 , target:GetAbsOrigin() )
	FindClearSpaceForUnit( target , caster:GetAbsOrigin() , false )
	target:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.01 } )
	ParticleManager:CreateParticle( "particles/econ/events/ti5/blink_dagger_end_lvl2_ti5.vpcf", PATTACH_ABSORIGIN, target )
end
