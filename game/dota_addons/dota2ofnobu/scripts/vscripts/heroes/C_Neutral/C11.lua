function C11W_start( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	Timers:CreateTimer(3, function ()
		  caster:RemoveNoDraw()
		end)
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C11W",nil)
	
	caster:AddNoDraw()

	local projectile_table = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = "particles/c11/c11w.vpcf",
		bDodgeable = true,
		bProvidesVision = true,
		iMoveSpeed = projectile_speed,
        iVisionRadius = 800,
        iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOC
	}
	ProjectileManager:CreateTrackingProjectile( projectile_table )

	ability.jump_count = 0
	ability.ended = false
	ability.projectile_table = projectile_table
	ability.first_target = target
end


function C11W_hit_unit( keys )
	local caster = keys.caster
	local target = keys.target
	local next_target = nil
	local ability = keys.ability

	if ability.ended == true then
		-- 結束技能
		caster:RemoveNoDraw()
		caster:RemoveModifierByName("modifier_C11W")
		local first_target = ability.first_target
		-- 如果一開始選的目標還活著則出現在目標周圍，並且命令攻擊他
		if IsValidEntity(first_target) and first_target:IsAlive() and 
			(first_target:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D() < 2000 then
			FindClearSpaceForUnit(caster,first_target:GetAbsOrigin(),true)
			-- 命令攻擊
			local order = {
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = first_target:entindex(),
				Queue = false
			}
			ExecuteOrderFromTable(order)
		end

		-- 直接離開
		return
	end

	local ability_damage = ability:GetAbilityDamage()
	local ability_type = ability:GetAbilityDamageType()
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
	local max_jump = ability:GetSpecialValueFor("max_jump")
	local remove_mana_percentage = ability:GetSpecialValueFor("remove_mana_percentage")
	local jump_range = ability:GetSpecialValueFor("jump_range")

	-- 製造傷害
	local damage_table = {
		victim = target,
		attacker = caster,
		damage_type = ability_type,
		damage = ability_damage
	}
	ApplyDamage(damage_table)

	-- 消去法力
	local remove_mana = target:GetMana() * (remove_mana_percentage / 100.0)
	target:ReduceMana(remove_mana)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_LOSS,target,remove_mana,nil)

	-- 特效
	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf",PATTACH_OVERHEAD_FOLLOW,target)
	ParticleManager:SetParticleControl(ifx,1,target:GetAbsOrigin()+Vector(0,0,1000))
	ParticleManager:ReleaseParticleIndex(ifx)

	-- 螢幕特效
	CreateScreenEffect(target)

	-- 音效
	EmitSoundOn("Hero_Zuus.GodsWrath.Target",target)

	-- 搜尋參數
	local center = target:GetAbsOrigin()
	local target_team = ability:GetAbilityTargetTeam()
	local target_type = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		center,				-- 搜尋的中心點
		nil, 				-- 好像是優化用的參數不懂怎麼用
		jump_range,			-- 搜尋半徑
		target_team,		-- 目標隊伍
		target_type,		-- 目標類型
		target_flags,		-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,		-- 結果的排列方式
		false) 				-- 好像是優化用的參數不懂怎麼用

	if units ~= nil then
		-- 從搜尋結果中移除當前目標
		for i,unit in ipairs(units) do
			if unit == target then
				table.remove(units, i)
				break
			end
		end
		-- 隨機選擇一個目標
		if #units > 0 then next_target = units[RandomInt(1,#units)] end
	end

	ability.jump_count = ability.jump_count + 1
	if ability.jump_count >= max_jump or next_target == nil then
		-- 下一次命中目標就結束
		ability.ended = true
		local first_target = ability.first_target
		-- 如果一開始選的目標還活著則將下一個目標設定為他，否則設定成自己
		if IsValidEntity(first_target) and first_target:IsAlive() then
			next_target = first_target
		else
			next_target = caster
		end
	end

	-- 彈跳至下一個目標
	local projectile_table = ability.projectile_table
	projectile_table["Target"] = next_target
	projectile_table["Source"] = target
	ProjectileManager:CreateTrackingProjectile( projectile_table )
end

