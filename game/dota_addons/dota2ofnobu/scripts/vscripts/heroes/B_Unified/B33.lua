	bj_PI                            = 3.14159
	bj_RADTODEG                      = 180.0/bj_PI
	bj_DEGTORAD                      = bj_PI/180.0
--ednglobal


--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Fires the projectile if the targets line up]]
function B33R(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("range_damage", ability:GetLevel() - 1)
	
	-- Notes the origin of the first target to be the center of the findunits radius
	local first_target_origin = target:GetAbsOrigin()
	-- Notes the damage the first target takes to apply to the other targets
	ability.first_target_damage = keys.damage
		
	-- Gets the caster's origin difference from the target
	-- local caster_origin_difference = caster:GetAbsOrigin() - first_target_origin 

	-- Get the radian of the origin difference between the attacker and TA. We use this to figure out at what angle the victim is at relative to the TA.
	-- local caster_origin_difference_radian = math.atan2(caster_origin_difference.y, caster_origin_difference.x)
	
	-- -- Convert the radian to degrees.
	-- caster_origin_difference_radian = caster_origin_difference_radian * 180
	-- local attacker_angle = caster_origin_difference_radian / math.pi
	-- -- Turns negative angles into positive ones and make the math simpler.
	-- attacker_angle = attacker_angle + 180.0
	
	local radius = ability:GetLevelSpecialValueFor("attack_spill_range", ability:GetLevel() - 1)
	--local attack_spill_width = ability:GetLevelSpecialValueFor("attack_spill_width", ability:GetLevel() - 1)/2
	
	-- Units in radius
	local units = FindUnitsInRadius(caster:GetTeamNumber(), first_target_origin, nil, radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	
	-- Calculates the position of each found unit in relation to the last target
	for i,unit in ipairs(units) do
		if unit ~= target then
			-- local target_origin_difference = target:GetAbsOrigin() - unit:GetAbsOrigin()
			
			-- -- Get the radian of the origin difference between the last target and the unit. We use this to figure out at what angle the unit is at relative to the the target.
			-- local target_origin_difference_radian = math.atan2(target_origin_difference.y, target_origin_difference.x)
	
			-- -- Convert the radian to degrees.
			-- target_origin_difference_radian = target_origin_difference_radian * 180
			-- local victim_angle = target_origin_difference_radian / math.pi
			-- -- Turns negative angles into positive ones and make the math simpler.
			-- victim_angle = victim_angle + 180.0
	
			-- -- The difference between the world angle of the caster-target vector and the target-unit vector
			-- local angle_difference = math.abs(victim_angle - attacker_angle)			
			
			-- local new_target = false
			
			-- -- Ensures the angle difference is less than the allowed width
			-- if angle_difference <= attack_spill_width then
				local info = {
				Target = unit,
				Source = target,
				Ability = ability,
				EffectName = keys.particle,
				bDodgeable = true,
				iMoveSpeed = 9000,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				}
				ProjectileManager:CreateTrackingProjectile( info )
				AMHC:Damage( caster,unit,damage,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			-- new_target = true
			-- end
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: April 8, 2016
	Deals damage to the secondary targets]]
function DealDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("range_damage", ability:GetLevel() - 1)

	-- Applies the damage to the attack target
	ApplyDamage({victim = target, attacker = caster, damage , damage_type = ability:GetAbilityDamageType()})
end

function B33T( keys )
	local caster = keys.caster
	local target = keys.target
	local point = caster:GetAbsOrigin()
	local team  = caster:GetTeamNumber()
	local dummy = CreateUnitByName("B33T_UNIT",caster:GetAbsOrigin(),true,nil,nil,team)
	local time = 0.1
	local num = 0
	--dummy:AddAbility("majia"):SetLevel(1)
	dummy:SetForwardVector(caster:GetForwardVector())
	EmitSoundOn("broodmother_broo_immort_01",keys.caster)
	dummy:EmitSound("broodmother_broo_win_01")
	Physics:Unit(dummy)
	keys.ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_tofly",nil)
	Timers:CreateTimer(0.1, function()
			if IsValidEntity(target) and not target:HasModifier("modifier_spawn_spiderlings_datadriven") then
				dummy:SetPhysicsVelocity((target:GetAbsOrigin() - dummy:GetAbsOrigin())*3)
				return 0.1
			end
		end)

	-- local particle=ParticleManager:CreateParticle("particles/c19e/c19e.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin())
	--EmitSoundOn( "Ability.Torrent", dummy )
 
	-- local particle=ParticleManager:CreateParticle("particles/b33t4/b33t4.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0,Vector(500,0,0))
	-- ParticleManager:SetParticleControl(particle,3,Vector(0,0,0))
	local particle=ParticleManager:CreateParticle("particles/b33t5/b33t5_u.vpcf",PATTACH_WORLDORIGIN,caster)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,1,Vector(5,0,0))
	ParticleManager:SetParticleControl(particle,3,Vector(0,0,0))
	ParticleManager:ReleaseParticleIndex(particle)
	-- Timers:CreateTimer(0.1, function()
	-- 	ParticleManager:DestroyParticle(particle, false)
	-- end)
	local particle=ParticleManager:CreateParticle("particles/b33t6/b33t6.vpcf",PATTACH_WORLDORIGIN,caster)
	ParticleManager:SetParticleControl(particle,0,point)
	local isstart = false
    Timers:CreateTimer(time, function()
    	if num > 10 then
			dummy:RemoveModifierByName("modifier_tofly")
    		dummy:SetPhysicsVelocity(Vector(0, 0, -1000))
    		Timers:CreateTimer(0.5, function()
    			dummy:ForceKill( true )
    			end)
    		if target:HasModifier("modifier_spawn_spiderlings_datadriven") then
    			target:RemoveModifierByName("modifier_spawn_spiderlings_datadriven")
    		end
    		return nil
    	else
    		num = num + time
		end
    	if not IsValidEntity(target) or  not target:IsAlive() then
    		dummy:RemoveModifierByName("modifier_tofly")
    		dummy:SetPhysicsVelocity(Vector(0, 0, -1000))
    		Timers:CreateTimer(0.5, function()
    			dummy:ForceKill( true )
    			end)
    		if target:HasModifier("modifier_spawn_spiderlings_datadriven") then
    			target:RemoveModifierByName("modifier_spawn_spiderlings_datadriven")
    		end
    		return nil
    	elseif (isstart and not target:HasModifier("modifier_spawn_spiderlings_datadriven")) then
    		keys.ability:ApplyDataDrivenModifier(caster, target,"modifier_spawn_spiderlings_datadriven",nil)
    		return time
    	else
	    	if isstart then
	    		dummy:SetAbsOrigin(target:GetAbsOrigin())
	    		ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP, Queue = false})
	    		dummy:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,1.0)
	    		dummy:SetForwardVector(target:GetForwardVector())

	    	else
	    		dummy:StartGestureWithPlaybackRate(ACT_DOTA_RUN,2.5)
	    		if CalcDistanceBetweenEntityOBB(dummy,target) < 50 then
	    			ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP, Queue = false})
	    			isstart = true
	    			keys.ability:ApplyDataDrivenModifier(caster, target,"modifier_spawn_spiderlings_datadriven",nil)
	    		end

				ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = target:GetAbsOrigin(), Queue = false}) 
	    	end

    		return time
    	end

    end)
