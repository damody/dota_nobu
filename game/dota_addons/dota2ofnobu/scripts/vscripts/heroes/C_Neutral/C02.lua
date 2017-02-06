-- 明智秀滿

function CreateMirror( keys )
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin()
	local duration = ability:GetSpecialValueFor( "illusion_duration")
	local outgoingDamage = ability:GetSpecialValueFor( "illusion_outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor( "illusion_incoming_damage")

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	--分身不能用法球
	illusion.nobuorb1 = "illusion"
	
	if illusion:IsHero() then
		illusion:SetPlayerID(caster:GetPlayerID())

		-- Level Up the unit to the casters level
		local casterLevel = target:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end	
		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
	end
	illusion:SetControllableByPlayer(player, true)
	

	-- Set the skill points to 0 and learn the skills of the caster
	for abilitySlot=0,15 do
		local ability = illusion:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if (illusionAbility ~= nil) then
				illusion:RemoveAbility(abilityName)
			end
		end
	end
	for abilitySlot=0,15 do
		local ability = target:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			illusion:AddAbility(abilityName):SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	illusion:MakeIllusion()
	illusion:AddNewModifier(target, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	illusion:SetForwardVector(target:GetForwardVector())
	illusion:SetControllableByPlayer(caster:GetPlayerID(), true)
	illusion:SetHealth(target:GetHealth())
	illusion:SetMana(target:GetMana())

	return illusion
end

function C02W_launch_projectile( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local point = keys.target_points[1]
	local ability = keys.ability
	local speed = 2000
	local range = ability:GetCastRange()

	-- 計算攻擊方向
	local angle = VectorToAngles(point-center).y
	local dx = math.cos(angle*(3.14/180))
	local dy = math.sin(angle*(3.14/180))
	local dir = Vector(dx,dy,0)

	-- 實際造成傷害的投射物
	ProjectileManager:CreateLinearProjectile({
		Ability				= ability,
		EffectName			= "",
		vSpawnOrigin		= center+Vector(0,0,100),
		fDistance			= range,
		fStartRadius		= 150,
		fEndRadius			= 400,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
		iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
		iUnitTargetType		= ability:GetAbilityTargetType(),
		fExpireTime			= GameRules:GetGameTime() + 2,
		bDeleteOnHit		= false,
		vVelocity			= dir*speed,
		bProvidesVision		= false,
		iVisionRadius		= 0,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	})

	-- 特效投射物
	local num = 3
	local delta_angle = 2
	for i=-num,num do
		local new_angle = angle+delta_angle*i
		dir.x = math.cos(new_angle*(3.14/180))
		dir.y = math.sin(new_angle*(3.14/180))
		ProjectileManager:CreateLinearProjectile({
			Ability				= ability,
			EffectName			= "particles/c02/c02w.vpcf",
			vSpawnOrigin		= center+Vector(0,0,100),
			fDistance			= range,
			fStartRadius		= 150,
			fEndRadius			= 400,
			Source				= caster,
			bHasFrontalCone		= true,
			bReplaceExisting	= false,
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_NONE,
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType		= DOTA_UNIT_TARGET_NONE,
			fExpireTime			= GameRules:GetGameTime() + 2,
			bDeleteOnHit		= false,
			vVelocity			= dir*speed,
			bProvidesVision		= false,
			iVisionRadius		= 0,
			iVisionTeamNumber	= caster:GetTeamNumber(),
		})
	end
end

function C02W_clone_hero( keys )
	local target = keys.target

	if target:IsHero() and target:IsRealHero() and not target:IsIllusion() then
		local effect_name = "particles/units/heroes/hero_siren/naga_siren_portrait.vpcf"
		local player = PlayerResource:GetPlayer(target:GetPlayerID())
		local ifx = ParticleManager:CreateParticleForPlayer(effect_name,PATTACH_ABSORIGIN_FOLLOW,target,player)
		Timers:CreateTimer(0.5, function ()
			ParticleManager:DestroyParticle(ifx,false)
		end)

		local illusion = CreateMirror( keys )
		-- 命令攻擊目標
		ExecuteOrderFromTable({
			UnitIndex = illusion:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		})
	end
end

function C02E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local dir = caster:GetForwardVector()
	local distance = ability:GetCastRange()
	local spell_point = caster:GetAbsOrigin()
	local target_point = spell_point+dir*distance

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C02E_buff",nil)
	FindClearSpaceForUnit(caster,target_point,false)

	-- 產生幻影
	keys.target = keys.caster
	local illusion = CreateMirror(keys)
	illusion:SetAbsOrigin(spell_point)
	caster:Stop()

	-- 位移特效
	target_point = caster:GetAbsOrigin()
	dir = (target_point-spell_point):Normalized()
	distance = (target_point-spell_point):Length()
	local flash_time = 0.2
	local dummy = CreateUnitByName("npc_dummy_unit",spell_point,false,nil,nil,caster:GetTeamNumber())
	Physics:Unit(dummy)
	dummy:SetForwardVector(dir)
	dummy:SetPhysicsVelocity(dir*distance/flash_time)
	dummy:SetAutoUnstuck(false) -- 取消自動移動至合法區
	dummy:SetNavCollisionType(PHYSICS_NAV_NOTHING) -- 無視碰撞
	dummy:FollowNavMesh(false) -- 不跟隨Nav
	dummy:SetPhysicsFriction(0)
	dummy:SetGroundBehavior(PHYSICS_GROUND_NOTHING) -- 不理會地面
	local ifx = ParticleManager:CreateParticle("particles/c02/c02e_flashjewel.vpcf",PATTACH_ABSORIGIN_FOLLOW,dummy)
	Timers:CreateTimer(flash_time, function()
		dummy:SetPhysicsVelocity(Vector(0,0,0))
		ParticleManager:DestroyParticle(ifx, false)
		dummy:ForceKill(false)
	end)
end

function C02R_OnUpgrade( keys )
	local caster = keys.caster
	local ability = keys.ability

	if caster:HasModifier("modifier_C02R_Timer") then
		caster:RemoveModifierByName("modifier_C02R")
	end
end

C02R_EXCLUDE_TARGET_NAME = {
	npc_dota_cursed_warrior_souls	= true,
	npc_dota_the_king_of_robbers	= true,
	com_general = true,
	com_general2 = true,
}

-- 這招要排除很多可能...
function C02R_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- 幻影不能用
	if caster:IsIllusion() then return end

	-- 幻影不能複製
	if target:IsIllusion() then return end

	-- 建築不能複製
	if target:IsBuilding() then return end

	-- 只能是英雄或野怪
	if not target:IsHero() and not target:IsCreep() then return end

	-- 額外排除項目
	if C02R_EXCLUDE_TARGET_NAME[target:GetUnitName()] == true then return end

	-- 製造幻影
	local illusion = CreateMirror(keys)

	-- 命令攻擊目標
	ExecuteOrderFromTable({
		UnitIndex = illusion:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()
	})

	-- 移除自己
	caster:RemoveModifierByName("modifier_C02R")

	-- 螢幕特效
	if target:IsHero() and target:IsRealHero() and target:IsIllusion()==false then
		local effect_name = "particles/units/heroes/hero_siren/naga_siren_portrait.vpcf"
		local player = PlayerResource:GetPlayer(target:GetPlayerID())
		local ifx = ParticleManager:CreateParticleForPlayer(effect_name,PATTACH_ABSORIGIN_FOLLOW,target,player)
		Timers:CreateTimer(0.5, function ()
			ParticleManager:DestroyParticle(ifx,false)
		end)
	end
end

require('libraries/animations')

function C02T_OnAbilityPhaseStart( keys )
	local caster = keys.caster

	-- 跳砍動畫
	StartAnimation(caster, {
		duration=0.5,
		activity=ACT_DOTA_ATTACK, 
		translate="duel_kill"
	})
end

function C02T_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local force_kill_hp = ability:GetSpecialValueFor("force_kill_hp")
	local stun_time = ability:GetSpecialValueFor("stun_time")
	local damage = ability:GetAbilityDamage()

	if target:GetHealth() < force_kill_hp then
		-- 製造傷害
		ApplyDamage({
			attacker=caster,
			victim=target,
			damage_type=DAMAGE_TYPE_PURE,
			damage=force_kill_hp
		})
		-- 處決特效
		local ifx = ParticleManager:CreateParticle("particles/econ/items/lich/frozen_chains_ti6/lich_frozenchains_frostnova.vpcf",PATTACH_ABSORIGIN,target)
		ParticleManager:ReleaseParticleIndex(ifx)
		-- 噴血特效
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_axe/axe_culling_blade_kill.vpcf",PATTACH_WORLDORIGIN,target)
		ParticleManager:SetParticleControlForward(ifx,3,caster:GetForwardVector())
		ParticleManager:SetParticleControl(ifx,4,target:GetAbsOrigin())
		ParticleManager:SetParticleControl(ifx,8,Vector(10,0,0))
		ParticleManager:ReleaseParticleIndex(ifx)
	else
		-- 跳驚嘆號
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_DENY,target,0,nil)
		-- 暈眩
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration=stun_time})
		-- 製造傷害
		ApplyDamage({
			attacker=caster,
			victim=target,
			damage_type=DAMAGE_TYPE_MAGICAL,
			damage=damage
		})
		-- 處決失敗特效
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_siren_song_cast.vpcf",PATTACH_ABSORIGIN,target)
		ParticleManager:ReleaseParticleIndex(ifx)
		-- 擴散傷害修改器
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C02T_aoe",nil)
	end
