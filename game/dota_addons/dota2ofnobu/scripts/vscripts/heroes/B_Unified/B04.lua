-- 伊達政宗

function B04W_Start( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local point = keys.target_points[1]
	local ability = keys.ability
	local speed = ability:GetSpecialValueFor("speed")
	local dir = (point-center):Normalized()
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir
	end
	local fake_center = center - dir
	local distance = (point-center):Length()
	local duration = distance/speed
	-- 把自己踢過去
	local knockbackProperties =
	{
	    center_x = fake_center.x,
	    center_y = fake_center.y,
	    center_z = fake_center.z,
	    duration = duration,
	    knockback_duration = duration,
	    knockback_distance = distance,
	    knockback_height = 0,
	    should_stun = 0,
	}
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_knockback",knockbackProperties)
	caster:RemoveGesture(ACT_DOTA_FLAIL)

	local projectile_radius = 400
	local velocity = speed * dir

	ProjectileManager:CreateLinearProjectile({
		Ability				= ability,
		EffectName			= "particles/dev/empty_particle.vpcf",
		vSpawnOrigin		= center,
		fDistance			= distance,
		fStartRadius		= projectile_radius,
		fEndRadius			= projectile_radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
		iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
		iUnitTargetType		= ability:GetAbilityTargetTeam(),
		fExpireTime			= GameRules:GetGameTime() + 10,
		bDeleteOnHit		= false,
		vVelocity			= Vector(velocity.x, velocity.y),
		bProvidesVision		= false,
		iVisionRadius		= 0,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	})

	ability.locked_targets = {}
end

function B04W_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local locked_targets = ability.locked_targets

	if locked_targets[target] == true then
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			--damage_flags = DOTA_DAMAGE_FLAG_NONE
		})
	else
		locked_targets[target] = true
		ProjectileManager:CreateTrackingProjectile({
			Target = target,
			Source = caster,
			Ability = ability,
			EffectName = "particles/dev/empty_particle.vpcf",
			bDodgeable = false,
			bProvidesVision = false,
			iMoveSpeed = ability:GetSpecialValueFor("speed")*0.5,
			iVisionRadius = 0,
			iVisionTeamNumber = caster:GetTeamNumber(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		})
	end
end

function B04E_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")

	local spell_hint_table = {
		duration   = 1,		-- 持續時間
		radius     = radius,	-- 半徑
	}
	local thinker = CreateModifierThinker(caster,ability,"nobu_modifier_spell_hint",spell_hint_table,point,caster:GetTeamNumber(),false)
	
	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		point,							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		radius,							-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 傷害資訊
	local damage_table = {
		--victim = target,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		--damage_flags = DOTA_DAMAGE_FLAG_NONE
	}

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		damage_table.victim = unit
		ApplyDamage(damage_table)
	end

	-- 砍樹
	GridNav:DestroyTreesAroundPoint(point, radius, false)
end

function B04T_OnCreated( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
end

function B04T_OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

function B04T_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stun_chance = ability:GetSpecialValueFor("stun_chance")
	local stun_time = ability:GetSpecialValueFor("stun_time")
	
	if target:IsHero() or target:IsCreep() then
		if stun_chance >= RandomInt(1,100) then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration=stun_time})
		end
	end
end

-- 伊達政宗 11.2B

function B04W_old_OnSpellStart( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local point = keys.target_points[1]
	local ability = keys.ability
	local speed = ability:GetSpecialValueFor("speed")
	local dir = (point-center):Normalized()
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir
	end
	local fake_center = center - dir
	local distance = (point-center):Length()
	local duration = distance/speed
	-- 把自己踢過去
	local knockbackProperties =
	{
	    center_x = fake_center.x,
	    center_y = fake_center.y,
	    center_z = fake_center.z,
	    duration = duration,
	    knockback_duration = duration,
	    knockback_distance = distance,
	    knockback_height = 0,
	    should_stun = 0,
	}
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_knockback",knockbackProperties)
	caster:RemoveGesture(ACT_DOTA_FLAIL)
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_B04W_old_aura",{duration=duration})
	caster:StartGesture(ACT_DOTA_VERSUS)
	Timers:CreateTimer(duration, function()
		if IsValidEntity(caster) then
			caster:RemoveGesture(ACT_DOTA_VERSUS)
		end
	end)
end