-- 產生一個單位讓他打
function C11W_miss_target( keys )
	local caster = keys.caster
	local dummy = CreateUnitByName("npc_dummy_unit",keys.target_points[1],false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
	keys.target = dummy
	C11W_hit_unit(keys)
end

function C11R_start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_damage = ability:GetAbilityDamage()
	local ability_type = ability:GetAbilityDamageType()

	local center = keys.target_points[1]
	local target_team = ability:GetAbilityTargetTeam()
	local target_type = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local radius = ability:GetSpecialValueFor("radius")

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		center,				-- 搜尋的中心點
		nil, 				-- 好像是優化用的參數不懂怎麼用
		radius,				-- 搜尋半徑
		target_team,		-- 目標隊伍
		target_type,		-- 目標類型
		target_flags,		-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,		-- 結果的排列方式
		false) 				-- 好像是優化用的參數不懂怎麼用

	for _,unit in ipairs(units) do
		-- 暈眩
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_C11R_stun",nil)
		-- 製造傷害
		local damage_table = {
			victim = unit,
			attacker = caster,
			damage_type = ability_type,
			damage = ability_damage
		}
		ApplyDamage(damage_table)
		-- 螢幕特效
		CreateScreenEffect(unit)
	end

	-- 打雷特效
	local light_count = 6
	local delta_angle = 3.14*2/light_count
	for i=1,light_count do
		local angle = delta_angle*i
		local range = radius * 0.7
		local dx = range * math.cos(angle)
		local dy = range * math.sin(angle)
		local point = center + Vector(dx,dy,0)
		point.z = GetGroundHeight(point,nil)

		local dummy = CreateUnitByName("npc_dummy_unit",point,false,nil,nil,caster:GetTeamNumber())
		dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
		local ifx = ParticleManager:CreateParticle("particles/item/item_thunderstorms.vpcf",PATTACH_ABSORIGIN,dummy)
		ParticleManager:SetParticleControl(ifx,1,point)
		ParticleManager:ReleaseParticleIndex(ifx)
	end

	-- 打雷音效
	local dummy = CreateUnitByName("npc_dummy_unit",center,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
	EmitSoundOn("ITEM_D09.sound",dummy)
	AddFOWViewer(caster:GetTeamNumber(), center, radius, 0.5, false)
end

function C11T_on_attack_landed( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- 直接離開
	-----------------------------------------
	if target:IsBuilding() or target:GetMaxMana() == 0 then return end
	-----------------------------------------

	local damage = ability:GetAbilityDamage()
	local remove_mana_percentage = ability:GetSpecialValueFor("remove_mana_percentage")
	local bouns70 = 1.2
	local bouns40 = 1.5
	local bouns15 = 2.0

	-- 特效
	--local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_loadout.vpcf",PATTACH_POINT,target)
	--local ifx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_gold.vpcf",PATTACH_POINT,target)
	--local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf",PATTACH_POINT,target)
	local ifx = ParticleManager:CreateParticle("particles/c11/c11t_ntimage_manavoid_ti_5.vpcf",PATTACH_POINT,target)
	ParticleManager:ReleaseParticleIndex(ifx)

	-- 消去魔力
	local remove_mana = target:GetMana()*(remove_mana_percentage/100.0)
	target:ReduceMana(remove_mana)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_LOSS,target,remove_mana,nil)

	-- 傷害參數
	local damage_table = {
		victim = target,
		attacker = caster,
		damage_type = DAMAGE_TYPE_PURE,
		damage = damage
	}
	
	local current_mana_percentage = target:GetManaPercent()
	if current_mana_percentage <= 15 then
		damage_table["damage"] = damage * bouns15
		-- 螢幕特效
		CreateScreenEffect(target)
	elseif current_mana_percentage <= 40 then
		damage_table["damage"] = damage * bouns40
		CreateScreenEffect(target)
	elseif current_mana_percentage <= 70 then
		damage_table["damage"] = damage * bouns70
	else
		damage_table["damage"] = damage
	end
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,target,damage_table["damage"],nil)
	ApplyDamage(damage_table)
end

