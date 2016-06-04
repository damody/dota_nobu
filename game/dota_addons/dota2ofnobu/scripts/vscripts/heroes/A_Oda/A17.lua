function A17R( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel()
	local dmg = keys.dmg
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_A17R",nil)
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
	end
end



function A17W( keys )
	-- variables
	local ability = keys.ability	
	local caster = keys.caster
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local radius = ability:GetLevelSpecialValueFor("radius",level)
	local charge = ability:GetLevelSpecialValueFor("charge",level)
	local dmg_duration = ability:GetLevelSpecialValueFor("dmg_duration",level)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration",level)
	local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
	local launch_sound_name = "Hero_Sniper.ShrapnelShoot"	
	local forwardVec =(point2 - point ):Normalized()
	local temp_point = nil

	local dummy = CreateUnitByName("Dummy_Ver1",point ,false,nil,nil,caster:GetTeam())	
	dummy:FindAbilityByName("majia"):SetLevel(1)
	local dummy_ability = dummy:AddAbility("sniper_shrapnel")
	dummy_ability:SetLevel(level + 1)	
	Timers:start(2,function()
		dummy:ForceKill(true);print("@@@")
		end)
    local order_type = DOTA_UNIT_ORDER_CAST_POSITION
    local abilityIndex = dummy_ability:GetEntityIndex()
    local unitIndex = dummy:GetEntityIndex()
    local queue = true
    ExecuteOrderFromTable({ UnitIndex = unitIndex, OrderType = order_type, Position = point2, AbilityIndex = abilityIndex, Queue = queue})


	Timers:start(dmg_duration,function()

	end)



end

-- function A17W( keys )
-- 	-- variables
-- 	local ability = keys.ability	
-- 	local caster = keys.caster
-- 	local point = caster:GetAbsOrigin()
-- 	local point2 = ability:GetCursorPosition()
-- 	local level = ability:GetLevel() - 1
-- 	local radius = ability:GetLevelSpecialValueFor("radius",level)
-- 	local charge = ability:GetLevelSpecialValueFor("charge",level)
-- 	local dmg_duration = ability:GetLevelSpecialValueFor("dmg_duration",level)
-- 	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration",level)
-- 	local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
-- 	local launch_sound_name = "Hero_Sniper.ShrapnelShoot"	
-- 	local forwardVec =(point2 - point ):Normalized()
-- 	local temp_point = nil

-- 	-- Create particle at caster
-- 	local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
-- 	ParticleManager:SetParticleControl( fxLaunchIndex, 0, point )
-- 	ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( point.x, point.y, 800 ) )
-- 	StartSoundEvent( launch_sound_name, caster )


-- 	fxLaunchIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf", PATTACH_POINT, caster )
-- 	ParticleManager:SetParticleControl( fxLaunchIndex, 0, point2 )
-- 	ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( 1, 1, 1 ) )
-- 	ParticleManager:SetParticleControl( fxLaunchIndex, 2, point2 )
-- 	ParticleManager:SetParticleControlForward(fxLaunchIndex,2,forwardVec)

-- 	for i=-10,10 do
-- 		print(i)
-- 		local r_int = RandomInt(20,50)
-- 		temp_point = point2 + Vector(r_int,r_int) * i
-- 		fxLaunchIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf", PATTACH_POINT, caster )
-- 		ParticleManager:SetParticleControl( fxLaunchIndex, 0, temp_point )
-- 		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( 1, 1, 1 ) )
-- 		ParticleManager:SetParticleControl( fxLaunchIndex, 2, temp_point )
-- 		ParticleManager:SetParticleControlForward(fxLaunchIndex,2,forwardVec)
-- 	end
-- end



-- function shrapnel_fire( keys )
-- 	-- Reduce stack if more than 0 else refund mana
-- 		-- variables
-- 		local caster = keys.caster
-- 		local target = keys.target_points[1]
-- 		local ability = keys.ability
-- 		local casterLoc = caster:GetAbsOrigin()
-- 		local modifierName = "modifier_shrapnel_stack_counter_datadriven"
-- 		local dummyModifierName = "modifier_shrapnel_dummy_datadriven"
-- 		local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
-- 		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
-- 		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
-- 		local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
-- 		local damage_delay = ability:GetLevelSpecialValueFor( "damage_delay", ( ability:GetLevel() - 1 ) ) + 0.1
-- 		local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
-- 		local launch_sound_name = "Hero_Sniper.ShrapnelShoot"
		
-- 		-- Deplete charge
-- 		local next_charge = caster.shrapnel_charges - 1
-- 		if caster.shrapnel_charges == maximum_charges then
-- 			caster:RemoveModifierByName( modifierName )
-- 			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
-- 			shrapnel_start_cooldown( caster, charge_replenish_time )
-- 		end
-- 		caster:SetModifierStackCount( modifierName, caster, next_charge )
-- 		caster.shrapnel_charges = next_charge
		
-- 		-- Check if stack is 0, display ability cooldown
-- 		if caster.shrapnel_charges == 0 then
-- 			-- Start Cooldown from caster.shrapnel_cooldown
-- 			ability:StartCooldown( caster.shrapnel_cooldown )
-- 		else
-- 			ability:EndCooldown()
-- 		end
		
-- 		-- Create particle at caster
-- 		local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
-- 		ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
-- 		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )
-- 		StartSoundEvent( launch_sound_name, caster )
		
