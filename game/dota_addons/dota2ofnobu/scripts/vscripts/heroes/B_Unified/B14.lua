-- 片倉景綱 by Nian Chen
-- 2017.4.30

function B14D_OnAbilityPhaseStart( keys )
	local caster = keys.caster
	if not GameRules:IsDaytime() then
		caster:Interrupt()
	end
end

function B14D_OnSpellStart( keys )
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("B14D_duration")
	GameRules:BeginTemporaryNight(duration)
end

function B14W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("B14W_damage")
	local str = caster:GetStrength()
	local strBonus = ability:GetSpecialValueFor("B14W_strBonus")
	local radius = ability:GetSpecialValueFor("B14W_radius")
	
	if not GameRules:IsDaytime() then
		local stunDuration = ability:GetSpecialValueFor("B14W_stunDuration")
		target:AddNewModifier( caster , ability , "modifier_stunned" , { duration = stunDuration } )
	end
	target:Stop()

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage + str * strBonus,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		local fxIndex = ParticleManager:CreateParticle( "particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_POINT, unit )
		ParticleManager:SetParticleControl( fxIndex, 0, unit:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, unit:GetAbsOrigin() )
		ApplyDamage(damageTable)
	end

	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()
	})

end

function B14E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local debuffDuration = ability:GetSpecialValueFor("B14E_debuffDuration")

	ability:ApplyDataDrivenModifier( caster , target , "modifier_B14E" , { duration = debuffDuration } )

	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()
	})

	if not GameRules:IsDaytime() then
		local magicImmuneDuration = ability:GetSpecialValueFor("B14E_magicImmuneDuration")
		local am = caster:FindAllModifiers()
		for _,v in pairs(am) do
			if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
				if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
					caster:RemoveModifierByName(v:GetName())
				end
			end
		end
		caster:Purge( false , true , false , true , true )
		ability:ApplyDataDrivenModifier( caster , caster , "modifier_perceive_wine" , { duration = magicImmuneDuration } )
	end
end

function B14R_OnSuccess( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B14R_Crit", nil )
end

function B14T_OnUpgrade( keys )
	keys.caster:FindAbilityByName("B14D"):SetLevel(keys.ability:GetLevel()+1)
end

function B14T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("B14T_duration")
	ability:ApplyDataDrivenModifier( caster , caster , "modifier_B14T" , { duration = duration } )
end

function B14T_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	if GameRules:IsDaytime() then
		if caster:HasModifier("modifier_B14T2") then
			caster:RemoveModifierByName("modifier_B14T2")
		end
	else
		if caster.B14T_timer == nil then
			if not caster:HasModifier("modifier_B14T2") then
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_B14T2",nil)
			end
		end
	end
end

function B14T_OnAction( keys )
	local caster = keys.caster
	local ability = keys.ability

	if not GameRules:IsDaytime() then
		if caster.B14T_timer then
			Timers:RemoveTimer(caster.B14T_timer)
		end

		caster.B14T_timer = Timers:CreateTimer( 0.5, function ()
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_B14T2",nil)
	      	caster.B14T_timer = nil
	    end)
	end
end

function B14D_old_End( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local abilityDamage = ability:GetSpecialValueFor("B14D_old_damage")
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			PopupCriticalDamage(target, abilityDamage)
			AMHC:Damage( caster, target, abilityDamage, AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end	
		keys.caster:RemoveModifierByName( "modifier_B14D_old" )
		keys.caster:RemoveModifierByName( "modifier_invisible" )
	end
end

function B14W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("B14W_damage")
	local stunDuration = ability:GetSpecialValueFor("B14W_stunDuration")
	target:AddNewModifier( caster , ability , "modifier_stunned" , { duration = stunDuration } )

	local damageTable = {
		victim = target,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}
	ApplyDamage(damageTable)

	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()
	})
end

function B14E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local magicImmuneDuration = ability:GetSpecialValueFor("B14E_old_magicImmuneDuration")
	local am = target:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= target:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= target:GetTeamNumber() then
				target:RemoveModifierByName(v:GetName())
			end
		end
	end
	target:Purge( false , true , false , true , true )
	ability:ApplyDataDrivenModifier( caster , target , "modifier_perceive_wine" , { duration = magicImmuneDuration } )
end

function B14R_old_OnSuccess( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B14R_old_Crit", nil )
end

function B14T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("B14T_old_duration")
	ability:ApplyDataDrivenModifier( caster , caster , "modifier_B14T_old" , { duration = duration } )
	caster:FindAbilityByName("B14D_old"):SetLevel(ability:GetLevel())
	caster:FindAbilityByName("B14D_old"):SetActivated(true)
end

function B14T_old_OnDestroy( keys )
	local caster = keys.caster
	caster:FindAbilityByName("B14D_old"):SetActivated(false)
end
