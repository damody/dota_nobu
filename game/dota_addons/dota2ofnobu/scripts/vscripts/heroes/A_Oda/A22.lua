
function A22W_OnDestroy( keys )
	local caster = keys.caster
	print("A22W_OnDestroy")
	caster:StopSound("Hero_Juggernaut.BladeFuryStart")
end


function A22W_OnSpellStart( keys )
	local caster = keys.caster
	Timers:CreateTimer(0,function()
		caster:StartGestureWithPlaybackRate(ACT_DOTA_SPAWN,2)
		if caster:HasModifier("modifier_A22W") then
			return 0.3
		end
		end)
end


function A22E_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		target:GetAbsOrigin(),							-- 搜尋的中心點
		nil,
		300,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		ability:ApplyDataDrivenModifier( caster, unit, "modifier_A22E_debuff", {} )
		AMHC:Damage(caster,unit, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end

function A22R_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local regen = ability:GetSpecialValueFor("regen")
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  900 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for _,enemy in ipairs(group) do
		if enemy:IsMagicImmune() then
			ability:ApplyDataDrivenModifier(caster,enemy,"modifier_A22R",{duration = 1})
		end
		AMHC:Damage(caster,enemy, regen * enemy:GetMaxHealth()*0.01,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
end

function A22T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration",level)

	ability:ApplyDataDrivenModifier(caster,target,"modifier_A22T",{duration = duration})
	local tsum = 0
	Timers:CreateTimer(0.1, function()
		if target:IsHero() then
			if not target:HasModifier("modifier_A22T") then
				ability:ApplyDataDrivenModifier(caster,target,"modifier_A22T",{duration = duration-tsum})
			end
		end
		tsum = tsum + 0.1
		if tsum < duration then
			return 0.1
		end
		end)
end


-- 仙石秀久 11.2B


function A22D_old_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability

	--【Group_radius】
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	--local radius = 800
   	local group = FindUnitsInRadius(
   		caster:GetTeamNumber(), 
   		caster:GetAbsOrigin(), 
   		nil, 
   		radius ,
   		DOTA_UNIT_TARGET_TEAM_ENEMY, --DOTA_UNIT_TARGET_TEAM_ENEMY --DOTA_UNIT_TARGET_TEAM_FRIENDLY
   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  --DOTA_UNIT_TARGET_BUILDING --DOTA_UNIT_TARGET_ALL
   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
   		FIND_ANY_ORDER,  --FIND_CLOSEST --FIND_FARTHEST --FIND_UNITS_EVERYWHERE
   		false)
	for _,v in ipairs(group) do
		v:SetForceAttackTarget(nil)
		local order = 
		{
			UnitIndex = v:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
		v:SetForceAttackTarget(caster)
		ability:ApplyDataDrivenModifier(caster,v,"modifier_A22D_old",nil)
	end
	Timers:CreateTimer(duration, function ()
			for _,v in ipairs(group) do
				if IsValidEntity(v) then
					v:SetForceAttackTarget(nil)
				end
			end
		end)
end



function A22W_old_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = keys.target_points[1]
	local vec = (point2-point):Normalized()
	local pointx = vec.x
	local pointy = vec.y
	local cs1	=	math.cos(30* bj_DEGTORAD)
	local sn1	=	math.sin(30* bj_DEGTORAD)
	local cs2	=	math.cos(-30* bj_DEGTORAD)
	local sn2	=	math.sin(-30* bj_DEGTORAD)
	
	local pointx1 	=  pointx * cs1 - pointy * sn1
	local pointy1 	=  pointx * sn1 + pointy * cs1
	local pointx2 	=  pointx * cs2 - pointy * sn2
	local pointy2 	=  pointx * sn2 + pointy * cs2
		
	local vec1 = Vector(pointx1 ,pointy1 , 0)
	local vec2 = Vector(pointx2 ,pointy2 , 0)

	local projectileTable =
		{
			EffectName = "particles/a22/a22wold.vpcf",
			Ability = ability,
			vSpawnOrigin = caster:GetAbsOrigin(),
			vVelocity = vec * 2000,
			fDistance = 800,
			fStartRadius = 175,
			fEndRadius = 175,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
	ProjectileManager:CreateLinearProjectile(projectileTable)
	projectileTable.vVelocity = vec1 * 2000
	ProjectileManager:CreateLinearProjectile(projectileTable)
	projectileTable.vVelocity = vec2 * 2000
	ProjectileManager:CreateLinearProjectile(projectileTable)
end


function A22E_old_OnAttacked( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability

	--【Group_radius】
	local radius = ability:GetSpecialValueFor("radius")
	--local radius = 800
   	local group = FindUnitsInRadius(
   		caster:GetTeamNumber(), 
   		caster:GetAbsOrigin(), 
   		nil, 
   		radius ,
   		DOTA_UNIT_TARGET_TEAM_ENEMY, --DOTA_UNIT_TARGET_TEAM_ENEMY --DOTA_UNIT_TARGET_TEAM_FRIENDLY
   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  --DOTA_UNIT_TARGET_BUILDING --DOTA_UNIT_TARGET_ALL
   		0, 
   		FIND_ANY_ORDER,  --FIND_CLOSEST --FIND_FARTHEST --FIND_UNITS_EVERYWHERE
   		false)
   	caster:StartGestureWithPlaybackRate(ACT_DOTA_SPAWN,2)
	for _,unit in ipairs(group) do
		AMHC:Damage(caster,unit, ability:GetAbilityDamage(), AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end


function A22E_old_OnAttacked2( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability

	--【Group_radius】
	local radius = ability:GetSpecialValueFor("radius")
	--local radius = 800
   	local group = FindUnitsInRadius(
   		caster:GetTeamNumber(), 
   		caster:GetAbsOrigin(), 
   		nil, 
   		radius ,
   		DOTA_UNIT_TARGET_TEAM_ENEMY, --DOTA_UNIT_TARGET_TEAM_ENEMY --DOTA_UNIT_TARGET_TEAM_FRIENDLY
   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  --DOTA_UNIT_TARGET_BUILDING --DOTA_UNIT_TARGET_ALL
   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
   		FIND_ANY_ORDER,  --FIND_CLOSEST --FIND_FARTHEST --FIND_UNITS_EVERYWHERE
   		false)
   	caster:StartGestureWithPlaybackRate(ACT_DOTA_SPAWN,2)
	for _,unit in ipairs(group) do
		if unit:IsMagicImmune() then
			AMHC:Damage(caster,unit, ability:GetAbilityDamage()*0.5, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		else
			AMHC:Damage(caster,unit, ability:GetAbilityDamage(), AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end
end


function A22R_old_OnAttackStart( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability

	local rnd = RandomInt(1, 100)
	if caster.A22R_old == nil then
		caster.A22R_old = 0
	end
	caster.A22R_old = caster.A22R_old + 1
	caster:RemoveModifierByName("modifier_A22R_old_critical_strike2")
	if rnd <= 20 or caster.A22R_old > 5 then
		caster.A22R_old = 0
		local rate = caster:GetAttackSpeed()+0.1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A22R_old_critical_strike2",{duration=rate})
		if rate < 1 then
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
		else
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end
	end
end

function process_A22T_old(caster, unit, ability, knockbackProperties)
	
	if unit.a22t == nil then
		unit.a22t = 0
	end	
	if unit.a22told == nil and unit.a22t < 8 then
		unit.a22t = unit.a22t + 1
		AMHC:Damage(caster,unit, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		if unit:HasModifier("modifier_knockback") then
			unit:RemoveModifierByName("modifier_knockback")
		end
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_knockback",knockbackProperties)
		Timers:CreateTimer(12,function()
			unit.a22t = nil
			end)
		unit.a22told = true
	end
end


function A22T_old_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local tduration = ability:GetSpecialValueFor("duration")
	local point = caster:GetAbsOrigin()
	local point2 = keys.target_points[1]
	local vec = (point2-point):Normalized()
	local pointx = vec.x
	local pointy = vec.y
	local cs1	=	math.cos(90* bj_DEGTORAD)
	local sn1	=	math.sin(90* bj_DEGTORAD)
	local cs2	=	math.cos(-90* bj_DEGTORAD)
	local sn2	=	math.sin(-90* bj_DEGTORAD)
	
	local pointx1 	=  pointx * cs1 - pointy * sn1
	local pointy1 	=  pointx * sn1 + pointy * cs1
	local pointx2 	=  pointx * cs2 - pointy * sn2
	local pointy2 	=  pointx * sn2 + pointy * cs2
		
	local vec1 = Vector(pointx1 ,pointy1 , 0)
	local vec2 = Vector(pointx2 ,pointy2 , 0)

	local dir = (point2-point):Normalized()
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point2 = center + dir
	end
	caster.center = point
	caster.dir = dir
	caster.point = point2

	local projectileTable =
		{
			EffectName = "particles/a22/a22told_2/b08t.vpcf",
			Ability = ability,
			vSpawnOrigin = caster:GetAbsOrigin(),
			vVelocity = vec * 500,
			fDistance = tduration * 500,
			fStartRadius = 175,
			fEndRadius = 175,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
	ProjectileManager:CreateLinearProjectile(projectileTable)
	projectileTable.vSpawnOrigin = caster:GetAbsOrigin() + vec1 * 200
	ProjectileManager:CreateLinearProjectile(projectileTable)
	projectileTable.vSpawnOrigin = caster:GetAbsOrigin() + vec1 * 400
	ProjectileManager:CreateLinearProjectile(projectileTable)
	projectileTable.vSpawnOrigin = caster:GetAbsOrigin() + vec2 * 200
	ProjectileManager:CreateLinearProjectile(projectileTable)
	projectileTable.vSpawnOrigin = caster:GetAbsOrigin() + vec2 * 400
	ProjectileManager:CreateLinearProjectile(projectileTable)

	local robon = CreateUnitByName("A22T_old_UNIT",caster:GetAbsOrigin(),false,nil,nil,caster:GetTeamNumber())

	robon:SetOwner(caster)
	robon:FindAbilityByName("majia_vison"):SetLevel(1)
	robon:AddNoDraw()

	local rp = robon:GetAbsOrigin()
	rp.z = rp.z + 300
	robon:SetAbsOrigin(rp)
	local speed = 500

	robon:SetForwardVector(dir)
	local fake_center = point - dir
	local distance = tduration * 500
	local duration = distance/speed
	-- 把自己踢過去
	local knockbackProperties = {
	    center_x = fake_center.x,
	    center_y = fake_center.y,
	    center_z = fake_center.z,
	    duration = duration,
	    knockback_duration = duration,
	    knockback_distance = distance,
	    knockback_height = 0,
	    should_stun = 0,
	}
	ability:ApplyDataDrivenModifier(robon,robon,"modifier_knockback",knockbackProperties)
	distance = 250
	knockbackProperties.knockback_distance = distance
	duration = distance/speed
	knockbackProperties.knockback_duration = duration
	knockbackProperties.duration = duration

	Timers:CreateTimer(0,function()
		if IsValidEntity(robon) and robon:IsAlive() then
			local pos = robon:GetAbsOrigin()
			pos = pos + dir * 100
			-- 搜尋
			local units1 = FindUnitsInRadius(caster:GetTeamNumber(),	
				pos,nil,250,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		FIND_ANY_ORDER, 
				false) 
			local units2 = FindUnitsInRadius(caster:GetTeamNumber(),	
				pos+ vec1 * 200,nil,250,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		FIND_ANY_ORDER, 
				false) 		
			local units3 = FindUnitsInRadius(caster:GetTeamNumber(),	
				pos- vec1 * 200,nil,250,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		FIND_ANY_ORDER, 
				false)
			local units4 = FindUnitsInRadius(caster:GetTeamNumber(),	
				pos+ vec1 * 400,nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		FIND_ANY_ORDER, 
				false) 
			local units5 = FindUnitsInRadius(caster:GetTeamNumber(),	
				pos- vec1 * 400,nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		FIND_ANY_ORDER, 
				false) 
			-- 處理搜尋結果
			for _,unit in ipairs(units1) do
				process_A22T_old(caster,unit,ability, knockbackProperties)
			end
			for _,unit in ipairs(units2) do
				process_A22T_old(caster,unit,ability, knockbackProperties)
			end
			for _,unit in ipairs(units3) do
				process_A22T_old(caster,unit,ability, knockbackProperties)
			end
			for _,unit in ipairs(units4) do
				process_A22T_old(caster,unit,ability, knockbackProperties)
			end
			for _,unit in ipairs(units5) do
				process_A22T_old(caster,unit,ability, knockbackProperties)
			end
			for _,unit in ipairs(units1) do
				unit.a22told = nil
			end
			for _,unit in ipairs(units2) do
				unit.a22told = nil
			end
			for _,unit in ipairs(units3) do
				unit.a22told = nil
			end
			for _,unit in ipairs(units4) do
				unit.a22told = nil
			end
			for _,unit in ipairs(units5) do
				unit.a22told = nil
			end
			return 0.5
		end
	end)
	Timers:CreateTimer(tduration,function()
		robon:ForceKill(false)
		robon:Destroy()
	end)
end
