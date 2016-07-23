function C07W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point  = keys.caster:GetAbsOrigin()

	--se
end

function C07E( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point  = keys.caster:GetAbsOrigin()

	--se
	-- local particle = ParticleManager:CreateParticle( "particles/c07e3/c07e3.vpcf", PATTACH_POINT, caster )
	-- ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_attack1", target:GetAbsOrigin(), true)
	-- ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT, "attach_attack1", target:GetAbsOrigin(), true)

	--se2
	local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_razor/razor_static_link_beam.vpcf", PATTACH_POINT_FOLLOW, caster )
	-- ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+Vector(0,0,220))
	-- ParticleManager:SetParticleControl(particle,1,target:GetAbsOrigin()+Vector(0,0,220))
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin()+Vector(0,0,2202), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin()+Vector(0,0,2202), true)

	--
	caster.C07E_P = particle
end

function C07E_END( keys )
	ParticleManager:DestroyParticle(keys.caster.C07E_P,false)
end

function C07E_SE( keys )
	local caster = keys.caster
	local target = keys.target
	if not caster:HasModifier("modifier_C07D") then--避免動作問題
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,0.9)
	end
	--se
	local particle = ParticleManager:CreateParticle( "particles/c07e3/c07e3.vpcf", PATTACH_POINT, keys.target )
	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
	Timers:CreateTimer(0.5,function()
		ParticleManager:DestroyParticle(particle ,true)
	end)
	--se2
	local particle2 = ParticleManager:CreateParticle( "particles/c07e3/c07e3.vpcf", PATTACH_POINT, keys.caster )
	ParticleManager:SetParticleControlEnt(particle2, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle2, 1, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
	Timers:CreateTimer(0.5,function()
		ParticleManager:DestroyParticle(particle2 ,true)
	end)
end

function C07D( keys )
	--模組
	local caster = keys.caster
	local ability = keys.ability
	caster.C07D_B = true
	caster:RemoveGesture(ACT_DOTA_ATTACK)
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,5508)--99 --120 --250G
	Timers:CreateTimer(0.05,function()
		if caster:HasModifier("modifier_C07D") then --等等添加
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_C07D_2",nil)
		end
	end)
end

function C07D_ATTACK( keys )
	local caster = keys.caster
	local rate = caster:GetAttackSpeed()
	caster:RemoveModifierByName("modifier_C07D_2")
	caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,rate)
	Timers:CreateTimer(rate/3,function()
		C07D( keys )
	end)
end

function C07R( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	local vec   = (point2 - point):Normalized()

	local level = ability:GetLevel() - 1
	local radius = ability:GetLevelSpecialValueFor("radius",level)
	local target_count = ability:GetLevelSpecialValueFor("target_count",level)
    local group = FindUnitsInRadius(caster:GetTeam(), point2, nil, radius , ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for i,v in ipairs(group) do
		if i > target_count then
			break
		else
			local lightningBolt = ParticleManager:CreateParticle("particles/c07r/c07r.vpcf", PATTACH_WORLDORIGIN, caster)
			ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ) + vec * 101 )
			ParticleManager:SetParticleControl(lightningBolt,1,Vector(v:GetAbsOrigin().x,v:GetAbsOrigin().y,v:GetAbsOrigin().z + v:GetBoundingMaxs().z ))
			--se
			local particle = ParticleManager:CreateParticle( "particles/c07e3/c07e3.vpcf", PATTACH_POINT, v )
			ParticleManager:SetParticleControlEnt(particle, 0, v, PATTACH_POINT, "attach_hitloc", v:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle, 1, v, PATTACH_POINT, "attach_hitloc", v:GetAbsOrigin(), true)
			Timers:CreateTimer(0.5,function()
				ParticleManager:DestroyParticle(particle ,true)
			end)
			--dmg
			ability:ApplyDataDrivenModifier(caster,v,"modifier_C07R",nil)
		end
	end
	group = nil
end

