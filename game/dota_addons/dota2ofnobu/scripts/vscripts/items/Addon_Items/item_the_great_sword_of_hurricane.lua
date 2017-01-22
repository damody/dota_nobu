
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local aura_duration = ability:GetLevelSpecialValueFor("aura_duration",0)

	local dummy = CreateUnitByName("npc_dummy_unit_new",caster:GetAbsOrigin(),false,caster,caster,caster:GetTeamNumber())
	dummy:AddNewModifier(caster,nil,"modifier_kill",{duration=aura_duration})
	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_great_sword_of_hurricane_aura", {duration=aura_duration})
end

function OnEquip( keys )
	local caster = keys.caster
end

function OnUnequip( keys )
	local caster = keys.caster
end

function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability

	-- 鏡像不給用:D
	if caster:IsIllusion() then return end

	-- Targeting variables
	local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE

	-- Ability variables
	local tornado_range = ability:GetLevelSpecialValueFor("tornado_range", 0)
	local tornado_speed = ability:GetLevelSpecialValueFor("tornado_speed", 0)
	local split_shot_projectile = "particles/item/item_the_great_sword_of_hurricane/tornado.vpcf"
	
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
	local tornado_damage = ability:GetLevelSpecialValueFor("tornado_damage",0)

	AMHC:Damage(caster, target, tornado_damage, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
end