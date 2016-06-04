	bj_PI                            = 3.14159
	bj_RADTODEG                      = 180.0/bj_PI
	bj_DEGTORAD                      = bj_PI/180.0


function B24T( keys )
	print("B24T")
	--DeepPrintTable(keys)
	local caster		= keys.caster
	local ability	= keys.ability
	local point = caster:GetAbsOrigin() --ability:GetCursorPosition()
	local pointx = point.x
	local pointy = point.y
	local pointz = point.z
	local team  = caster:GetTeamNumber()
	local pointx2
	local pointy2
	local a

	--se
	local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0,point)

	local particle=ParticleManager:CreateParticle("particles/b24t/b01t.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0,point)	

	local particle=ParticleManager:CreateParticle("particles/b24t3/b24t3.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0,point)		

	--獲取攻擊範圍
    local group = {}

   	group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 800, 3, 63, 80, 0, false)

	--group = FindUnitsInRadius(caster:GetTeamNumber(),point,nil,radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)

	-- print(caster:GetTeamNumber())
	-- print(ability:GetAbilityTargetTeam())
	-- print(ability:GetAbilityTargetType())
	-- print(ability:GetAbilityTargetFlags())
    --獲取周圍的單位
	-- group = FindUnitsInRadius(caster:GetTeamNumber(),
 --                              point,
 --                              nil,
 --                              600,
 --                              DOTA_UNIT_TARGET_TEAM_BOTH,
 --                              DOTA_UNIT_TARGET_HERO | DOTA_UNIT_TARGET_BASIC | DOTA_UNIT_TARGET_ALL | DOTA_UNIT_TARGET_COURIER | DOTA_UNIT_TARGET_CREEP,
 --                              DOTA_UNIT_TARGET_FLAG_INVULNERABLE | DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
 --                              FIND_ANY_ORDER,
 --                              false)


	for _,v in ipairs(group) do
		v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	end



	for i=1,16 do
		a	=	(	22.5	*	i	)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	420.00 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	420.00 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)

		local particle=ParticleManager:CreateParticle("particles/b24w/b24w.vpcf",PATTACH_POINT,caster)
		ParticleManager:SetParticleControl(particle,0,point)
		ParticleManager:SetParticleControl(particle,1,point)
		ParticleManager:SetParticleControl(particle,2,Vector(6,6,6))

		local dummy = CreateUnitByName("B24T_HIDE",point,true,nil,nil,team)
		ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_B24T",nil)
		dummy:SetOrigin(point)--不加會卡點
		
		--紀錄
		dummy.B24Tparticle = particle

		dummy:EmitSound("Creep_Siege_Dire.Destruction") 


		-- local dummy = CreateUnitByName("B24T_HIDE",point,true,nil,nil,team)
		-- dummy:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	end


	-- for i=1,48 do
	-- 	a	=	(	7.5	*	i	)* bj_DEGTORAD
	-- 	pointx2 	=  	pointx 	+ 	420.00 	* 	math.cos(a)
	-- 	pointy2 	=  	pointy 	+ 	420.00 	*	math.sin(a)
	-- 	point = Vector(pointx2 ,pointy2 , pointz)

	-- 	local particle=ParticleManager:CreateParticle("particles/b24w/b24w.vpcf",PATTACH_POINT,caster)
	-- 	ParticleManager:SetParticleControl(particle,0,point)
	-- 	ParticleManager:SetParticleControl(particle,1,point)
	-- 	ParticleManager:SetParticleControl(particle,2,Vector(6,6,6))

	-- 	local dummy = CreateUnitByName("B24T_HIDE",point,true,nil,nil,DOTA_TEAM_BADGUYS)
	-- 	dummy:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})

	-- 	ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_B24T",nil)
		
	-- 	--紀錄
	-- 	dummy.B24Tparticle = particle


	-- 	-- local dummy = CreateUnitByName("B24T_HIDE",point,true,nil,nil,team)
	-- 	-- dummy:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	-- end
end


function B24T2_Death( keys )
	local dummy	= keys.caster
	ParticleManager:DestroyParticle(dummy.B24Tparticle,false)