function C07T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local level = ability:GetLevel() - 1
	local height = 0
	local distance = 100
	local life_time = ability:GetLevelSpecialValueFor("duration",level)

	local dummy = CreateUnitByName("Dummy_Ver1",point ,false,nil,nil,caster:GetTeam())
	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07T",nil)
	dummy:FindAbilityByName("majia"):SetLevel(1)

	--debug
    local group = {}
   	group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 200, 3, 63, 80, 0, false)
	for _,v in ipairs(group) do
		v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	end

	local point2 = 4000
	--print("@@@@")
	--print(life_time)
	local particle = ParticleManager:CreateParticle( "particles/07t/c07t.vpcf", PATTACH_POINT, dummy )
	ParticleManager:SetParticleControlEnt(particle,0, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point+Vector(point2 ,point2,height), true)
	ParticleManager:SetParticleControlEnt(particle,1, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point+Vector(point2,point2,height), true)
	ParticleManager:SetParticleControlEnt(particle,2, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point+Vector(point2,point2,height), true)

	local particle2 = ParticleManager:CreateParticle( "particles/07t/c07t_zc.vpcf", PATTACH_POINT, dummy )
	ParticleManager:SetParticleControlEnt(particle2,0, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point+Vector(point2 ,point2,height), true)
	ParticleManager:SetParticleControlEnt(particle2,1, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point+Vector(point2,point2,height), true)
	ParticleManager:SetParticleControlEnt(particle2,2, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point+Vector(point2,point2,height), true)

	Timers:CreateTimer(life_time,function()
		ParticleManager:DestroyParticle(particle,false)
		ParticleManager:DestroyParticle(particle2,true)
		dummy:ForceKill(true)
		--print("@@@@".."dead")
	end	)
end



--particles/07t/c07t.vpcf
--particles/rain_fx/rain_storm.vpcf
--particles/units/heroes/hero_razor/razor_rain_storm.vpcf

function C07_Effect( keys )
	local caster = keys.caster
	local dummy = keys.target
	local ability = keys.ability
	local point = dummy:GetAbsOrigin()
	local point2
	local dmg = keys.C07_dmg
	local height = 700
	--print(dmg)
	local group = {}
   	group = FindUnitsInRadius(dummy:GetTeamNumber(), point, nil, 1000,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for i,v in ipairs(group) do
		if i == 1 then
			StartSoundEvent( "Hero_Leshrac.Lightning_Storm", dummy )
			StartSoundEvent( "Hero_Leshrac.Lightning_Storm", v )

			point2 = v:GetAbsOrigin()
			local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN , v)
			-- Raise 1000 if you increase the camera height above 1000
			ParticleManager:SetParticleControl(particle, 0, point + Vector(0,0,height))
			ParticleManager:SetParticleControl(particle, 1, Vector(point2.x,point2.y,point2.z + v:GetBoundingMaxs().z ))
			ParticleManager:SetParticleControl(particle, 2, Vector(point2.x,point2.y,point2.z + v:GetBoundingMaxs().z ))

		   	group2 = FindUnitsInRadius(dummy:GetTeamNumber(), point2, nil, 300,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
			for i2,v2 in ipairs(group2) do
				AMHC:Damage( caster,v2,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
			end
		end
		if not v:IsBuilding() then
			ability:ApplyDataDrivenModifier(caster,v,"modifier_C07T_2",nil)
		end
	end
end

function C07W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel()
	local height = 0
	local distance = 100

	local dummy = CreateUnitByName("Dummy_Ver1",point2 ,false,nil,nil,caster:GetTeam())
	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07W",nil)
	dummy:FindAbilityByName("majia"):SetLevel(1)

	--debug
  local group = {}
 	group = FindUnitsInRadius(caster:GetTeamNumber(), point2, nil, 200, 3, 63, 80, 0, false)
	for _,v in ipairs(group) do
		v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	end

	for i=1,1 do
		local particle = ParticleManager:CreateParticle( "particles/c07w/c07w.vpcf", PATTACH_POINT, dummy )
		-- ParticleManager:SetParticleControl(particle,0,point+Vector(0,0,height*i))
		-- ParticleManager:SetParticleControl(particle,1,point+Vector(0,0,height*i))
		-- ParticleManager:SetParticleControl(particle,2,point+Vector(0,0,height*i))
		ParticleManager:SetParticleControlEnt(particle,0, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point2, true)
		ParticleManager:SetParticleControlEnt(particle,1, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point2, true)
		ParticleManager:SetParticleControlEnt(particle,2, dummy, PATTACH_POINT_FOLLOW,"attach_hitloc",point2, true)
		----print(particle)
	end

	Timers:CreateTimer(10,function()
		dummy:ForceKill(false)
		--ParticleManager:DestroyParticle(particle,true)
	end)
end

function C07W_DMG(keys)
	local caster = keys.caster
	local dummy = keys.target
	local ability = keys.ability
	local point = dummy:GetAbsOrigin()
	local dmg = keys.C07W_dmg
	local radius = ability:GetLevelSpecialValueFor("radius",ability:GetLevel() - 1)
	--print(dmg)
	--print(dummy:GetUnitName())
	StartSoundEvent( "Hero_StormSpirit.Attack", dummy )
	local group = {}
   	group = FindUnitsInRadius(dummy:GetTeamNumber(), point, nil, radius ,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for i,v in ipairs(group) do
		AMHC:Damage( caster,v,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end