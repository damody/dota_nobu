
--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Creates the illusion on the target]]
function B02W( keys )
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	--分身不能用法球
	--illusion.nobuorb1 = "illusion"
	
	if illusion:IsHero() then
		illusion:SetPlayerID(caster:GetPlayerID())

		-- Level Up the unit to the casters level
		local casterLevel = target:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end	
		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
	end
	illusion:SetControllableByPlayer(player, true)
	

	-- Set the skill points to 0 and learn the skills of the caster
	for abilitySlot=0,15 do
		local ability = illusion:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if (illusionAbility ~= nil) then
				illusion:RemoveAbility(abilityName)
			end
		end
	end
	for abilitySlot=0,15 do
		local ability = target:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			illusion:AddAbility(abilityName):SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	illusion:MakeIllusion()
	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(target, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	--illusion:SetRenderColor(0,0,200)
	

	--【KV】
	illusion:SetForwardVector(target:GetForwardVector())
	illusion:SetControllableByPlayer(caster:GetPlayerID(), true)
	--【Player】
	-- PlayerResource:SetOverrideSelectionEntity(player, illusion)
	-- PlayerResource:SetOverrideSelectionEntity(player, caster)

end

function B02W_OnUpgrade(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetPlayerID()
	local ability = keys.ability
	--【KV】
	local b02d = caster:FindAbilityByName("B02D")
	if b02d ~= nil then
		b02d:SetLevel(ability:GetLevel()+1)
	end
end

function B02D_OnAttackLanded(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	
	--【DMG】
		--【Varible】
	local dmg = ability:GetLevelSpecialValueFor("bonus_damage",level)
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )	
end


function B02R(keys)
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
	local Time = ability:GetLevelSpecialValueFor("time",level)

	--【Particle】
	-- local particle = ParticleManager:CreateParticle("particles/c15t5/c15t5.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point)
	-- ParticleManager:SetParticleControl(particle,1, point)

	for i=0,3 do
		local particle2 = ParticleManager:CreateParticle("particles/b02r3/b02r3.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle2,0, point2+Vector(0,0,i*40))
		ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
		ParticleManager:SetParticleControl(particle2,3, point2)	
		Timers:CreateTimer(Time,function ()
			ParticleManager:DestroyParticle(particle2,true)
		end	)
	end
	--【Varible Of Tem】
	local point_tem = point
	-- local deg = 0 
	-- local distance = 300	
	--【Dummy Kv】
	local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point_tem ,false,caster,caster,caster:GetTeam())	
	--dummy:SetControllableByPlayer(player,false)
	--ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07T",nil)
	dummy:FindAbilityByName("majia"):SetLevel(1)		
	-- local dummy_ability = dummy:AddAbility("batrider_firefly")
	-- dummy_ability:SetLevel(1)
	-- ExecuteOrderFromTable({ UnitIndex = dummy:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET, AbilityIndex = dummy_ability:GetEntityIndex(), Queue = false}) 
	-- Execute the attack order for the caster
	--dummy:SetForwardVector(vec)
	--【Special】
	dummy.b02r_D = 0
	local tem_P =Vector( point2.x + 420*math.cos(dummy.b02r_D*3.14159/180.0) ,point2.y + 420*math.sin(dummy.b02r_D*3.14159/180.0),point2.z)
	dummy:SetAbsOrigin(tem_P)	
	ability:ApplyDataDrivenModifier(dummy,target,"modifier_B02R_2",nil)--一定要放MOVE後面
	--【Timer】
	local num = 0
	Timers:CreateTimer(3,function()
		if IsValidEntity(dummy) then
			dummy:ForceKill(true)
		end
	end)	
	--【MODIFIER】
	ability:ApplyDataDrivenModifier(dummy,target,"modifier_B02R",nil)--綑綁 

	local sumt = 0
	Timers:CreateTimer(0.1, function()
		sumt = sumt + 0.1
		if sumt < Time then
			if (not target:HasModifier("modifier_B02R")) then
				local tt = Time-sumt
				--print("tt "..tt)
				ability:ApplyDataDrivenModifier(caster, target,"modifier_B02R",{duration=tt})
			end
			return 0.1
		end
		end)
end

function B02R_hit(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	if not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B02R_3",nil)
	end
	local dmg = ability:GetLevelSpecialValueFor("dmg",level)
	print("dmg "..dmg)
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
end

function B02R_MOVE(keys)
	--【Basic】
	local dummy = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	--local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--【MOVE】
	dummy.b02r_D = dummy.b02r_D + 20
	local tem_P =Vector( point2.x + 420*math.cos(dummy.b02r_D*3.14159/180.0) ,point2.y + 420*math.sin(dummy.b02r_D*3.14159/180.0),point2.z)
	dummy:SetAbsOrigin(tem_P)
	--【PROJECTILE】
	local info = {
		Target = target,
		Source = dummy,
		Ability = ability,
		EffectName = "particles/b02r4/b02r4.vpcf",
		bDodgeable = false,
		bProvidesVision = true,
		iMoveSpeed = 1000,
        iVisionRadius = 10,
        iVisionTeamNumber = dummy:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )	
	-- Play the sound on Bristleback.
	EmitSoundOn("Hero_BountyHunter.Shuriken.Impact", target)	
end

function B02T(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = caster:GetForwardVector()
	--【Varible】
	local num = ability:GetLevelSpecialValueFor("cast_times",level)

	--【Temp】
	local distance = 100
	local tem_Deg = 0
	local tem_P = nil
	local height = 400
	--【Particle】
	local particle = ParticleManager:CreateParticle("particles/b02t2/b02t2_o.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0, point+Vector(0,0,75)+vec*50)

	particle = ParticleManager:CreateParticle("particles/b02t2/b02t2_n.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0, point+Vector(0,0,75)+vec*50)
	-- ParticleManager:SetParticleControl(particle,1, point2+Vector(0,0,400))
	-- ParticleManager:SetParticleControl(particle,2, point2+Vector(0,0,0))
	-- ParticleManager:SetParticleControl(particle,3, point2+Vector(0,0,0))	
	
	--【Timer】
	height = 125
	distance = 245
	local dmg = ability:GetLevelSpecialValueFor("dmg",level)
	Timers:CreateTimer(1,function() 
		if num == 0 or not target:IsAlive() then
			return nil
		else
			--【DMG】
			AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )				
			--【SOUND】
			-- EmitSoundOn("Hero_Leshrac.Lightning_Storm", target)
			-- EmitSoundOn("Hero_Leshrac.Lightning_Storm", caster)
			--【MOVE】
			tem_Deg = tem_Deg +RandomInt(25,75)
			point2 = target:GetAbsOrigin()
			for i=1,4 do
				tem_Deg = tem_Deg + 90 
				tem_P = Vector( point2.x + distance*math.cos(tem_Deg*3.14159/180.0) ,point2.y + distance*math.sin(tem_Deg*3.14159/180.0),point2.z)
				--【Particle】
				local particle = ParticleManager:CreateParticle("particles/b02t2/b02t2.vpcf",PATTACH_POINT,target)
				ParticleManager:SetParticleControl(particle,0, tem_P+Vector(0,0,height))
				ParticleManager:SetParticleControl(particle,1, point2+Vector(0,0,75))
				ParticleManager:SetParticleControl(particle,2, point2+Vector(0,0,0))
				ParticleManager:SetParticleControl(particle,3, point2+Vector(0,0,0))
			end
			--【MODIFIER】
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B02T",nil)--暈眩			
			num = num - 1
			return 1
		end
	end)	
end

function B02E(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = caster:GetForwardVector()
	--【Varible】
	local life = ability:GetLevelSpecialValueFor("duration",level)	
	-- --【Particle】
	-- local particle = ParticleManager:CreateParticle("particles/b02e2/b02e2.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point)	
	-- ParticleManager:SetParticleControl(particle,11, Vector(1,0,0))
	-- --【Timer】
	-- -- height = 125
	-- -- distance = 245
	-- -- local dmg = ability:GetLevelSpecialValueFor("dmg",level)
	-- -- local duration = 0.05
	-- -- local num = 300
	-- -- Timers:CreateTimer(duration,function()
	-- -- 	if num == 0 then
	-- -- 		print("end")
	-- -- 		ParticleManager:DestroyParticle(particle,false)
	-- -- 		return nil
	-- -- 	else
	-- -- 		print(num)
	-- -- 		point = caster:GetAbsOrigin()
	-- -- 		ParticleManager:SetParticleControl(particle,0, point)
	-- -- 		num = num - 1 
	-- -- 		return duration
	-- -- 	end
	-- -- end)
	-- Timers:CreateTimer(20,function()
	-- 	ParticleManager:DestroyParticle(particle,false) --暫時補救方法
	-- end)	

	--【dummy】
	-- local dummy = CreateUnitByName("caster:GetUnitName()",point,false,caster,caster,caster:GetTeam())	--"npc_dummy_unit_Ver2"
	-- dummy:FindAbilityByName("majia"):SetLevel(1)

	--【Special】
	caster.B02E_particle = particle
	caster.B02E_Location = point
	caster.B02E_Table = nil
	caster.B02E_Table = {point}	
	caster.B02E_DUMMY = dummy
	--caster.B02E_Table = FindUnitsInRadius(caster:GetTeamNumber(), point , nil, 9999,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)

	-- local tem_table = {
	-- 	Duration = 20,
	-- 	Damage_Per_Second	=	1080,
	-- 	Radius		=		200,
	-- 	Tick_Interval		=	0.03
	-- }
	-- ability:ApplyDataDrivenModifier(caster,caster,"modifier_batrider_firefly",tem_table)
end

function B02E_Cast(keys)
	--【Basic】	
	local caster = keys.caster
	local point = caster:GetAbsOrigin()
	local ability = keys.ability
	--【Particle】	
	--ParticleManager:SetParticleControl(caster.B02E_particle,0, point)
	--print(nobu_distance( point,caster.B02E_Location ))
	if (nobu_distance( point,caster.B02E_Location )) > 100 then
		caster.B02E_Location = point
		local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point,false,caster,caster,caster:GetTeam())	--"npc_dummy_unit_Ver2"
		dummy:FindAbilityByName("majia"):SetLevel(1)
		--【MODIFIER】
		ability:ApplyDataDrivenModifier(caster,dummy,"modifier_B02E_2",nil) 	
		Timers:CreateTimer(10, function()
			if IsValidEntity(dummy) then
				dummy:ForceKill(true)
			end
			end)
	end
	

end

-- 11.2B
-------------------------------------------------

function B02W_old_first_hit( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	
	--【DMG】
	local dmg = ability:GetLevelSpecialValueFor("bonus_damage",level)
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )	
end

function B02E_old_fire_path_init( keys )
	--【Basic】
	local ability = keys.ability

	-- init
	ability.pre_position = Vector(0,0,9999)
	ability.fire_duration = ability:GetLevelSpecialValueFor("fire_duration",ability:GetLevel()-1)
end

function B02E_old_fire_path_creator( keys )
	--【Basic】	
	local caster = keys.caster
	local point = caster:GetAbsOrigin()
	local ability = keys.ability

	if (nobu_distance( point,ability.pre_position )) > 100 then
		ability.pre_position = point
		local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point,false,caster,caster,caster:GetTeam())	--"npc_dummy_unit_Ver2"
		dummy:FindAbilityByName("majia"):SetLevel(1)
		--【MODIFIER】
		ability:ApplyDataDrivenModifier(caster,dummy,"modifier_B02E_2",nil)
		Timers:CreateTimer(ability.fire_duration, function()
			dummy:Destroy()
		end)
	end
end

function B02T_old_init( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local first_hit_delay = ability:GetLevelSpecialValueFor("first_hit_delay",level)
	local view_duration = ability:GetLevelSpecialValueFor("view_duration",level)
	local wave_num = ability:GetLevelSpecialValueFor("wave_num",ability:GetLevel()-1)
	
	-- 延遲一段時間後打出4道閃電
	Timers:CreateTimer(first_hit_delay, function()
		if IsValidEntity(caster) and IsValidEntity(target) then
			B02T_old_fire_thunder( keys )
		end
	end)

	-- 紀錄粒子效果編號
	if ability.ball == nil then
		ability.ball = {}
	end
	ability.radius = 300

	-- 產生雷電球
	local angle_gap = 3.14159*2.0/wave_num
	local radius = ability.radius
	for i=1,wave_num do
		local angle = angle_gap*i
		local dx = math.cos(angle) * radius
		local dy = math.sin(angle) * radius
		local center = target:GetAbsOrigin()
		local start_pos = Vector(center.x+dx, center.y+dy, center.z+300) 
		local ifx = ParticleManager:CreateParticle("particles/b02/b02t_old_ball.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(ifx,0,start_pos)
		ParticleManager:SetParticleControlEnt(ifx,2,target,PATTACH_POINT,"attach_hitloc",target:GetAbsOrigin(),true)
		ability.ball[i] = ifx
		Timers:CreateTimer(view_duration, function() 
			ParticleManager:DestroyParticle(ifx,false)
		end)
	end
end

function B02T_old_think( keys )
	local caster = keys.caster
	local target = keys.target

	-- 持續提供視野
	AddFOWViewer(caster:GetTeamNumber(),target:GetAbsOrigin(),600,3.0,false)
end

function B02T_old_on_unit_move( keys )
	local target = keys.unit
	local ability = keys.ability
	local wave_num = ability:GetLevelSpecialValueFor("wave_num",ability:GetLevel()-1)

	-- 隨著目標持續移動特效
	local radius = ability.radius
	local angle_gap = 3.14159*2.0/wave_num
	for i=1,wave_num do
		local angle = angle_gap*i
		local dx = math.cos(angle) * radius
		local dy = math.sin(angle) * radius
		local center = target:GetAbsOrigin()
		local start_pos = Vector(center.x+dx, center.y+dy, center.z+300) 
		ParticleManager:SetParticleControl(ability.ball[i],0,start_pos)
	end
end

function B02T_old_fire_thunder( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", ability:GetLevel()-1)

	ability:ApplyDataDrivenModifier(caster,target,"modifier_B02T_old_stun",{})
	local wave_num = ability:GetLevelSpecialValueFor("wave_num",ability:GetLevel()-1)

	-- 稍微延遲分別打出閃電
	local angle_gap = 3.14159*2.0/wave_num
	for i=1,wave_num do
		Timers:CreateTimer(0.07*(i-1), function()
			if IsValidEntity(caster) and IsValidEntity(target) then
				local angle = angle_gap*i
				local dx = math.cos(angle) * ability.radius
				local dy = math.sin(angle) * ability.radius
				local center = target:GetAbsOrigin()
				local start_pos = Vector(center.x+dx, center.y+dy, center.z+300) 
				B02T_old_jump_init(keys, start_pos)

				ApplyDamage({victim = target, attacker = caster, damage = base_damage, damage_type = ability:GetAbilityDamageType()})
				ability:ApplyDataDrivenModifier(caster,target,"modifier_arc_lightning_datadriven",{})
			end
		end)
	end
	
end

--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Keeps track of all instances of the spell (since more than one can be active at once)]]
function B02T_old_jump_init(keys, start_pos)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
		ability.first_target = {}
	else
		ability.instance = ability.instance + 1
	end

	local angel = caster:GetAngles().y
	local point = Vector(caster:GetAbsOrigin().x+75*math.cos(angel*bj_DEGTORAD) ,  caster:GetAbsOrigin().y+75*math.sin(angel*bj_DEGTORAD), caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z)
	
	ability.jump_count[ability.instance] = ability:GetLevelSpecialValueFor("jump_max", (ability:GetLevel() -1))
	ability.target[ability.instance] = target
	ability.first_target[ability.instance] = target
	
	-- Creates the particle between the caster and the first target
	local lightningBolt = ParticleManager:CreateParticle("particles/b02/b02t_old_link.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(lightningBolt,0,start_pos)
	ParticleManager:SetParticleControlEnt(lightningBolt,1,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetOrigin(),true)
end

--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Finds the next unit to jump to and deals the damage]]
function B02T_old_Jump(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_delay = ability:GetLevelSpecialValueFor("jump_delay", (ability:GetLevel() -1))
	local jump_radius = ability:GetLevelSpecialValueFor("jump_radius", (ability:GetLevel() -1))
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", (ability:GetLevel() -1))
	local bonus_damage = ability:GetLevelSpecialValueFor("bonus_damage", (ability:GetLevel() -1))
	local jump_max = ability:GetLevelSpecialValueFor("jump_max", (ability:GetLevel() -1))
	local team = ability:GetAbilityTargetTeam()

	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_arc_lightning_datadriven")
	local count = 0
	-- Waits on the jump delay

	Timers:CreateTimer(jump_delay,
	function()
	-- Finds the current instance of the ability by ensuring both current targets are the same
	local current
	for i=0,ability.instance do
		if IsValidEntity(ability.target[i]) then
			if ability.target[i] == target then
				current = i
			end
		end
	end

	-- Adds a global array to the target, so we can check later if it has already been hit in this instance
	if target.hit == nil then
		target.hit = {}
	end
	-- Sets it to true for this instance
	target.hit[current] = true

	-- Decrements our jump count for this instance
	ability.jump_count[current] = ability.jump_count[current] - 1

	-- Checks if there are jumps left
	if ability.jump_count[current] > 0 then
		-- Finds units in the jump_radius to jump to
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, jump_radius, team, ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		local closest = jump_radius
		local new_target
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = target:GetAbsOrigin() - unit_location
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
			AddFOWViewer(caster:GetTeamNumber(),new_target:GetAbsOrigin(),300,2.0,false)
			-- Creates the particle between the new target and the last target
			local lightningBolt = ParticleManager:CreateParticle("particles/b02/b02t_old_link.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(lightningBolt,0,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetOrigin(),true)
			ParticleManager:SetParticleControlEnt(lightningBolt,1,new_target,PATTACH_POINT_FOLLOW,"attach_hitloc",new_target:GetOrigin(),true)
			-- Sets the new target as the current target for this instance
			ability.target[current] = new_target
			-- Applies the modifer to the new target, which runs this function on it
			ability:ApplyDataDrivenModifier(caster, new_target, "modifier_arc_lightning_datadriven", {})
			-- Applies damage to the target
			local new_damage = base_damage*(1+(jump_max-ability.jump_count[current])*bonus_damage)
			ApplyDamage({victim = new_target, attacker = caster, damage = new_damage, damage_type = ability:GetAbilityDamageType()})
		else
			-- If there are no new targets, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil

			-- 製造最後一次傷害
			new_target = ability.first_target[current]
			if IsValidEntity(new_target) and new_target:IsAlive() and (ability.jump_count[current]<jump_max-1) then
				--【Particle】
				local particle = ParticleManager:CreateParticle("particles/b02/b02t_old_final.vpcf",PATTACH_POINT,target)
				ParticleManager:SetParticleControlEnt(particle,0,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetOrigin(),true)
				ParticleManager:SetParticleControlEnt(particle,1,new_target,PATTACH_POINT_FOLLOW,"attach_hitloc",new_target:GetOrigin(),true)

				-- Applies damage to the target
				local new_damage = base_damage*(1+(jump_max-ability.jump_count[current])*bonus_damage)
				ApplyDamage({victim = new_target, attacker = caster, damage = new_damage, damage_type = ability:GetAbilityDamageType()})
			end
		end
	else
		-- If there are no more jumps, we set the current target to nil to indicate this instance is over
		ability.target[current] = nil

		-- 製造最後一次傷害
		new_target = ability.first_target[current]
		if IsValidEntity(new_target) and new_target:IsAlive() then
			--【Particle】
			local particle = ParticleManager:CreateParticle("particles/b02/b02t_old_final.vpcf",PATTACH_POINT,target)
			ParticleManager:SetParticleControlEnt(particle,0,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetOrigin(),true)
			ParticleManager:SetParticleControlEnt(particle,1,new_target,PATTACH_POINT_FOLLOW,"attach_hitloc",new_target:GetOrigin(),true)

			-- Applies damage to the target
			local new_damage = base_damage*(1+(jump_max-ability.jump_count[current])*bonus_damage)
			ApplyDamage({victim = new_target, attacker = caster, damage = new_damage, damage_type = ability:GetAbilityDamageType()})
		end
	end
	end)
end

function B02T_old(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,target,"modifier_B02T_old",nil)
end