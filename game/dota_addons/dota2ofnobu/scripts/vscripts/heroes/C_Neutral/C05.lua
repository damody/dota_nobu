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

		EmitSoundOn("Hero_Zuus.ProjectileImpact",target)
	end
end

-- 範圍攻擊特效
function C05T_CreateParticle( point, radius, team_number )
	local dummy = CreateUnitByName("npc_dummy_unit",point,false,nil,nil,team_number)
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf",PATTACH_ABSORIGIN,dummy)
	ParticleManager:SetParticleControl(ifx,1,Vector(1,1,1))
	ParticleManager:SetParticleControl(ifx,2,Vector(1,1,1))
	ParticleManager:ReleaseParticleIndex(ifx)

	---[[
	local sub_num = 6
	local sub_radius = radius * 0.33
	local angle_offset = RandomInt(1,360)
	local angle_delta = 360/sub_num
	for i=1,sub_num do
		local angle = angle_offset + i*angle_delta
		local dx = math.cos(angle*3.14/180) * sub_radius
		local dy = math.sin(angle*3.14/180) * sub_radius
		local sub_point = point + Vector(dx,dy,0)
		local dummy = CreateUnitByName("npc_dummy_unit",sub_point,false,nil,nil,team_number)
		dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf",PATTACH_ABSORIGIN,dummy)
		ParticleManager:SetParticleControl(ifx,1,Vector(3,3,3))
		ParticleManager:SetParticleControl(ifx,2,Vector(3,3,3))
		ParticleManager:ReleaseParticleIndex(ifx)
	end
	--]]
end

function C05T_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	
	-- 提示攻擊範圍
	local dummy = CreateUnitByName("npc_dummy_unit_new",point,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
	local ifx = ParticleManager:CreateParticle("particles/c05/c05t_aoe_hint.vpcf",PATTACH_ABSORIGIN,dummy)
	ParticleManager:ReleaseParticleIndex(ifx)

	Timers:CreateTimer(ability:GetChannelTime()-0.3, function()
		if ability:IsChanneling() then
			local dummy = CreateUnitByName("npc_dummy_unit_new",caster:GetAbsOrigin(),false,nil,nil,caster:GetTeamNumber())
			dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
			local ifx = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_start.vpcf",PATTACH_ABSORIGIN,dummy)
			ParticleManager:ReleaseParticleIndex(ifx)

			EmitSoundOn("Hero_Zuus.GodsWrath.PreCast",dummy)
		end
	end)
end

function C05T_OnChannelInterrupted( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
	ability:EndCooldown()
	ability:StartCooldown(ability:GetCooldown(level)*0.25)
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

	damage_table = {
		victim = nil,
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