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
	caster.C07E_target = target
	--
	caster.C07E_P = particle
	Timers:CreateTimer(0.2, function ()
          if target ~= nil and IsValidEntity(target) and target:HasModifier("modifier_C07E") and caster:HasModifier("modifier_C07E2") then
          	return 0.2
          else
          	target:RemoveModifierByName("modifier_C07E")
          	caster.C07E_target = nil
          	ParticleManager:DestroyParticle(particle,false)
          	return nil
          end
        end)
	
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

function C07R_old( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	local vec   = (point2 - point):Normalized()
	local level = ability:GetLevel() - 1
	local radius = ability:GetLevelSpecialValueFor("radius",level)
	local target_count = ability:GetLevelSpecialValueFor("target_count",level)
    local group = FindUnitsInRadius(caster:GetTeam(), point2, nil, radius , ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for i,v in ipairs(group) do
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
	group = nil
end

function C07R( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	local vec   = (point2 - point):Normalized()
	
	-- 扣20%血
	if not caster:HasModifier("modifier_C07D") then
		if (caster:GetHealth() < caster:GetMaxHealth()*0.25) then
			caster:SetHealth(1)
		else
			AMHC:Damage( caster, caster, caster:GetMaxHealth()*0.25,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end

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
	AddFOWViewer(caster:GetTeamNumber(), point, 1400, life_time, false)
	local dummy = CreateUnitByName("Dummy_Ver1",point ,false,nil,nil,caster:GetTeam())
	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C07T",nil)
	dummy:FindAbilityByName("majia"):SetLevel(1)
	dummy:SetOwner(caster)

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
		if IsValidEntity(dummy) then
			dummy:ForceKill(true)
		end
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
	local group = FindUnitsInRadius(dummy:GetTeamNumber(),
                              point,
                              nil,
                              1400,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                              FIND_CLOSEST,
                              false)
	local dummyx = CreateUnitByName( "npc_dummy", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
	AddFOWViewer(DOTA_TEAM_GOODGUYS, dummyx:GetAbsOrigin(), 100, 1, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, dummyx:GetAbsOrigin(), 100, 1, false)
	dummyx:SetOwner(caster)
	Timers:CreateTimer(1,function()
		dummyx:ForceKill(true)
		end)
	local ii = 0
	if caster.C07E_target ~= nil then
		local v = caster.C07E_target
		ii = 1
		StartSoundEvent( "Hero_Leshrac.Lightning_Storm", dummy )
		StartSoundEvent( "Hero_Leshrac.Lightning_Storm", v )

		point2 = v:GetAbsOrigin()
		local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN , v)
		-- Raise 1000 if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 0, point + Vector(0,0,height))
		ParticleManager:SetParticleControl(particle, 1, Vector(point2.x,point2.y,point2.z + v:GetBoundingMaxs().z ))
		ParticleManager:SetParticleControl(particle, 2, Vector(point2.x,point2.y,point2.z + v:GetBoundingMaxs().z ))

	   	local group2 = FindUnitsInRadius(dummy:GetTeamNumber(),
                          point2,
                          nil,
                          350,
                          DOTA_UNIT_TARGET_TEAM_ENEMY,
                          DOTA_UNIT_TARGET_ALL,
                          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                          FIND_ANY_ORDER,
                          false)
		for i2,v2 in ipairs(group2) do
			if v2:IsHero() then
				ParticleManager:CreateParticle("particles/shake1.vpcf", PATTACH_ABSORIGIN, v2)
			end
			if IsValidEntity(caster) and caster:IsAlive() then
				if v2:IsBuilding() then
					AMHC:Damage( caster,v2,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				else
					if v2:IsMagicImmune() then
						AMHC:Damage( caster,v2,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
					else
						AMHC:Damage( caster,v2,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
					end
				end
			else
				if v2:IsBuilding() then
					AMHC:Damage( dummyx,v2*0.5,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				else
					if v2:IsMagicImmune() then
						AMHC:Damage( dummyx,v2,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
					else
						AMHC:Damage( dummyx,v2,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
					end
				end
				caster.takedamage = caster.takedamage + dmg
				if (v2:IsRealHero()) then
					caster.herodamage = caster.herodamage + dmg
				end
			end
		end
	end
	for i,v in ipairs(group) do
		if ii == 0 then
			if dummyx:CanEntityBeSeenByMyTeam(v) and not v:HasModifier("modifier_majia") and not string.match(v:GetUnitName(),"dummy") then
				ii = 1
				StartSoundEvent( "Hero_Leshrac.Lightning_Storm", dummy )
				StartSoundEvent( "Hero_Leshrac.Lightning_Storm", v )

				point2 = v:GetAbsOrigin()
				local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN , v)
				-- Raise 1000 if you increase the camera height above 1000
				ParticleManager:SetParticleControl(particle, 0, point + Vector(0,0,height))
				ParticleManager:SetParticleControl(particle, 1, Vector(point2.x,point2.y,point2.z + v:GetBoundingMaxs().z ))
				ParticleManager:SetParticleControl(particle, 2, Vector(point2.x,point2.y,point2.z + v:GetBoundingMaxs().z ))

			   	local group2 = FindUnitsInRadius(dummy:GetTeamNumber(),
	                              point2,
	                              nil,
	                              350,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
				for i2,v2 in ipairs(group2) do
					if v2:IsHero() then
						ParticleManager:CreateParticle("particles/shake1.vpcf", PATTACH_ABSORIGIN, v2)
					end
					if IsValidEntity(caster) and caster:IsAlive() then
						if v2:IsBuilding() then
							AMHC:Damage( caster,v2,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
						else
							if v2:IsMagicImmune() then
								AMHC:Damage( caster,v2,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
							else
								AMHC:Damage( caster,v2,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
							end
						end
					else
						if v2:IsBuilding() then
							AMHC:Damage( dummyx,v2,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
						else
							if v2:IsMagicImmune() then
								AMHC:Damage( dummyx,v2,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
							else
								AMHC:Damage( dummyx,v2,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
							end
						end
						caster.takedamage = caster.takedamage + dmg
						if (v2:IsRealHero()) then
							caster.herodamage = caster.herodamage + dmg
						end
					end
				end
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
