-- 濃姬

function A26W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
end

function A26E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local knockback_speed = ability:GetSpecialValueFor("knockback_speed")
	local center = caster:GetAbsOrigin()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		center,							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration=duration})
		Physics:Unit(unit)
		local diff = unit:GetAbsOrigin()-center
		diff.z = 0
		unit:SetVelocity(Vector(0,0,-9.8))
		unit:AddPhysicsVelocity(diff:Normalized()*knockback_speed)
	end
end

function A26R_OnUpgrade( keys )
	local caster = keys.caster
	local ability = keys.ability
	local A26D = caster:FindAbilityByName("A26D")
	if IsValidEntity(A26D) then
		A26D:SetLevel(ability:GetLevel()+1)
	end
end

function A26R_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local crit_chance = ability:GetSpecialValueFor("crit_chance")
	local rnd = RandomInt(1,100)
	caster:RemoveModifierByName("modifier_A26R_crit")
	if crit_chance >= rnd then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A26R_crit",nil)
	end
end

function A26D_OnSpellStart( keys )
	local caster = keys.caster
	local center = keys.target_points[1]
	local ability = keys.ability
	local radius_setup = ability:GetSpecialValueFor("radius_setup")
	local number_of_sub_mine = ability:GetSpecialValueFor("number_of_sub_mine")

	CreateMine(ability, center)

	for i=1,number_of_sub_mine do
		local angle = RandomInt(1,360)
		local dx = math.cos(angle) * radius_setup
		local dy = math.sin(angle) * radius_setup
		CreateMine(ability, center+Vector(dx,dy,0))
	end
end

function CreateMine( ability, position )
	local caster = ability:GetCaster()
	local duration = ability:GetSpecialValueFor("duration")
	local mine = CreateUnitByName("A26_MINE",position,true,caster,caster,caster:GetTeamNumber())
	mine:AddNewModifier(caster,ability,"modifier_kill",{duration=duration})
	ability:ApplyDataDrivenModifier(mine,mine,"modifier_A26D_mine_aura",{duration=duration})
	mine:SetHullRadius(ability:GetSpecialValueFor("radius_trigger"))
end

function A26D_OnCreated( keys )
	local target = keys.target
	local ability = keys.ability

end

function A26D_OnTrigger( keys )
	local caster = keys.caster -- mine
	local ability = keys.ability

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	local attacker = ability:GetCaster()
	for _,unit in ipairs(units) do
		ApplyDamage({
			victim = unit,
			attacker = attacker,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE
		})
	end

	caster:ForceKill(true)
end

function A26T_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")

	local dummy = CreateUnitByName("npc_dummy_unit",point,false,nil,nil,caster:GetTeamNumber())

	-- 產生投射物	
	ProjectileManager:CreateTrackingProjectile({
		Target = dummy,
		Source = caster,
		Ability = ability,
		EffectName = "particles/units/heroes/hero_techies/techies_base_attack.vpcf",
		bDodgeable = false,
		bProvidesVision = false,
		iMoveSpeed = projectile_speed,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	})
end

function A26T_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stun_time = ability:GetSpecialValueFor("stun_time")
	local radius = ability:GetSpecialValueFor("radius")
	local need_stun = caster:HasModifier("modifier_A26T_big_bomb")

	if need_stun then
		caster:RemoveModifierByName("modifier_A26T_big_bomb")
	end

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		target:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		radius,							-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		-- 製造傷害
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE
		})
		if need_stun then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration=stun_time})
		end
	end

	ability.count = ability.count or 0
	ability.count = ability.count + 1
	if ability.count == 2 then 
		ability.count = -1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A26T_big_bomb",nil)
	end
	target:ForceKill(true)
end