function C11T_20_on_attack_landed( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- 直接離開
	-----------------------------------------
	if target:IsBuilding() or target:GetMaxMana() == 0 then return end
	-----------------------------------------

	local damage = ability:GetAbilityDamage()
	local remove_mana_percentage = ability:GetSpecialValueFor("remove_mana_percentage")
	local bouns70 = 1.2
	local bouns40 = 1.5
	local bouns15 = 2.0

	-- 特效
	--local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_loadout.vpcf",PATTACH_POINT,target)
	--local ifx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_gold.vpcf",PATTACH_POINT,target)
	--local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf",PATTACH_POINT,target)
	local ifx = ParticleManager:CreateParticle("particles/c11/c11t_ntimage_manavoid_ti_5.vpcf",PATTACH_POINT,target)
	ParticleManager:ReleaseParticleIndex(ifx)

	-- 消去魔力
	local remove_mana = target:GetMana()*(remove_mana_percentage/100.0)
	target:ReduceMana(remove_mana)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_LOSS,target,remove_mana,nil)

	-- 傷害參數
	local damage_table = {
		victim = target,
		attacker = caster,
		damage_type = DAMAGE_TYPE_PURE,
		damage = damage
	}
	
	local current_mana_percentage = target:GetManaPercent()
	if current_mana_percentage <= 15 then
		damage_table["damage"] = damage * bouns15
		-- 螢幕特效
		CreateScreenEffect(target)
	elseif current_mana_percentage <= 40 then
		damage_table["damage"] = damage * bouns40
		CreateScreenEffect(target)
	elseif current_mana_percentage <= 70 then
		damage_table["damage"] = damage * bouns70
	else
		damage_table["damage"] = damage
	end
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,target,damage_table["damage"],nil)
	ApplyDamage(damage_table)
end

function CreateScreenEffect( target )
	if IsValidEntity(target) and target:IsHero() then 
		local effect_name = "particles/units/heroes/hero_zeus/zues_screen_empty.vpcf"
		local player = PlayerResource:GetPlayer(target:GetPlayerID())
		local ifx = ParticleManager:CreateParticleForPlayer(effect_name,PATTACH_ABSORIGIN_FOLLOW,target,player)
		ParticleManager:ReleaseParticleIndex(ifx)
	end
end

-- 11.2B

