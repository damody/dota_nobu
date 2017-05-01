-- 前田慶次

function C05E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local projectile_speed = ability:GetSpecialValueFor("projectile_speed")

	-- 產生投射物	
	projectile_table = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = "particles/econ/items/zeus/lightning_weapon_fx/zuus_base_attack_immortal_lightning.vpcf",
		bDodgeable = false,
		bProvidesVision = false,
		iMoveSpeed = projectile_speed,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}

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
		projectile_table.Target = unit
		ProjectileManager:CreateTrackingProjectile( projectile_table )
	end

	EmitSoundOn("Hero_Zuus.ArcLightning.Cast",caster)
end

function C05E_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- 製造傷害
	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		-- damage_flags = DOTA_DAMAGE_FLAG_NONE
	})

	EmitSoundOn("Hero_Zuus.ProjectileImpact",target)
end

function C05R_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:IsHero() or target:IsCreep() then
		local ifx = ParticleManager:CreateParticle("particles/neutral_fx/harpy_chain_lightning_head.vpcf",PATTACH_POINT_FOLLOW,target)
		ParticleManager:SetParticleControlEnt(ifx,0,caster,PATTACH_POINT,"attach_attack1",caster:GetAbsOrigin(),true)
		ParticleManager:SetParticleControlEnt(ifx,1,target,PATTACH_POINT_FOLLOW,nil,target:GetAbsOrigin(),true)
		ParticleManager:ReleaseParticleIndex(ifx)
		ability:ApplyDataDrivenModifier(caster,target,"modifier_C05R_debuff",{})

		EmitSoundOn("Hero_Zuus.ArcLightning.Cast",target)
	end
end

-- 範圍攻擊特效
function C05T_CreateParticle( point, radius, team_number )
	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf",PATTACH_WORLDORIGIN,nil)
	ParticleManager:SetParticleControl(ifx,0,point)
	ParticleManager:SetParticleControl(ifx,1,Vector(radius,radius,1.5))
	ParticleManager:SetParticleControl(ifx,2,Vector(1,1,radius))
	ParticleManager:SetParticleControl(ifx,3,point)
	ParticleManager:ReleaseParticleIndex(ifx)
end

function C05T_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	
	-- 提示攻擊範圍
	
	local dummy = CreateUnitByName("npc_dummy_unit_new",point,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
	local ifx = ParticleManager:CreateParticleForTeam("particles/c05/c05t_aoe_hint.vpcf",PATTACH_ABSORIGIN,dummy, caster:GetTeamNumber())
	ParticleManager:ReleaseParticleIndex(ifx)
	

	Timers:CreateTimer(ability:GetChannelTime()-0.3, function()
		if caster:IsChanneling() then
			local dummy = CreateUnitByName("npc_dummy_unit_new",caster:GetAbsOrigin(),false,nil,nil,caster:GetTeamNumber())
			dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
			local ifx = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_start.vpcf",PATTACH_ABSORIGIN,dummy)
			ParticleManager:ReleaseParticleIndex(ifx)

			EmitSoundOn("Hero_Zuus.GodsWrath.PreCast",dummy)
		end
	end)
end

function C05T_OnAbilityPhaseStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
	local point = keys.target_points[1]

	local group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
  	
	for _,v in ipairs(group) do
		if v:GetUnitName() == "com_general" then
			caster:Interrupt()
			break
		end
	end
end

function C05T_OnChannelInterrupted( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
	ability:EndCooldown()
	ability:StartCooldown(ability:GetCooldown(level)*0.5)
end

function C05T_OnChannelSucceeded( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local stun_time = ability:GetSpecialValueFor("stun_time")
	local radius = ability:GetSpecialValueFor("radius")

	-- 移動
	FindClearSpaceForUnit(caster,point,true)

	-- 範圍攻擊特效
	C05T_CreateParticle( point, radius, caster:GetTeamNumber() )

	-- 砍樹
	GridNav:DestroyTreesAroundPoint(point, radius, false)

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		point,												-- 搜尋的中心點
		nil,												-- 好像是優化用的參數不懂怎麼用
		radius,												-- 搜尋半徑
		ability:GetAbilityTargetTeam(),						-- 目標隊伍
		ability:GetAbilityTargetType(),						-- 目標類型
		ability:GetAbilityTargetFlags(),					-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,										-- 結果的排列方式
		false)												-- 好像是優化用的參數不懂怎麼用

	local damage_table = {
		--victim = nil,
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
		unit:AddNewModifier(caster,ability,"modifier_stunned",{duration=stun_time})
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_mana_loss.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
		ParticleManager:ReleaseParticleIndex(ifx)
	end

	local ifx = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_end.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:ReleaseParticleIndex(ifx)

	caster:StartGestureWithPlaybackRate(ACT_DOTA_SPAWN,2.0)

	EmitSoundOn("Hero_Zuus.GodsWrath",caster)
end

-- 11.2B

function C05E_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- 製造傷害
	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		-- damage_flags = DOTA_DAMAGE_FLAG_NONE
	})

	ability:ApplyDataDrivenModifier(caster,target,"modifier_C05E_old_debuff",{})

	EmitSoundOn("Hero_Zuus.ProjectileImpact",target)
end

function CreateScreenEffect( target )
	if target:IsHero() and target:IsRealHero() and not target:IsIllusion() and PlayerResource:IsValidPlayerID(target:GetPlayerID()) then 
		local effect_name = "particles/units/heroes/hero_zeus/zues_screen_empty.vpcf"
		local player = PlayerResource:GetPlayer(target:GetPlayerID())
		local ifx = ParticleManager:CreateParticleForPlayer(effect_name,PATTACH_ABSORIGIN_FOLLOW,target,player)
		ParticleManager:ReleaseParticleIndex(ifx)
	end
end

function C05R_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		--damage_flags = DOTA_DAMAGE_FLAG_NONE
	})

	ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration=ability:GetSpecialValueFor("stun_time")})

	CreateScreenEffect(target)

	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf",PATTACH_POINT_FOLLOW,target)
	ParticleManager:SetParticleControlEnt(ifx,0,caster,PATTACH_POINT_FOLLOW,"attach_attack1",caster:GetAbsOrigin(),true)
	ParticleManager:SetParticleControlEnt(ifx,1,target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetAbsOrigin(),true)
	ParticleManager:ReleaseParticleIndex(ifx)

	EmitSoundOn("Hero_Zuus.GodsWrath",target)
