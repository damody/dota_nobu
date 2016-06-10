udg_C05W_stun = {}
udg_C05W_stun[1] = 0.30
udg_C05W_stun[2] = 0.50
udg_C05W_stun[3] = 0.70
udg_C05W_stun[4] = 0.90	






function new_C17R( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	--local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	local point2 = ability:GetCursorPosition()
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

	local particle2 = ParticleManager:CreateParticle("particles/c17r/c17r.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle2,0, point2)
	ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
	ParticleManager:SetParticleControl(particle2,2, point2)	

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

function new_C17R_dmg( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = caster:GetIntellect() * 4  
	--【DMG】
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )		
	--【DEBUG】
	----print(dmg)
end

function new_C17D( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local dmg = caster:GetIntellect() * 4  
	local point = caster:GetAbsOrigin()
	local point2 = nil
	--PopupHealing(caster, health)
	--【Group】
	local group = {}
	local radius = 650.00
 	group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for i,v in ipairs(group) do
		point2 = v:GetAbsOrigin()
		local particle = ParticleManager:CreateParticle("particles/c17d/c17d.vpcf", PATTACH_ABSORIGIN_FOLLOW , v)
		-- Raise 1000 if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 0, point2)
		--ParticleManager:SetParticleControl(particle, 1, Vector(point2.x,point2.y,point2.z + v:GetBoundingMaxs().z ))
		ParticleManager:SetParticleControl(particle, 2, point2)

		-- Timers:CreateTimer(1,function()
		-- 	ParticleManager:DestroyParticle(particle,false)
		-- end)

		--【KV】
		local mana = v:GetMaxMana() * 0.04 
		local health = v:GetMaxHealth() * 0.05
		v:SetMana(mana + v:GetMana())
		v:SetHealth(health + v:GetHealth())

		--【DEBUG】
		--print(health)
		--print(mana)	
		--print(v:GetUnitName())	

	end	
end

function new_C17D_DMG( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local dmg = keys.dmg
	local cure = ability:GetLevelSpecialValueFor("cure",ability:GetLevel() - 1)
	--【KV】
	if caster:GetHealth() > 21 and caster.damagetype ==1 then
		if dmg < cure then
			caster:SetHealth(dmg + caster:GetHealth())
		else
			caster:SetHealth(cure + caster:GetHealth())
		end
	end
	--【DEBUG】
	-- --print(cure)
	-- --print(caster.damagetype)
	----print(mana)	
end

function new_C17D_OnCreated( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local ta = {damage_reduction = 1000,damage_cleanse = 1000,amage_reset_interval =100}
			-- "01"
			-- {
			-- 	"var_type"				"FIELD_INTEGER"
			-- 	"damage_reduction"		"12 24 36 48"
			-- }
			-- "02"
			-- {
			-- 	"var_type"				"FIELD_INTEGER"
			-- 	"damage_cleanse"		"600 550 500 450"
			-- }
			-- "03"
			-- {
			-- 	"var_type"				"FIELD_FLOAT"
			-- 	"damage_reset_interval"	"6.0 6.0 6.0 6.0"
			-- }
	caster:AddNewModifier(caster,nil,"modifier_tidehunter_kraken_shell",ta)
	--【DEBUG】
	if caster:HasModifier("modifier_tidehunter_kraken_shell") then
		--print("C17_SUCCEESS")
		--print(caster:GetUnitName())
	end
end

function C17E(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	--local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()
	--【Particle】
	-- local particle = ParticleManager:CreateParticle("particles/c15t5/c15t5.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point)
	-- ParticleManager:SetParticleControl(particle,1, point)
	local particle2 = ParticleManager:CreateParticle("particles/c17e/c17e.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle2,0, point2)
	ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
	ParticleManager:SetParticleControl(particle2,2, point2)	
	ParticleManager:SetParticleControl(particle2,3, point2)	
	--ParticleManager:SetParticleControlForward(int nFXIndex,int nPoint,vForward)
end

function C17W(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration",level)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration",level)
	--local vec = caster:GetForwardVector():Normalized()
	--【Particle】
	-- local particle = ParticleManager:CreateParticle("particles/c15t5/c15t5.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point)
	-- ParticleManager:SetParticleControl(particle,1, point)m
	-- local height = 4
	-- local particle2 = ParticleManager:CreateParticle("particles/c17w/c17w.vpcf",PATTACH_POINT,target)
	-- ParticleManager:SetParticleControl(particle2,0, point)
	-- ParticleManager:SetParticleControl(particle2,1, point2)	
	-- ParticleManager:SetParticleControl(particle2,6, Vector(height,height,height))	

	-- Fire the explosion effect
	local height = 3
	local particleName = "particles/c17w2/c17w2.vpcf"
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControl(particle,6, Vector(height,height,height))		
	--【Timer】
	Timers:CreateTimer(duration,function()
		ParticleManager:DestroyParticle(particle,true)

		--【Basic】
		point = caster:GetAbsOrigin()
		point2 = target:GetAbsOrigin() 
		local r = 0
		local r2 = 0
		local time = nil
		if CalcDistanceBetweenEntityOBB(caster,target) >=1001.00 then
			r=1000.00
		else
			r=CalcDistanceBetweenEntityOBB(caster,target)
		end
		r2=(1000.00-r)
		r=r*(0.18+(0.17*(level + 1)))
		AMHC:Damage( caster,target,r,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		r2=((r2/200.00)+1.00)

		time = r2*udg_C05W_stun[level + 1]

		--【Modifier】
		ability:ApplyDataDrivenModifier(caster,target,"modifier_C17W",{duration = time})		
		--ParticleManager:SetParticleControl(particle2,1, point2)

		--【SE】
		local particle3 = ParticleManager:CreateParticle("particles/c17w5/c17w5.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle3,0, point2+Vector(0,0,40))
		ParticleManager:SetParticleControl(particle3,3, point2+Vector(0,0,40))

		for i=1,3 do
			local particle2 = ParticleManager:CreateParticle("particles/c17w3/c17w3.vpcf",PATTACH_POINT,target)
			ParticleManager:SetParticleControl(particle2,0, point2+Vector(0,0,i*40))
			Timers:CreateTimer(time,function()
				ParticleManager:DestroyParticle(particle2,false)
			end)
		end		

		--【DEBUG】
		--print(r)			
		--print(time)	

	end)			
end


function C17T(keys)
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--【SE】
	local particle3 = ParticleManager:CreateParticle("particles/c17t3/c17t3.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle3,0, point2+Vector(0,0,40))
	ParticleManager:SetParticleControl(particle3,3, point2+Vector(0,0,40))

	-- local particle = ParticleManager:CreateParticle("particles/c17t2/c17t2.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point2+Vector(0,0,40))
	--【Group】	
	local caster_team = caster:GetTeamNumber()
	local group = {}
	local radius = 650.00
	local dmg = 350.00+150.00*(level + 1)
	local r2 = 0.20+0.10*(level + 1)
 	group = FindUnitsInRadius(caster:GetTeamNumber(), point2, nil, radius,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for i,v in ipairs(group) do
		if v:GetTeamNumber() ~= caster_team then
        	if (v:GetHealth()*0.25) <= dmg then
        		AMHC:Damage( caster,v,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
       		else
       			local dmg2 = v:GetMaxHealth()*0.25
       			AMHC:Damage( caster,v,dmg2,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
        	end
		else
			--【KV】
			local hp = v:GetHealth() + v:GetMaxHealth() * r2
			v:SetHealth(hp)
			--【DEBUG】
			--print(hp)
			-- --print(mana)	
			-- --print(v:GetUnitName())	
		end
	end	

--【DEBUG】
----print(caster:GetTeamNumber())
 --print(dmg)	
-- --print(v:GetUnitName())	
end