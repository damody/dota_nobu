function B15W_on_spell_start(keys)
	-- keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_black_king_bar_datadriven_active", nil)
	keys.caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
	
	local final_model_scale = (30 / 100) + 1  --This will be something like 1.3.
	local model_scale_increase_per_interval = 100 / (final_model_scale - 1)
	local duration = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1 )

	--Scale the model up over time.
	for i=1,100 do
		Timers:CreateTimer(i/75, 
		function()
			keys.caster:SetModelScale(1 + i/model_scale_increase_per_interval)
		end)
	end

	--Scale the model back down around the time the duration ends.
	for i=1,100 do
		Timers:CreateTimer(duration - 1 + (i/50),
		function()
			keys.caster:SetModelScale(final_model_scale - i/model_scale_increase_per_interval)
		end)
	end
end

--[[Author: Pizzalol
	Date: 04.03.2015.
	Creates additional attack projectiles for units within the specified radius around the caster]]
function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	print("@@@@@222222222222222")
	-- Targeting variables
	local target_type = ability:GetAbilityTargetType()
	local target_team = ability:GetAbilityTargetTeam()
	local target_flags = ability:GetAbilityTargetFlags()
	local attack_target = caster:GetAttackTarget()

	-- Ability variables
	local projectile_speed = 1800
	local split_shot_projectile = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf"

	local projectile_info = 
	{
		EffectName = split_shot_projectile,
		Ability = ability,
		vSpawnOrigin = caster_location,
		Target = attack_target,
		Source = caster,
		bHasFrontalCone = false,
		iMoveSpeed = projectile_speed,
		bReplaceExisting = false,
		bProvidesVision = false
	}
	ProjectileManager:CreateTrackingProjectile(projectile_info)
end

-- Apply the auto attack damage to the hit unit
function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = ability:GetAbilityDamageType()
	--damage_table.damage = caster:GetAttackDamage()
	damage_table.damage = 12000

	ApplyDamage(damage_table)
end

-- Apply the auto attack damage to the hit unit
function test( keys )
print("@@@@@1111")
end