-- 雷之卷
--[[
	Author: Noya
	Date: April 4, 2015.
	Finds targets to fire the ether shock effect and damage.
]]
function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local start_radius = ability:GetLevelSpecialValueFor("start_radius", level )
	local end_radius = ability:GetLevelSpecialValueFor("end_radius", level )
	local end_distance = ability:GetLevelSpecialValueFor("end_distance", level )
	local targets = ability:GetLevelSpecialValueFor("targets", level )
	local damage = ability:GetLevelSpecialValueFor("damage", level )
	local AbilityDamageType = ability:GetAbilityDamageType()
	local particleName = "particles/item/d09/d09.vpcf"
	local vec = caster:GetForwardVector():Normalized()
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = (point2-point):Normalized() --caster:GetForwardVector():Normalized()

	--【KV】
	--caster:SetForwardVector(vec)

	-- Make sure the main target is damaged
	local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)

	--【Particle】
	local particle = ParticleManager:CreateParticle("particles/item/d09/d09.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0, point + vec * 100)
	ParticleManager:SetParticleControl(particle,1, point2)

	-- ParticleManager:SetParticleControl(lightningBolt,0,Vector(point.x,point.y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))	
	-- ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	--【DMG】
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = AbilityDamageType})
	target.has_D09 = true
	-- target:EmitSound("Hero_ShadowShaman.EtherShock.Target")

	--【Varible Of Tem】
	--local tem_point = nil


	local cone_units = FindUnitsInRadius( caster:GetTeamNumber(), point2, nil, 700, 
					DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 
					DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
	local targets_shocked = 1 --Is targets=extra targets or total?
	for _,unit in pairs(cone_units) do
		if targets_shocked < targets then
			if unit.has_D09 ~= true then
				unit.has_D09 = true
				-- Particle
				local tem_point = unit:GetAbsOrigin()

				--【Particle】
				particle = ParticleManager:CreateParticle("particles/item/d09/d09.vpcf",PATTACH_POINT,caster)
				ParticleManager:SetParticleControl(particle,0, point + vec * 100)
				ParticleManager:SetParticleControl(particle,1, tem_point)
			
				--【DMG】
				ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = AbilityDamageType})

				-- Increment counter
				targets_shocked = targets_shocked + 1
			end
		else
			break
		end
	end

	for _,unit in pairs(cone_units) do
		unit.has_D09 = nil
	end

	--【SOUND】
	caster:EmitSound("ITEM_D09.sound")
	Timers:CreateTimer(2,function()
		caster:StopSound("ITEM_D09.sound")
	end)
end


function GetEnemiesInCone( unit,vec,start_radius, end_radius, end_distance)
	local DEBUG = false
	-- Positions
	local fv = vec
	local origin = unit:GetAbsOrigin()

	local start_point = origin + fv * start_radius -- Position to find units with start_radius
	local end_point = origin + fv * (start_radius + end_distance) -- Position to find units with end_radius

	if DEBUG then
		DebugDrawCircle(start_point, Vector(255,0,0), 100, start_radius, true, 3)
		DebugDrawCircle(end_point, Vector(255,0,0), 100, end_radius, true, 3)
	end

	-- 1 medium circle should be enough as long as the mid_interval isn't too large
	local mid_interval = end_distance - start_radius - end_radius
	local mid_radius = (start_radius + end_radius) / 2
	local start_point2 = origin + fv * mid_radius * 1	
	local mid_point = origin + fv * mid_radius * 2
	local mid_point2 = origin + fv * mid_radius * 3
	
	if DEBUG then
		--print("There's a space of "..mid_interval.." between the circles at the cone edges")
		DebugDrawCircle(mid_point, Vector(0,255,0), 100, mid_radius, true, 3)
		DebugDrawCircle(mid_point2, Vector(0,255,0), 100, mid_radius, true, 3)
		DebugDrawCircle(start_point2, Vector(255,0,0), 100, start_radius*1.5, true, 3)
	end

	-- Find the units
	local team = unit:GetTeamNumber()
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = FIND_ANY_ORDER

	local start_units = FindUnitsInRadius(team, start_point, nil, start_radius, iTeam, iType, iFlag, iOrder, false)
	local start_units2 = FindUnitsInRadius(team, start_point2, nil, start_radius*1.5, iTeam, iType, iFlag, iOrder, false)	
	local end_units = FindUnitsInRadius(team, end_point, nil, end_radius, iTeam, iType, iFlag, iOrder, false)
	local mid_units = FindUnitsInRadius(team, mid_point, nil, mid_radius, iTeam, iType, iFlag, iOrder, false)
	local mid_units2 = FindUnitsInRadius(team, mid_point2, nil, mid_radius, iTeam, iType, iFlag, iOrder, false)

	-- Join the tables
	local cone_units = {}
	for k,v in pairs(end_units) do
		table.insert(cone_units, v)
	end

	for k,v in pairs(start_units) do
		if not tableContains(cone_units, k) then
			table.insert(cone_units, v)
		end
	end	

	for k,v in pairs(start_units2) do
		if not tableContains(cone_units, k) then
			table.insert(cone_units, v)
		end
	end		

	for k,v in pairs(mid_units) do
		if not tableContains(cone_units, k) then
			table.insert(cone_units, v)
		end
	end

	for k,v in pairs(mid_units2) do
		if not tableContains(cone_units, k) then
			table.insert(cone_units, v)
		end
	end	

	--DeepPrintTable(cone_units)
	return cone_units