end

function C02T_OnAttack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local aoe_chance = ability:GetSpecialValueFor("aoe_chance")

	-- 鏡像不給用
	if caster:IsIllusion() then return end

	-- 機率不到
	if aoe_chance < RandomInt(1,100) then return end

	local ability_type = ability:GetAbilityType()
	local aoe_damage = ability:GetSpecialValueFor("aoe_damage")
	local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
	local target_team = ability:GetAbilityTargetTeam()
	local target_type = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local center = caster:GetAbsOrigin()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		center,				-- 搜尋的中心點
		nil, 				-- 好像是優化用的參數不懂怎麼用
		aoe_radius,			-- 搜尋半徑
		target_team,		-- 目標隊伍
		target_type,		-- 目標類型
		target_flags,		-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,		-- 結果的排列方式
		false) 				-- 好像是優化用的參數不懂怎麼用

	for _,unit in ipairs(units) do
		-- 製造傷害
		ApplyDamage({
			victim = unit,
			attacker = caster,
			damage_type = ability_type,
			damage = aoe_damage
		})
		-- 跳數字
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,unit,aoe_damage,nil)
		-- 特效
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_riptide.vpcf",PATTACH_POINT_FOLLOW,unit)
		ParticleManager:SetParticleControl(ifx,1,Vector(200,200,200))
		ParticleManager:ReleaseParticleIndex(ifx)
	end
