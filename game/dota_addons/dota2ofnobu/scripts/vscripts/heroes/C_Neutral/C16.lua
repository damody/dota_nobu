-- 果心居士 by Nian Chen
-- 2017.3.24


--D
function C16D( keys )
	local target = keys.target
	if _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] == nil then
		local illusion = CreateMirror( keys )
	else
		keys.ability:EndCooldown()
	end
end

function CreateMirror( keys )
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = target:GetUnitName()
	local origin = caster:GetAbsOrigin()
	local duration = ability:GetSpecialValueFor( "duration")
	local outgoingDamage = ability:GetSpecialValueFor( "outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor( "incoming_damage")

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	--分身不能用法球
	illusion:SetOwner(caster)
	if illusion:IsHero() then
		illusion:SetPlayerID(caster:GetPlayerID())

		-- Level Up the unit to the casters level
		local casterLevel = target:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end	
		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
	end
	illusion:SetControllableByPlayer(player, true)
	
	-- Set the skill points to 0 and learn the skills of the caster
	for abilitySlot=0,15 do
		local ability = illusion:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if (illusionAbility ~= nil) then
				illusion:RemoveAbility(abilityName)
			end
		end
	end
	for abilitySlot=0,15 do
		local ability = target:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			illusion:AddAbility(abilityName):SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	illusion:MakeIllusion()
	if target:IsHero() then
		incomingDamage = ability:GetSpecialValueFor( "incoming_damage2")
	end
	illusion.illusion_damage = (100+outgoingDamage)*0.01
	illusion:AddNewModifier(target, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	illusion:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})
	illusion:SetForwardVector(target:GetForwardVector())
	illusion:SetControllableByPlayer(caster:GetPlayerID(), true)
	illusion:SetHealth(target:GetHealth())
	illusion:SetMana(target:GetMana())
	local am = target:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and IsValidEntity(v:GetAbility()) then
			if (not v:GetAbility():IsItem()) and v:GetName() ~= "modifier_exorcism" then
				v:GetAbility():ApplyDataDrivenModifier(illusion,illusion,v:GetName(),{duration=v:GetDuration()})
			end
		end
	end
	return illusion
end

function C16E( keys )
	local caster = keys.caster
    local spawnPosition = keys.unit:GetOrigin()
	local ghost = CreateUnitByName("C16E_ghost", spawnPosition, true, nil, nil , caster:GetTeamNumber())
    ghost:SetOwner(caster)
    ghost:SetControllableByPlayer(caster:GetPlayerID(), true)

    ghost:AddNewModifier(caster, nil, "modifier_phased",{duration=0.1})
    ghost:AddNewModifier(caster, nil, "modifier_invisible", nil )
    ghost:AddNewModifier(caster, nil, "modifier_magic_immune", nil )
    ghost:AddNewModifier(caster, nil, "modifier_kill",{duration=300})
    keys.ability:ApplyDataDrivenModifier( caster, ghost , "modifier_vison", nil )
    --ghost:AddNewModifier(caster, nil, "modifier_illusion", { duration = keys.ability:GetSpecialValueFor("C16E_ghostDuration") })
end

