-- 齋藤道三 by Nian Chen
-- 2017.3.28

function A11W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local duration = ability:GetSpecialValueFor("A11W_duration")
	local radius = ability:GetSpecialValueFor("A11W_radius")
	local A11W_damage = ability:GetSpecialValueFor("A11W_damage")
	local A11W_adjustOnBuilding = ability:GetSpecialValueFor("A11W_adjustOnBuilding")

	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=duration} )
	dummy:SetOwner( caster)
	dummy:AddAbility( "majia"):SetLevel(1)

	local time = 0.1 + duration
	local count = 0

	Timers:CreateTimer(0,function()
		count = count + 1
		if count > time then
			return nil
		end

		local ifx = ParticleManager:CreateParticle( "particles/a11w/a11wonkey_king_spring_water_base.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,50))
		ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,50))
		Timers:CreateTimer(duration, function ()
			ParticleManager:DestroyParticle(ifx,true)
		end)

		StartSoundEvent("Hero_Slark.Pounce.Impact",dummy)

		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
		for _,unit in ipairs(units) do
			damageTable = {
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = A11W_damage,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			if unit:IsBuilding() then
				damageTable.damage = damageTable.damage * A11W_adjustOnBuilding
			end
			ApplyDamage(damageTable)
		end
		return 1
	end)
end

function A11E( keys )
	local caster = keys.caster
	local target = keys.target
	local particle = ParticleManager:CreateParticle("particles/a11e/a11e_rope.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	caster.A11E_target = target

	local particle3 = ParticleManager:CreateParticle("particles/a11e/a11e_rope_flames.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle3, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle3, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	caster.A11E_P = particle
	Timers:CreateTimer(0.2, function ()
      	if target ~= nil and IsValidEntity(target) and target:HasModifier("modifier_A11E") then
      		local particle2 = ParticleManager:CreateParticle("particles/a11e/a11e_rope_flames.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(particle2, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle2, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
      		return 0.2
      	else
      		caster.A11E_target = nil
      		ParticleManager:DestroyParticle(particle,false)
      		return nil
      	end
    end)
end

function A11R( keys )
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.unit
	local A11R_damage = caster:GetIntellect() * 1.5
	if not unit:HasModifier("modifier_A11R_locker") then
		ability:ApplyDataDrivenModifier( caster, unit, "modifier_A11R_locker", nil)
		damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = A11R_damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if unit:IsMagicImmune() then
			damageTable.damage = damageTable.damage * 0.5
		end
		ApplyDamage(damageTable)
	end
end

function A11T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("A11T_radius")
	local A11T_damage = caster:GetIntellect()
	local maxTarget = ability:GetSpecialValueFor("A11T_maxTarget")

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for i,unit in ipairs(units) do
		damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = A11T_damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if unit:IsMagicImmune() then
			damageTable.damage = damageTable.damage * 0.5
		end
		caster:Heal( damageTable.damage * 0.5, caster)

		local particle = ParticleManager:CreateParticle("particles/a11t2/a11t5b.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)

		ApplyDamage(damageTable)
		if i==maxTarget then
			break
		end
	end
end

function A11T_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("A11T_duration")

	local dummy = CreateUnitByName( "npc_dummy_unit", caster:GetOrigin(), false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=duration} )
	dummy:SetOwner(caster)
	dummy:AddAbility( "majia"):SetLevel(1)

	ability:ApplyDataDrivenModifier( caster, dummy, "modifier_A11T_aura", nil)
end