end

function C05T_old_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:IsHero() or target:IsCreep() then
		ability:ApplyDataDrivenModifier(target,target,"modifier_C05T_old_debuff",{})
		target:FindModifierByName("modifier_C05T_old_debuff").caster = caster

		if target:IsMagicImmune() then
			ApplyDamage({
				victim = target,
				attacker = caster,
				ability = ability,
				damage = ability:GetSpecialValueFor("damage_per_think")*0.5,
				damage_type = ability:GetAbilityDamageType(),
				--damage_flags = DOTA_DAMAGE_FLAG_NONE
			})
		else
			ApplyDamage({
				victim = target,
				attacker = caster,
				ability = ability,
				damage = ability:GetSpecialValueFor("damage_per_think"),
				damage_type = ability:GetAbilityDamageType(),
				--damage_flags = DOTA_DAMAGE_FLAG_NONE
			})
		end

		local ifx = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_bodyarc_immortal_lightningyzuus_lightning_bolt_bodyarc_immortal_lightning.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
		ParticleManager:SetParticleControlEnt(ifx,1,target,PATTACH_ABSORIGIN_FOLLOW,nil,target:GetAbsOrigin(),true)
		ParticleManager:SetParticleControl(ifx,2,target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(ifx)

		EmitSoundOn("Hero_Zuus.ArcLightning.Cast",target)
	end
end

function C05T_old_OnIntervalThink( keys )
	
	local target = keys.target
	local caster = target:FindModifierByName("modifier_C05T_old_debuff").caster
	local ability = keys.ability
		if target:IsMagicImmune() then
			ApplyDamage({
				victim = target,
				attacker = caster,
				ability = ability,
				damage = ability:GetSpecialValueFor("damage_per_think")*0.5,
				damage_type = ability:GetAbilityDamageType(),
				--damage_flags = DOTA_DAMAGE_FLAG_NONE
			})
		else
			ApplyDamage({
				victim = target,
				attacker = caster,
				ability = ability,
				damage = ability:GetSpecialValueFor("damage_per_think"),
				damage_type = ability:GetAbilityDamageType(),
				--damage_flags = DOTA_DAMAGE_FLAG_NONE
			})
		end

		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_impact.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
		ParticleManager:SetParticleControlEnt(ifx,1,target,PATTACH_ABSORIGIN_FOLLOW,nil,target:GetAbsOrigin(),true)
		ParticleManager:ReleaseParticleIndex(ifx)

		EmitSoundOn("Hero_Zuus.ProjectileImpact",target)

end