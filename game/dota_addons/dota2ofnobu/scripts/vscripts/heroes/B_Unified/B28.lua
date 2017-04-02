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
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", (ability:GetLevel() -1))
	local point = keys.target_points[1]

	local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	local count = 0
	for i,unit in ipairs(units) do
		count = count + 1
		B28T_old_jump_init(keys, caster:GetAbsOrigin(), unit, count)
		ApplyDamage({victim = unit, attacker = caster, damage = base_damage, damage_type = ability:GetAbilityDamageType()})
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_B28T_arc_lightning_datadriven",{})
	end
end

function B28T_old_jump_init(keys, start_pos, target, count)
	local caster = keys.caster
	local ability = keys.ability
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
		ability.first_target = {}
	else
		ability.instance = ability.instance + 1
	end
	print("ability.instance", ability.instance)

	ability.jump_count[ability.instance] = ability:GetLevelSpecialValueFor("jump_max", (ability:GetLevel() -1))
	ability.target[ability.instance] = target
	ability.first_target[ability.instance] = target

	
	-- Creates the particle between the caster and the first target
	local lightningBolt = ParticleManager:CreateParticle("particles/b28t/b28t.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(lightningBolt,1,start_pos)
	ParticleManager:SetParticleControlEnt(lightningBolt,2,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetOrigin(),true)
end

function B28T_old_Jump(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_delay = ability:GetLevelSpecialValueFor("jump_delay", (ability:GetLevel() -1))
	local jump_radius = ability:GetLevelSpecialValueFor("jump_radius", (ability:GetLevel() -1))
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", (ability:GetLevel() -1))
	local bonus_damage = ability:GetLevelSpecialValueFor("bonus_damage", (ability:GetLevel() -1))
	local jump_max = ability:GetLevelSpecialValueFor("jump_max", (ability:GetLevel() -1))
	local team = ability:GetAbilityTargetTeam()

	-- Removes the hidden modifier
	--target:RemoveModifierByName("modifier_B28T_arc_lightning_datadriven")
	local count = 0
	-- Waits on the jump delay
	local pos = target:GetAbsOrigin()
	Timers:CreateTimer(jump_delay,
	function()
	-- Finds the current instance of the ability by ensuring both current targets are the same
	local current
	for i=0,ability.instance do
		if IsValidEntity(ability.target[i]) then
			if ability.target[i] == target then
				current = i
			end
		end
	end
	if IsValidEntity(target) then
		pos = target:GetAbsOrigin()
		-- Adds a global array to the target, so we can check later if it has already been hit in this instance
		if target.hit == nil then
			target.hit = {}
		end
		-- Sets it to true for this instance
		target.hit[current] = true
	end
	-- Decrements our jump count for this instance
	ability.jump_count[current] = ability.jump_count[current] - 1

	-- Checks if there are jumps left
	if ability.jump_count[current] > 0 then
		-- Finds units in the jump_radius to jump to
		local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, jump_radius, team, ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		local closest = jump_radius
		local new_target
		print("current", current)
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = pos - unit_location
			local distance = (vector_distance):Length2D()
			-- Checks if the unit is closer than the closest checked so far
			if distance < closest then
				-- If the unit has not been hit yet, we set its distance as the new closest distance and it as the new target
				if unit.hit == nil then
					new_target = unit
					closest = distance
				elseif unit.hit[current] == nil then
					new_target = unit
					closest = distance
				end
			end
		end
		-- Checks if there is a new target
		if new_target ~= nil then
			AddFOWViewer(caster:GetTeamNumber(),new_target:GetAbsOrigin(),300,2.0,false)
			-- Creates the particle between the new target and the last target
			local lightningBolt = ParticleManager:CreateParticle("particles/b28t/b28t.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(lightningBolt,1,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetOrigin(),true)
			ParticleManager:SetParticleControlEnt(lightningBolt,2,new_target,PATTACH_POINT_FOLLOW,"attach_hitloc",new_target:GetOrigin(),true)
			-- Sets the new target as the current target for this instance
			ability.target[current] = new_target
			-- Applies the modifer to the new target, which runs this function on it
			ability:ApplyDataDrivenModifier(caster, new_target, "modifier_B28T_arc_lightning_datadriven", {})
			-- Applies damage to the target
			local new_damage = base_damage*(1+(jump_max-ability.jump_count[current])*bonus_damage)
			ApplyDamage({victim = new_target, attacker = caster, damage = new_damage, damage_type = ability:GetAbilityDamageType()})
		else
			-- If there are no new targets, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
		end
	else
		-- If there are no more jumps, we set the current target to nil to indicate this instance is over
		ability.target[current] = nil
	end
	end)
end


