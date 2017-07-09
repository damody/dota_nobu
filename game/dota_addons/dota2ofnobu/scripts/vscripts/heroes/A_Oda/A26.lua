-- 濃姬

function A26W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

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
		if IsValidEntity(unit) then
			local dir = (caster:GetAbsOrigin()-unit:GetAbsOrigin()):Normalized()
			local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_base_attack_explosion_b.vpcf",PATTACH_POINT,unit)
			ParticleManager:SetParticleControlEnt(ifx,3,unit,PATTACH_POINT,"attach_hitloc",unit:GetAbsOrigin()+Vector(0,0,200),true)
			ParticleManager:SetParticleControlForward(ifx,3,dir)
			ParticleManager:ReleaseParticleIndex(ifx)
		end
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
		nil,
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if _G.EXCLUDE_TARGET_NAME[unit:GetUnitName()] == nil then
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
			local dir = diff:Normalized()
			unit:SetVelocity(Vector(0,0,-9.8))
			unit:AddPhysicsVelocity(dir*knockback_speed)


			local ifx = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_attack_smoke_arcana.vpcf",PATTACH_ABSORIGIN,caster)
			local attack_point = caster:GetAbsOrigin() + dir*100
			attack_point.z = 200
			ParticleManager:SetParticleControl(ifx,0,attack_point)
			ParticleManager:SetParticleControl(ifx,7,attack_point)
			ParticleManager:SetParticleControlForward(ifx,0,dir)
			ParticleManager:SetParticleControl(ifx,15,Vector(255,255,255))
			ParticleManager:SetParticleControl(ifx,16,Vector(1,0,0))
			ParticleManager:ReleaseParticleIndex(ifx)
		end
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
	if caster.A26R_count == nil then
		caster.A26R_count = 0
	end
	caster.A26R_count = caster.A26R_count + 1
	if crit_chance >= rnd or caster.A26R_count > (100/crit_chance) then
		caster.A26R_count = 0
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A26R_crit",{})
		local rate = caster:GetAttackSpeed()
		if rate < 1 then
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
		else
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end
	end
end

function A26D_OnSpellStart( keys )
	local caster = keys.caster
	local center = keys.target_points[1]
	local ability = keys.ability
	local radius_sub_mine = ability:GetSpecialValueFor("radius_sub_mine")
	local number_of_sub_mine = ability:GetSpecialValueFor("number_of_sub_mine")
	local duration = ability:GetSpecialValueFor("duration")

	CreateMine(ability, center, nil)

	for i=1,number_of_sub_mine do
		local angle = RandomInt(1,360)
		local dx = math.cos(angle) * radius_sub_mine
		local dy = math.sin(angle) * radius_sub_mine
		CreateMine(ability, center+Vector(dx,dy,0), duration)
	end

	EmitSoundOn("Hero_Techies.StasisTrap.Plant",caster)
end

function CreateMine( ability, position, duration )
	local caster = ability:GetCaster()
	local active_delay = ability:GetSpecialValueFor("active_delay")
	local mine 
	if caster.skin == "school" then
		mine = CreateUnitByName("A26_MINE_school_hero", position, false, caster, caster, caster:GetTeamNumber())
	else
		mine = CreateUnitByName("A26_MINE_hero", position, false, caster, caster, caster:GetTeamNumber())
	end
	mine:RemoveModifierByName("modifier_invulnerable")
	mine:SetForwardVector(RandomVector(1)) 
	mine:SetOwner(caster)
	ability:ApplyDataDrivenModifier(caster,mine,"modifier_A26D_mine_passive",{})
	Timers:CreateTimer(active_delay, function()
		if IsValidEntity(mine) and mine:IsAlive() then
			if duration then
				mine:AddNewModifier(caster,ability,"modifier_kill",{duration=duration})
				ability:ApplyDataDrivenModifier(mine,mine,"modifier_A26D_mine_aura",{duration=duration})
			else
				ability:ApplyDataDrivenModifier(mine,mine,"modifier_A26D_mine_aura",{})
			end
		end
	end)
end