-- 		-- Deal damage
-- 		shrapnel_damage( caster, ability, target, damage_delay, dummyModifierName, dummy_duration )
-- end





-- function shrapnel_start_charge( keys )
-- 	-- Only start charging at level 1
-- 	if keys.ability:GetLevel() ~= 1 then return end

-- 	-- Variables
-- 	local caster = keys.caster
-- 	local ability = keys.ability
-- 	local modifierName = "modifier_shrapnel_stack_counter_datadriven"
-- 	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
-- 	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
-- 	-- Initialize stack
-- 	caster:SetModifierStackCount( modifierName, caster, 0 )
-- 	caster.shrapnel_charges = maximum_charges
-- 	caster.start_charge = false
-- 	caster.shrapnel_cooldown = 0.0
	
-- 	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
-- 	caster:SetModifierStackCount( modifierName, caster, maximum_charges )
	
-- 	-- create timer to restore stack
-- 	Timers:CreateTimer( function()
-- 			-- Restore charge
-- 			if caster.start_charge and caster.shrapnel_charges < maximum_charges then
-- 				-- Calculate stacks
-- 				local next_charge = caster.shrapnel_charges + 1
-- 				caster:RemoveModifierByName( modifierName )
-- 				if next_charge ~= 3 then
-- 					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
-- 					shrapnel_start_cooldown( caster, charge_replenish_time )
-- 				else
-- 					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
-- 					caster.start_charge = false
-- 				end
-- 				caster:SetModifierStackCount( modifierName, caster, next_charge )
				
-- 				-- Update stack
-- 				caster.shrapnel_charges = next_charge
-- 			end
			
-- 			-- Check if max is reached then check every 0.5 seconds if the charge is used
-- 			if caster.shrapnel_charges ~= maximum_charges then
-- 				caster.start_charge = true
-- 				return charge_replenish_time
-- 			else
-- 				return 0.5
-- 			end
-- 		end
-- 	)
-- end

-- --[[
-- 	Author: kritth
-- 	Date: 6.1.2015.
-- 	Helper: Create timer to track cooldown
-- ]]
-- function shrapnel_start_cooldown( caster, charge_replenish_time )
-- 	caster.shrapnel_cooldown = charge_replenish_time
-- 	Timers:CreateTimer( function()
-- 			local current_cooldown = caster.shrapnel_cooldown - 0.1
-- 			if current_cooldown > 0.1 then
-- 				caster.shrapnel_cooldown = current_cooldown
-- 				return 0.1
-- 			else
-- 				return nil
-- 			end
-- 		end
-- 	)
-- end

-- --[[
-- 	Author: kritth
-- 	Date: 6.1.2015.
-- 	Main: Check/Reduce charge, spawn dummy and cast the actual ability
-- ]]
-- function shrapnel_fire( keys )
-- 	-- Reduce stack if more than 0 else refund mana
-- 		-- variables
-- 		local caster = keys.caster
-- 		local target = keys.target_points[1]
-- 		local ability = keys.ability
-- 		local casterLoc = caster:GetAbsOrigin()
-- 		local modifierName = "modifier_shrapnel_stack_counter_datadriven"
-- 		local dummyModifierName = "modifier_shrapnel_dummy_datadriven"
-- 		local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
-- 		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
-- 		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
-- 		local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
-- 		local damage_delay = ability:GetLevelSpecialValueFor( "damage_delay", ( ability:GetLevel() - 1 ) ) + 0.1
-- 		local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
-- 		local launch_sound_name = "Hero_Sniper.ShrapnelShoot"
		
-- 		-- Deplete charge
-- 		local next_charge = caster.shrapnel_charges - 1
-- 		if caster.shrapnel_charges == maximum_charges then
-- 			caster:RemoveModifierByName( modifierName )
-- 			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
-- 			shrapnel_start_cooldown( caster, charge_replenish_time )
-- 		end
-- 		caster:SetModifierStackCount( modifierName, caster, next_charge )
-- 		caster.shrapnel_charges = next_charge
		
-- 		-- Check if stack is 0, display ability cooldown
-- 		if caster.shrapnel_charges == 0 then
-- 			-- Start Cooldown from caster.shrapnel_cooldown
-- 			ability:StartCooldown( caster.shrapnel_cooldown )
-- 		else
-- 			ability:EndCooldown()
-- 		end
		
-- 		-- Create particle at caster
-- 		local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
-- 		ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
-- 		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )
-- 		StartSoundEvent( launch_sound_name, caster )
		
-- 		-- Deal damage
-- 		shrapnel_damage( caster, ability, target, damage_delay, dummyModifierName, dummy_duration )
-- end

-- --[[
-- 	Author: kritth
-- 	Date: 6.1.2015.
-- 	Main: Create dummy to apply damage
-- ]]
-- function shrapnel_damage( caster, ability, target, damage_delay, dummyModifierName, dummy_duration )
-- 	Timers:CreateTimer( damage_delay, function()
-- 			-- create dummy to do damage and apply debuff modifier
-- 			local dummy = CreateUnitByName( "Dummy_Ver1", target, false, caster, caster, caster:GetTeamNumber() )
-- 			ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
-- 			Timers:CreateTimer( dummy_duration, function()
-- 					dummy:ForceKill( true )
-- 					return nil
-- 				end
-- 			)
-- 			return nil
-- 		end
-- 	)
-- end
