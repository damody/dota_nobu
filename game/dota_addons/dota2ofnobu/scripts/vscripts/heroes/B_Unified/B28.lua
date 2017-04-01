-- 松永久秀 by Nian Chen
-- 2017.4.1

function B28E( keys )
	local caster = keys.caster
	local target = keys.target
	caster.B28E_target = target

	local particle3 = ParticleManager:CreateParticle("particles/b28e/b28e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle3, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle3, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	caster.B28E_P = particle
	Timers:CreateTimer(0.2, function ()
      	if target ~= nil and IsValidEntity(target) and target:HasModifier("modifier_B28E") then
      		local particle2 = ParticleManager:CreateParticle("particles/b28e/b28e.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(particle2, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
      		return 0.2
      	else
      		caster.B28E_target = nil
      		ParticleManager:DestroyParticle(particle2,false)
      		return nil
      	end
    end)
end

function B28R( keys )
	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetSpecialValueFor("B28R_radius")

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for i,v in ipairs(units) do
		if caster:CanEntityBeSeenByMyTeam(v) then
			local projTable = {
		        EffectName = "particles/b28r/b28r.vpcf",
		        Ability = ability,
		        vSpawnOrigin = caster:GetAbsOrigin(),
		        Target = v,
		        Source = caster,
		        bDodgeable = false,
		        iMoveSpeed = 1300,
		        iVisionRadius = 225,
				iVisionTeamNumber = caster:GetTeamNumber(),
		        iUnitTargetTeam = ability:GetAbilityTargetTeam(),
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		        iUnitTargetType = ability:GetAbilityDamageType(),
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			 }
			ProjectileManager:CreateTrackingProjectile( projTable )
			break
		end
	end
	
end

function B28T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("B28T_radius")
	local finishTime = ability:GetSpecialValueFor("B28T_finishTime")
	local damage = ability:GetSpecialValueFor("B28T_startDamage")
	local damageIncrease = ability:GetSpecialValueFor("B28T_damageIncrease")
	local point = keys.target_points[1]

	local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	local count = 0
	Timers:CreateTimer(0,function()
		count = count + 1
		if count > #units then
			return nil
		end
		local unit = units[count]
		local particle = ParticleManager:CreateParticle("particles/b28t/b28t.vpcf", PATTACH_CUSTOMORIGIN, caster)
		if count == 1 then
			ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		else
			ParticleManager:SetParticleControlEnt(particle, 2, units[count-1], PATTACH_POINT_FOLLOW, "attach_hitloc", units[count-1]:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		end
		local particle2 = ParticleManager:CreateParticle("particles/b28t/b28t_2ti_5.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(particle2, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)

		ApplyDamage({	
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		damage = damage * ( 1 + damageIncrease )
		if ( finishTime/ #units ) > 0.2 then
			return 0.2
		else
			return ( finishTime/ #units )
		end
	end)
end