
function B19W_OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
	else
		ability.instance = ability.instance + 1
	end

	local angel = caster:GetAngles().y
	local point = Vector(caster:GetAbsOrigin().x+75*math.cos(angel*bj_DEGTORAD) ,  caster:GetAbsOrigin().y+75*math.sin(angel*bj_DEGTORAD), caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z)
	
	-- Sets the total number of jumps for this instance (to be decremented later)
	ability.jump_count[ability.instance] = ability:GetSpecialValueFor("jump_count")
	-- Sets the first target as the current target for this instance
	ability.target[ability.instance] = target
	
	-- Creates the particle between the caster and the first target
	local lightningBolt = ParticleManager:CreateParticle(keys.particle, PATTACH_POINT, caster)
	-- ParticleManager:SetParticleControlEnt(lightningBolt, 0, caster, PATTACH_POINT, "attach_attack", Vector(0,0,0), true)
	-- ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z )) 
    ParticleManager:SetParticleControl(lightningBolt,0,point)   
    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
end

function LightningJump(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_delay = ability:GetSpecialValueFor("jump_delay")
	local radius = ability:GetSpecialValueFor("radius")
	
	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_arc_lightning_datadriven")
	local pos = target:GetAbsOrigin()
	-- Waits on the jump delay
	Timers:CreateTimer(jump_delay,
    function()
		-- Finds the current instance of the ability by ensuring both current targets are the same
		local current
		for i=0,ability.instance do
			if ability.target[i] ~= nil then
				if ability.target[i] == target then
					current = i
				end
			end
		end
	
		-- Adds a global array to the target, so we can check later if it has already been hit in this instance
		if IsValidEntity(target) then
			pos = target:GetAbsOrigin()
			if target.hit == nil then
				target.hit = {}
			end
			-- Sets it to true for this instance
			target.hit[current] = true
		end
	
		-- Decrements our jump count for this instance
		ability.jump_count[current] = ability.jump_count[current] - 1
	
		-- Checks if there are jumps left
		if ability.jump_count[current] > 0 then
			-- Finds units in the radius to jump to
			local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, ability:GetAbilityTargetTeam(), 
				ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
			local closest = radius
			local new_target
			for i,unit in ipairs(units) do
				-- Positioning and distance variables
				local unit_location = unit:GetAbsOrigin()
				local vector_distance = pos - unit_location
				local distance = (vector_distance):Length2D()
				-- Checks if the unit is closer than the closest checked so far
				if distance < closest then
					-- If the unit has not been hit yet, we set its distance as the new closest distance and it as the new target
					if unit.hit == nil then
						new_target = unit
						closest = distance
					elseif unit.hit[current] == nil then
						new_target = unit
						closest = distance
					end
				end
			end
			-- Checks if there is a new target
			if new_target ~= nil then
				-- Creates the particle between the new target and the last target
				local lightningBolt = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
				ParticleManager:SetParticleControl(lightningBolt,0,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
				ParticleManager:SetParticleControl(lightningBolt,1,Vector(new_target:GetAbsOrigin().x,new_target:GetAbsOrigin().y,new_target:GetAbsOrigin().z + new_target:GetBoundingMaxs().z ))
				-- Sets the new target as the current target for this instance
				ability.target[current] = new_target
				-- Applies the modifer to the new target, which runs this function on it
				ability:ApplyDataDrivenModifier(caster, new_target, "modifier_arc_lightning_datadriven", {})
			else
				-- If there are no new targets, we set the current target to nil to indicate this instance is over
				ability.target[current] = nil
			end
		else
			-- If there are no more jumps, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
		end
		-- Applies damage to the current target
	
	end)
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
end


function B19E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local targetLocation = keys.target_points[1]
	local range = ability:GetSpecialValueFor( "A25E_range")
	local randonint = 5
	local dura = ability:GetSpecialValueFor( "A25E_Duration")
	local damage = ability:GetSpecialValueFor( "A25E_damage")
	local spike = ParticleManager:CreateParticle("particles/b19/b19eikes.vpcf", PATTACH_ABSORIGIN, keys.caster)
	local maxrock = 20
	local pos = {}
	local pointx = targetLocation.x
	local pointy = targetLocation.y
	local pointz = targetLocation.z
	for i=1,maxrock do
		a	=	(	(360.0/maxrock)	*	i	)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	(range-100) 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	(range-100) 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)
		table.insert(pos, point)
	end
	local ct = 0
	local interval = 0.05
	Timers:CreateTimer(interval, function() 
		ct = ct + 1
		ParticleManager:SetParticleControl(spike, 3, pos[math.fmod(ct,#pos)+1])
		if ct*interval < dura then
			return interval
		else
			ParticleManager:DestroyParticle(spike,false)
		end
		end)
	

	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), targetLocation, nil, range+50, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _,it in pairs(enemies) do
		if (not(it:IsBuilding())) then
			ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = dura})
			AMHC:Damage(caster,it, damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
	local dummy = CreateUnitByName( "npc_dummy", targetLocation, false, caster, caster, caster:GetTeamNumber() )
	dummy:EmitSound( "A25E.spiked_carapace" )
	Timers:CreateTimer( 0.5, function()
			dummy:ForceKill( true )
			return nil
		end)
end

function B19E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local targetLocation = keys.target_points[1]
	local range = ability:GetSpecialValueFor( "A25E_range")
	local randonint = 5
	local dura = ability:GetSpecialValueFor( "A25E_Duration")
	local damage = ability:GetSpecialValueFor( "A25E_damage")
	local spike = ParticleManager:CreateParticle("particles/b19/b19eikes.vpcf", PATTACH_ABSORIGIN, keys.caster)
	local maxrock = 20
	local pos = {}
	local pointx = targetLocation.x
	local pointy = targetLocation.y
	local pointz = targetLocation.z
	for i=1,maxrock do
		a	=	(	(360.0/maxrock)	*	i	)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	(range-100) 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	(range-100) 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)
		table.insert(pos, point)
	end
	local ct = 0
	local interval = 0.05
	Timers:CreateTimer(interval, function()
		ct = ct + 1
		ParticleManager:SetParticleControl(spike, 3, pos[math.fmod(ct,#pos)+1])
		if ct*interval < dura+0.6 then
			return interval
		else
			ParticleManager:DestroyParticle(spike,false)
		end
		end)
	
	Timers:CreateTimer(0.6, function()
		local enemies = FindUnitsInRadius( caster:GetTeamNumber(), targetLocation, nil, range+50, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		for _,it in pairs(enemies) do
			if (not(it:IsBuilding())) then
				ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = dura})
				AMHC:Damage(caster,it, damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		end)
	local dummy = CreateUnitByName( "npc_dummy", targetLocation, false, caster, caster, caster:GetTeamNumber() )
	dummy:EmitSound( "A25E.spiked_carapace" )
	Timers:CreateTimer( 0.5, function()
			dummy:ForceKill( true )
			return nil
		end)
end

function B19R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local hp = ability:GetSpecialValueFor("hp")
	local mana = ability:GetSpecialValueFor("mana")
	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		90000,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		unit:Heal(hp,caster)
		unit:SetMana(unit:GetMana()+mana)
		if IsValidEntity(unit) then
			local ifx = ParticleManager:CreateParticle("particles/a15/a15eoldmoonlight_shaft03_ti_5.vpcf",PATTACH_ABSORIGIN,unit)
			ParticleManager:SetParticleControl(ifx, 0, unit:GetAbsOrigin())
		end
	end
end

function B19T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local targetpos = keys.target_points[1]
	local cavalry = ability:GetSpecialValueFor( "cavalry")
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor( "duration")
	local stun = ability:GetSpecialValueFor( "stun")
	local wolfall = {}
	for i=1,cavalry do
		local pos = targetpos + RandomVector(RandomInt(10,radius*0.7))
		local wolf = CreateUnitByName("B19T_old",pos ,false,caster,caster,caster:GetTeam())
		wolf:AddNewModifier(wolf,nil,"equilibrium_constant",{})
	 	wolf:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		wolf:AddNewModifier(wolf,ability,"modifier_phased",{duration=0.1})
	 	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_kill",{duration = duration})
	 	table.insert(wolfall, wolf)
	end
	Timers:CreateTimer(1, function() 
		for i,wolf in pairs(wolfall) do
			ability:ApplyDataDrivenModifier(wolf,wolf,"Passive_B19T",{duration = duration})
		end
		end)
	Timers:CreateTimer(duration, function() 
		for i,wolf in pairs(wolfall) do
			wolf:Destroy()
		end
		end)
	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), targetpos, nil, radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for _,it in pairs(enemies) do
		if (not(it:IsBuilding())) then
			ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = stun})
		end
	end
	
	Timers:CreateTimer(0.1, function()
			local enemies = FindUnitsInRadius( caster:GetTeamNumber(), targetpos, nil, radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
			if #enemies > 0 then
				for i,wolf in pairs(wolfall) do
					local order = {UnitIndex = wolf:entindex(),
							OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
							TargetIndex = enemies[1]:entindex()}
					ExecuteOrderFromTable(order)
				end
			end
		end)
	
	local dummy = CreateUnitByName( "npc_dummy", targetpos, false, caster, caster, caster:GetTeamNumber() )
	dummy:EmitSound( "A25E.spiked_carapace" )
	Timers:CreateTimer( 0.5, function()
			dummy:ForceKill( true )
			return nil
		end)
end


function B19W_old_OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
	else
		ability.instance = ability.instance + 1
	end

	local angel = caster:GetAngles().y
	local point = Vector(caster:GetAbsOrigin().x+75*math.cos(angel*bj_DEGTORAD) ,  caster:GetAbsOrigin().y+75*math.sin(angel*bj_DEGTORAD), caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z)
	
	-- Sets the total number of jumps for this instance (to be decremented later)
	ability.jump_count[ability.instance] = ability:GetSpecialValueFor("jump_count")
	-- Sets the first target as the current target for this instance
	ability.target[ability.instance] = target
	
	-- Creates the particle between the caster and the first target
	local lightningBolt = ParticleManager:CreateParticle(keys.particle, PATTACH_POINT, caster)
	-- ParticleManager:SetParticleControlEnt(lightningBolt, 0, caster, PATTACH_POINT, "attach_attack", Vector(0,0,0), true)
	-- ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z )) 
    ParticleManager:SetParticleControl(lightningBolt,0,point)   
    ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
