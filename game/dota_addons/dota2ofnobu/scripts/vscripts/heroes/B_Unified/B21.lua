-- 馬場信房

function B21W_OnSpellStart( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local speed = ability:GetSpecialValueFor("projectile_speed")

	local diff = target_point-caster:GetAbsOrigin()
	diff.z = 0
	local dir = diff:Normalized()
	if dir == Vector(0,0,0) then
		dir = caster:GetForwardVector()
	end

	ProjectileManager:CreateLinearProjectile({
		Ability				= ability,
		EffectName			= "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
		vSpawnOrigin		= caster:GetAbsOrigin(),
		fDistance			= ability:GetCastRange(),
		fStartRadius		= 200,
		fEndRadius			= 200,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
		iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
		iUnitTargetType		= ability:GetAbilityTargetType(),
		fExpireTime			= GameRules:GetGameTime() + 5.0,
		bDeleteOnHit		= false,
		vVelocity			= dir*speed,
		bProvidesVision		= false,
		iVisionRadius		= 0,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	})

	EmitSoundOn("Hero_DragonKnight.BreathFire",caster)

	-- 儲存投射物方向給命中特效使用
	ability.dir = dir
end

function B21W_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local ifx = ParticleManager:CreateParticle("particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_impact_headflame.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
	ParticleManager:SetParticleControlForward(ifx,1,ability.dir)
	ParticleManager:ReleaseParticleIndex(ifx)

	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage_type = ability:GetAbilityDamageType(),
		damage = ability:GetAbilityDamage(),
	})
end

function B21E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local buff_duration = ability:GetSpecialValueFor("buff_duration")
	local stun_time = ability:GetSpecialValueFor("stun_time")
	local stun_radius = ability:GetSpecialValueFor("stun_radius")
	local stun_hp_threshold = ability:GetSpecialValueFor("stun_hp_threshold")

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_B21E_buff",{duration=buff_duration})

	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:ReleaseParticleIndex(ifx)

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),				-- 搜尋的中心點
		nil, 								-- 好像是優化用的參數不懂怎麼用
		stun_radius,						-- 搜尋半徑
		DOTA_UNIT_TARGET_TEAM_ENEMY,		-- 目標隊伍
		DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,	-- 目標類型
		DOTA_UNIT_TARGET_FLAG_NONE,			-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,						-- 結果的排列方式
		false) 								-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if unit:GetHealthPercent() <= stun_hp_threshold then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration=stun_time})
		end
	end

	EmitSoundOn("Hero_ChaosKnight.ChaosStrike",caster)
end

LinkLuaModifier("modifier_b21r_lua","heroes/B_Unified/B21.lua",LUA_MODIFIER_MOTION_NONE)

modifier_b21r_lua = class({})

function modifier_b21r_lua:IsHidden() return true end

function modifier_b21r_lua:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE -- OnTakeDamage
	}
end

-- 這個function會收到全場的傷害事件，無論目標是誰...
function modifier_b21r_lua:OnTakeDamage( keys )
	if IsClient() then return end

	local unit = self:GetParent()

	-- 判斷目標是否是自己
	if keys.unit ~= unit then return end

	-- 只反彈物理傷害
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end

	-- 不能反彈反彈傷害
	if keys.damage_flags == DOTA_DAMAGE_FLAG_REFLECTION then return end

	local attacker = keys.attacker
	local ability = self:GetAbility()

	ApplyDamage({
		victim = attacker,
		attacker = unit,
		ability = self:GetAbility(),
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
	})

	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_return.vpcf",PATTACH_POINT_FOLLOW,unit)
	ParticleManager:SetParticleControlEnt(ifx,0,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit:GetAbsOrigin(),true)
	ParticleManager:SetParticleControlEnt(ifx,1,attacker,PATTACH_POINT_FOLLOW,"attach_hitloc",attacker:GetAbsOrigin(),true)
	ParticleManager:ReleaseParticleIndex(ifx)
end

function B21R_OnCreated( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,target,"modifier_b21r_lua",nil)
end

function B21R_OnDestroy( keys )
	local caster = keys.caster
	caster:RemoveModifierByNameAndCaster("modifier_b21r_lua",caster)
end

