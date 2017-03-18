-- 伊勢姬 by Nian Chen
-- 2017.3.18

--亡魂Table
B23D_ghostTable = {} 

--D 亡靈之契
function B23D_OnSpellStart( keys )
	local caster = keys.caster
    local count = keys.ability:GetLevelSpecialValueFor("B23D_count", keys.ability:GetLevel()-1 )
    local spawnPosition
    if #B23D_ghostTable < count then
    	for i,v in pairs(keys.target_entities) do
	        if v:GetHealth() == 0 then
	        	spawnPosition = v:GetOrigin()
	        	break
	        end
	    end
    	local ghost = CreateUnitByName("B23D_ghost", spawnPosition, true, nil, nil , caster:GetTeamNumber())
	    ghost:SetOwner(caster)
	    ghost:SetControllableByPlayer(caster:GetPlayerID(), true)
	    ghost:SetBaseDamageMin( 52 + 3 * caster:GetLevel() )
	    ghost:SetBaseDamageMax( 58 + 3 * caster:GetLevel() )
	    ghost:SetBaseMaxHealth( 700 + 36 * caster:GetLevel() )
	    ghost:SetHealth( ghost:GetMaxHealth() )
	    ghost:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})

	    table.insert(B23D_ghostTable, ghost)

	    keys.ability:ApplyDataDrivenModifier( caster, caster, "modifier_B23D_damageReduction", nil )
		local hModifier = caster:FindModifierByNameAndCaster("modifier_B23D_damageReduction", caster)
		hModifier:SetStackCount( #B23D_ghostTable )
	    keys.ability:ApplyDataDrivenModifier( caster, ghost, "modifier_B23D_diedTrigger", nil)
	    keys.ability:ApplyDataDrivenModifier( caster, ghost, "modifier_B23D_distanceDetector_ghost", nil)
    end
    
end

function B23D_check( keys )
	local caster = keys.caster
	local deadBody = false
	for i,v in pairs(keys.target_entities) do
        if v:GetHealth() == 0 then
        	deadBody = true
        	break
        end
    end
    if deadBody == false then
    	caster:Interrupt()
    end
end

function B23D_die( keys )
	local unit = keys.unit
	local owner = unit:GetOwner()
	local particle = ParticleManager:CreateParticle("particles/item/c05/c05.vpcf",PATTACH_POINT,unit)
	ParticleManager:SetParticleControl(particle,0, unit:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle,1, unit:GetAbsOrigin())

	for i=1,#B23D_ghostTable do
		if B23D_ghostTable[i] == unit then
			table.remove(B23D_ghostTable, i)
		end
	end

	local hModifier = owner:FindModifierByNameAndCaster("modifier_B23D_damageReduction", owner)
	hModifier:SetStackCount( #B23D_ghostTable )

	if hModifier:GetStackCount() == 0 then
		owner:RemoveModifierByName("modifier_B23D_damageReduction")
	end

	local mana = owner:GetMana() - owner:GetMaxMana() * 0.15
	if mana < 0 then
		owner:SetMana(0)
	else
		owner:SetMana(mana)
	end
end

function B23D_heroDie( keys )
	for i=1,#B23D_ghostTable do
		B23D_ghostTable[1]:ForceKill(true)
	end
end

function B23D_distanceDetector_hero( keys )
	local heroPosition = keys.unit:GetOrigin()

	for i=1,#B23D_ghostTable do
		if (B23D_ghostTable[i]:GetOrigin() - heroPosition):Length() >= 1200 then
			FindClearSpaceForUnit( B23D_ghostTable[i], heroPosition + RandomVector(RandomInt(100,200)) , true)
			local particle = ParticleManager:CreateParticle("particles/item/c05/c05.vpcf",PATTACH_POINT,B23D_ghostTable[i])
			ParticleManager:SetParticleControl(particle,0, B23D_ghostTable[i]:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle,1, B23D_ghostTable[i]:GetAbsOrigin())
			B23D_ghostTable[i]:AddNewModifier(B23D_ghostTable[i],nil,"modifier_phased",{duration=0.1})
			B23D_ghostTable[i]:Stop()
		end
	end
end

function B23D_distanceDetector_ghost( keys )
	local unit = keys.unit
	local heroPosition = unit:GetOwner():GetOrigin()
	if (unit:GetOrigin() - heroPosition):Length() >= 1200 then
		FindClearSpaceForUnit( unit, heroPosition + RandomVector(RandomInt(100,200)) , true)
		local particle = ParticleManager:CreateParticle("particles/item/c05/c05.vpcf",PATTACH_POINT,unit)
		ParticleManager:SetParticleControl(particle,0, unit:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle,1, unit:GetAbsOrigin())
		unit:AddNewModifier(unit,nil,"modifier_phased",{duration=0.1})
		unit:Stop()
	end
end

function B23D_onCreated( keys )
	keys.ability:SetLevel( 1 )
end

--W 聚靈咒	ref A19W
function B23W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()

	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=30} )
	dummy:SetOwner( caster)
	dummy:AddAbility( "majia"):SetLevel(1)

	local ifx = ParticleManager:CreateParticle( "particles/b23w/abyssal_underlord_darkrift_target.vpcf", PATTACH_ABSORIGIN, dummy)
	ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 1, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 2, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 4, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 5, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 6, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 20, point + Vector(0,0,100))
	ParticleManager:ReleaseParticleIndex( ifx )
	
	local radius = ability:GetSpecialValueFor("B23W_radius")
	local time = 0.1 + ability:GetSpecialValueFor("B23W_duration")
	local count = 0
