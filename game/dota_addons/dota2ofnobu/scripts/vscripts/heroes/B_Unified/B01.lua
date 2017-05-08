
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
end

function B01E_CHECK(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	table.insert(caster.B01E, target)
	target:SetBaseDamageMin(70+caster:GetLevel()*10)
	target:SetBaseDamageMax(70+caster:GetLevel()*10)

	local tem_point = target:GetAbsOrigin()
	--【Particle】
	local particle = ParticleManager:CreateParticle("particles/b01e2/b01e2.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0, tem_point)

end

function B01E_old_CHECK(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	table.insert(caster.B01E, target)
	target:SetBaseDamageMin(70+caster:GetLevel()*15)
	target:SetBaseDamageMax(70+caster:GetLevel()*15)

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
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )

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
			local dmgori = dmg
			dmg = dmg * per_atk  / 100
			--print(dmgori, damageReduction, dmg)
			AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		elseif  target:IsBuilding() then
			per_atk = ability:GetLevelSpecialValueFor("atk_building",level)
			local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
			Timers:CreateTimer(1, function()
				ParticleManager:DestroyParticle(particle,false)
			end)
			local dmgori = dmg
			dmg = dmg * per_atk  / 100
			--print(dmgori, damageReduction, dmg)
			AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		else
			per_atk = ability:GetLevelSpecialValueFor("atk_unit",level)
			local dmgori = dmg
			dmg = dmg * per_atk  / 100
			--print(dmgori, damageReduction, dmg)
			AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end
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
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		if IsValidEntity(target) then
			local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
			Timers:CreateTimer(1, function()
				ParticleManager:DestroyParticle(particle,false)
				end)
		end
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
			AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
			if IsValidEntity(target) then
				local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
				ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
				Timers:CreateTimer(1, function()
					ParticleManager:DestroyParticle(particle,false)
					end)
			end
		end
	end
end


function C01W_sound( keys )
	local caster = keys.caster
	caster:EmitSound( "B01W.sound"..1)
end

function B01W_lock( keys )
	keys.ability:SetActivated(false)
end

function B01W_unlock( keys )
	keys.ability:SetActivated(true)
end
