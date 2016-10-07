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

	--【Translation】
	local modifier = keys.modifier_one-- Deciding the transformation level
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
	caster:AddNewModifier(caster,ability,"modifier_B01W",{duration = duration})--變身

	--【Particle】
	local particle = ParticleManager:CreateParticle("particles/b01w/b01w.vpcf",PATTACH_POINT_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControl(particle,0, point)
	ParticleManager:SetParticleControl(particle,1, Vector(10,0,0))
	ParticleManager:SetParticleControl(particle,2, point)
	caster.B01W_effect = particle

end

function B01W_end( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability

	caster:RemoveModifierByName("modifier_B01W")--變身

	ParticleManager:DestroyParticle(caster.B01W_effect,false)	

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
			if v ~= nil and not v:IsNull() then
				if v:IsAlive() then
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

-- function B01R(keys)
-- 	--【Basic】
-- 	local caster = keys.caster
-- 	local target = keys.target
-- 	local ability = keys.ability
-- 	local level = ability:GetLevel() - 1
-- 	local dmg = keys.dmg
-- 	local per_atk = 0
-- 	if target:IsHero() then	
-- 		per_atk = ability:GetLevelSpecialValueFor("atk_hero",level)
-- 		print("hero")
-- 	elseif  target:IsBuilding() then
-- 		per_atk = ability:GetLevelSpecialValueFor("atk_building",level)
-- 		print("building")
-- 	else
-- 		per_atk = ability:GetLevelSpecialValueFor("atk_unit",level)
-- 		print("unit")
-- 	end
-- 	dmg = dmg * per_atk  / 100
-- 	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
-- 	print(dmg)
-- end


function B01R3(keys)
	--【Basic】
	local caster = keys.caster
	if caster.nobuorb1 == nil then
		local target = keys.target
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local dmg = keys.dmg
		--print("B01R "..dmg)
		local per_atk = 0
		local targetArmor = target:GetPhysicalArmorValue()

		if target:IsHero() then 
			per_atk = ability:GetLevelSpecialValueFor("atk_hero",level)
			local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
			Timers:CreateTimer(1, function()
				ParticleManager:DestroyParticle(particle,false)
			end)
		elseif  target:IsBuilding() then
			per_atk = ability:GetLevelSpecialValueFor("atk_building",level)
			
		else
			per_atk = ability:GetLevelSpecialValueFor("atk_unit",level)
			local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
			Timers:CreateTimer(1, function()
				ParticleManager:DestroyParticle(particle,false)
			end)
		end
		local dmgori = dmg
		dmg = dmg * per_atk  / 100
		--print(dmgori, damageReduction, dmg)
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )

	end
end

function B01R2(keys)
	--【Basic】
	local caster = keys.caster
	if caster.nobuorb1 == nil then
		local target = keys.target
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local dmg = keys.dmg
		--print("B01R "..dmg)
		local per_atk = 0
		local targetArmor = target:GetPhysicalArmorValue()

		if target:IsHero() then 
			per_atk = ability:GetLevelSpecialValueFor("atk_hero",level)
			--print("hero")
		elseif  target:IsBuilding() then
			per_atk = ability:GetLevelSpecialValueFor("atk_building",level)
			local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
			Timers:CreateTimer(1, function()
				ParticleManager:DestroyParticle(particle,false)
			end)
		else
			per_atk = ability:GetLevelSpecialValueFor("atk_unit",level)
			--print("unit")
		end
		local dmgori = dmg
		dmg = dmg * per_atk  / 100
		--print(dmgori, damageReduction, dmg)
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )

	end
end


function B01R(keys)
	--【Basic】
	local caster = keys.caster
	if caster.nobuorb1 == nil then
		local target = keys.target
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local dmg = keys.dmg
		--print("B01R "..dmg)
		local per_atk = 0
		local targetArmor = target:GetPhysicalArmorValue()

		if target:IsHero() then 
			per_atk = ability:GetLevelSpecialValueFor("atk_hero",level)
			--print("hero")
		elseif  target:IsBuilding() then
			per_atk = ability:GetLevelSpecialValueFor("atk_building",level)
			--print("building")
		else
			per_atk = ability:GetLevelSpecialValueFor("atk_unit",level)
			--print("unit")
		end
		local dmgori = dmg
		dmg = dmg * per_atk  / 100
		--print(dmgori, damageReduction, dmg)
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
		Timers:CreateTimer(1, function()
			ParticleManager:DestroyParticle(particle,false)
			end)
	end
end

function B01R_old(keys)
	--【Basic】
	local caster = keys.caster
	if caster.B01R_old == nil then
		caster.B01R_old = 0
	end
	if caster.nobuorb1 == nil then
		local ran =  RandomInt(0, 100)
		if (ran > 45) then
			caster.B01R_old = caster.B01R_old + 1
		end
		if (caster.B01R_old > 2 or ran <= 45) then
			caster.B01R_old = 0

			local target = keys.target
			local ability = keys.ability
			local level = ability:GetLevel() - 1
			local dmg = keys.dmg
			--print("B01R "..dmg)
			local per_atk = 0
			local targetArmor = target:GetPhysicalArmorValue()

			if target:IsHero() then 
				per_atk = ability:GetLevelSpecialValueFor("atk_hero",level)
				--print("hero")
			elseif  target:IsBuilding() then
				per_atk = ability:GetLevelSpecialValueFor("atk_building",level)
				--print("building")
			else
				per_atk = ability:GetLevelSpecialValueFor("atk_unit",level)
				--print("unit")
			end
			local dmgori = dmg
			dmg = dmg * per_atk  / 100
			--print(dmgori, damageReduction, dmg)
			AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			
			local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
			Timers:CreateTimer(1, function()
				ParticleManager:DestroyParticle(particle,false)
				end)
		end
	end
end


function C01W_sound( keys )
	local caster = keys.caster
	caster:EmitSound( "B01W.sound"..1)
end