--靈火傷害
	Timers:CreateTimer(0,function()
		count = count + 1
		if count > time then
			return nil
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
		for _,unit in ipairs(units) do
			ApplyDamage({
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = ability:GetSpecialValueFor("B23W_fireDamage"),
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			})
		end		
		return 1
	end)
--亡魂傷害
	for i=1,#B23D_ghostTable do
		FindClearSpaceForUnit( B23D_ghostTable[i], point + RandomVector(RandomInt(100,200)) , true)
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
		for _,unit in ipairs(units) do
			ApplyDamage({
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = ability:GetSpecialValueFor("B23W_shockDamage"),
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			})
		end
	end

end

--E 生靈衝擊
function B23E_onSpellStart( keys )
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	
	for i=1, #B23D_ghostTable do
		local projTable = {
	        EffectName = "particles/units/heroes/hero_bane/bane_projectile.vpcf",
	        Ability = ability,
	        vSpawnOrigin = B23D_ghostTable[i]:GetOrigin(),
	        Target = target,
	        Source = B23D_ghostTable[i],
	        bDodgeable = false,
	        iMoveSpeed = 1300,
	        iVisionRadius = 225,
			iVisionTeamNumber = caster:GetTeamNumber(),
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	        iUnitTargetType = ability:GetAbilityDamageType(),
	        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
   	 	}
   	 	ProjectileManager:CreateTrackingProjectile( projTable )
	end

end

function B23E_onProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = ability:GetSpecialValueFor("B23E_damage"),
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	})
end

--R 魂饗
function B23R( keys )
	local caster = keys.caster
	local ability = keys.ability
	local healPoint = ability:GetLevelSpecialValueFor("B23R_heal", ability:GetLevel()-1 )

	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B23R_castAnimation", nil )
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B23R_magicImmune", nil )
	for i=1, #B23D_ghostTable do
		ability:ApplyDataDrivenModifier( caster, B23D_ghostTable[i], "modifier_B23R_magicImmune", nil )
	end

	Timers:CreateTimer(0, function()
		local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), nil, 800, ability:GetAbilityTargetTeam(),
				ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
		for k, v in pairs( units ) do
			v:Heal( healPoint , caster )
		end
		
		if caster:IsChanneling() == false then
			return nil
		else
			return 0.2
		end
	end)
end

function B23R_interrupted( keys )
	local caster = keys.caster
	caster:RemoveModifierByName("modifier_B23R_castAnimation")
	for i=1, #B23D_ghostTable do
		B23D_ghostTable[i]:RemoveModifierByName( "modifier_B23R_magicImmune" )
	end
end

--T 英靈庇佑
function B23T( keys )
	local caster = keys.caster
	local ability = keys.ability

	for i=1, #B23D_ghostTable do
		ability:ApplyDataDrivenModifier( caster, B23D_ghostTable[i], "modifier_B23T_attackspeedBonus", nil )
	end
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B23T_castAnimation", nil )
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B23T_invulnerableAura", nil )
end

function B23T_interrupted( keys )
	local caster = keys.caster
	for i=1, #B23D_ghostTable do
		B23D_ghostTable[i]:RemoveModifierByName( "modifier_B23T_attackspeedBonus" )
	end
	caster:RemoveModifierByName("modifier_B23T_invulnerableAura")
	caster:RemoveModifierByName("modifier_B23T_castAnimation")
end

function B23T_upgrade( keys )
	keys.caster:FindAbilityByName("B23D"):SetLevel(keys.ability:GetLevel()+1)
end
