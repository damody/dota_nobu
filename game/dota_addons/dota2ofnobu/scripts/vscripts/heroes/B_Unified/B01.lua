modifier_B01W = class({})

--[[Author: Noya
	Date: 27.01.2016.
	Changes the model of the unit into the Dragon Knight Elder Dragon Form model as long as the modifier is active]]
function modifier_B01W:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_B01W:GetModifierModelChange()
	return "models/b01/b01_2.vmdl"
end

function modifier_B01W:IsHidden() 
	return true
end

LinkLuaModifier("modifier_B01W", "heroes/B_Unified/B01.lua", LUA_MODIFIER_MOTION_NONE)
function B01W( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()

	local duration = ability:GetLevelSpecialValueFor("duration",level - 1)

	--【Translation】
	local modifier = keys.modifier_one-- Deciding the transformation level
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
	caster:AddNewModifier(caster,ability,"modifier_B01W",{duration = duration})--變身

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
	local particle = ParticleManager:CreateParticle("particles/b01w/b01w.vpcf",PATTACH_POINT_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControl(particle,0, point)
	ParticleManager:SetParticleControl(particle,1, Vector(10,0,0))
	ParticleManager:SetParticleControl(particle,2, point)
	--【Timer】
	Timers:CreateTimer(duration,function()
		ParticleManager:DestroyParticle(particle,false)
	end)		

	-- local particle2 = ParticleManager:CreateParticle("particles/c17r/c17r.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle2,0, point2)
	-- ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
	-- ParticleManager:SetParticleControl(particle2,2, point2)	

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

function B01E(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = caster:GetForwardVector():Normalized()	
	local point2 = point + vec * 300

	--【MOVE】
	--target:SetAbsOrigin(point2)
	--target:AddNewModifier(nil,nil,"modifier_phased",{duration=0.01})
	--【Special】
	if caster.B01E ~= nil then
		print(caster.B01E)
		for i,v in ipairs(caster.B01E) do
			local tem_point = v:GetAbsOrigin()
			--【Particle】
			local particle = ParticleManager:CreateParticle("particles/b01e2/b01e2.vpcf",PATTACH_POINT,caster)
			ParticleManager:SetParticleControl(particle,0, tem_point)
			--【KV】			
			print("KILL")
			v:ForceKill(true)
			v:Destroy()
		end
	end
	caster.B01E = nil
	caster.B01E = {}
 	--【Dummy Kv】
 	local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point2 ,false,caster,caster,caster:GetTeam())	
 	--dummy:SetControllableByPlayer(player,false)
 	--ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07T",nil)
 	dummy:FindAbilityByName("majia_2"):SetLevel(1)		
 	-- local dummy_ability = dummy:AddAbility("batrider_firefly")
 	-- dummy_ability:SetLevel(1)
 	-- ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = dummy_ability:GetEntityIndex(), Queue = false}) 
 	-- Execute the attack order for the caster
 	--dummy:SetForwardVector(vec)
 	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_B01E",nil)

	--【Timer】
	Timers:CreateTimer(0.01,function()
		dummy:ForceKill(true)
	end)	 				
end

function B01E_CHECK(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	table.insert(caster.B01E, target)

	local tem_point = target:GetAbsOrigin()
	--【Particle】
	local particle = ParticleManager:CreateParticle("particles/b01e2/b01e2.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0, tem_point)

end

function B01R(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dmg = keys.dmg
	local per_atk = 0
	if target:IsHero() then	
		per_atk = ability:GetLevelSpecialValueFor("atk_hero",level)
		print("hero")
	elseif  target:IsBuilding() then
		per_atk = ability:GetLevelSpecialValueFor("atk_building",level)
		print("building")
	else
		per_atk = ability:GetLevelSpecialValueFor("atk_unit",level)
		print("unit")
	end
	dmg = dmg * per_atk  / 100
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	print(dmg)
end

function C01W_sound( keys )
	local caster = keys.caster
	caster:EmitSound( "B01W.sound"..RandomInt(1, 3) )
end