end

function B33R_Levelup( keys )
	keys.caster:ModifyAgility( 5 )
	keys.caster:CalculateStatBonus()
end

-- 11.2B
------------------------------------------------------------

function B33R_old_on_attck_landed( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local poison_duration = ability:GetLevelSpecialValueFor("poison_duration",ability:GetLevel()-1)
	local poison_damage_delay = ability:GetLevelSpecialValueFor("poison_damage_delay",ability:GetLevel()-1)

	local hideUnit = CreateUnitByName("npc_dummy_unit_new",target:GetAbsOrigin(),false,caster,caster,caster:GetTeam())
	hideUnit:AddNewModifier(hideUnit,nil,"modifier_kill",{duration=poison_duration})
	ability:ApplyDataDrivenModifier(hideUnit,hideUnit,"modifier_B33R_old_poision_aura",{})
	hideUnit:AddNewModifier(hideUnit,nil,"modifier_invulnerable",{duration=poison_duration})

	local poison_radius = ability:GetSpecialValueFor("poison_radius")
	local group = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, poison_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	
	for _,unit in ipairs(group) do
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_B33R_old_debuff",{duration=3})
		if target:IsMagicImmune() then
			AMHC:Damage(caster, unit, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		else
			AMHC:Damage(caster, unit, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end
end

function B33R_old_OnIntervalThink( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local poison_radius = ability:GetSpecialValueFor("poison_radius")
	local group = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, poison_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	
	for _,unit in ipairs(group) do
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_B33R_old_debuff",{duration=3})
	end
end

function B33R_old_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local handle = target:FindModifierByName("modifier_B33R_old_debuff")
	if handle then
		local c = handle:GetStackCount()
		if target:IsMagicImmune() then
			AMHC:Damage(caster, target, ability:GetAbilityDamage()*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		else
			AMHC:Damage(caster, target, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end
end