end

function LightningJump_old(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_delay = ability:GetSpecialValueFor("jump_delay")
	local radius = ability:GetSpecialValueFor("radius")
	
	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_arc_lightning_datadriven")
	local pos = target:GetAbsOrigin()
	-- Waits on the jump delay
	Timers:CreateTimer(jump_delay,
    function()
		-- Finds the current instance of the ability by ensuring both current targets are the same
		local current
		for i=0,ability.instance do
			if ability.target[i] ~= nil then
				if ability.target[i] == target then
					current = i
				end
			end
		end

		if IsValidEntity(target) then
			pos = target:GetAbsOrigin()
			if target.hit == nil then
				target.hit = {}
			end
			target.hit[current] = true
			Timers:CreateTimer(0.8, function ()
				if IsValidEntity(target) then
					target.hit[current] = nil
				end
				end)
		end
		-- Decrements our jump count for this instance
		ability.jump_count[current] = ability.jump_count[current] - 1
	
		-- Checks if there are jumps left
		if ability.jump_count[current] > 0 then
			-- Finds units in the radius to jump to
			local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, ability:GetAbilityTargetTeam(), 
				ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
			local closest = radius
			local new_target
			for i,unit in ipairs(units) do
				-- Positioning and distance variables
				local unit_location = unit:GetAbsOrigin()
				local vector_distance = pos - unit_location
				local distance = (vector_distance):Length2D()
				-- Checks if the unit is closer than the closest checked so far
				if distance < closest then
					-- If the unit has not been hit yet, we set its distance as the new closest distance and it as the new target
					if unit.hit == nil then
						new_target = unit
						closest = distance
					elseif unit.hit[current] == nil then
						new_target = unit
						closest = distance
					end
				end
			end
			-- Checks if there is a new target
			if new_target ~= nil then
				-- Creates the particle between the new target and the last target
				local lightningBolt = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
				ParticleManager:SetParticleControl(lightningBolt,0,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))   
				ParticleManager:SetParticleControl(lightningBolt,1,Vector(new_target:GetAbsOrigin().x,new_target:GetAbsOrigin().y,new_target:GetAbsOrigin().z + new_target:GetBoundingMaxs().z ))
				-- Sets the new target as the current target for this instance
				ability.target[current] = new_target
				-- Applies the modifer to the new target, which runs this function on it
				ability:ApplyDataDrivenModifier(caster, new_target, "modifier_arc_lightning_datadriven", {})
			else
				-- If there are no new targets, we set the current target to nil to indicate this instance is over
				ability.target[current] = nil
			end
		else
			-- If there are no more jumps, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
		end
		-- Applies damage to the current target
	
	end)
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
end
function B19T_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local dmg = keys.dmg

	if not target:IsBuilding() then
		AMHC:Damage(caster,target,20,AMHC:DamageType("DAMAGE_TYPE_MAGICAL"))
	end
end

function B19T_old_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local dmg = keys.dmg

	if not target:IsBuilding() then
		AMHC:Damage(caster,target,dmg,AMHC:DamageType("DAMAGE_TYPE_PHYSICAL"))
		AMHC:Damage(caster,target,20,AMHC:DamageType("DAMAGE_TYPE_MAGICAL"))
	end
end


function B19D_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local spike = ParticleManager:CreateParticle("particles/b19/b19dold.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(spike, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(spike, 1, target:GetAbsOrigin())
	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 500, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _,it in pairs(enemies) do
		AMHC:Damage(caster,it,ability:GetAbilityDamage(),AMHC:DamageType("DAMAGE_TYPE_MAGICAL"))
	end
end