function ExorcismStart( event )
	local caster = event.caster
	local ability = event.ability
	local playerID = caster:GetPlayerID()
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local spirits = ability:GetLevelSpecialValueFor( "spirits", ability:GetLevel() - 1 )
	local delay_between_spirits = ability:GetLevelSpecialValueFor( "delay_between_spirits", ability:GetLevel() - 1 )
	local unit_name = event.DummyName

	-- Initialize the table to keep track of all spirits
	ability.spirits = {}
	print("Spawning "..spirits.." spirits")
	for i=1,spirits do
		Timers:CreateTimer(i * delay_between_spirits, function()
			if (caster:IsAlive()) then
				-- local unit = CreateUnitByName(unit_name, caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
				local unit = CreateUnitByName(unit_name, caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())

				-- The modifier takes care of the physics and logic
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_exorcism_spirit", {})
				
				-- Add the spawned unit to the table
				table.insert(ability.spirits, unit)

				-- Initialize the number of hits, to define the heal done after the ability ends
				unit.numberOfHits = 0

				-- Double check to kill the units, remove this later
				Timers:CreateTimer(duration+10, function() if unit and IsValidEntity(unit) then unit:RemoveSelf() end end)
			end
		end)
	end
	local count = 0
	Timers:CreateTimer(0.5, function()
		count = count + 0.5
		if (caster:IsAlive() and count < duration) then
			return 0.5
		else
			if (not caster:IsAlive()) then
				print("ExorcismDeath(event)")
				ExorcismDeath(event)
				ExorcismEnd(event)
			end
			return nil
		end
	end)
end

-- Movement logic for each spirit
-- Units have 4 states: 
	-- acquiring: transition after completing one target-return cycle.
	-- target_acquired: tracking an enemy or point to collide
	-- returning: After colliding with an enemy, move back to the casters location
	-- end: moving back to the caster to be destroyed and heal
function ExorcismPhysics( event )
	local caster = event.caster
	local unit = event.target
	local ability = event.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local spirit_speed = ability:GetLevelSpecialValueFor( "spirit_speed", ability:GetLevel() - 1 )
	local min_damage = ability:GetLevelSpecialValueFor( "min_damage", ability:GetLevel() - 1 )
	local max_damage = ability:GetLevelSpecialValueFor( "max_damage", ability:GetLevel() - 1 )
	local max_damage = ability:GetLevelSpecialValueFor( "max_damage", ability:GetLevel() - 1 )
	local average_damage = ability:GetLevelSpecialValueFor( "average_damage", ability:GetLevel() - 1 )
	local give_up_distance = ability:GetLevelSpecialValueFor( "give_up_distance", ability:GetLevel() - 1 )
	local max_distance = ability:GetLevelSpecialValueFor( "max_distance", ability:GetLevel() - 1 )
	local heal_percent = ability:GetLevelSpecialValueFor( "heal_percent", ability:GetLevel() - 1 ) * 0.01
	local min_time_between_attacks = ability:GetLevelSpecialValueFor( "min_time_between_attacks", ability:GetLevel() - 1 )
	local abilityDamageType = ability:GetAbilityDamageType()
	local abilityTargetType = ability:GetAbilityTargetType()
	local particleDamage = "particles/units/heroes/hero_death_prophet/death_prophet_exorcism_attack.vpcf"
	local particleDamageBuilding = "particles/units/heroes/hero_death_prophet/death_prophet_exorcism_attack_building.vpcf"
	--local particleNameHeal = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_start_sparks_b.vpcf"

	-- Make the spirit a physics unit
	Physics:Unit(unit)

	-- General properties
	unit:PreventDI(true)
	unit:SetAutoUnstuck(false)
	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	unit:FollowNavMesh(false)
	unit:SetPhysicsVelocityMax(spirit_speed)
	unit:SetPhysicsVelocity(spirit_speed * RandomVector(1))
	unit:SetPhysicsFriction(0)
	unit:Hibernate(false)
	unit:SetGroundBehavior(PHYSICS_GROUND_LOCK)

	-- Initial default state
	unit.state = "acquiring"

	-- This is to skip frames
	local frameCount = 0

	-- Store the damage done
	unit.damage_done = 0

	-- Store the interval between attacks, starting at min_time_between_attacks
	unit.last_attack_time = GameRules:GetGameTime() - min_time_between_attacks

	-- Color Debugging for points and paths. Turn it false later!
	local Debug = false
	local pathColor = Vector(255,255,255) -- White to draw path
	local targetColor = Vector(255,0,0) -- Red for enemy targets
	local idleColor = Vector(0,255,0) -- Green for moving to idling points
	local returnColor = Vector(0,0,255) -- Blue for the return
	local endColor = Vector(0,0,0) -- Back when returning to the caster to end
	local draw_duration = 3

	-- Find one target point at random which will be used for the first acquisition.
	local point = caster:GetAbsOrigin() + RandomVector(RandomInt(radius/2, radius))
	point.z = GetGroundHeight(point,nil)

	-- This is set to repeat on each frame
	unit:OnPhysicsFrame(function(unit)

		-- Move the unit orientation to adjust the particle
		unit:SetForwardVector( ( unit:GetPhysicsVelocity() ):Normalized() )

		-- Current positions
		local source = caster:GetAbsOrigin()
		local current_position = unit:GetAbsOrigin()

		-- Print the path on Debug mode
		if Debug then DebugDrawCircle(current_position, pathColor, 0, 2, true, draw_duration) end

		local enemies = nil

		-- Use this if skipping frames is needed (--if frameCount == 0 then..)
		frameCount = (frameCount + 1) % 3
		if frameCount == 0 then
			-- Movement and Collision detection are state independent

			-- MOVEMENT	
			-- Get the direction
			local diff = point - unit:GetAbsOrigin()
	        diff.z = 0
	        local direction = diff:Normalized()

			-- Calculate the angle difference
			local angle_difference = RotationDelta(VectorToAngles(unit:GetPhysicsVelocity():Normalized()), VectorToAngles(direction)).y
			
			-- Set the new velocity
			if math.abs(angle_difference) < 5 then
				-- CLAMP
				local newVel = unit:GetPhysicsVelocity():Length() * direction * 2
				unit:SetPhysicsVelocity(newVel)
			elseif angle_difference > 0 then
				local newVel = RotatePosition(Vector(0,0,0), QAngle(0,10,0), unit:GetPhysicsVelocity())
				unit:SetPhysicsVelocity(newVel)
			else		
				local newVel = RotatePosition(Vector(0,0,0), QAngle(0,-10,0), unit:GetPhysicsVelocity())
				unit:SetPhysicsVelocity(newVel)
			end

			-- COLLISION CHECK
			local distance = (point - current_position):Length()
			local collision = distance < 300

			-- MAX DISTANCE CHECK
			local distance_to_caster = (source - current_position):Length()
			if distance > max_distance then 
				unit:SetAbsOrigin(source)
				unit.state = "acquiring" 
			end

			-- STATE DEPENDENT LOGIC
			-- Damage, Healing and Targeting are state dependent.
			-- Update the point in all frames

			-- Acquiring...
			-- Acquiring -> Target Acquired (enemy or idle point)
			-- Target Acquired... if collision -> Acquiring or Return
			-- Return... if collision -> Acquiring

			-- Acquiring finds new targets and changes state to target_acquired with a current_target if it finds enemies or nil and a random point if there are no enemies
			if unit.state == "acquiring" then

				-- This is to prevent attacking the same target very fast
				local time_between_last_attack = GameRules:GetGameTime() - unit.last_attack_time
				--print("Time Between Last Attack: "..time_between_last_attack)

				-- If enough time has passed since the last attack, attempt to acquire an enemy
				if time_between_last_attack >= min_time_between_attacks then
					-- If the unit doesn't have a target locked, find enemies near the caster
					enemies = FindUnitsInRadius(caster:GetTeamNumber(), source, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
												  abilityTargetType, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

					-- Check the possible enemies
					-- Focus the last attacked target if there's any
					local last_targeted = ability.last_targeted
					local target_enemy = nil
					local focus_attack = RandomInt(1,100)
					for _,enemy in pairs(enemies) do
						-- If the caster has a last_targeted and this is in range of the ghost acquisition, set to attack it
						if last_targeted and enemy == last_targeted then
							target_enemy = enemy
						end
					end

					-- Else if we don't have a target_enemy from the last_targeted, get one at random
					if not target_enemy or focus_attack > 50 then
						target_enemy = enemies[RandomInt(1, #enemies)]
					end
					
					-- Keep track of it, set the state to target_acquired
					if target_enemy then
						unit.state = "target_acquired"
						unit.current_target = target_enemy
						point = unit.current_target:GetAbsOrigin()

					-- If no enemies, set the unit to collide with a random idle point.
					else
						unit.state = "target_acquired"
						unit.current_target = nil
						unit.idling = true
						point = source + RandomVector(RandomInt(radius/2, radius))
						point.z = GetGroundHeight(point,nil)
						
						--print("Acquiring -> Random Point Target acquired")
						if Debug then DebugDrawCircle(point, idleColor, 100, 25, true, draw_duration) end
					end

				-- not enough time since the last attack, get a random point
				else
					unit.state = "target_acquired"
					unit.current_target = nil
					unit.idling = true
					point = source + RandomVector(RandomInt(radius/2, radius))
					point.z = GetGroundHeight(point,nil)
					
					if Debug then DebugDrawCircle(point, idleColor, 100, 25, true, draw_duration) end
				end

			-- If the state was to follow a target enemy, it means the unit can perform an attack. 		
			elseif unit.state == "target_acquired" then

				-- Update the point of the target's current position
				if unit.current_target and IsValidEntity(unit.current_target) then
					IsValidEntity(handle_1)
					point = unit.current_target:GetAbsOrigin()
					if Debug then DebugDrawCircle(point, targetColor, 100, 25, true, draw_duration) end
				end

				-- Give up on the target if the distance goes over the give_up_distance
				if distance_to_caster > give_up_distance then
					unit.state = "acquiring"
					--print("Gave up on the target, acquiring a new target.")

				end

				-- Do physical damage here, and increase hit counter. 
				if collision then

					-- If the target was an enemy and not a point, the unit collided with it
					if unit.current_target ~= nil then
						
						-- Damage, units will still try to collide with attack immune targets but the damage wont be applied
						if IsValidEntity(unit) and IsValidEntity(unit.current_target) and not unit.current_target:IsAttackImmune() then
							local damage_table = {}

							local spirit_damage = RandomInt(min_damage,max_damage)
							damage_table.victim = unit.current_target
							damage_table.attacker = caster					
							damage_table.damage_type = abilityDamageType
							damage_table.damage = spirit_damage

							ApplyDamage(damage_table)

							-- Calculate how much physical damage was dealt
							local targetArmor = unit.current_target:GetPhysicalArmorValue()
							local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
							local damagePostReduction = spirit_damage * (1 - damageReduction)

							unit.damage_done = unit.damage_done + damagePostReduction

							-- Damage particle, different for buildings
							if unit.current_target.InvulCount == 0 then
								local particle = ParticleManager:CreateParticle(particleDamageBuilding, PATTACH_ABSORIGIN, unit.current_target)
								ParticleManager:SetParticleControl(particle, 0, unit.current_target:GetAbsOrigin())
								ParticleManager:SetParticleControlEnt(particle, 1, unit.current_target, PATTACH_POINT_FOLLOW, "attach_hitloc", unit.current_target:GetAbsOrigin(), true)
							elseif unit.damage_done > 0 then
								local particle = ParticleManager:CreateParticle(particleDamage, PATTACH_ABSORIGIN, unit.current_target)
								ParticleManager:SetParticleControl(particle, 0, unit.current_target:GetAbsOrigin())
								ParticleManager:SetParticleControlEnt(particle, 1, unit.current_target, PATTACH_POINT_FOLLOW, "attach_hitloc", unit.current_target:GetAbsOrigin(), true)
							end

							-- Increase the numberOfHits for this unit
							unit.numberOfHits = unit.numberOfHits + 1 

							-- Fire Sound on the target unit
							unit.current_target:EmitSound("Hero_DeathProphet.Exorcism.Damage")
							
							-- Set to return
							unit.state = "returning"
							point = source
							--print("Returning to caster after dealing ",unit.damage_done)

							-- Update the attack time of the unit.
							unit.last_attack_time = GameRules:GetGameTime()
							--unit.enemy_collision = true

						end

					-- In other case, its a point, reacquire target or return to the caster (50/50)
					else
						if RollPercentage(50) then
							unit.state = "acquiring"
							--print("Attempting to acquire a new target")
						else
							unit.state = "returning"
							point = source
							--print("Returning to caster after idling")
						end
					end
				end

			-- If it was a collision on a return (meaning it reached the caster), change to acquiring so it finds a new target
			elseif unit.state == "returning" then
				
				-- Update the point to the caster's current position
				point = source
				if Debug then DebugDrawCircle(point, returnColor, 100, 25, true, draw_duration) end

				if collision then 
					unit.state = "acquiring"
					local heal_done =  unit.numberOfHits * average_damage* heal_percent
					caster:Heal(heal_done, ability)
					caster:EmitSound("Hero_DeathProphet.Exorcism.Heal")
					unit.numberOfHits = 0
				end	

			-- if set the state to end, the point is also the caster position, but the units will be removed on collision
			elseif unit.state == "end" then
				point = source
				if Debug then DebugDrawCircle(point, endColor, 100, 25, true, 2) end

				-- Last collision ends the unit
				if collision then 

					-- Heal is calculated as: a percentage of the units average attack damage multiplied by the amount of attacks the spirit did.
					-- local heal_done =  unit.numberOfHits * average_damage* heal_percent
					-- caster:Heal(heal_done, ability)
					-- caster:EmitSound("Hero_DeathProphet.Exorcism.Heal")
					--print("Healed ",heal_done)

					unit:SetPhysicsVelocity(Vector(0,0,0))
		        	unit:OnPhysicsFrame(nil)
		        	unit:Destroy()
		        end
		    end
		end
    end)
end

-- Change the state to end when the modifier is removed
function ExorcismEnd( event )
	local caster = event.caster
	local ability = event.ability
	local targets = ability.spirits

	caster:StopSound("Hero_DeathProphet.Exorcism")
	for _,unit in pairs(targets) do		
	   	if unit and IsValidEntity(unit) then
    	  	unit.state = "end"
    	end
	end

	-- Reset the last_targeted
	ability.last_targeted = nil
end

-- Updates the last_targeted enemy, to focus the ghosts on it.
function ExorcismAttack( event )
	local ability = event.ability
	local target = event.target

	ability.last_targeted = target
	--print("LAST TARGET: "..target:GetUnitName())
end

-- Kill all units when the owner dies or the spell is cast while the first one is still going
function ExorcismDeath( event )
	local caster = event.caster
	local ability = event.ability
	local targets = ability.spirits or {}

	caster:StopSound("Hero_DeathProphet.Exorcism")
	for _,unit in pairs(targets) do		
	   	if unit and IsValidEntity(unit) then
    	  	unit:SetPhysicsVelocity(Vector(0,0,0))
	        unit:OnPhysicsFrame(nil)

			-- Kill
	        -- unit:ForceKill(false)
	        unit:Destroy()
    	end
	end
end

function C16T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local stunDuration = ability:GetSpecialValueFor("C16T_stun")
	local target = keys.target_entities
	for _,v in pairs(target) do
		ability:ApplyDataDrivenModifier( caster, v , "modifier_stunned", { duration = stunDuration } )
	end

	local count = ability:GetSpecialValueFor("C16T_count")
	for i=1,count do
		local stone = CreateUnitByName("C16T_stone", point + RandomVector(RandomInt(200,600)), true, nil, nil , caster:GetTeamNumber())
		stone:SetOwner(caster)
	    stone:SetControllableByPlayer(caster:GetPlayerID(), true)
	    stone:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})
	    stone:AddNewModifier(caster,nil,"modifier_magic_immune", nil )
	    ability:ApplyDataDrivenModifier( caster, stone, "modifier_C16T_attackDamage", nil )

	    Timers:CreateTimer(15, function ()
			if not stone:IsNull() then
				stone:ForceKill( true )
			end
		end)
	end
end

function C16T_onAttackLanded( keys )
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability

	local dmgt = {
				victim = target,
				attacker = attacker,
				ability = ability,
				damage = ability:GetSpecialValueFor("C16T_damage") ,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}
	ApplyDamage(dmgt)
end

function C16D_old( keys )
	local unit = keys.unit
	if not unit:IsIllusion() then
		local ghost = CreateUnitByName("C16D_old_ghost", unit:GetOrigin(), true, nil, nil , unit:GetTeamNumber())
		ghost:SetOwner(unit)
	    ghost:SetControllableByPlayer(keys.unit:GetPlayerID(), true)
	    ghost:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})
	end
