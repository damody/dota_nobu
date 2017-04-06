-- 松永久秀 by Nian Chen
-- 2017.4.1

function B28E( keys )
	local caster = keys.caster
	local target = keys.target
	caster.B28E_target = target

	local particle = ParticleManager:CreateParticle("particles/b28e/b28e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	
	Timers:CreateTimer(0.2, function ()
      	if target ~= nil and IsValidEntity(target) and target:HasModifier("modifier_B28E") and caster:HasModifier("modifier_B28E2") then
      		local particle2 = ParticleManager:CreateParticle("particles/b28e/b28e.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(particle2, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
      		return 0.2
      	else
      		if IsValidEntity(target) then
      			target:RemoveModifierByName("modifier_B28E")
      		end
      		if IsValidEntity(caster) then
      			caster.B28E_target = nil
      		end
      		if particle then
      			ParticleManager:DestroyParticle(particle,false)
      		end
      		return nil
      	end
    end)
end

function B28R_OnProjectileHitUnit( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	if target:IsBuilding() then
		AMHC:Damage( caster,target,ability:GetSpecialValueFor("B28R_damage")*0.2,AMHC:DamageType("DAMAGE_TYPE_MAGICAL") )
	else
		AMHC:Damage( caster,target,ability:GetSpecialValueFor("B28R_damage"),AMHC:DamageType("DAMAGE_TYPE_MAGICAL") )
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B28R_dot",nil)
	end
end

function B28R_OnIntervalThink( keys )
	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetSpecialValueFor("B28R_radius")

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for i,v in ipairs(units) do
		if caster:CanEntityBeSeenByMyTeam(v) then
			local projTable = {
		        EffectName = "particles/b28r/b28r.vpcf",
		        Ability = ability,
		        vSpawnOrigin = caster:GetAbsOrigin(),
		        Target = v,
		        Source = caster,
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
			break
		end
	end
end

function B28T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("B28T_radius")
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", (ability:GetLevel() -1))
	local point = keys.target_points[1]

	local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	local count = 0
	for i,unit in ipairs(units) do
		count = count + 1
		B28T_old_jump_init(keys, caster:GetAbsOrigin(), unit, count)
		ApplyDamage({victim = unit, attacker = caster, damage = base_damage, damage_type = ability:GetAbilityDamageType()})
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_B28T_arc_lightning_datadriven",{})
	end
end

function B28T_old_jump_init(keys, start_pos, target, count)
	local caster = keys.caster
	local ability = keys.ability
	-- Keeps track of the total number of instances of the ability (increments on cast)
	if ability.instance == nil then
		ability.instance = 0
		ability.jump_count = {}
		ability.target = {}
		ability.first_target = {}
	else
		ability.instance = ability.instance + 1
	end
	--print("ability.instance", ability.instance)

	ability.jump_count[ability.instance] = ability:GetLevelSpecialValueFor("jump_max", (ability:GetLevel() -1))
	ability.target[ability.instance] = target
	ability.first_target[ability.instance] = target

	
	-- Creates the particle between the caster and the first target
	local lightningBolt = ParticleManager:CreateParticle("particles/b28t/b28t.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(lightningBolt,1,caster,PATTACH_POINT_FOLLOW,"attach_attack1",caster:GetAbsOrigin(),true)
	ParticleManager:SetParticleControlEnt(lightningBolt,2,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetAbsOrigin(),true)
end

function B28T_old_Jump(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local jump_delay = ability:GetLevelSpecialValueFor("jump_delay", (ability:GetLevel() -1))
	local jump_radius = ability:GetLevelSpecialValueFor("jump_radius", (ability:GetLevel() -1))
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", (ability:GetLevel() -1))
	local bonus_damage = ability:GetLevelSpecialValueFor("bonus_damage", (ability:GetLevel() -1))
	local jump_max = ability:GetLevelSpecialValueFor("jump_max", (ability:GetLevel() -1))
	local team = ability:GetAbilityTargetTeam()

	-- Removes the hidden modifier
	target:RemoveModifierByName("modifier_B28T_arc_lightning_datadriven")
	local count = 0
	-- Waits on the jump delay
	local pos = target:GetAbsOrigin()
	Timers:CreateTimer(jump_delay,
	function()
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
	end
	-- Decrements our jump count for this instance
	ability.jump_count[current] = ability.jump_count[current] - 1

	-- Checks if there are jumps left
	if ability.jump_count[current] > 0 then
		-- Finds units in the jump_radius to jump to
		local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, jump_radius, team, ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		local closest = jump_radius
		local new_target
		--print("current", current)
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = pos - unit_location
			local distance = (vector_distance):Length2D()
			-- Checks if the unit is closer than the closest checked so far
			if distance < closest then
				-- If the unit has not been hit yet, we set its distance as the new closest distance and it as the new target
				if unit.hit == nil then
					new_target = unit
					closest = distance
				elseif unit.hit[current] == nil then
					new_target = unit
					closest = distance
				end
			end
		end
		-- Checks if there is a new target
		if new_target ~= nil then
			AddFOWViewer(caster:GetTeamNumber(),new_target:GetAbsOrigin(),300,2.0,false)
			-- Creates the particle between the new target and the last target
			local lightningBolt = ParticleManager:CreateParticle("particles/b28t/b28t.vpcf", PATTACH_POINT_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(lightningBolt,1,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetAbsOrigin(),true)
			ParticleManager:SetParticleControlEnt(lightningBolt,2,new_target,PATTACH_POINT_FOLLOW,"attach_hitloc",new_target:GetAbsOrigin(),true)
			-- Sets the new target as the current target for this instance
			ability.target[current] = new_target
			-- Applies the modifer to the new target, which runs this function on it
			ability:ApplyDataDrivenModifier(caster, new_target, "modifier_B28T_arc_lightning_datadriven", {})
			-- Applies damage to the target
			local new_damage = base_damage*(1+(jump_max-ability.jump_count[current])*bonus_damage)
			Timers:CreateTimer(0.3, function ()
				if IsValidEntity(new_target) and IsValidEntity(caster) then
					ApplyDamage({victim = new_target, attacker = caster, damage = new_damage, damage_type = ability:GetAbilityDamageType()})
				end
				end)
		else
			-- If there are no new targets, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
		end
	else
		-- If there are no more jumps, we set the current target to nil to indicate this instance is over
		ability.target[current] = nil
	end
	end)
end

function B28W_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local duration1 = ability:GetSpecialValueFor("B28W_old_duration1")
	local duration2 = ability:GetSpecialValueFor("B28W_old_duration2")
	local tick1 = ability:GetSpecialValueFor("B28W_old_tick1")
	local tick2 = ability:GetSpecialValueFor("B28W_old_tick2")
	local damage1 = ability:GetSpecialValueFor("B28W_old_damage1")
	local damage2 = ability:GetSpecialValueFor("B28W_old_damage2")
	local adjustOnBuilding = ability:GetSpecialValueFor("B28W_old_adjustOnBuilding")
	local radius = ability:GetSpecialValueFor("B28W_old_radius")

	local ifx = ParticleManager:CreateParticle("particles/a19/a19_wfire/monkey_king_spring_arcana_fire.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(ifx,0,point)
	ParticleManager:ReleaseParticleIndex(ifx)
	local ifx2 = ParticleManager:CreateParticle("particles/a19/a19w_oldchar.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(ifx2,3,point)

	local time = duration1
	local count1 = 0
	Timers:CreateTimer(0,function()
		count1 = count1 + tick1
		if count1 > time then
			return nil
		end
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			point,			-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			radius,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in ipairs(units) do
			local damageTable = {
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = damage1,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			if unit:IsBuilding() then
				damageTable.damage = damageTable.damage * adjustOnBuilding
			end
			ApplyDamage(damageTable)
		end
		return tick1
	end)
	local count2 = 0
	Timers:CreateTimer(duration1,function()
		count2 = count2 + tick2
		if count2 > duration2 then
			ParticleManager:DestroyParticle(ifx2,false)
			return nil
		end
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			point,			-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			radius,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in ipairs(units) do
			local damageTable = {
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = damage2,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			if unit:IsBuilding() then
				damageTable.damage = damageTable.damage * adjustOnBuilding
			end
			ApplyDamage(damageTable)
		end
		return tick2
	end)
end

function B28R_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local wave_delay = ability:GetSpecialValueFor("B28R_old_waveDelay")
	local adjustOnBuilding = ability:GetSpecialValueFor("B28R_old_adjustOnBuilding")
	local aoe_radius = ability:GetSpecialValueFor("B28R_old_radius")
	local aoe_damage = ability:GetSpecialValueFor("B28R_old_damage")
	local max_wave = ability:GetSpecialValueFor("B28R_old_maxWave")
	local channelTime = ability:GetChannelTime()
	local aoe_damage_type = ability:GetAbilityDamageType()
	
	ability.isChanneling = true

	-- 搜尋參數
	local iTeam = caster:GetTeamNumber()
	local center = keys.target_points[1]
	local tTeam = ability:GetAbilityTargetTeam()
	local tType = ability:GetAbilityTargetType()
	local tFlag = ability:GetAbilityTargetFlags()

	Timers:CreateTimer(0, function()
		-- 停止施法則中斷
		if not ability.isChanneling then
			return nil
		end
		AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 1, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 1, false)
		-- 照亮目標周圍
		AddFOWViewer(iTeam,center,aoe_radius*1.1,1.0,false)
		-- 搜尋敵人
		local units = FindUnitsInRadius(iTeam,center,nil,aoe_radius,tTeam,tType,tFlag,FIND_ANY_ORDER,false)
		for _,unit in ipairs(units) do
			local adjust = 1.0
			if unit:IsBuilding() then
				adjust = adjustOnBuilding
			end
			-- 傷害參數
			local damage_table = {
				attacker = caster,
				victim = unit,
				damage = aoe_damage*adjust,
				damage_type = aoe_damage_type
			}
			
			-- 配合特效延遲傷害造成時間
			Timers:CreateTimer(0.3, function()
				if not unit:IsBuilding() then
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_B28R_old_dot",nil)
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = 0.25})
				end
				ApplyDamage(damage_table)
			end)
		end
		-- 特效
		B28R_create_meteor_particle_effect(caster, center, aoe_radius)
		return wave_delay
	end)

	-- 配合特效延遲砍樹
	Timers:CreateTimer(0.45, function()
		GridNav:DestroyTreesAroundPoint(center, aoe_radius, false)
	end)
end

function B28R_create_meteor_particle_effect( caster, target_pos, radius )
	local caster_pos = caster:GetAbsOrigin()
	for i=1,10 do
		local ifx = ParticleManager:CreateParticle("particles/a23r/a23rfly.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(ifx, 0, caster_pos + Vector (0, 0, 1000)) -- 隕石產生的位置
		ParticleManager:SetParticleControl(ifx, 1, target_pos + RandomVector(RandomInt(0,radius))) -- 命中位置
		ParticleManager:SetParticleControl(ifx, 2, Vector(0.5, 0, 0)) -- 效果存活時間
	end
end

function B28T_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("B28T_old_radius")
	local damage = ability:GetSpecialValueFor("B28T_old_damage")
	local point = keys.target_points[1]

	ability.isChanneling = true

	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", { duration = ability:GetChannelTime() } )
	dummy:SetOwner(caster)
	dummy:AddAbility( "majia"):SetLevel(1)

	ability:ApplyDataDrivenModifier( caster, dummy, "modifier_B28T_old_debuffAura", nil)

	Timers:CreateTimer(0, function()
		if not caster:IsChanneling() then
			dummy:ForceKill(true)
			return nil
		end
		AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 200, 1, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 200, 1, false)
		for i=1,5 do
			local random = RandomVector(RandomInt( (i-1)*radius/6 , i*radius/6 ))
			local ifx = ParticleManager:CreateParticle("particles/b28t_old/b28t_old.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(ifx, 0, point + random)
			local ifx2 = ParticleManager:CreateParticle("particles/b28t_old/b28t_old2.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(ifx2, 0, point + random)
			for j=1,2 do
				local random2 = RandomVector(RandomInt( 4*radius/6 , 5*radius/6 ))
				local ifx3 = ParticleManager:CreateParticle("particles/b28t_old/b28t_old.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(ifx3, 0, point + random2)
				local ifx4 = ParticleManager:CreateParticle("particles/b28t_old/b28t_old2.vpcf", PATTACH_CUSTOMORIGIN, caster)
				ParticleManager:SetParticleControl(ifx4, 0, point + random2)
			end
		end

		StartSoundEvent("Hero_ElderTitan.EarthSplitter.Cast",dummy)

		local units = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for _,unit in ipairs(units) do
			if unit:IsBuilding() then
				local damage_table = {
					attacker = caster,
					victim = unit,
					damage = damage,
					damage_type = ability:GetAbilityDamageType()
				}
				ApplyDamage(damage_table)
			end
		end
		return 1
	end)
end

function channel_interrupt( keys )
	keys.ability.isChanneling = false
end
