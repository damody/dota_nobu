-- 寧寧 by Nian Chen
-- 2017.4.10

function A15W_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("A15W_duration")
	ability:ApplyDataDrivenModifier( caster, target, "modifier_A15W_debuff", { duration = duration } )
end

function A15E_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("A15E_radius")
	local moonradius = ability:GetSpecialValueFor("A15E_moonRadius")
	local damage = ability:GetSpecialValueFor("A15E_damage")
	local stunDuration = ability:GetSpecialValueFor("A15E_stunDuration")
	local maxMoon = ability:GetSpecialValueFor("A15E_maxMoon")

	local moonCount = 0

	Timers:CreateTimer( 0, function()
		if not caster:IsChanneling() then
			return nil
		end
		if moonCount < maxMoon then
			moonCount = moonCount + 1
			local randomPoint = point + RandomVector( RandomInt( 0 , radius ) )

			local particle = ParticleManager:CreateParticle( "particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_impact_moonfall.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl( particle, 0, randomPoint )
			ParticleManager:SetParticleControl( particle, 1, randomPoint )
			ParticleManager:SetParticleControl( particle, 2, randomPoint )
			ParticleManager:SetParticleControl( particle, 5, randomPoint )
			ParticleManager:ReleaseParticleIndex( particle )

			StartSoundEventFromPosition( "Hero_Luna.Eclipse.NoTarget" , randomPoint )

			local units = FindUnitsInRadius( caster:GetTeamNumber(), randomPoint, nil, moonradius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
			for _,unit in ipairs(units) do
				local damage_table = {
					attacker = caster,
					victim = unit,
					damage = damage,
					damage_type = ability:GetAbilityDamageType()
				}
				unit:AddNewModifier( caster, ability, "modifier_stunned", { duration = stunDuration } )
				ApplyDamage(damage_table)
			end
		end
		return 0.1
	end)
end

function A15R_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	A15R_bounce_init( keys )
	ability:ApplyDataDrivenModifier( caster, target, "modifier_A15R_bounceAttack", nil)
end

function A15R_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_A15R_bounceAttack", nil)
	end
end

function A15R_bounce_init( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = keys.Damage
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
		ability.first_target = {}
		ability.damage = {}
	else
		ability.instance = ability.instance + 1
	end

	ability.jump_count[ability.instance] = ability:GetSpecialValueFor("jump_max")
	ability.target[ability.instance] = target
	ability.first_target[ability.instance] = target
	ability.damage[ability.instance] = damage

end

function A15R_bounceAttack(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_radius = ability:GetSpecialValueFor("jump_radius")
	local bonus_damage = ability:GetSpecialValueFor("bonus_damage")
	local jump_max = ability:GetSpecialValueFor("jump_max")
	local pos

	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_A15R_bounceAttack")

	-- Finds the current instance of the ability by ensuring both current targets are the same
	local current
	for i=0,ability.instance do
		if IsValidEntity(ability.target[i]) then
			if ability.target[i] == target then
				current = i
			end
		end
	end

	if IsValidEntity(target) then
		pos = target:GetAbsOrigin()
	-- Adds a global array to the target, so we can check later if it has already been hit in this instance
		if target.hit == nil then
			target.hit = {}
		end
		-- Sets it to true for this instance
		target.hit[current] = true
		local tt = 0.25
		if target:IsBuilding() then
			tt = 0.1
		end
			Timers:CreateTimer(tt, function ()
				if IsValidEntity(target) then
					target.hit[current] = nil
				end
				end)
		
	end

	-- Deal damage
	if ability.first_target[current] ~= target then
		local base_damage = ability.damage[current]
		local new_damage = base_damage * math.pow( 1 + bonus_damage, jump_max-ability.jump_count[current] )

		local damageTable = {
			victim = target, 
			attacker = caster, 
			damage = new_damage, 
			damage_type = ability:GetAbilityDamageType()
		}
		if target:IsBuilding() then
			damageTable.damage = damageTable.damage * 0.5
		end
		ApplyDamage( damageTable )
		if caster:HasModifier("modifier_A15T") then
			if not target:IsBuilding() then
				local lifeSteal = caster:FindAbilityByName("A15T"):GetSpecialValueFor("A15T_lifeSteal")
				A15_LifeSteal( caster, target, new_damage, lifeSteal )
				ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
			end
		end
	end

	-- Decrements our jump count for this instance
	ability.jump_count[current] = ability.jump_count[current] - 1

	-- Checks if there are jumps left
	if ability.jump_count[current] > 0 then
		-- Finds units in the jump_radius to jump to
		local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, jump_radius, ability:GetAbilityTargetTeam(), 
										ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
		local new_target

		for i,unit in ipairs(units) do
			if unit.hit == nil or unit.hit[current] == nil then
				new_target = unit
				break
			end
		end
		-- Checks if there is a new target
		if new_target ~= nil then
			AddFOWViewer(caster:GetTeamNumber(),new_target:GetAbsOrigin(),300,2.0,false)
			-- Sets the new target as the current target for this instance
			ability.target[current] = new_target
			-- Fire Projectile
			local projTable = {
		        EffectName = "particles/econ/items/luna/luna_lucent_rider/luna_glaive_bounce_lucent_rider.vpcf",
		        Ability = ability,
		        vSpawnOrigin = target:GetAbsOrigin(),
		        Target = new_target,
		        Source = target,
		        bDodgeable = false,
		        iMoveSpeed = 1300,
		        iVisionRadius = 225,
				iVisionTeamNumber = caster:GetTeamNumber(),
		        iUnitTargetTeam = ability:GetAbilityTargetTeam(),
		        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		        iUnitTargetType = ability:GetAbilityDamageType(),
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
			}
			ProjectileManager:CreateTrackingProjectile( projTable )
		else
			-- If there are no new targets, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
		end
	else
		-- If there are no more jumps, we set the current target to nil to indicate this instance is over
		ability.target[current] = nil
	end
end

function A15T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("A15T_duration")
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_A15T", { duration = duration } )
end

function A15T_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target.isvoid == nil then
		if not target:IsBuilding() then
			local lifeSteal = ability:GetSpecialValueFor("A15T_lifeSteal")
			local damage = keys.Damage
			A15_LifeSteal( caster, target, damage, lifeSteal )
		    ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
		end
	end
end

function A15_LifeSteal( caster, target, damage, lifeSteal )
	local damageAfterReduction = CalcDamageAfterReduction( target, damage )
	caster:Heal( damageAfterReduction * lifeSteal/100 , caster )
end

function CalcDamageAfterReduction( target, damage )
	local armor = target:GetPhysicalArmorValue()
	-- The damage multiplier for both positive and negative armor:
	-- Damage multiplier = 1 - 0.06 × armor ÷ (1 + 0.06 × |armor|)
	local multiplier = 1 - 0.06 * armor / ( 1 + 0.06 * math.abs(armor) )
	local damageAfterReduction = damage * multiplier
	return damageAfterReduction
end

function A15W_old_End( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local abilityDamage = ability:GetSpecialValueFor("A15W_old_damage")
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			PopupCriticalDamage(target, abilityDamage)
			AMHC:Damage( caster, target, abilityDamage, AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end	
		keys.caster:RemoveModifierByName( "modifier_A15W_old" )
		keys.caster:RemoveModifierByName( "modifier_invisible" )
	end
end

function A15E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local duration = ability:GetSpecialValueFor("A15E_duration")

	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", { duration = duration } )
	dummy:SetOwner(caster)
	dummy:AddAbility("majia_vison"):SetLevel(1)

	ability:ApplyDataDrivenModifier( caster, dummy, "modifier_A15E_old_show_invi_aura", nil)
	local count = 0
	local particle = nil
	Timers:CreateTimer( 0, function()
		count = count + 1
		if particle then
			ParticleManager:DestroyParticle(particle,true)
		end
		particle = ParticleManager:CreateParticle( "particles/a15/a15eoldmoonfall.vpcf", PATTACH_POINT, dummy)
		ParticleManager:SetParticleControl( particle, 0, point )
		ParticleManager:SetParticleControl( particle, 1, point )
		ParticleManager:SetParticleControl( particle, 2, point )
		ParticleManager:SetParticleControl( particle, 3, point )
		if count < duration then
			return 1
		end
		end)
end

function A15T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("A15T_old_duration")
	local healPoint = ability:GetSpecialValueFor("A15T_old_heal")

	caster:Heal( healPoint , caster )
	PopupNumbers(caster, "heal", Vector(0, 255, 0), 1.0, healPoint, POPUP_SYMBOL_PRE_PLUS, nil)
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_A15T_old", { duration = duration } )
end

function A15T_old_OnIntervalThink( keys )
	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetSpecialValueFor("A15T_old_radius")

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	if #units > 0 then
		local v = units[1]
		local projTable = {
	        EffectName = "particles/a15t_old/a15t_old.vpcf",
	        Ability = ability,
	        vSpawnOrigin = caster:GetAbsOrigin(),
	        Target = v,
	        Source = caster,
	        bDodgeable = false,
	        iMoveSpeed = 400,
	        iVisionRadius = 225,
			iVisionTeamNumber = caster:GetTeamNumber(),
	        iUnitTargetTeam = ability:GetAbilityTargetTeam(),
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	        iUnitTargetType = ability:GetAbilityDamageType(),
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		 }
		ProjectileManager:CreateTrackingProjectile( projTable )
	end
end

function A15T_old_OnProjectileHitUnit( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	if IsValidEntity(target) and IsValidEntity(caster) then
		AMHC:Damage( caster,target,ability:GetSpecialValueFor("A15T_old_damage"),AMHC:DamageType("DAMAGE_TYPE_MAGICAL") )
	end
end
