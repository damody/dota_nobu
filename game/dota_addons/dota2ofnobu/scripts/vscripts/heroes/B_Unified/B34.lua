function B34W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point   = caster:GetAbsOrigin()
	local point2  = target:GetAbsOrigin()
	local vec = nobu_atan2( point2,point )
	local distance = 35

	local temp_point = nobu_move( point, point2 , distance )

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,2,Vector(0,0,10))

	Timers:CreateTimer(function()
		point2  = target:GetAbsOrigin()
        temp_point = nobu_move( temp_point, point2 , distance )

        --temp_point = nobu_move_ver2( temp_point , distance ,RandomFloat(0,-30))

        print(nobu_radtodeg(math.atan2(point2.y-point.y,point2.x-point.x)))

		if nobu_distance( temp_point,point2 ) < 50  or not target:IsAlive()  then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B34W",nil)
			ParticleManager:DestroyParticle(particle,false)

			print("Stop")
			return nil
		else
			ParticleManager:SetParticleControl(particle,0,temp_point)
			return 0.01
		end
	end)
end

function B34R( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster.B34R = caster.B34R - 1
	if caster.B34R == 0 then
		caster:RemoveModifierByName("modifier_B34R")
	end
end

function B34R_limit( keys )
	local caster = keys.caster
	caster.B34R = 5
end

function B34T( keys )
	local caster = keys.caster
	caster.B34R = 5
end

function B34E( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition() --keys.target_points[1] ability
	local vec = caster:GetForwardVector()

	local dummy = CreateUnitByName("Dummy_B34E",point2 ,false,nil,nil,caster:GetTeam())
	--modifier
	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_B34E_2",nil)

	local particle = ParticleManager:CreateParticle("particles/b34e/b34e.vpcf",PATTACH_POINT,dummy)
	ParticleManager:SetParticleControl(particle,0,point2)
	ParticleManager:SetParticleControl(particle,1,point2)
	--紀錄
	dummy.B34E_P = particle

	particle = ParticleManager:CreateParticle("particles/b34e/b34e2.vpcf",PATTACH_POINT,dummy)
	ParticleManager:SetParticleControl(particle,0,point2)

	local x1 = point2.x
	local y1 = point2.y
	local x2
	local y2
	local x3
	local y3
	local a1 = nobu_atan2( point,point2 )
	for i=1,8 do
		x2 = x1 + 138.00*i*math.cos(a1+90.00*3.14159/180)
		y2 = y1 + 138.00*i*math.sin(a1+90.00*3.14159/180)
		x3 = x1 + 138.00*i*math.cos(a1-90.00*3.14159/180)
		y3 = y1 + 138.00*i*math.sin(a1-90.00*3.14159/180)

			dummy = CreateUnitByName("Dummy_B34E",Vector(x2,y2) ,false,nil,nil,caster:GetTeam())
			dummy:FindAbilityByName("majia"):SetLevel(1)
			--modifier
			ability:ApplyDataDrivenModifier(caster,dummy,"modifier_B34E_2",nil)
			--sound
			dummy:EmitSound("Hero_Alchemist.Attack")

			particle = ParticleManager:CreateParticle("particles/b34e/b34e2.vpcf",PATTACH_POINT,dummy)
			ParticleManager:SetParticleControl(particle,0,Vector(x2,y2))

			particle = ParticleManager:CreateParticle("particles/b34e/b34e.vpcf",PATTACH_POINT,dummy)
			ParticleManager:SetParticleControl(particle,0,Vector(x2,y2))
			ParticleManager:SetParticleControl(particle,1,Vector(x2,y2))

			--紀錄
			dummy.B34E_P = particle

		dummy = CreateUnitByName("Dummy_B34E",Vector(x3,y3) ,false,nil,nil,caster:GetTeam())
		dummy:FindAbilityByName("majia"):SetLevel(1)
		--modifier
		ability:ApplyDataDrivenModifier(caster,dummy,"modifier_B34E_2",nil)
		--sound
		dummy:EmitSound("Hero_Alchemist.Attack")

		particle = ParticleManager:CreateParticle("particles/b34e/b34e2.vpcf",PATTACH_POINT,dummy)
		ParticleManager:SetParticleControl(particle,0,Vector(x3,y3))

		particle = ParticleManager:CreateParticle("particles/b34e/b34e.vpcf",PATTACH_POINT,dummy)
		ParticleManager:SetParticleControl(particle,0,Vector(x3,y3))
		ParticleManager:SetParticleControl(particle,1,Vector(x3,y3))

		--紀錄
		dummy.B34E_P = particle
	end
end

function B34E_END( keys )
	ParticleManager:DestroyParticle(keys.target.B34E_P,false)
	keys.target:ForceKill(true)
	keys.target:Destroy()
end


-- Function Description

-- handle CreateUnitByName(string string_1, Vector Vector_2, bool bool_3, handle handle_4, handle handle_5, int int_6)
-- Creates a DOTA unit by its dota_npc_units.txt name ( szUnitName, vLocation, bFindClearSpace, hNPCOwner, hUnitOwner, iTeamNumber )