function A26D_OnTrigger( keys )
	local caster = keys.caster -- mine
	local ability = keys.ability
	local radius_explosion = ability:GetSpecialValueFor("radius_explosion")

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		radius_explosion,				-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	local attacker = ability:GetCaster()
	for _,unit in ipairs(units) do
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE
		})
	end

	local center = caster:GetAbsOrigin()
	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(ifx,0,center)
	ParticleManager:SetParticleControl(ifx,1,Vector(0,0,radius_explosion))
	ParticleManager:SetParticleControl(ifx,2,Vector(1,0,0))
	ParticleManager:ReleaseParticleIndex(ifx)

	EmitSoundOn("Hero_Techies.LandMine.Detonate",caster)
	caster:RemoveModifierByName("modifier_A26D_mine_aura")
	for _,unit in ipairs(units) do
		unit:RemoveModifierByName("modifier_A26D_mine_trigger")
	end
	caster:ForceKill(true)
end

function A26T_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")

	-- 計算攻擊次數
	ability.count = ability.count or 0
	ability.count = ability.count + 1
	if ability.count == 2 then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A26T_big_bomb",{})
	end
	if ability.count == 3 then
		ability.count = 0
		ability.need_stun = true
		caster:RemoveModifierByName("modifier_A26T_big_bomb")
	end

	local dummy = CreateUnitByName("npc_dummy_unit",point,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(nil,nil,"modifier_kill",{duration=20})
	local diff = point-caster:GetAbsOrigin()
	diff.z = 0
	dummy:SetForwardVector(diff:Normalized())
	-- 產生投射物	
	local projectile_table = {
		Target = dummy,
		Source = caster,
		Ability = ability,
		EffectName = "",
		bDodgeable = true,
		bProvidesVision = false,
		iMoveSpeed = projectile_speed,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	if ability.need_stun then
		projectile_table.EffectName = "particles/econ/items/techies/techies_arcana/techies_base_attack_arcana.vpcf"
	else
		projectile_table.EffectName = "particles/units/heroes/hero_techies/techies_base_attack.vpcf"
	end
	if caster.skin == "school" then
		projectile_table.EffectName = "particles/a26/a26t_bookecon/items/techies/techies_arcana/techies_base_attack_arcana.vpcf"
	end
	ProjectileManager:CreateTrackingProjectile(projectile_table)
end

function A26T_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local center = target:GetAbsOrigin()
	local ability = keys.ability
	local stun_time = ability:GetSpecialValueFor("stun_time")
	local radius = ability:GetSpecialValueFor("radius")

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		center,							-- 搜尋的中心點
		nil,
		radius,							-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		-- 製造傷害
		if unit:IsMagicImmune() then
			ApplyDamage({
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = ability:GetAbilityDamage()*0.5,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE
			})
		else
			ApplyDamage({
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = ability:GetAbilityDamage(),
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE
			})
		end
		
		if ability.need_stun then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration=stun_time})
		end
	end

	GridNav:DestroyTreesAroundPoint(center, radius, false)

	if ability.need_stun then
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flamebreak_explosion.vpcf",PATTACH_ABSORIGIN,target)
		ParticleManager:SetParticleControl(ifx,3,target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(ifx)
	end

	local ifx = ParticleManager:CreateParticle("particles/econ/courier/courier_snapjaw/courier_snapjaw_ambient_rocket_explosion.vpcf",PATTACH_ABSORIGIN,target)
	ParticleManager:SetParticleControl(ifx,3,target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(ifx)

	ability.need_stun = false

	EmitSoundOn("Hero_Techies.RemoteMine.Detonate",target)
end

-- 濃姬 11.2B

function A26W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	for i,unit in ipairs(units) do
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		caster:PerformAttack(unit, true, true, true, true, true, false, true)
		if IsValidEntity(unit) then
			local dir = (caster:GetAbsOrigin()-unit:GetAbsOrigin()):Normalized()
			local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_base_attack_explosion_b.vpcf",PATTACH_POINT,unit)
			ParticleManager:SetParticleControlEnt(ifx,3,unit,PATTACH_POINT,"attach_hitloc",unit:GetAbsOrigin()+Vector(0,0,200),true)
			ParticleManager:SetParticleControlForward(ifx,3,dir)
			ParticleManager:ReleaseParticleIndex(ifx)
		end

		-- 最多4個敵人
		if i == 4 then break end
	end
end

function A26E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local knockback_duration = ability:GetSpecialValueFor("knockback_duration")
	local knockback_speed = ability:GetSpecialValueFor("knockback_speed")
	local center = caster:GetAbsOrigin()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		center,							-- 搜尋的中心點
		nil,
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	local damage_table = {
		--victim = unit,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		--damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if _G.EXCLUDE_TARGET_NAME[unit:GetUnitName()] == nil then
			damage_table.victim = unit
			ApplyDamage(damage_table)
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_rooted",{duration=knockback_duration})
			Physics:Unit(unit)
			local diff = unit:GetAbsOrigin()-center
			diff.z = 0
			local dir = diff:Normalized()
			unit:SetVelocity(Vector(0,0,-9.8))
			unit:AddPhysicsVelocity(dir*knockback_speed)

			ability:ApplyDataDrivenModifier(caster,unit,"modifier_A26E_old_debuff",{})

			local ifx = ParticleManager:CreateParticle("particles/econ/items/techies/techies_arcana/techies_attack_smoke_arcana.vpcf",PATTACH_ABSORIGIN,caster)
			local attack_point = caster:GetAbsOrigin() + dir*100
			attack_point.z = 200
			ParticleManager:SetParticleControl(ifx,0,attack_point)
			ParticleManager:SetParticleControl(ifx,7,attack_point)
			ParticleManager:SetParticleControlForward(ifx,0,dir)
			ParticleManager:SetParticleControl(ifx,15,Vector(255,255,255))
			ParticleManager:SetParticleControl(ifx,16,Vector(1,0,0))
			ParticleManager:ReleaseParticleIndex(ifx)
		end
	end
end

function A26R_old_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local crit_chance = ability:GetSpecialValueFor("crit_chance")
	local rnd = RandomInt(1,100)
	--caster:RemoveModifierByName("modifier_A26R_old_crit")
	if caster.A26R_count == nil then
		caster.A26R_count = 0
	end
	caster.A26R_count = caster.A26R_count + 1
	if crit_chance >= rnd or caster.A26R_count > 4 then
		caster.A26R_count = 0
		--ability:ApplyDataDrivenModifier(caster,caster,"modifier_A26R_old_crit",{})
		caster:PerformAttack(target, true, true, true, true, true, false, true)
		local rate = caster:GetAttackSpeed()
		if rate < 1 then
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
		else
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end
	end
end

function A26T_old_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")

	local dummy = CreateUnitByName("npc_dummy_unit",point,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(nil,nil,"modifier_kill",{duration=5})
	local diff = point-caster:GetAbsOrigin()
	diff.z = 0
	dummy:SetForwardVector(diff:Normalized())
	-- 產生投射物	
	local projectile_table = {
		Target = dummy,
		Source = caster,
		Ability = ability,
		EffectName = "particles/econ/items/techies/techies_arcana/techies_base_attack_arcana.vpcf",
		bDodgeable = true,
		bProvidesVision = true,
		iMoveSpeed = projectile_speed,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	if caster.skin == "school" then
		projectile_table.EffectName = "particles/a26/a26t_bookecon/items/techies/techies_arcana/techies_base_attack_arcana.vpcf"
	end
	ProjectileManager:CreateTrackingProjectile(projectile_table)
end

function A26T_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local center = target:GetAbsOrigin()
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		center,							-- 搜尋的中心點
		nil,
		radius,							-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	local damage_table = {
		--victim = unit,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		--damage_flags = DOTA_DAMAGE_FLAG_NONE
	}

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		-- 製造傷害
		damage_table.victim = unit
		if unit:IsHero() then
			ApplyDamage(damage_table)
		else
			for i=1,10 do
				ApplyDamage(damage_table)
			end
		end
	end

	GridNav:DestroyTreesAroundPoint(center, radius, false)

	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flamebreak_explosion.vpcf",PATTACH_ABSORIGIN,target)
	ParticleManager:SetParticleControl(ifx,3,target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(ifx)

	local ifx = ParticleManager:CreateParticle("particles/econ/courier/courier_snapjaw/courier_snapjaw_ambient_rocket_explosion.vpcf",PATTACH_ABSORIGIN,target)
	ParticleManager:SetParticleControl(ifx,3,target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(ifx)

	EmitSoundOn("Hero_Techies.RemoteMine.Detonate",target)
end