end

function C16W_old( keys )
	local target = keys.target
	if _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] == nil then
		local illusion = CreateMirror( keys )
	else
		keys.ability:EndCooldown()
	end
end

function C16E_old( keys )
	local caster = keys.caster
    local spawnPosition = keys.unit:GetOrigin()
	local ghost = CreateUnitByName("C16E_ghost", spawnPosition, true, nil, nil , caster:GetTeamNumber())
    ghost:SetOwner(caster)
    ghost:SetControllableByPlayer(caster:GetPlayerID(), true)

    ghost:AddNewModifier(caster, nil, "modifier_phased",{duration=0.1})
    ghost:AddNewModifier(caster, nil, "modifier_invisible", nil )
    ghost:AddNewModifier(caster, nil, "modifier_magic_immune", nil )
    ghost:AddNewModifier(caster, nil, "modifier_kill",{duration=300})
    --ghost:AddNewModifier(caster, nil, "modifier_illusion", { duration = keys.ability:GetSpecialValueFor("C16E_ghostDuration") })
    keys.ability:ApplyDataDrivenModifier( caster, ghost , "modifier_C16E_old_passiveAura", nil )
    keys.ability:ApplyDataDrivenModifier( caster, ghost , "modifier_vison", nil )
end

function C16T_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local stunDuration = ability:GetSpecialValueFor("C16T_stun")
	local duration = ability:GetSpecialValueFor("C16T_duration")

	local count = ability:GetSpecialValueFor("C16T_count")
	for i=1,count do
		local stone = CreateUnitByName("C16T_stone", point + RandomVector(RandomInt(200,600)), true, nil, nil , caster:GetTeamNumber())
		local units = FindUnitsInRadius(caster:GetTeamNumber(), stone:GetOrigin(), nil, 275, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
		for _,unit in ipairs(units) do
			ability:ApplyDataDrivenModifier( caster, unit , "modifier_stunned", { duration = stunDuration } )
		end
		stone:SetOwner(caster)
	    stone:SetControllableByPlayer(caster:GetPlayerID(), true)
	    stone:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})
	    stone:AddNewModifier(caster,nil,"modifier_magic_immune", nil )
	    stone:AddNewModifier(caster,nil,"modifier_rooted", nil )
	    ability:ApplyDataDrivenModifier( caster, stone, "modifier_C16T_attackDamage", nil )

	    Timers:CreateTimer( duration, function ()
			if not stone:IsNull() then
				stone:ForceKill( true )
			end
		end)
	end
end

function C16T_upgrade( keys )
	keys.caster:FindAbilityByName("C16D"):SetLevel(keys.ability:GetLevel()+1)
end
