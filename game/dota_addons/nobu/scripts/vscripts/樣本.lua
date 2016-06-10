	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = caster:GetForwardVector():Normalized()

	--【Varible】
	--local duration = ability:GetLevelSpecialValueFor("duration",level)
	--local radius = ability:GetLevelSpecialValueFor("radius",level)

	--【Varible Of Tem】
	local point_tem = point + Vector(100*vec.x,100*vec.y) 
	local deg = 0 
	local distance = 50

	--【Dummy Kv】
	local dummy = CreateUnitByName("Dummy_Ver1",point_tem ,false,nil,nil,caster:GetTeam())	
	--ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07T",nil)
	dummy:FindAbilityByName("majia"):SetLevel(level + 1)		
	local dummy_ability = dummy:AddAbility("batrider_firefly")
	dummy_ability:SetLevel(1)
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