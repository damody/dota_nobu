function B27E( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point   = caster:GetAbsOrigin()
	local point2  = target:GetAbsOrigin()
	local vec = nobu_atan2( point2,point )
	local distance = 35

	local temp_point = nobu_move( point, point2 , distance )

	local particle = ParticleManager:CreateParticle("particles/b27e/b27e_2.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,2,Vector(0,0,10))

	Timers:CreateTimer(function()
		point2  = target:GetAbsOrigin()
        temp_point = nobu_move( temp_point, point2 , distance )

        --temp_point = nobu_move_ver2( temp_point , distance ,RandomFloat(0,-30))

        --print(nobu_radtodeg(math.atan2(point2.y-point.y,point2.x-point.x)))

		if nobu_distance( temp_point,point2 ) < 50  or not target:IsAlive()  then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B27E",nil)
			ParticleManager:DestroyParticle(particle,false)

			--print("Stop")
			return nil
		else
			ParticleManager:SetParticleControl(particle,0,temp_point)
			return 0.01
		end
	end)
end

function B27E_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point   = caster:GetAbsOrigin()
	local point2  = target:GetAbsOrigin()
	local vec = nobu_atan2( point2,point )
	local distance = 35

	local temp_point = nobu_move( point, point2 , distance )

	local particle = ParticleManager:CreateParticle("particles/b27e/b27e_2.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,2,Vector(0,0,10))

	Timers:CreateTimer(function()
		point2  = target:GetAbsOrigin()
        temp_point = nobu_move( temp_point, point2 , distance )

        --temp_point = nobu_move_ver2( temp_point , distance ,RandomFloat(0,-30))

        --print(nobu_radtodeg(math.atan2(point2.y-point.y,point2.x-point.x)))

		if nobu_distance( temp_point,point2 ) < 50  or not target:IsAlive()  then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B27E_old",nil)
			ParticleManager:DestroyParticle(particle,false)

			--print("Stop")
			return nil
		else
			ParticleManager:SetParticleControl(particle,0,temp_point)
			return 0.01
		end
	end)
end

function B27W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	AMHC:AddModelScale(caster, 1.3, 6)
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
				caster:RemoveModifierByName(v:GetName())
			end
		end
	end
end

function B27W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	AMHC:AddModelScale(caster, 1.3, 13)
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
				caster:RemoveModifierByName(v:GetName())
			end
		end
	end
end

function B27T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration",level)
	local particle = ParticleManager:CreateParticle("particles/b34t/b34t2.vpcf", PATTACH_ABSORIGIN, caster)

	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  1000 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	for _, it in pairs(group) do
		if it:IsHero() then
			ParticleManager:CreateParticle("particles/shake2.vpcf", PATTACH_ABSORIGIN, it)
		end
		AMHC:Damage( caster,it, ability:GetLevelSpecialValueFor("dmg",level),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		ability:ApplyDataDrivenModifier(it,it,"modifier_B27T",{})
	end
	tsum = 0.1
	Timers:CreateTimer(0.1, function()
		for _, it in pairs(group) do
			if it:IsHero() then
				if IsValidEntity(it) and not it:HasModifier("modifier_B27T") then
					ability:ApplyDataDrivenModifier(it,it,"modifier_B27T",{duration = duration-tsum})
				end
			end
		end
		tsum = tsum + 0.1
		end)
end



function B27T_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability =keys.ability
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 300, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		if not unit:IsBuilding() then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_B27T_2",{duration = 6})
		end
	end
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
	Timers:CreateTimer(0.2,function()
		local order = {UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()}
		ExecuteOrderFromTable(order)
		end)
end