end

function B24T2_Kill( keys )
	local dummy	= keys.caster
	dummy:ForceKill(true)
end

--bug = T再使用W 會把敵人彈出外圍
function B24W( keys )
	local caster = keys.caster
	local dummy	= keys.target
	local point = dummy:GetAbsOrigin()
	local ability = keys.ability

	caster.B24WUNIT = dummy

	--紀錄次數
	dummy.B24W_NUM = ability:GetLevelSpecialValueFor("time",ability:GetLevel()-1)

	--一定要放紀錄次數下面
	ability:ApplyDataDrivenModifier(dummy, dummy,"modifier_B24W",nil)

	print(tostring(dummy.B24W_NUM))

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
	local dummy = keys.caster
	local ability = keys.ability

	print(tostring(dummy.B24W_NUM))
	print(dummy:GetUnitName())
	
	dummy.B24W_NUM = dummy.B24W_NUM - 1
	if dummy.B24W_NUM == 0 then
		dummy:RemoveModifierByName("modifier_B24W")
	end
end

--[[Author: Pizzalol
	Date: 09.02.2015.
	Forces the target to attack the caster]]
function B24E( keys )
	local caster = keys.caster
	local target = keys.target

	-- Clear the force attack target
	target:SetForceAttackTarget(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
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
function BerserkersCallEnd( keys )
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

		-- local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche_projectile.vpcf",PATTACH_POINT,target)
		-- ParticleManager:SetParticleControl(particle,0,point)
		-- ParticleManager:SetParticleControl(particle,1,point2)

		-- local projectile_info = 
		-- {
		-- 	EffectName = "particles/units/heroes/hero_tiny/tiny_avalanche_projectile.vpcf",
		-- 	Ability = ability,
		-- 	vSpawnOrigin = point,
		-- 	Target = target,
		-- 	Source = caster,
		-- 	bHasFrontalCone = false,
		-- 	iMoveSpeed = 1000,
		-- 	bReplaceExisting = false,
		-- 	bProvidesVision = false
		-- }
		-- ProjectileManager:CreateTrackingProjectile(projectile_info)

		-- local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",PATTACH_POINT,caster)
		-- ParticleManager:SetParticleControl(particle,1,Vector(100,100,100))


		local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",PATTACH_POINT,caster)
		ParticleManager:SetParticleControl(particle,0,point)
		ParticleManager:SetParticleControl(particle,1,Vector(100,100,100))

		Timers:CreateTimer(0.0,function ()
			if not target:IsAlive() then
				ParticleManager:DestroyParticle(particle,false)
				return nil
			end

			x1 = x1 + distance * math.cos(RAD) 
			y1 = y1 + distance * math.sin(RAD)
			point = Vector(x1,y1,z1)
			point2 = target:GetAbsOrigin()

			ParticleManager:SetParticleControl(particle,0,point)

			local distance = nobu_distance( point,point2 )
			if distance <100 then
				ParticleManager:DestroyParticle(particle,false)

				particle=ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",PATTACH_POINT,target)
				ParticleManager:SetParticleControl(particle,0,point)
				ParticleManager:SetParticleControl(particle,1,Vector(100,100,100))	

				Timers:CreateTimer(0.3,function ()
					ParticleManager:DestroyParticle(particle,false)	
				end)	

				--effect
				--獲取攻擊範圍
			    local group = {}
		        local radius = 225

		        --獲取周圍的單位
		        group = FindUnitsInRadius(caster:GetTeamNumber(),point2,nil,radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		        for i,v in ipairs(group) do
		        	print(i,v)
		        	ability:ApplyDataDrivenModifier(caster,v,"modifier_B24R_2",nil)
		        end

				return nil
			else
				--print(tostring(distance))
				return 0.03
			end

		end)
	end
end

function B24R2( keys )
	local caster = keys.target
	local point2 = target:GetAbsOrigin()

	local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0,point2)
	ParticleManager:SetParticleControl(particle,1,Vector(100,100,100))
end