end

function C02W_old_launch_projectile( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local point = keys.target_points[1]
	local ability = keys.ability
	local speed = 2000
	local range = ability:GetCastRange()
	local start_width = ability:GetSpecialValueFor("start_width")
	local ended_width = ability:GetSpecialValueFor("ended_width")

	-- 計算攻擊方向
	local angle = VectorToAngles(point-center).y
	local dx = math.cos(angle*(3.14/180))
	local dy = math.sin(angle*(3.14/180))
	local dir = Vector(dx,dy,0)

	-- 實際造成傷害的投射物
	ProjectileManager:CreateLinearProjectile({
		Ability				= ability,
		EffectName			= "",
		vSpawnOrigin		= center+Vector(0,0,100),
		fDistance			= range,
		fStartRadius		= start_width,
		fEndRadius			= ended_width,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
		iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
		iUnitTargetType		= ability:GetAbilityTargetType(),
		fExpireTime			= GameRules:GetGameTime() + 2,
		bDeleteOnHit		= false,
		vVelocity			= dir*speed,
		bProvidesVision		= false,
		iVisionRadius		= 0,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	})

	-- 特效投射物
	local num = 3
	local delta_angle = 2
	for i=-num,num do
		local new_angle = angle+delta_angle*i
		dir.x = math.cos(new_angle*(3.14/180))
		dir.y = math.sin(new_angle*(3.14/180))
		ProjectileManager:CreateLinearProjectile({
			Ability				= ability,
			EffectName			= "particles/c02/c02w.vpcf",
			vSpawnOrigin		= center+Vector(0,0,100),
			fDistance			= range,
			fStartRadius		= start_width,
			fEndRadius			= ended_width,
			Source				= caster,
			bHasFrontalCone		= true,
			bReplaceExisting	= false,
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_NONE,
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType		= DOTA_UNIT_TARGET_NONE,
			fExpireTime			= GameRules:GetGameTime() + 2,
			bDeleteOnHit		= false,
			vVelocity			= dir*speed,
			bProvidesVision		= false,
			iVisionRadius		= 0,
			iVisionTeamNumber	= caster:GetTeamNumber(),
		})
	end
end