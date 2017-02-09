function new_C15E( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = (point2-point):Normalized()

	--【Varible】
	--local duration = ability:GetLevelSpecialValueFor("duration",level)
	--local radius = ability:GetLevelSpecialValueFor("radius",level)

	--【Varible Of Tem】
	local point_tem = point + Vector(100*vec.x,100*vec.y) 
	local deg = 0 
	local distance = 50

	--【Timer】
	local num = 0
	Timers:CreateTimer(0.03,function()
		if num == 60 then
			return nil
		else
			point_tem = Vector(point_tem.x+distance*vec.x ,  point_tem.y+distance*vec.y , point_tem.z)
			local z = GetGroundHeight(point_tem, nil)
			point_tem.z = z
			local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point_tem ,false,caster,caster,caster:GetTeam())	
			dummy:SetOwner(caster)
			dummy:FindAbilityByName("majia"):SetLevel(1)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_C15E_2",nil)
			dummy:SetAbsOrigin(point_tem)
			AddFOWViewer ( caster:GetTeam(), point_tem, 200, 12, true)
			num = num + 1
			Timers:CreateTimer(15, function()
				dummy:ForceKill(true)
				end)
			return 0.03
		end
	end)	

	--【DEBUG】
	--print(level)

end

function new_C15T( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	local level = ability:GetLevel() - 1
	local vec = caster:GetForwardVector():Normalized()

	--【Varible】
	--local duration = ability:GetLevelSpecialValueFor("duration",level)
	--local radius = ability:GetLevelSpecialValueFor("radius",level)

	--【Varible Of Tem】
	local point_tem = nil
	local deg = 0 
	local distance = 300

	ability:ApplyDataDrivenModifier(caster,target,"modifier_C15T_2",nil)
	--【For】
	for i=1,10 do
		deg = deg + 36
		point_tem = point2 + Vector(distance*math.cos(nobu_degtorad(deg))  , distance*math.sin(nobu_degtorad(deg))  ,point2.z ) 
		--【Dummy Kv】
		local dummy = CreateUnitByName("C15T_DUMMY",point_tem ,false,caster,caster,caster:GetTeam())	
		--dummy:SetControllableByPlayer(player,false)
		--ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07T",nil)
		dummy:FindAbilityByName("majia"):SetLevel(1)		
		-- local dummy_ability = dummy:AddAbility("batrider_firefly")
		-- dummy_ability:SetLevel(1)
		-- ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = dummy_ability:GetEntityIndex(), Queue = false}) 
		-- Execute the attack order for the caster
		dummy:SetForwardVector(vec)
		ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C15T",nil)

		local order =
		{
			UnitIndex = dummy:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex(),
			Queue = true
		}

		ExecuteOrderFromTable(order)				
	end

	--【Particle】
	local particle = ParticleManager:CreateParticle("particles/c15t5/c15t5.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0, point)
	ParticleManager:SetParticleControl(particle,1, point)

	--【Order】	
	local order =
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex(),
		Queue = true
	}

	ExecuteOrderFromTable(order)		

	--【Test】
	--modifier_batrider_firefly
	-- local modifier_S = "modifier_batrider_firefly"
	-- local modifier_T = {damage_per_second = 10,radius = 200,duration = 18 ,tick_interval = 0.1 , tree_radius = 100}
	-- caster:AddNewModifier(caster,caster,modifier_S,modifier_T)

	--【Timer】
	-- local num = 0
	-- Timers:CreateTimer(0.03,function()
	-- 	if num == 60 then
	-- 		--dummy:ForceKill(false)
	-- 		return nil
	-- 	else

	-- 		--deg = 5
	-- 		--local rad = nobu_degtorad(deg)
	-- 		--point_tem = Vector(point_tem.x+distance*math.cos(rad) ,  point_tem.y+distance*math.sin(rad) , point_tem.z) --point_tem.z
	-- 		point_tem = Vector(point_tem.x+distance*vec.x ,  point_tem.y+distance*vec.y , point_tem.z)
	-- 		dummy:SetAbsOrigin(point_tem)
	-- 		AddFOWViewer ( caster:GetTeam(), point_tem, 200, 12, true)

	-- 		num = num + 1
	-- 		return 0.03
	-- 	end
	-- end)	


	--【DEBUG】
	--print(vec)
