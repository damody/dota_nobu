function B24T( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	--local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()	

	--【Particle】
	local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0,point)

	local particle=ParticleManager:CreateParticle("particles/b24t/b01t.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0,point)	

	local particle=ParticleManager:CreateParticle("particles/b24t3/b24t3.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0,point)

	--【Group_radius】
	local radius = 800
   	local group = FindUnitsInRadius(
   		caster:GetTeamNumber(), 
   		caster:GetAbsOrigin(), 
   		nil, 
   		radius ,
   		DOTA_UNIT_TARGET_TEAM_BOTH, 
   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
   		FIND_ANY_ORDER, 
   		false)
	for _,v in ipairs(group) do
		v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.01})
		--print("nobu"..v:GetUnitName())
	end

	--【For】
	local pointx = point.x
	local pointy = point.y
	local pointz = point.z
	local pointx2
	local pointy2
	local a	
	for i=1,16 do
		a	=	(	22.5	*	i	)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	420.00 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	420.00 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)

		local particle=ParticleManager:CreateParticle("particles/b24w/b24w.vpcf",PATTACH_POINT,caster)
		ParticleManager:SetParticleControl(particle,0,point)
		ParticleManager:SetParticleControl(particle,1,point)
		ParticleManager:SetParticleControl(particle,2,Vector(6,6,6))

		local dummy = CreateUnitByName("B24T_HIDE",point,false,nil,nil,caster:GetTeam())
		ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_B24T",nil)
		--dummy:SetOrigin(point)--不加會卡點
		
		--紀錄
		dummy.B24Tparticle = particle

		--dummy:EmitSound("Creep_Siege_Dire.Destruction") 
	end
end

function B24T2_Death( keys )
	local dummy	= keys.caster
	ParticleManager:DestroyParticle(dummy.B24Tparticle,false)
end

function B24T2_Kill( keys )
	local dummy	= keys.caster
	dummy:ForceKill(true)
end

function B24W( keys )
	--【Basic】
	local caster = keys.caster
	local dummy	= keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = dummy:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()	

	caster.B24WUNIT = dummy --擊退次數完 刪除單位用

	--紀錄次數
	dummy.B24W_NUM = ability:GetLevelSpecialValueFor("time",ability:GetLevel()-1)

	--一定要放紀錄次數下面
	ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_B24W",nil)

	--【Group】
	local teams = DOTA_UNIT_TARGET_TEAM_BOTH
	local types =DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local group = FindUnitsInRadius(caster:GetTeam(),point2,nil, 500, teams, types, flags, FIND_CLOSEST, true)	
	for i,v in ipairs(group) do
		if v ~= dummy then
			----print("nobu"..v:GetUnitName())
			--FindClearSpaceForUnit(v,v:GetAbsOrigin(), true)
			v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
		end
	end		
end

function B24W2( keys )
	local caster = keys.caster
	local dummy = caster.B24WUNIT
	local ability = keys.ability
	local spell_point = ability:GetCursorPosition()
	local point = spell_point

	dummy:SetForwardVector(keys.caster:GetForwardVector())
	dummy:SetAbsOrigin(spell_point)

	local particle=ParticleManager:CreateParticle("particles/b24w/b24w.vpcf",PATTACH_POINT,dummy)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,1,point)
	ParticleManager:SetParticleControl(particle,2,Vector(12,12,12))

	--紀錄
	dummy.B24Tparticle = particle

	particle=ParticleManager:CreateParticle("particles/b24t/b01t.vpcf",PATTACH_POINT,dummy)
	ParticleManager:SetParticleControl(particle,0,point)	
end

