
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local aura_duration = ability:GetSpecialValueFor("aura_duration")

	local dummy = CreateUnitByName("ksitigarbha_stick", ability:GetCursorPosition(),false,caster,caster,caster:GetTeamNumber())
	dummy:AddNewModifier(caster,nil,"modifier_kill",{duration=aura_duration})
	dummy:SetOwner(caster)
	dummy:AddNewModifier(dummy,ability,"modifier_phased",{duration=0.1})
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_great_sword_of_hurricane_auto_attack", {duration=aura_duration})
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_great_sword_of_hurricane_auto_attack2", {duration=aura_duration})

	local spell_hint_table = {
		duration   = aura_duration,		-- 持續時間
		radius     = 1000,		-- 半徑
	}
	dummy:AddNewModifier(dummy,nil,"nobu_modifier_spell_hint",spell_hint_table)
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_invulnerable",{duration = aura_duration})
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_ksitigarbha_aura", {duration=aura_duration})
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_ksitigarbha_hero_aura", {duration=aura_duration})
end

function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability

	-- Targeting variables
	local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

	-- Ability variables
	local tornado_range = ability:GetLevelSpecialValueFor("tornado_range", 0)
	local tornado_speed = ability:GetLevelSpecialValueFor("tornado_speed", 0)
	local split_shot_projectile = "particles/c19_projectile/c19_projectile.vpcf"
	
	local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), 
		caster_location, 
		nil, 
		tornado_range, 
		target_team, 
		target_type, 
		target_flags, 
		FIND_ANY_ORDER, 
		false)

	if #split_shot_targets == 0 then return end

	-- 隨機選擇一個敵方單位
	local rnd = RandomInt(1,#split_shot_targets)

	-- 打出風之傷
	local info = {
		Target = split_shot_targets[rnd],
		Source = caster,
		Ability = ability,
		EffectName = split_shot_projectile,
		bDodgeable = false,
		bProvidesVision = false,
		iMoveSpeed = tornado_speed,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( info )
end

-- Apply the auto attack damage to the hit unit
function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster:IsAlive() then
		AMHC:Damage(caster, target, 150, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	else
		AMHC:Damage(caster.donkey, target, 150, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end