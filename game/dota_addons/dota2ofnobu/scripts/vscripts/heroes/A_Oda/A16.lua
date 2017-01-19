function A16T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local point3 = point
	local rad = nobu_atan2( point2,point )
	local level = ability:GetLevel() - 1

	local time = ability:GetLevelSpecialValueFor("crack_time",level)
	local distance = ability:GetLevelSpecialValueFor("crack_distance",level)
	local vec = (point2 - point):Normalized()

	-- local x1 = point.x
	-- local y1 = point.y
	-- local z1 = point.z
	-- x1 = x1 + distance * math.cos(rad)
	-- y1 = y1 + distance * math.sin(rad)
	-- point2 = Vector(x1,y1,z1)

	-- local particle=ParticleManager:CreateParticle("particles/a16t/a16t.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0,point)
	-- ParticleManager:SetParticleControl(particle,1,point2)
	-- ParticleManager:SetParticleControl(particle,3,Vector(0,time,0))
	local num = 0
	Timers:CreateTimer(0,function()
		num = num + 1


		if num > 7 then
			point = point + vec * 300

			NobuDummyCreateSound (caster,point,"Hero_Leshrac.Split_Earth.Tormented")


			--effect
			--獲取攻擊範圍
	    local group = {}
	    local radius = 300

	    -- Register units around caster
	    group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 300, ability:GetAbilityTargetTeam(), 63, 80, 0, false)
	    for i,v in ipairs(group) do
	    	if (not v:IsBuilding()) then
				ability:ApplyDataDrivenModifier(caster,v,"modifier_A16T",nil)
			end
	    end
			--
	    -- print(point)
		else
			distance = 300
			x1 = point3.x
			y1 = point3.y
			z1 = point3.z
			x1 = x1 + distance * math.cos(rad)
			y1 = y1 + distance * math.sin(rad)
			point2 = Vector(x1,y1,z1)
			point3 = point3 + vec * 300
			local particle=ParticleManager:CreateParticle("particles/a16t/a16t.vpcf",PATTACH_POINT,caster)
			ParticleManager:SetParticleControl(particle,0,point3)
			ParticleManager:SetParticleControl(particle,1,point2)
			ParticleManager:SetParticleControl(particle,3,Vector(0,0.18*8,0))

			print(point3)
		end

		if num <= 13 then
			return .18
		else
			return nil
		end
	end)

	-- for i=1,7 do
	-- 	distance = 7200
	-- 	x1 = point.x
	-- 	y1 = point.y
	-- 	z1 = point.z
	-- 	x1 = x1 + distance * math.cos(rad)
	-- 	y1 = y1 + distance * math.sin(rad)
	-- 	point2 = Vector(x1,y1,z1)
	-- 	local particle=ParticleManager:CreateParticle("particles/a16t/a16t.vpcf",PATTACH_POINT,caster)
	-- 	ParticleManager:SetParticleControl(particle,0,point)
	-- 	ParticleManager:SetParticleControl(particle,1,point2)
	-- 	ParticleManager:SetParticleControl(particle,3,Vector(0,i,0))
	-- end

	--A16T2( keys )
	--     7200      1000 2000 3000 4000
end


function A16R( keys )
	--[[
	O在這邊放計時器是因為節省particle的使用
	O魔免的時候，不能在KV裡面傷害單位
		要在lua裡面
	]]
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_percent = ability:GetLevelSpecialValueFor("damage_percent",ability:GetLevel()-1)
	local dmg = keys.dmg * damage_percent
	--print(dmg) --%attack_damage * %damage_percent
	--test
	-- target:Kill(nil,nil)
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )

	if target.A16R == nil then
		target.A16R = true
	end

	if target.A16R == true then
		target.A16R = false
		Timers:CreateTimer(0.8,function ()
			target.A16R = true
		end)

		local particle=ParticleManager:CreateParticle("particles/a16r3/a16r3.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle,0,target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle,1,Vector(1,0,0))
		ParticleManager:SetParticleControl(particle,2,target:GetAbsOrigin())

		NobuDestoryParticle (particle,1)
	end
end
