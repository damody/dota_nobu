-- 齋藤朝信 by Nian Chen
-- 2017.4.16

function B03W_OnUpgrade( keys )
	local caster = keys.caster
	local abilityLevel = keys.ability:GetLevel()
	caster:FindAbilityByName("B03D"):SetLevel(abilityLevel)
	caster:FindAbilityByName("B03F"):SetLevel(abilityLevel)
end

function B03W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local distance = ability:GetSpecialValueFor("B03W_distance")
	local damage = ability:GetSpecialValueFor("B03W_damage")
	local radius = ability:GetSpecialValueFor("B03W_radius")
	local stunDuration = ability:GetSpecialValueFor("B03W_stunDuration")

	local point = caster:GetAbsOrigin() + caster:GetForwardVector() * distance

	local particle = ParticleManager:CreateParticle("particles/b03w/b03w.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, point)

	local particle2 = ParticleManager:CreateParticle("particles/b03w/b03w2.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle2, 1, point)

	StartSoundEventFromPosition( "Hero_Leshrac.Split_Earth" , point )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		if not unit:IsMagicImmune() then
			local damageTable = {
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			unit:AddNewModifier( caster, ability, "modifier_stunned", { duration = stunDuration } )
			ApplyDamage(damageTable)
		end
	end
end

function B03E_OnTakeDamage( keys )
	if IsServer() then
		local caster = keys.caster
		local damage = keys.Damage
		local ability = keys.ability
		local mpSpend = ability:GetSpecialValueFor("B03E_mpSpend")
		if caster:GetManaPercent() >= 15 then
			local particle = ParticleManager:CreateParticle("particles/b03e/b03e.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
			caster:SetHealth( caster:GetHealth() + damage )
			caster:SpendMana( caster:GetMaxMana() * mpSpend , ability )
		end
	end
end

function B03E_OnKill( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit
	local mpRegen = ability:GetSpecialValueFor("B03E_mpRegen")
	if not target:IsBuilding() then
		caster:GiveMana( mpRegen )
	end
end

function B03R_OnAttackLanded( keys )
	local target = keys.target
	if not target:IsBuilding() then
		local ability = keys.ability
		local caster = keys.caster
		local strBonus = ability:GetSpecialValueFor("B03R_strBonus")
		local fxIndex = ParticleManager:CreateParticle( "particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_POINT, target )
		ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = strBonus * caster:GetStrength(),
			damage_type = ability:GetAbilityDamageType()
		}
		ApplyDamage(damageTable)
	end
end

function B03T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("B03T_duration")
	ability:ApplyDataDrivenModifier( caster, caster , "modifier_B03T" , nil )
	local modifier = caster:FindModifierByName("modifier_B03T")
	modifier.count = ability:GetSpecialValueFor("B03T_maxCount")
	B03T_OnIntervalThink( keys )
end

function B03T_OnIntervalThink( keys )
	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetSpecialValueFor("B03T_radius")
	local modifier = caster:FindModifierByName("modifier_B03T")

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for i,v in ipairs(units) do
		if caster:CanEntityBeSeenByMyTeam(v) then
			StartSoundEvent( "Hero_ChaosKnight.idle_throw" , caster )
			local projTable = {
		        EffectName = "particles/b03t/b03t.vpcf",
		        Ability = ability,
		        vSpawnOrigin = caster:GetAbsOrigin(),
		        Target = v,
		        Source = caster,
		        bDodgeable = false,
		        iMoveSpeed = 700,
		        iVisionRadius = 225,
				iVisionTeamNumber = caster:GetTeamNumber(),
		        iUnitTargetTeam = ability:GetAbilityTargetTeam(),
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		        iUnitTargetType = ability:GetAbilityDamageType(),
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			 }
			ProjectileManager:CreateTrackingProjectile( projTable )
			modifier.count = modifier.count - 1
			break
		end
	end

	if modifier.count <= 0 then
		caster:RemoveModifierByName("modifier_B03T")
	end
end

function B03T_OnProjectileHitUnit( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local stunDuration = ability:GetSpecialValueFor("B03T_stunDuration")
	AMHC:Damage( caster, target, ability:GetSpecialValueFor("B03T_damage"), AMHC:DamageType("DAMAGE_TYPE_PHYSICAL") )
	target:AddNewModifier( caster, ability, "modifier_stunned" , { duration = stunDuration } )
	StartSoundEvent( "Hero_ElderTitan.Attack" , target )
end

function B03W_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("B03W_old_duration")
	ability:ApplyDataDrivenModifier( caster, target , "modifier_B03W_old" , { duration = duration } )
end

function B03R_old_OnAttackLanded( keys )
	local target = keys.target
	if not target:IsBuilding() then
		local ability = keys.ability
		local caster = keys.caster
		local damage = ability:GetSpecialValueFor("B03R_old_damage")
		local stunDuration = ability:GetSpecialValueFor("B03R_old_stunDuration")
		local fxIndex = ParticleManager:CreateParticle( "particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_POINT, target )
		ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType()
		}
		target:AddNewModifier( caster, ability, "modifier_stunned" , { duration = stunDuration } )
		ApplyDamage(damageTable)
	end
end

function B03T_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("B03T_old_radius")
	local damage = ability:GetSpecialValueFor("B03T_old_damage")

	local particle = ParticleManager:CreateParticle("particles/b03t_old/b03t_oldfallback_mid.vpcf", PATTACH_ABSORIGIN, target)

	local particle2 = ParticleManager:CreateParticle("particles/b03t_old/b03t_old2egset.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(particle2, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle2, 1, target:GetAbsOrigin())

	StartSoundEvent( "Hero_Leshrac.Split_Earth" , target )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		ApplyDamage(damageTable)
	end
end
