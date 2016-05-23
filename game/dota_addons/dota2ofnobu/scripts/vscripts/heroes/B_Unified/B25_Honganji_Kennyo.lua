--[[
	Author: kritth
	Date: 10.01.2015.
	Burn mana and damage enemies with the same amount
]]

--<<global>>
	B25T_UNIT={}
--<<endglobal>>

function mana_burn_function( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local current_mana = target:GetMana()
	local burn_amount = keys.ability:GetLevelSpecialValueFor( "burn_amount", keys.ability:GetLevel() - 1 )
	local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
	local burn_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"
	local damageType = keys.ability:GetAbilityDamageType()
	
	-- Calculation
	local mana_to_burn = math.min( current_mana,  burn_amount)
	local life_time = 2.0
	local digits = string.len( math.floor( mana_to_burn ) ) + 1
	
	-- Fail check
	if target:IsMagicImmune() then
		mana_to_burn = 0
	end
	
	-- Apply effect of ability
	target:ReduceMana( mana_to_burn )
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = mana_to_burn,
		damage_type = damageType
	}
	ApplyDamage( damageTable )
	
	-- Show VFX
	if mana_to_burn ~= 0 then
		local numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
		ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
	    ParticleManager:SetParticleControl( numberIndex, 2, Vector( life_time, digits, 0 ) )
		local burnIndex = ParticleManager:CreateParticle( burn_particle_name, PATTACH_ABSORIGIN, target )
		
		-- Create timer to properly destroy particles
		Timers:CreateTimer( life_time, function()
				ParticleManager:DestroyParticle( numberIndex, false )
				ParticleManager:DestroyParticle( burnIndex, false)
				return nil
			end
		)
	end
end



function heat_seeking_missile_seek_targets( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local particleName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf"
	-- local modifierDudName = "modifier_heat_seeking_missile_dud"
	local projectileSpeed = 900
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local max_targets = ability:GetLevelSpecialValueFor( "targets", ability:GetLevel() - 1 )
	local targetTeam = ability:GetAbilityTargetTeam()
	local targetType = ability:GetAbilityTargetType()
	local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
	local projectileDodgable = false
	local projectileProvidesVision = false
	
	-- pick up x nearest target heroes and create tracking projectile targeting the number of targets
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam, targetType, targetFlag, FIND_CLOSEST, false
	)
	
	-- Seek out target
	local count = 0
	for k, v in pairs( units ) do
		if count < max_targets then
			local projTable = {
				Target = v,
				Source = caster,
				Ability = ability,
				EffectName = particleName,
				bDodgeable = projectileDodgable,
				bProvidesVision = projectileProvidesVision,
				iMoveSpeed = projectileSpeed, 
				vSpawnOrigin = caster:GetAbsOrigin()
			}
			ProjectileManager:CreateTrackingProjectile( projTable )
			count = count + 1
		else
			break
		end
	end
	
	-- If no unit is found, fire dud
	-- if count == 0 then
	-- 	ability:ApplyDataDrivenModifier( caster, caster, modifierDudName, {} )
	-- end
end

function B25T_start( keys )
	local ability = keys.ability
	local caster = keys.caster
	local id 	= caster:GetPlayerID()
	-- local current_instance = 0
	local dummyModifierName = "modifier_bane_fiends_grip"
	-- local dummyModifierName = "modifier_enigma_midnight_pulse_thinker"
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local interval = ability:GetLevelSpecialValueFor( "damage_interval", ability:GetLevel() - 1 )
	local dummyMaximum = ability:GetLevelSpecialValueFor( "dummy_maximum", ability:GetLevel() - 1 )
	-- local max_instances = math.floor( duration / interval )
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local target = keys.target_points[1]
	local damagePerSec = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_HERO
	local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
	local damageType = ability:GetAbilityDamageType() -- DAMAGE_TYPE_MAGICAL
	-- local soundTarget = "Hero_SkywrathMage.MysticFlare.Target"
	
	-- Create for VFX particles on ground
	-- local dummy = CreateUnitByName( "B25T_dummy", target, false, caster, caster, caster:GetTeamNumber() )
	-- B25T_UNIT[id] = dummy

	-- -- Get random point
	local directionConstraint = 0
	local dummyCount = 0
	Timers:CreateTimer(interval, function()
			if dummyCount < dummyMaximum then
				directionConstraint = (directionConstraint + 1) % 4
				dummyCount = dummyCount + 1
				local castDistance = RandomInt( 0, radius )
				local angle = RandomInt( 0, 90 )
				local dy = castDistance * math.sin( angle )
				local dx = castDistance * math.cos( angle )
				local attackPoint = Vector( 0, 0, 0 )
				
				if directionConstraint == 0 then			-- NW
					attackPoint = Vector( target.x - dx, target.y + dy, target.z )
				elseif directionConstraint == 1 then		-- NE
					attackPoint = Vector( target.x + dx, target.y + dy, target.z )
				elseif directionConstraint == 2 then		-- SE
					attackPoint = Vector( target.x + dx, target.y - dy, target.z )
				else										-- SW
					attackPoint = Vector( target.x - dx, target.y - dy, target.z )
				end

				local dummy = CreateUnitByName( "B25T_dummy", attackPoint, false, caster, caster, caster:GetTeamNumber() )
				local DummyAbility=dummy:AddAbility("majia")
				DummyAbility:SetLevel(1)
				ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
				Timers:CreateTimer( 0.5, function()
					dummy:ForceKill( true )
					dummyCount = dummyCount - 1
				end )
			end

			local units = FindUnitsInRadius(
				caster:GetTeamNumber(), target, caster, radius, targetTeam,
				targetType, targetFlag, FIND_ANY_ORDER, false
			)
			if #units > 0 then
				for k, v in pairs( units ) do
					-- Apply damage
					local damageTable = {
						victim = v,
						attacker = caster,
						damage = damagePerSec * interval,
						damage_type = damageType
					}
					ApplyDamage( damageTable )
				end
			end
			
			-- Check if maximum instances reached
			if caster:IsChanneling() == false then
				return nil
			else
				return interval
			end
		end)

	-- ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {radius = 700} )
	
	-- -- Referencing total damage done per interval
	-- local damage_per_interval = total_damage / max_instances
	
	-- -- Deal damage per interval equally
	-- Timers:CreateTimer( function()
	-- 		local units = FindUnitsInRadius(
	-- 			caster:GetTeamNumber(), target, caster, radius, targetTeam,
	-- 			targetType, targetFlag, FIND_ANY_ORDER, false
	-- 		)
	-- 		if #units > 0 then
	-- 			local damage_per_hero = damage_per_interval / #units
	-- 			for k, v in pairs( units ) do
	-- 				-- Apply damage
	-- 				local damageTable = {
	-- 					victim = v,
	-- 					attacker = caster,
	-- 					damage = damage_per_hero,
	-- 					damage_type = damageType
	-- 				}
	-- 				ApplyDamage( damageTable )
					
	-- 				-- Fire sound
	-- 				StartSoundEvent( soundTarget, v )
	-- 			end
	-- 		end
			
	-- 		current_instance = current_instance + 1
			
	-- 		-- Check if maximum instances reached
	-- 		if current_instance >= max_instances then
	-- 			dummy:Destroy()
	-- 			return nil
	-- 		else
	-- 			return interval
	-- 		end
	-- 	end
	-- )
end


function B25T_stop( keys )
		--如果停止施法就殺掉單位
	local caster = keys.caster
	local id 	= caster:GetPlayerID() --獲取玩家ID
end

function B25_add_hand( )
end