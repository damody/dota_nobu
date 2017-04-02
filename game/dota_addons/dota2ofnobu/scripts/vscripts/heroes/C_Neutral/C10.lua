

function C10T_Init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.caster:GetAbsOrigin()
	if keys.caster.C10T_T ~= nil then
		keys.caster.C10T_T = nil
	end 
	keys.caster.C10T_T = {}

    local group = keys.caster.C10T_T
   	group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, 
   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
   	
	for i,v in ipairs(group) do
		if v:IsHero() then
			ParticleManager:CreateParticle("particles/shake3.vpcf", PATTACH_ABSORIGIN, v)
		end
		table.insert(keys.caster.C10T_T,v)
		ability:ApplyDataDrivenModifier(caster,v,"modifier_C10T",nil)
	end	
	local delay = ability:GetLevelSpecialValueFor("delay",0)
	local count = 0
	Timers:CreateTimer(0, function()
		count = count + 0.1
		-- 死了就清掉
		if (not caster:IsAlive()) then
			keys.caster.C10T_T = {}
		end
		if (count > delay) then
			return nil
		else
			return 0.1
		end
    	end)
end

function C10T_PutIn( keys )
	table.insert(keys.caster.C10T_T,keys.target)
end

function C10T_END( keys )
	local point = keys.caster:GetAbsOrigin()
	keys.caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	for i,v in ipairs(keys.caster.C10T_T) do
		if IsValidEntity(v) and (keys.caster:GetAbsOrigin() - v:GetAbsOrigin()):Length2D() < 5500 then
			if v:IsHero() then
				ParticleManager:CreateParticle("particles/shake3.vpcf", PATTACH_ABSORIGIN, v)
			end
			v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
			if not string.match(v:GetUnitName(), "com_general") then
				v:SetAbsOrigin(point)
				if not (v:HasModifier("modifier_C10T")) then
					keys.ability:ApplyDataDrivenModifier(caster,v,"modifier_C10T",{duration=3})
				end
			end
		end
	end
end

function C10T_SE( keys )
	keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,2.0)
end

function C10W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point  = keys.caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local forwardVec =(point2 - point ):Normalized()
	forwardVec = caster:GetForwardVector()

	local level = ability:GetLevel() - 1

	-- Necessary variables from KV
	local movespeed = ability:GetLevelSpecialValueFor("speed",level)
	local start_radius = ability:GetLevelSpecialValueFor("start_radius",level)
	local end_radius = ability:GetLevelSpecialValueFor("end_radius",level)
	local distance = ability:GetLevelSpecialValueFor("distance",level)
	local movespeed = ability:GetLevelSpecialValueFor("start_radius",level)

	local projectileTable =
	{
		EffectName = "particles/c10w/c10w.vpcf",
		Ability = ability,
		vSpawnOrigin = point,
		vVelocity = forwardVec * movespeed * 8,
		fDistance = distance,
		fStartRadius = start_radius,
		fEndRadius = end_radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iVisionRadius = end_radius,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	caster.powershot_projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
end


function C10R(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dmg = keys.dmg
	local per_atk = 0
	local targetArmor = target:GetPhysicalArmorValue()
	local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
	local dmg = dmg / (1 - damageReduction)
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil, 385 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

	dmg = dmg * ability:GetLevelSpecialValueFor("CleavePercent",level)
	for _, it in pairs(group) do
		if it ~= target then
			AMHC:Damage( caster,it,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end
	end
end

-- 11.2B
--------------------------------------------------------------------------------------------------------------------

--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Keeps track of all instances of the spell (since more than one can be active at once)]]
function C10W_old(keys)
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

--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Finds the next unit to jump to and deals the damage]]
function C10W_old_Jump(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_delay = ability:GetLevelSpecialValueFor("jump_delay", (ability:GetLevel() -1))
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local team = DOTA_UNIT_TARGET_TEAM_ENEMY

	-- Applies damage to the current target
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})

	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_arc_lightning_datadriven")
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
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, team, ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
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
			ability:ApplyDataDrivenModifier(caster, new_target, "modifier_arc_lightning_datadriven", {})
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

function C10T_old_break( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:IsMagicImmune() then
		AMHC:Damage(caster,target, ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	else
		AMHC:Damage(caster,target, ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 ),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
	
end

function C10T_old_on_attack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local chance = ability:GetLevelSpecialValueFor("chance",level)
	local rnd = RandomInt(1,100)
	if not keys.target:IsBuilding() then
		-- ***機率不到就什麼都不做***
		if rnd > chance then
			return 
		end

		local point  = caster:GetAbsOrigin()
		local forwardVec = caster:GetForwardVector()
		local movespeed = ability:GetLevelSpecialValueFor("speed",level)
		local radius = ability:GetLevelSpecialValueFor("radius",level)
		local distance = ability:GetLevelSpecialValueFor("distance",level)

		local projectileTable =
		{
			EffectName = "particles/c10w/c10w.vpcf",
			Ability = ability,
			vSpawnOrigin = point,
			vVelocity = forwardVec * movespeed,
			fDistance = distance,
			fStartRadius = radius,
			fEndRadius = radius,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = ability:GetAbilityTargetType(),
			iVisionRadius = radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile( projectileTable )
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,caster:GetAttackSpeed())
	end
end