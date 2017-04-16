-- 山縣昌景 by Nian Chen
-- 2017.4.14

function B20W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local dv = (point - caster:GetAbsOrigin()) / 30

	StartSoundEvent( "Hero_Tiny.Pick" , caster )

	local count = 0
	Timers:CreateTimer( 0, function ()
		if count >= 10 then
			return nil
		else
			local pPoint = caster:GetAbsOrigin()
			local particle=ParticleManager:CreateParticle("particles/b20w/b20w.vpcf",PATTACH_POINT,caster)
			ParticleManager:SetParticleControl(particle,0,pPoint)
			ParticleManager:SetParticleControl(particle,1,Vector(200,200,200))

			local count2 = 0
			Timers:CreateTimer( 0, function ()
				if count2 > 0.3 then
					B20W_HitDestination( caster, ability, point )
					Timers:CreateTimer( 0.3, function ()
						ParticleManager:DestroyParticle( particle, false )
					end)
					return nil
				end
				pPoint = pPoint + dv
				ParticleManager:SetParticleControl( particle, 0, pPoint + B20W_getHeight(count2)*2000 )
				count2 = count2 + 0.01
				return 0.01
			end)
			count = count + 1
			return 1/15
		end
	end)
end

function B20W_getHeight( time )
	local z = -4 * math.pow((time-0.15),2) + 0.1
	return Vector(0,0,z)
end

function B20W_HitDestination( caster, ability, point )
	local stunDuration = ability:GetSpecialValueFor("B20W_stunDuration")
	local damage = ability:GetSpecialValueFor("B20W_damage")
	local radius = ability:GetSpecialValueFor("B20W_radius")

	local units = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		if not unit:IsMagicImmune() then
			local damageTable = {
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = damage/10,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			unit:AddNewModifier( caster, ability, "modifier_stunned", { duration = stunDuration } )
			ApplyDamage(damageTable)
		end
	end
end

function B20E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stunDuration = ability:GetSpecialValueFor("B20E_stunDuration")
	local damage = ability:GetSpecialValueFor("B20E_damage")
	local radius = ability:GetSpecialValueFor("B20E_radius")

	local particle = ParticleManager:CreateParticle("particles/b20e/b20eburrowstrike.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())

	local particle2 = ParticleManager:CreateParticle("particles/b20t/b20t.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		FindClearSpaceForUnit( unit, caster:GetAbsOrigin() , true)
		unit:AddNewModifier( nil, nil, "modifier_phased", { duration = 0.1 } )
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

function B20R_OnAbilityExecuted( keys )
	local caster = keys.caster
	local ability = keys.ability
	local mpRegen = ability:GetSpecialValueFor("B20R_mpRegen")
	local maxMana = caster:GetMaxMana()
	local newMana = caster:GetMana() + maxMana * mpRegen/100

	if newMana > maxMana then
		caster:SetMana(maxMana)
	else
		caster:SetMana(newMana)
	end

	if caster:GetHealthPercent() < 50 then
		local maxHealth = caster:GetMaxHealth()
		local hpRegen = ability:GetSpecialValueFor("B20R_hpRegen")
		caster:Heal( maxHealth * hpRegen/100 , ability )
	end
end

function B20T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("B20T_duration")
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B20T", { duration = duration } )
	B20T_OnIntervalThink( keys )
end

function B20T_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("B20T_radius")
	local damage = ability:GetSpecialValueFor("B20T_damage")
	local debuffDuration = ability:GetSpecialValueFor("B20T_debuffDuration")

	local particle = ParticleManager:CreateParticle("particles/b20e/b20eburrowstrike.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())

	local particle2 = ParticleManager:CreateParticle("particles/b20t/b20t.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())

	StartSoundEvent( "Hero_Brewmaster.ThunderClap" , caster )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		ability:ApplyDataDrivenModifier( caster, unit, "modifier_B28T_debuff", { duration = debuffDuration } )
		if not unit:IsMagicImmune() then
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
end

function B20R_old_OnSuccess( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B20R_old_Crit2", nil )
end

function B20R_old_OnAttackLanded( keys )
	for k,v in pairs(keys) do
		print(k,v)
	end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damageBonus = ability:GetSpecialValueFor("B20R_old_damageBonus")
	if not target:IsBuilding() then
		local damageTable = {
			victim = target,
			attacker = caster,
			ability = ability,
			damage = damageBonus,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		ApplyDamage(damageTable)
	end
end
