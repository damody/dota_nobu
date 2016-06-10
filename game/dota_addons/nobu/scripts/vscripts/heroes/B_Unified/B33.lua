	bj_PI                            = 3.14159
	bj_RADTODEG                      = 180.0/bj_PI
	bj_DEGTORAD                      = bj_PI/180.0
--ednglobal


--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Fires the projectile if the targets line up]]
function CheckAngles(keys)
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
	local units = FindUnitsInRadius(caster:GetTeamNumber(), first_target_origin, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
	
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
				bDodgeable = false,
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
	local b = false
	local num = 0
	--dummy:AddAbility("majia"):SetLevel(1)
	dummy:SetForwardVector(caster:GetForwardVector())
	EmitSoundOn("broodmother_broo_immort_01",keys.caster)
	dummy:EmitSound("broodmother_broo_win_01") 

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

    Timers:CreateTimer(time, function()

    	if not target:IsAlive() or num == 120 then
    		dummy:ForceKill( true )
    		if target:HasModifier("modifier_spawn_spiderlings_datadriven") then
    			target:RemoveModifierByName("modifier_spawn_spiderlings_datadriven")
    		end
    		print("Stop")
    		return nil
    	else
	    	if b then
	    		dummy:SetAbsOrigin(target:GetAbsOrigin())
	    		ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP, Queue = false})
	    		dummy:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,1.0)
	    		dummy:SetForwardVector(target:GetForwardVector())
	    	else
	    		dummy:StartGestureWithPlaybackRate(ACT_DOTA_RUN,2.5)
	    		if CalcDistanceBetweenEntityOBB(dummy,target) < 50 then
	    			ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP, Queue = false})
	    			b = true
	    			keys.ability:ApplyDataDrivenModifier(caster, target,"modifier_spawn_spiderlings_datadriven",nil)
	    			print("B33")
	    		end

				ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION, Position = target:GetAbsOrigin(), Queue = false}) 
	    	end

	    	print(tostring(num))	
    		num = num + 1
    		return time
    	end

    end)

end