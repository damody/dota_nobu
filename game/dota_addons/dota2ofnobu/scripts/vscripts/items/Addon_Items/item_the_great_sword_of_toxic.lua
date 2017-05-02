function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = 560
	local int = 0
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	local mod = "particles/b33/b33r_old_poison.vpcf"
	local part = ParticleManager:CreateParticle(mod, PATTACH_ABSORIGIN, target)
	Timers:CreateTimer( 0,function ()
		if int <= 4 then
			int = int + 1
			AMHC:Damage( caster,target,50,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			PopupDamageOverTime(target, 50)
			return 1
		else
			ParticleManager:DestroyParticle(part, false)
			return nil
		end
	end)
end

function OnEquip( keys )
	local caster = keys.caster
end

function OnUnequip( keys )
	local caster = keys.caster
end

function OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
		ability:ApplyDataDrivenModifier(caster,caster,"Passive_the_great_bow_of_scorpion3",nil)
	elseif caster:HasModifier("Passive_the_great_bow_of_scorpion3") then
		caster:RemoveModifierByName("Passive_the_great_bow_of_scorpion3")
	end
end

function OnUnequip_scorpion( keys )
	local caster = keys.caster
	if caster:HasModifier("Passive_the_great_bow_of_scorpion3") then
		caster:RemoveModifierByName("Passive_the_great_bow_of_scorpion3")
	end
end

function Shock2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(target,target,"modifier_the_great_sword_of_toxic",nil)
		ability:ApplyDataDrivenModifier(caster,target,"modifier_the_great_sword_of_toxic2",nil)
		AMHC:Damage( caster,target,85,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end

function Shock_puffer_poison( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_puffer_poison",nil)
		AMHC:Damage( caster,target,45,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )	
	end
end

function Shock_poisonous_ring( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	print("Shock_poisonous_ring")
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_poisonous_ring",nil)
		AMHC:Damage( caster,target,20,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )	
	end
end

function Shock_bow_of_scorpion( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = 560
	local int = 0
	local group = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

	for _,v in ipairs(group) do
	local projTable = {
		EffectName = "particles/b33r/b33r.vpcf",
		Ability = ability,
		Target = v,
		Source = caster,
		bDodgeable = false,
		bProvidesVision = false,
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1200,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projTable )
	end
	
end

function Shock_bow_of_scorpion2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = 560
	local int = 0
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	ability:ApplyDataDrivenModifier(caster,target,"modifier_the_great_bow_of_scorpion2",nil)
end