function B21T_OnCreated( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ifx = ParticleManager:CreateParticle("particles/b21/b21t_buff.vpcf",PATTACH_CUSTOMORIGIN,caster)
	ParticleManager:SetParticleControl(ifx,0,Vector(0,0,0))
	ability.ifx = ifx
	ability.stack = 0
	ability.modifer = nil
end

function B21T_OnDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ifx = ability.ifx
	ParticleManager:DestroyParticle(ifx,false)
	ability.stack = 0
	ability.modifier = nil
end

function B21T_OnHealthChange( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_hp = ability:GetSpecialValueFor("stack_hp")
	local lost_hp = 100 - caster:GetHealthPercent()
	local stack = math.floor(lost_hp / stack_hp)
	local modifier = ability.modifier

	if ability.stack == stack then 
		return 
	else
		ability.stack = stack
		ParticleManager:SetParticleControl(ability.ifx,0,Vector(stack*20))
	end

	if stack == 0 then
		if modifier == nil then
			return
		else
			modifier:Destroy()
			ability.modifier = nil
		end
	else
		if modifier == nil then 
			modifier = ability:ApplyDataDrivenModifier(caster,caster,"modifier_B21T_stack",nil)
			ability.modifier = modifier
		end
		modifier:SetStackCount(stack)
	end
end

-- 馬場信房 11.2B

require('libraries/animations')

function B21W_old_OnSpellStart( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local speed = ability:GetSpecialValueFor("projectile_speed")

	local diff = target_point-caster:GetAbsOrigin()
	diff.z = 0
	local dir = diff:Normalized()
	if dir == Vector(0,0,0) then
		dir = caster:GetForwardVector()
	end

	local projectile_table = {
		Ability				= ability,
		EffectName			= "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
		vSpawnOrigin		= caster:GetAbsOrigin(),
		fDistance			= ability:GetCastRange(),
		fStartRadius		= 300,
		fEndRadius			= 300,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
		iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
		iUnitTargetType		= ability:GetAbilityTargetType(),
		fExpireTime			= GameRules:GetGameTime() + 5.0,
		bDeleteOnHit		= false,
		vVelocity			= dir*speed,
		bProvidesVision		= false,
		iVisionRadius		= 0,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	}

	local channel_time = ability:GetChannelTime() - 0.05 -- 避免最後一次出不來
	local fire_num = 3
	local fire_delay = channel_time / (fire_num+1)

	for i=1,fire_num do
		Timers:CreateTimer(fire_delay*i,function()
			if ability:IsChanneling() then
				ProjectileManager:CreateLinearProjectile(projectile_table)
				EmitSoundOn("Hero_DragonKnight.BreathFire",caster)
			end
		end)
	end

	-- 儲存投射物方向給命中特效使用
	ability.dir = dir
end

function B21W_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local ifx = ParticleManager:CreateParticle("particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_impact_headflame.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
	ParticleManager:SetParticleControlForward(ifx,1,ability.dir)
	ParticleManager:ReleaseParticleIndex(ifx)

	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage_type = ability:GetAbilityDamageType(),
		damage = ability:GetAbilityDamage(),
	})
end

function B21E_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local buff_duration = ability:GetSpecialValueFor("buff_duration")
	local stun_time = ability:GetSpecialValueFor("stun_time")
	local hp_threshold = ability:GetSpecialValueFor("hp_threshold")

	ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration=stun_time})
	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf",PATTACH_ABSORIGIN,target)
	ParticleManager:ReleaseParticleIndex(ifx)

	if target:GetHealthPercent() <= hp_threshold then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_B21E_old_buff",{duration=buff_duration})
	end

	ExecuteOrderFromTable({
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex(),
		Queue = false
	})

	EmitSoundOn("Hero_ChaosKnight.ChaosStrike",caster)
end

function B21R_old_buff_OnCreated( keys )
	local target = keys.target
	local ifx = ParticleManager:CreateParticle("particles/b21/b21r_old_buff_soft.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
	ParticleManager:SetParticleControl(ifx,1,Vector(target:BoundingRadius2D()*4))
	target.ifx_B21R_old_buff = ifx
end

function B21R_old_buff_OnDestroy( keys )
	local target = keys.target
	ParticleManager:DestroyParticle(target.ifx_B21R_old_buff,false)
end

function B21T_old_OnHealthChange( keys )
	local caster = keys.caster
	local ability = keys.ability
	local hp_threshold = ability:GetSpecialValueFor("hp_threshold")
	local hp = caster:GetHealth()

	if ability.modifier == nil then
		if hp < hp_threshold then
			ability.modifier = ability:ApplyDataDrivenModifier(caster,caster,"modifier_B21T_old",nil)
		end
	else
		if hp >= hp_threshold then
			caster:RemoveModifierByNameAndCaster("modifier_B21T_old",caster)
			ability.modifier = nil
		end
	end
end

function B21T_old_OnCreated( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ifx = ParticleManager:CreateParticle("particles/b21/b21t_buff.vpcf",PATTACH_CUSTOMORIGIN,caster)
	ParticleManager:SetParticleControl(ifx,0,Vector(50))
	ability.ifx = ifx
end

function B21T_old_OnDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	ParticleManager:DestroyParticle(ability.ifx,false)
end