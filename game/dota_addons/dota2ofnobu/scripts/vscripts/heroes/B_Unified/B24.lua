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
	local radius = 600
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
		if v:IsHero() then
			ParticleManager:CreateParticle("particles/shake2.vpcf", PATTACH_ABSORIGIN, v)
		end
		if _G.EXCLUDE_TARGET_NAME[v:GetUnitName()] == nil then
			v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
		end
	end

	group = FindUnitsInRadius(
   		caster:GetTeamNumber(), 
   		caster:GetAbsOrigin(), 
   		nil, 
   		radius ,
   		DOTA_UNIT_TARGET_TEAM_ENEMY, 
   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
   		0, 
   		FIND_ANY_ORDER, 
   		false)
	for _,v in ipairs(group) do
		ability:ApplyDataDrivenModifier(caster, v,"modifier_B24T_2",{duration=100})
	end


	--【For】
	local pointx = point.x
	local pointy = point.y
	local pointz = point.z
	local pointx2
	local pointy2
	local a	
	local maxrock = 20
	for i=1,maxrock do
		a	=	(	(360.0/maxrock)	*	i	)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	420 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	420 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)

		local dummy = CreateUnitByName("B24T_HIDE_hero",point,false,nil,nil,caster:GetTeam())
		dummy:RemoveModifierByName("modifier_invulnerable")
		ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_kill",{duration = 6})
		ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_B24T",nil)
		Timers:CreateTimer(0.2, function()
			local particle=ParticleManager:CreateParticle("particles/b24w/b24w.vpcf",PATTACH_POINT,caster)
			ParticleManager:SetParticleControl(particle,0,dummy:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle,1,dummy:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle,2,Vector(6,6,6))
			dummy.B24Tparticle = particle
		end)
	end
end

function B24T2_Death( keys )
	local dummy	= keys.caster
	ParticleManager:DestroyParticle(dummy.B24Tparticle,false)
end

function B24T2_Kill( keys )
	local dummy	= keys.caster
	if IsValidEntity(dummy) then
		dummy:ForceKill(true)
	end
end

function B24W( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local mouse = ability:GetCursorPosition()
	local dummy	= CreateUnitByName("B24W_dummy_hero", mouse, true, nil, nil, caster:GetTeamNumber())
	dummy:RemoveModifierByName("modifier_invulnerable")
	dummy:SetOwner(caster)
	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_kill",{duration=12})
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = dummy:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()	

	caster.B24WUNIT = dummy --擊退次數完 刪除單位用
	dummy:SetHealth(dummy:GetMaxHealth())
	--紀錄次數
	dummy.B24W_NUM = ability:GetLevelSpecialValueFor("times",ability:GetLevel()-1)

	dummy:SetBaseMaxHealth(800+level*400)
	dummy:SetHealth(dummy:GetMaxHealth())
	--一定要放紀錄次數下面
	ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_B24W",nil)


	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	          dummy:GetAbsOrigin(),
	          nil,
	          250,
	          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	          DOTA_UNIT_TARGET_HERO,
	          DOTA_UNIT_TARGET_FLAG_NONE,
	          0,
	          false)
	for _,target in pairs(direUnits) do
		target:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	end
	local count = 0
	Timers:CreateTimer(function ()
		local SEARCH_RADIUS = 250
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	          dummy:GetAbsOrigin(),
	          nil,
	          SEARCH_RADIUS,
	          DOTA_UNIT_TARGET_TEAM_ENEMY,
	          DOTA_UNIT_TARGET_HERO,
	          0,
	          0,
	          false)

		
		local hasenemy = false
		for _,target in pairs(direUnits) do
			if not target:IsBuilding() then
				Physics:Unit(target)
				target:SetPhysicsVelocity((target:GetAbsOrigin() - dummy:GetAbsOrigin()):Normalized()*1000)
				AMHC:Damage( caster,target,ability:GetLevelSpecialValueFor("Damage",ability:GetLevel()-1),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				target:AddNewModifier(caster,ability,"modifier_stunned",{duration=0.1})
				local wcount = 0
				Timers:CreateTimer(0.1, function()
					if IsValidEntity(target) then
						local its = FindUnitsInRadius(caster:GetTeamNumber(),
							target:GetAbsOrigin(),
							nil,
							100,
							DOTA_UNIT_TARGET_TEAM_FRIENDLY,
							DOTA_UNIT_TARGET_BUILDING,
							DOTA_UNIT_TARGET_FLAG_NONE,
							FIND_ANY_ORDER,
							false)
						for _,it in pairs(its) do
							target:SetPhysicsVelocity((dummy:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()*(1000 - wcount*150))
							return nil
						end
						wcount = wcount + 1
						if (wcount > 5) then
							return nil
						else
							return 0.1
						end
					end
					end)
				
				hasenemy = true
			end
		end
		if hasenemy then
			dummy.B24W_NUM = dummy.B24W_NUM - 1
		end

		if (dummy:IsAlive() and dummy.B24W_NUM > 0) then
			return 0.3
		else
			if dummy:IsAlive() then
				dummy:ForceKill(false)
			end
			return nil
		end
	end)
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
	local duration = ability:GetLevelSpecialValueFor("duration",ability:GetLevel() - 1)
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
	Timers:CreateTimer(0.1, function ()
		if IsValidEntity(caster) and caster:IsAlive() then
			for _,v in ipairs(group) do
				if IsValidEntity(v) and v:IsAlive() and v:HasModifier("modifier_B24E") then
					hasv = true
					-- Clear the force attack target
					v:SetForceAttackTarget(nil)
					local order = 
					{
						UnitIndex = v:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
						TargetIndex = caster:entindex()
					}

					ExecuteOrderFromTable(order)
					-- Set the force attack target to be the caster
					v:SetForceAttackTarget(caster)
				else
					if IsValidEntity(v) then
						v:SetForceAttackTarget(nil)
						v:Stop()
					end
				end
			end
		end
		end)
	Timers:CreateTimer(duration+0.1, function ()
			for _,v in ipairs(group) do
				if IsValidEntity(v) then
					v:SetForceAttackTarget(nil)
					v:Stop()
				end
			end
		end)
end

function B24E( keys )
	local caster = keys.caster
	local target = keys.target

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
	--【ExecuteOrder】
	if IsValidEntity(caster) and caster:IsAlive() then
		-- Clear the force attack target
		target:SetForceAttackTarget(nil)
		local order = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
		-- Set the force attack target to be the caster
		target:SetForceAttackTarget(caster)
	else
		target:RemoveModifierByName("modifier_B24E")
	end

	
end

-- Clears the force attack target upon expiration
function B24E_END( keys )
	local target = keys.target
	target:SetForceAttackTarget(nil)
	target:Stop()
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
	if target:IsBuilding() then
		return
	end
	local damage = ability:GetLevelSpecialValueFor("damage",ability:GetLevel() - 1)
	local damage2 = ability:GetLevelSpecialValueFor("damage2",ability:GetLevel() - 1)
	--INIT
	if caster.B24R_B == nil then
		caster.B24R_B = false
	end 

	if caster.B24R_B == false then
		caster.B24R_B = true

		--animation
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,3)

		--使用間隔
		Timers:CreateTimer(0.3,function ()
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
				if IsValidEntity(caster) then
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
						if IsValidEntity(v) then
							AMHC:Damage( caster,v,damage2,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
						end
						if IsValidEntity(v) and not v:IsMagicImmune() then
							AMHC:Damage( caster,v,damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
							ability:ApplyDataDrivenModifier(caster,v,"modifier_B24R_2",nil)
						end
					end
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