end

-- Returns true if the element can be found on the list, false otherwise
function tableContains(list, element)
    if list == nil then return false end
    for i=1,#list do
        if list[i] == element then
            return true
        end
    end
    return false
end

function OnEquip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == nil) then
		caster.nobuorb1 = "item_raikiri"
	end
end

function OnUnequip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == "item_raikiri") then
		caster.nobuorb1 = nil
	end
end

function Shock2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local start_radius = ability:GetLevelSpecialValueFor("start_radius", level )
	local end_radius = ability:GetLevelSpecialValueFor("end_radius", level )
	local end_distance = ability:GetLevelSpecialValueFor("end_distance", level )
	local targets = ability:GetLevelSpecialValueFor("targets", level )
	local damage = ability:GetLevelSpecialValueFor("damage", level )
	local chance = ability:GetLevelSpecialValueFor("chance", level )
	local AbilityDamageType = ability:GetAbilityDamageType()
	local particleName = "particles/item/d09/d09.vpcf"
	local vec = caster:GetForwardVector():Normalized()
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = (point2-point):Normalized() --caster:GetForwardVector():Normalized()
	if (caster.nobuorb1 == "item_raikiri" or caster.nobuorb1 == nil) and not target:IsBuilding() and caster.goraikiri == nil then
		caster.nobuorb1 = "item_raikiri"
		local ran =  RandomInt(0, 100)
		if (caster.raikiri == nil) then
			caster.raikiri = 0
		end
		if (ran > chance) then
			caster.raikiri = caster.raikiri + 1
		end
		if (caster.raikiri > (100/chance) or ran <= chance) then
			caster.raikiri = 0
			--【KV】
			--caster:SetForwardVector(vec)

			-- Make sure the main target is damaged
			local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)

			--【Particle】
			local particle = ParticleManager:CreateParticle("particles/item/d09/d09.vpcf",PATTACH_POINT,caster)
			ParticleManager:SetParticleControl(particle,0, point + vec * 100)
			ParticleManager:SetParticleControl(particle,1, point2)

			-- ParticleManager:SetParticleControl(lightningBolt,0,Vector(point.x,point.y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))	
			-- ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
			--【DMG】
			ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = AbilityDamageType})
			target.has_D09 = true
			-- target:EmitSound("Hero_ShadowShaman.EtherShock.Target")

			--【Varible Of Tem】
			--local tem_point = nil


			local cone_units = FindUnitsInRadius(caster:GetTeamNumber(),
		                              point2,
		                              nil,
		                              500,
		                              DOTA_UNIT_TARGET_TEAM_ENEMY,
		                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		                              DOTA_UNIT_TARGET_FLAG_NONE,
		                              FIND_ANY_ORDER,
		                              false)
			local targets_shocked = 1 --Is targets=extra targets or total?
			for _,unit in pairs(cone_units) do
				if targets_shocked < targets then
					Timers:CreateTimer(0.1, function() 
						keys.target.raikiri = nil
					end)
					if unit.has_D09 ~= true then
						unit.has_D09 = true
						-- Particle
						local tem_point = unit:GetAbsOrigin()

						--【Particle】
						particle = ParticleManager:CreateParticle("particles/item/d09/d09.vpcf",PATTACH_POINT,caster)
						ParticleManager:SetParticleControl(particle,0, point + vec * 100)
						ParticleManager:SetParticleControl(particle,1, tem_point)
					
						--【DMG】
						ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = AbilityDamageType})

						-- Increment counter
						targets_shocked = targets_shocked + 1
					end
				else
					break
				end
			end

			for _,unit in pairs(cone_units) do
				unit.has_D09 = nil
			end

			--【SOUND】
			local dummy = CreateUnitByName( "npc_dummy", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
			dummy:EmitSound("ITEM_D09.sound")
			Timers:CreateTimer(2,function()
				dummy:StopSound("ITEM_D09.sound")
				if IsValidEntity(dummy) then
					dummy:ForceKill(true)
				end
			end)
		end
	end
end
