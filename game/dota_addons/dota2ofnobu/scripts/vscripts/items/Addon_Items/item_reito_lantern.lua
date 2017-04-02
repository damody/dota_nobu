
--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Finds the next unit to jump to and deals the damage]]
function reito_lantern_Jump(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_delay = ability:GetLevelSpecialValueFor("jump_delay", (ability:GetLevel() -1))
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local team = DOTA_UNIT_TARGET_TEAM_ENEMY
	if (caster:GetTeamNumber() == target:GetTeamNumber()) then
		team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	end
	
	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_arc_reito_lantern")
	local count = 0
	-- Waits on the jump delay
	local pos = target:GetAbsOrigin()
	Timers:CreateTimer(jump_delay,
	function()
	-- Finds the current instance of the ability by ensuring both current targets are the same
	local current
	for i=0,ability.instance do
		if ability.target[i] ~= nil then
			if ability.target[i] == target then
				current = i
			end
		end
	end
	if IsValidEntity(target) then
		pos = target:GetAbsOrigin()
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
		-- Finds units in the radius to jump to
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, team, ability:GetAbilityTargetType(), 
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		
		local closest = radius
		local new_target
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
			-- Creates the particle between the new target and the last target
			local lightningBolt = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
			ParticleManager:SetParticleControl(lightningBolt,0,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
			ParticleManager:SetParticleControl(lightningBolt,1,Vector(new_target:GetAbsOrigin().x,new_target:GetAbsOrigin().y,new_target:GetAbsOrigin().z + new_target:GetBoundingMaxs().z ))
			-- Sets the new target as the current target for this instance
			ability.target[current] = new_target
			-- Applies the modifer to the new target, which runs this function on it
			ability:ApplyDataDrivenModifier(caster, new_target, "modifier_arc_reito_lantern", {})
		else
			-- If there are no new targets, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
		end
	else
		-- If there are no more jumps, we set the current target to nil to indicate this instance is over
		ability.target[current] = nil
	end
	end)
	-- Applies damage to the current target
	if (team == DOTA_UNIT_TARGET_TEAM_ENEMY) then
		ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
	else
		target:Heal(ability:GetAbilityDamage(), caster)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Keeps track of all instances of the spell (since more than one can be active at once)]]
function reito_lantern(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
	else
		ability.instance = ability.instance + 1
	end

	local angel = caster:GetAngles().y
	local point = Vector(caster:GetAbsOrigin().x+75*math.cos(angel*bj_DEGTORAD) ,  caster:GetAbsOrigin().y+75*math.sin(angel*bj_DEGTORAD), caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z)
	
	-- Sets the total number of jumps for this instance (to be decremented later)
	ability.jump_count[ability.instance] = ability:GetLevelSpecialValueFor("jump_count", (ability:GetLevel() -1))
	-- Sets the first target as the current target for this instance
	ability.target[ability.instance] = target
	
	-- Creates the particle between the caster and the first target
	local lightningBolt = ParticleManager:CreateParticle(keys.particle, PATTACH_POINT, caster)
	-- ParticleManager:SetParticleControlEnt(lightningBolt, 0, caster, PATTACH_POINT, "attach_attack", Vector(0,0,0), true)
	-- ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z )) 
    ParticleManager:SetParticleControl(lightningBolt,0,point)   
    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
end

