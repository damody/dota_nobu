function item_D01( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()

	--【Varible】
	--local duration = ability:GetLevelSpecialValueFor("duration",level)
	--local radius = ability:GetLevelSpecialValueFor("radius",level)

	--【Varible Of Tem】
	-- local point_tem = nil
	-- local deg = 0 
	-- local distance = 300


	-- --【For】
	-- for i=1,10 do
	-- 	deg = deg + 36
	-- 	point_tem = point2 + Vector(distance*math.cos(nobu_degtorad(deg))  , distance*math.sin(nobu_degtorad(deg))  ,point2.z ) 
	-- 	--【Dummy Kv】
	-- 	local dummy = CreateUnitByName("C15T_DUMMY",point_tem ,false,caster,caster,caster:GetTeam())	
	-- 	--dummy:SetControllableByPlayer(player,false)
	-- 	--ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07T",nil)
	-- 	dummy:FindAbilityByName("majia"):SetLevel(1)		
	-- 	-- local dummy_ability = dummy:AddAbility("batrider_firefly")
	-- 	-- dummy_ability:SetLevel(1)
	-- 	-- ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = dummy_ability:GetEntityIndex(), Queue = false}) 
	-- 	-- Execute the attack order for the caster
	-- 	dummy:SetForwardVector(vec)
	-- 	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C15T",nil)

	-- 	local order =
	-- 	{
	-- 		UnitIndex = dummy:entindex(),
	-- 		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
	-- 		TargetIndex = target:entindex(),
	-- 		Queue = true
	-- 	}

	-- 	ExecuteOrderFromTable(order)				
	-- end

	--【Particle】
	-- local particle = ParticleManager:CreateParticle("particles/c15t5/c15t5.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point)
	-- ParticleManager:SetParticleControl(particle,1, point)
	local height = 400
	target:SetAbsOrigin(point2+Vector(0,0,height))
	local particle2 = ParticleManager:CreateParticle("particles/item_d01_3/d01_3.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle2,0, point+Vector(0,0,0))
	-- ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
	-- ParticleManager:SetParticleControl(particle2,2, point2)	


	local particle = ParticleManager:CreateParticle("particles/item_d01_3/d01_3_c.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0, point+Vector(0,0,0))
	local num = 0
	local tem_p1 = point2+Vector(0,0,height)
	local tem_p2 = nil
	local function ltt( ... )
		if num == 10 then
			ParticleManager:DestroyParticle(particle,false)
			return nil
		else
			tem_p2 = tem_p1
 			ParticleManager:DestroyParticle(particle,false)
			particle = ParticleManager:CreateParticle("particles/item_d01_3/d01_3_c.vpcf",PATTACH_POINT,target)
			ParticleManager:SetParticleControl(particle,0, tem_p2)
			return 2	
		end
	end
	Timers:CreateTimer (  0 ,  ltt )

	--【SOUND】
	caster:StopSound("ITEM_D01_SOUND")
	caster:EmitSound("ITEM_D01_SOUND")

	--【Order】	
	-- local order =
	-- {
	-- 	UnitIndex = caster:entindex(),
	-- 	OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
	-- 	TargetIndex = target:entindex(),
	-- 	Queue = true
	-- }

	-- ExecuteOrderFromTable(order)		

	--【Test】
	--modifier_batrider_firefly
	-- local modifier_S = "modifier_batrider_firefly"
	-- local modifier_T = {damage_per_second = 10,radius = 200,duration = 18 ,tick_interval = 0.1 , tree_radius = 100}
	-- caster:AddNewModifier(caster,caster,modifier_S,modifier_T)

	----【Timer】
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

	--【System】
	-- if target.yushou == nil or target.yushou == false then
	-- 	ability:ApplyDataDrivenModifier(caster,target,"modifier_C15T_2",nil)
	-- end

	--【Group】
	-- local group = {}
	-- local aoe = ability:GetLevelSpecialValueFor("aoe",ability:GetLevel() - 1)
 --   	group = FindUnitsInRadius(dummy:GetTeamNumber(), point2, nil, aoe ,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	-- for i,v in ipairs(group) do
	-- 	AMHC:Damage( caster,v2,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	-- end	

	--【DEBUG】
	--print(vec)
end

function item_D01_END( keys )
	print("DEAD")
	local target = keys.target
	target:ForceKill(true)
	target:Destroy()
end