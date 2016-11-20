function new_C15W( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local particle = ParticleManager:CreateParticle("particles/c15w3/c15w3.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0, point)
	ParticleManager:SetParticleControl(particle,1, point+Vector(0,0,299))
	--varible
	local duration = ability:GetLevelSpecialValueFor("duration",level)
	local radius = ability:GetLevelSpecialValueFor("radius",level)
	--tem
	local point_tem = point2
	local deg = 0
	local distance = radius

	Timers:CreateTimer(0,function()
		-- local dummy = CreateUnitByName("Dummy_Ver1",point2 ,false,nil,nil,caster:GetTeam())	
		-- dummy:FindAbilityByName("majia"):SetLevel(1)
		--StartSoundEventFromPosition("Ability.StarfallImpact",point_tem)
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf",PATTACH_POINT,caster)
		ParticleManager:SetParticleControl(particle,0, point_tem)
		ParticleManager:SetParticleControl(particle,1, point_tem)	
		ParticleManager:SetParticleControl(particle,3, point_tem)	

		for i=1,10 do
			deg = i * 36
			local rad = nobu_degtorad(deg)
			point_tem = Vector(point2.x+distance*math.cos(rad) ,  point2.y+distance*math.sin(rad) , point.z)
			--point_tem = Vector(point2.x + distance * 	,	point2.y		,	point2.z	)


			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf",PATTACH_POINT,caster)
			ParticleManager:SetParticleControl(particle,0, point_tem)
			ParticleManager:SetParticleControl(particle,1, point_tem)	
			ParticleManager:SetParticleControl(particle,3, point_tem)	
		end		

		distance = distance / 2
		for i=1,10 do
			deg = i * 36
			local rad = nobu_degtorad(deg)
			point_tem = Vector(point2.x+distance*math.cos(rad) ,  point2.y+distance*math.sin(rad) , point2.z)
			--point_tem = Vector(point2.x + distance * 	,	point2.y		,	point2.z	)


			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf",PATTACH_POINT,caster)
			ParticleManager:SetParticleControl(particle,0, point_tem)
			ParticleManager:SetParticleControl(particle,1, point_tem)	
			ParticleManager:SetParticleControl(particle,3, point_tem)	
		end
		
	end)	

end

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

	--【Dummy Kv】
	local dummy = CreateUnitByName("Dummy_Ver1",point_tem ,false,caster,caster,caster:GetTeam())	
	--ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07T",nil)
	dummy:FindAbilityByName("majia"):SetLevel(level + 1)		
	local dummy_ability = dummy:AddAbility("batrider_firefly")
	dummy_ability:SetLevel(level + 1)
	ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = dummy_ability:GetEntityIndex(), Queue = false}) 

	--【Particle】
	-- local particle = ParticleManager:CreateParticle("particles/c15w3/c15w3.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point)
	-- ParticleManager:SetParticleControl(particle,1, point+Vector(0,0,299))

	--【Test】
	--modifier_batrider_firefly
	-- local modifier_S = "modifier_batrider_firefly"
	-- local modifier_T = {damage_per_second = 10,radius = 200,duration = 18 ,tick_interval = 0.1 , tree_radius = 100}
	-- caster:AddNewModifier(caster,caster,modifier_S,modifier_T)

	--【Timer】
	local num = 0
	Timers:CreateTimer(0.03,function()
		if num == 60 then
			--dummy:ForceKill(false)
			return nil
		else

			--deg = 5
			--local rad = nobu_degtorad(deg)
			--point_tem = Vector(point_tem.x+distance*math.cos(rad) ,  point_tem.y+distance*math.sin(rad) , point_tem.z) --point_tem.z
			point_tem = Vector(point_tem.x+distance*vec.x ,  point_tem.y+distance*vec.y , point_tem.z)
			dummy:SetAbsOrigin(point_tem)
			AddFOWViewer ( caster:GetTeam(), point_tem, 200, 12, true)

			num = num + 1
			return 0.03
		end
	end)	

	--【DEBUG】
	print(level)

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
	print(vec)
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