function C11W_old_M_on_attack_start( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local crit_chance = ability:GetSpecialValueFor("crit_chance")

	local rnd = RandomInt(1,100)
	caster:RemoveModifierByName("modifier_C11W_old_crit")
	if crit_chance >= rnd then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C11W_old_crit",nil)
	end
end

function C11D_20_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local out = ability:GetSpecialValueFor("out")
	local units = FindUnitsInRadius(caster:GetOpposingTeamNumber(), caster:GetOrigin(), nil, 1300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
	if #units == 1 then
		AMHC:Damage(caster,target, keys.dmg*out*0.01,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
end
function C11T_old_on_attack_landed( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- 直接離開
	-----------------------------------------
	if target:IsBuilding() or target:GetMaxMana() == 0 then return end
	-----------------------------------------

	local remove_mana = ability:GetSpecialValueFor("remove_mana")
	local damage_adjust_for_hero = ability:GetSpecialValueFor("damage_adjust_for_hero")
	local damage_adjust_for_creep = ability:GetSpecialValueFor("damage_adjust_for_creep")

	-- 消去魔力
	local current_mana = target:GetMana()
	if current_mana < remove_mana then 
		remove_mana = current_mana
	else
		-- 特效
		--local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_loadout.vpcf",PATTACH_POINT,target)
		--local ifx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_manaburn_basher_ti_5_gold.vpcf",PATTACH_POINT,target)
		--local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf",PATTACH_POINT,target)
		local ifx = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_impact_moonfall.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
		ParticleManager:SetParticleControlEnt(ifx,0,target,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
		ParticleManager:SetParticleControlEnt(ifx,1,target,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
		ParticleManager:SetParticleControlEnt(ifx,2,target,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
		ParticleManager:SetParticleControlEnt(ifx,5,target,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
		ParticleManager:ReleaseParticleIndex(ifx)
	end
	target:ReduceMana(remove_mana)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_MANA_LOSS,target,remove_mana,nil)

	-- 傷害參數
	local damage_table = {
		victim = target,
		attacker = caster,
		damage_type = DAMAGE_TYPE_PURE,
		damage = 0
	}
	
	if target:IsHero() then
		damage_table["damage"] = remove_mana * damage_adjust_for_hero
	else
		damage_table["damage"] = remove_mana * damage_adjust_for_creep
	end
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,target,damage_table["damage"],nil)
	ApplyDamage(damage_table)
end

function C11W_20_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	Timers:CreateTimer(3, function ()
		  caster:RemoveNoDraw()
		end)
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C11W_buff",nil)
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C11W_old",nil)
	
	caster:AddNoDraw()

	local projectile_table = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = "particles/c11/c11w.vpcf",
		bDodgeable = true,
		bProvidesVision = true,
		iMoveSpeed = projectile_speed,
        iVisionRadius = 800,
        iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOC
	}
	ProjectileManager:CreateTrackingProjectile( projectile_table )

	ability.jump_count = 0
	ability.ended = false
	ability.projectile_table = projectile_table
	ability.first_target = target
end


function C11W_20_hit_unit( keys )
	local caster = keys.caster
	local target = keys.target
	local next_target = nil
	local ability = keys.ability

	if ability.ended == true then
		-- 結束技能
		caster:RemoveNoDraw()
		caster:RemoveModifierByName("modifier_C11W")
		local first_target = ability.first_target
		-- 如果一開始選的目標還活著則出現在目標周圍，並且命令攻擊他
		if IsValidEntity(first_target) and first_target:IsAlive() and 
			(first_target:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D() < 2000 then
			FindClearSpaceForUnit(caster,first_target:GetAbsOrigin(),true)
			-- 命令攻擊
			local order = {
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = first_target:entindex(),
				Queue = false
			}
			ExecuteOrderFromTable(order)
		end

		-- 直接離開
		return
	end
	local handle = caster:FindModifierByName("modifier_C11W_buff")
	if handle then
		local c = handle:GetStackCount()
		c = c + 1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C11W_buff",nil)
		handle:SetStackCount(c)
	end
	local ability_damage = ability:GetAbilityDamage()
	local ability_type = ability:GetAbilityDamageType()
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")
	local max_jump = ability:GetSpecialValueFor("max_jump")
	local remove_mana_percentage = ability:GetSpecialValueFor("remove_mana_percentage")
	local jump_range = ability:GetSpecialValueFor("jump_range")

	-- 特效
	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf",PATTACH_OVERHEAD_FOLLOW,target)
	ParticleManager:SetParticleControl(ifx,1,target:GetAbsOrigin()+Vector(0,0,1000))
	ParticleManager:ReleaseParticleIndex(ifx)

	-- 螢幕特效
	CreateScreenEffect(target)

	-- 音效
	EmitSoundOn("Hero_Zuus.GodsWrath.Target",target)

	-- 搜尋參數
	local center = target:GetAbsOrigin()
	local target_team = ability:GetAbilityTargetTeam()
	local target_type = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		center,				-- 搜尋的中心點
		nil, 				-- 好像是優化用的參數不懂怎麼用
		jump_range,			-- 搜尋半徑
		target_team,		-- 目標隊伍
		target_type,		-- 目標類型
		target_flags,		-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,		-- 結果的排列方式
		false) 				-- 好像是優化用的參數不懂怎麼用

	if units ~= nil then
		-- 從搜尋結果中移除當前目標
		for i,unit in ipairs(units) do
			if unit == target then
				table.remove(units, i)
				break
			end
		end
		-- 隨機選擇一個目標
		if #units > 0 then next_target = units[RandomInt(1,#units)] end
	end

	ability.jump_count = ability.jump_count + 1
	if ability.jump_count >= max_jump or next_target == nil then
		-- 下一次命中目標就結束
		ability.ended = true
		local first_target = ability.first_target
		-- 如果一開始選的目標還活著則將下一個目標設定為他，否則設定成自己
		if IsValidEntity(first_target) and first_target:IsAlive() then
			next_target = first_target
		else
			next_target = caster
		end
	end

	-- 彈跳至下一個目標
	local projectile_table = ability.projectile_table
	projectile_table["Target"] = next_target
	projectile_table["Source"] = target
	ProjectileManager:CreateTrackingProjectile( projectile_table )

	-- 製造傷害
	local damage_table = {
		victim = target,
		attacker = caster,
		damage_type = ability_type,
		damage = ability_damage
	}
	ApplyDamage(damage_table)
end

function C11T_20_OnUpgrade( keys )
	local caster = keys.caster
	local ability = keys.ability
	local C11D_20 = caster:FindAbilityByName("C11D_20")
	if IsValidEntity(C11D_20) then
		C11D_20:SetLevel(ability:GetLevel()+1)
	end
end