function B24W3( keys )
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
	local check_boolean = false

	--【判斷有沒有卡牆】
	--判斷背後有沒有碰撞單位
	--【Group_Line】
	local vec = (point2 - point) :Normalized()
	local vStartPos = point2 + 50 * vec
	local vEndPos = point2 + 100 * vec
	local width = 50
	local group = FindUnitsInLine(
		target:GetTeam(), 
		vStartPos, 
		vEndPos, 
		target, 
		width, 
		DOTA_UNIT_TARGET_TEAM_BOTH, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
	-- Make the found units move to (0, 0, 0)
	for i,v in pairs(group) do
		if v ~= caster and v ~= target then
			if v:GetUnitName() == "B24T_HIDE" then
			   --print("nobu"..v:GetUnitName())
			   check_boolean = true
			   break
			end
		end
	end

	--【DEBUG】
	if nobu_debug then
		local start_point = vStartPos
		local end_point = vEndPos
		local radius = 50 --可以獲取單位碰撞面積
		DebugDrawLine(start_point, end_point, 0, 0, 255, true, 5)
		DebugDrawCircle(point, Vector(0,255,0), 100, 150, true, 5)
		DebugDrawCircle(start_point, Vector(255,0,0), 100, radius, true, 5)
		DebugDrawCircle(end_point, Vector(255,0,0), 100, radius, true, 5)
	end			

	if check_boolean == true then
		--print("nobu".."true")
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B24W_3",nil)	--原地擊退
	else
		--print("nobu".."false")
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B24W_2",nil)
	end
	
	--【判斷擊退次數】
	caster.B24W_NUM = caster.B24W_NUM - 1
	if caster.B24W_NUM == 0 then
		caster:RemoveModifierByName("modifier_B24W") --刪除modifier 就會殺死單位
	end
end

function B24E_START( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	--local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	local point2 = ability:GetCursorPosition()
	--local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()

	--【Group_radius】
	local radius = ability:GetLevelSpecialValueFor("radius",ability:GetLevel() - 1)
	--local radius = 800
   	local group = FindUnitsInRadius(
   		caster:GetTeamNumber(), 
   		point2, 
   		nil, 
   		radius ,
   		DOTA_UNIT_TARGET_TEAM_ENEMY, --DOTA_UNIT_TARGET_TEAM_ENEMY --DOTA_UNIT_TARGET_TEAM_FRIENDLY
   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  --DOTA_UNIT_TARGET_BUILDING --DOTA_UNIT_TARGET_ALL
   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
   		FIND_ANY_ORDER,  --FIND_CLOSEST --FIND_FARTHEST --FIND_UNITS_EVERYWHERE
   		false)
	for _,v in ipairs(group) do
		--v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.01})
		--print("nobu"..v:GetUnitName())
		ability:ApplyDataDrivenModifier(caster,v,"modifier_B24E",nil)
	end			
end

function B24E( keys )
	local caster = keys.caster
	local target = keys.target

	-- Clear the force attack target
	target:SetForceAttackTarget(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
	--【ExecuteOrder】
	if caster:IsAlive() then
		local order = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
	else
		target:Stop()
	end

	-- Set the force attack target to be the caster
	target:SetForceAttackTarget(caster)
end

-- Clears the force attack target upon expiration
function B24E_END( keys )
	local target = keys.target
	target:SetForceAttackTarget(nil)
end

function B24R( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.attacker 
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	local num = 100

	local RAD = nobu_atan2( point2,point )
	local x1 = point.x
	local y1 = point.y
	local z1 = point.z
	local distance = 40

	--INIT
	if caster.B24R_B == nil then
		caster.B24R_B = false
	end 

	if caster.B24R_B == false then
		caster.B24R_B = true

		--animation
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,3)

		--使用間隔
		Timers:CreateTimer(2.0,function ()
			caster.B24R_B = false
		end)

		--【particle】		
		local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",PATTACH_POINT,caster)
		ParticleManager:SetParticleControl(particle,0,point)
		ParticleManager:SetParticleControl(particle,1,Vector(100,100,100))

		--【Timer】
		Timers:CreateTimer(function ()
			if not target:IsAlive() then
				ParticleManager:DestroyParticle(particle,false)
				return nil
			end

			x1 = x1 + distance * math.cos(RAD) 
			y1 = y1 + distance * math.sin(RAD)
			point = Vector(x1,y1,z1)
			point2 = target:GetAbsOrigin()

			--【particle】
			ParticleManager:SetParticleControl(particle,0,point)

			local distance = nobu_distance( point,point2 )
			if distance <100 then
				--【particle】
				ParticleManager:DestroyParticle(particle,false)
				particle=ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",PATTACH_POINT,target)
				ParticleManager:SetParticleControl(particle,0,point)
				ParticleManager:SetParticleControl(particle,1,Vector(100,100,100))	
				Timers:CreateTimer(0.3,function() 
					ParticleManager:DestroyParticle(particle,false)	
				end)	

				--【Group_radius】
				local radius = 225
			   	local group = FindUnitsInRadius(
			   		caster:GetTeamNumber(), 
			   		point2, 
			   		nil, 
			   		radius ,
			   		DOTA_UNIT_TARGET_TEAM_ENEMY, 
			   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
			   		FIND_ANY_ORDER, 
			   		false)
				for _,v in ipairs(group) do
					ability:ApplyDataDrivenModifier(caster,v,"modifier_B24R_2",nil)
				end

				--【DEBUG】
				if nobu_debug then
					local start_point = point
					local end_point = point2
					--local radius = 50 --可以獲取單位碰撞面積
					--DebugDrawLine(start_point, end_point, 0, 0, 255, true, 5)
					DebugDrawCircle(start_point, Vector(0,0,255), 100, radius, true, 5)
					DebugDrawCircle(end_point, Vector(255,0,0), 100, radius, true, 5)
				end		

				return nil
			else
				------print(tostring(distance))
				return 0.03
			end

		end)
	end
end

