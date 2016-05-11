--global
local A17R_noncrit_count = 0
local A17R_level = 0
--ednglobal

LinkLuaModifier( "A17R_critical", "scripts/vscripts/heroes/A_Oda/A17_Oda_Nobunaga.lua",LUA_MODIFIER_MOTION_NONE )




function A17W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local casterLocation = keys.target_points[1]
	local damage = ability:GetLevelSpecialValueFor( "A17W_damage", ability:GetLevel() - 1 )
	local startAttackSound = "Ability.PowershotPull"
	local startTraverseSound = "Ability.Powershot"
	local origin_pos = caster:GetAbsOrigin()
	local forwardVec = casterLocation - origin_pos
	local Distance = 2100
	forwardVec = forwardVec:Normalized()
	caster:EmitSound( "A17W.lagunablade_impact" )
	-- Stop sound event and fire new one, can do this in datadriven but for continuous purpose, let's put it here
	StopSoundEvent( startAttackSound, caster )
	StartSoundEvent( startTraverseSound, caster )
	local RADIUS = 100
	-- Create projectile
	-- Spawn projectiles
	local projectileTable = {
		Ability = ability,
		EffectName = "particles/a17w/a17w.vpcf",
		vSpawnOrigin = origin_pos,
		fDistance = 2100,
		fStartRadius = RADIUS,
		fEndRadius = RADIUS,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		bProvidesVision = false,
		iUnitTargetTeam = 0,
		iUnitTargetType = 0,
		vVelocity = forwardVec * 2000
	}
	ProjectileManager:CreateLinearProjectile( projectileTable )
	
	-- Register units around caster
	local elapsed_time = 0
	Timers:CreateTimer( 0.1, 
		function()
			elapsed_time = elapsed_time + 0.1
			local len = 2000 * elapsed_time
			local pos = origin_pos + forwardVec * len
			local enemies = FindUnitsInRadius( caster:GetTeamNumber(), pos, caster, RADIUS,
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false )
			for _,it in pairs(enemies) do
				if (not(it:IsBuilding())) then
					ApplyDamage({ victim = it, attacker = caster, damage = damage, 
						damage_type = ability:GetAbilityDamageType() , ability = ability})
				end
			end
			if (len < Distance) then
				return 0.1
			else
				return nil
			end
		end )
end





--EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE

function A17E( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local casterLocation = keys.target_points[1]
	local range = ability:GetLevelSpecialValueFor( "A17E_range", ability:GetLevel() - 1 )
	local dura = ability:GetLevelSpecialValueFor( "A17E_Duration", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor( "A17E_damage", ability:GetLevel() - 1 )
	for i=1,40 do
		local pos = casterLocation + RandomVector(RandomInt(50 , range-50))
		local spike = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_impale_hit_spikes.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(spike, 0, pos)
	end
	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), casterLocation, nil, range+50, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _,it in pairs(enemies) do
		if (not(it:IsBuilding())) then
			ApplyDamage({ victim = it, attacker = caster, damage = damage, 
				damage_type = ability:GetAbilityDamageType() , ability = ability})
			ability:ApplyDataDrivenModifier( caster, it, "modifier_A17E", {duration = dura} )
		end
	end
	local dummy = CreateUnitByName( "npc_dummy", casterLocation, false, caster, caster, caster:GetTeamNumber() )
	dummy:EmitSound( "A17E.spiked_carapace" )
	Timers:CreateTimer( 0.5, function()
					dummy:ForceKill( true )
					return nil
				end
			)
	
end



--RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR

A17R_critical = class({})

function A17R_critical:IsHidden()
	return true
end

function A17R_critical:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function A17R_critical:GetModifierPreAttack_CriticalStrike()
	return A17R_level*50 + 150
end

function A17R_critical:CheckState()
	local state = {
	}
	return state
end


function A17R_Levelup( keys )
	local caster = keys.caster
	local level = keys.ability:GetLevel()
	A17R_level = level
end

function A17R( keys )
	local caster = keys.caster
	local skill = keys.ability
	local id  = caster:GetPlayerID()
	local ran =  RandomInt(0, 100)
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > 20) then
			A17R_noncrit_count = A17R_noncrit_count + 1
		end
		if (A17R_noncrit_count > 5 or ran <= 20) then
			A17R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			caster:AddNewModifier(caster, skill, "A17R_critical", { duration = 0.1 } )
		end
	end
end

function A17T( keys )
	local caster = keys.caster
	local skill = keys.ability
	local id  = caster:GetPlayerID()
	local ran =  RandomInt(0, 100)
	local tornado = ParticleManager:CreateParticle("particles/a17t/a17t_funnel.vpcf", PATTACH_ABSORIGIN, keys.caster)
	local timecount = 0
	local small_tornado_count = 0
	Timers:CreateTimer(0, function()
		local pos = caster:GetAbsOrigin()
		ParticleManager:SetParticleControl(tornado, 3, pos)
		timecount = timecount + 0.1
		small_tornado_count = small_tornado_count + 1
		if (small_tornado_count % 4 == 0) then
			A17T2(keys)
		end
		if (timecount < 7) then
			return 0.1
		else
			ParticleManager:DestroyParticle(tornado, false)
			return nil
		end
	end)
	
end

function A17T2( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local ran =  RandomInt(0, 100)
	local tornado = ParticleManager:CreateParticle("particles/a17t/a17t2_funnel.vpcf", PATTACH_ABSORIGIN, keys.caster)
	local timecount = 0
	local movedir = RandomVector(10)
	local pos = caster:GetAbsOrigin()

	Timers:CreateTimer(0, function()
		pos = pos + movedir
		ParticleManager:SetParticleControl(tornado, 3, pos)
		local enemies = FindUnitsInRadius( caster:GetTeamNumber(), pos, nil, 150, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, 0, 0, false )
		for _,it in pairs(enemies) do
			ApplyDamage({ victim = it, attacker = caster, damage = 6, 
				damage_type = ability:GetAbilityDamageType() , ability = ability})
		end

		timecount = timecount + 0.1
		if (timecount < 7) then
			return 0.1
		else
			ParticleManager:DestroyParticle(tornado, false)
			return nil
		end
	end)
	
end