end

function new_C15T_attack( keys )
	local target = keys.attacker
	--【Particle】
	local particle = ParticleManager:CreateParticle("particles/base_attacks/ranged_tower_good_explosion.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle,3, target:GetAbsOrigin()+Vector(0,0,150))
end


function new_C15T_end( keys )
	local target = keys.target
	--print(target:GetUnitName())
	target:ForceKill(true)
	target:Destroy()
end

-- --[[Author: Pizzalol
-- 	Date: 26.09.2015.
-- 	Clears current caster commands and disjoints projectiles while setting up everything required for movement]]
-- function Leap( keys )
-- 	local caster = keys.caster
-- 	local ability = keys.ability
-- 	local ability_level = ability:GetLevel() - 1	

-- 	-- Clears any current command and disjoints projectiles
-- 	caster:Stop()
-- 	ProjectileManager:ProjectileDodge(caster)

-- 	-- Ability variables
-- 	ability.leap_direction = caster:GetForwardVector()
-- 	ability.leap_distance = ability:GetLevelSpecialValueFor("leap_distance", ability_level)
-- 	ability.leap_speed = ability:GetLevelSpecialValueFor("leap_speed", ability_level) * 1/30
-- 	ability.leap_traveled = 0
-- 	ability.leap_z = 0
-- end

-- --[[Moves the caster on the horizontal axis until it has traveled the distance]]
-- function LeapHorizonal( keys )
-- 	local caster = keys.target
-- 	local ability = keys.ability

-- 	if ability.leap_traveled < ability.leap_distance then
-- 		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
-- 		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
-- 	else
-- 		caster:InterruptMotionControllers(true)
-- 	end
-- end

-- --[[Moves the caster on the vertical axis until movement is interrupted]]
-- function LeapVertical( keys )
-- 	local caster = keys.target
-- 	local ability = keys.ability

-- 	-- For the first half of the distance the unit goes up and for the second half it goes down
-- 	if ability.leap_traveled < ability.leap_distance/2 then
-- 		-- Go up
-- 		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
-- 		ability.leap_z = ability.leap_z + ability.leap_speed/2
-- 		-- Set the new location to the current ground location + the memorized z point
-- 		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
-- 	else
-- 		-- Go down
-- 		ability.leap_z = ability.leap_z - ability.leap_speed/2
-- 		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
-- 	end
-- end

-- 11.2B
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

function C15W_old( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1

	local projectile_max = 3
	local projectile_delay = 0.1

	for i=0,projectile_max-1 do
		Timers:CreateTimer(projectile_delay*i,function()
			-- 產生投射物
			local info = {
				Target = target,
				Source = caster,
				Ability = ability,
				EffectName = "particles/units/heroes/hero_mirana/mirana_base_attack.vpcf",
				bDodgeable = false,
				bProvidesVision = true,
				iMoveSpeed = 1500,
			    iVisionRadius = 0,
			    iVisionTeamNumber = caster:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			}
			ProjectileManager:CreateTrackingProjectile( info )
		end)	
	end
end

function C15E_old_orb_fire( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local mana_per_attack = ability:GetLevelSpecialValueFor("mana_per_attack", ability:GetLevel()-1)

	-- 判斷魔力是否足夠，不夠就關掉技能
	if caster.nobuorb1 == nil then
		if caster:GetMana() < mana_per_attack then
			caster:CastAbilityToggle(ability,-1)		
		else
			caster:SpendMana(mana_per_attack,ability)
		end
	end
end

function C15E_old_orb_apply_damage( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local dmg = ability:GetLevelSpecialValueFor("damage_bonus", ability:GetLevel()-1)
	if caster.nobuorb1 == nil then
		AMHC:Damage( caster,target,dmg,AMHC:DamageType("DAMAGE_TYPE_MAGICAL") )
	end
end