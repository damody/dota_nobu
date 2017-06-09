--島左近

function A35W_OnSpellStart( event )
	local caster		= event.caster
	local ability		= event.ability
	local pathLength	= (ability:GetCursorPosition() - caster:GetAbsOrigin()):Length2D()
	local pathDelay		= event.path_delay
	local pathDuration	= event.duration
	local pathRadius	= event.path_radius

	local startPos = caster:GetAbsOrigin()
	local endPos = ability:GetCursorPosition()

	ability.ice_path_stunStart	= GameRules:GetGameTime() + pathDelay
	ability.ice_path_stunEnd	= GameRules:GetGameTime() + pathDelay + pathDuration

	ability.ice_path_startPos	= startPos * 1
	ability.ice_path_endPos		= endPos * 1

	ability.ice_path_startPos.z = 0
	ability.ice_path_endPos.z = 0

	-- Create ice_path
	local particleName = "particles/a35/a35w.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, startPos )

	ability.pfxIcePath = pfx

	-- Create ice_path_b
	particleName = "particles/a35/a35wbice_path_b.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, Vector( pathDelay + pathDuration, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 9, startPos )
	ability.pfxIcePath2 = pfx

	-- Generate projectiles
	if pathRadius < 35 then
		print( "Set the proper value of path_radius in ice_path_datadriven." )
		return
	end

	local projectileRadius = pathRadius * math.sqrt(2)
	local numProjectiles = math.floor( pathLength / (pathRadius*2) ) + 2
	local stepLength = pathLength / ( numProjectiles - 1 )

	for i=1, numProjectiles do
		local projectilePos = startPos + caster:GetForwardVector() * (i-1) * stepLength
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                              projectilePos,
                              nil,
                              projectileRadius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if it.A35W == nil then
				it.A35W = true
				AMHC:Damage( caster,it,ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end		
	end
	for i=1, numProjectiles do
		local projectilePos = startPos + caster:GetForwardVector() * (i-1) * stepLength
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                              projectilePos,
                              nil,
                              projectileRadius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			it.A35W = nil
		end		
	end
	caster:SetAbsOrigin(ability:GetCursorPosition())
	caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})

end


function A35E_OnSpellStart( keys )
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
	local particleName = "particles/a35/a35t.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
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
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_A35E",{duration = 3})
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = 1})
	end
end

function A35T_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	local particleName = "particles/a35/a35t.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
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
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = 0.1})
		unit:Stop()
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		unit:ReduceMana(ability:GetAbilityDamage())
	end
end

function A35E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local count = ability:GetSpecialValueFor("count")
	local particleName = "particles/a35/a35e_olds_heal_wispa.vpcf"
	if caster.A35Ecount == nil then
		caster.A35E = {}
		for i=1,count do
			local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
			caster.A35E[i] = pfx
		end
		caster.A35Ecount = count
	else
		local op = caster.A35Ecount + 1
		local ed = caster.A35Ecount + count + 1
		for i=op,ed do
			local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
			caster.A35E[i] = pfx
		end
		caster.A35Ecount = ed
	end

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
	local particleName = "particles/a35/a35t.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
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
	caster.A35E_old = 0
end

function A35E_old_OnDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	local count = ability:GetSpecialValueFor("count")
	if caster.A35Ecount then
		for i=1,caster.A35Ecount do
			ParticleManager:DestroyParticle(caster.A35E[i],true)
		end
		caster.A35Ecount = nil
	end
end

function A35E_old_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local count = ability:GetSpecialValueFor("count")

	for i=1,caster.A35Ecount do
		ParticleManager:SetParticleControl(caster.A35E[i],0,caster:GetAbsOrigin())
	end

	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		DOTA_UNIT_TARGET_HERO,	-- 目標類型
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 					

	caster.A35E_old = caster.A35E_old + 1
	-- 處理搜尋結果
	if #units > 0 and caster.A35Ecount > 0 and math.mod(caster.A35E_old, 4) == 0 then
		local split_shot_projectile = "particles/a35/a35e_old_2.vpcf"
		local projectile_info = 
			{
				EffectName = split_shot_projectile,
				Ability = ability,
				vSpawnOrigin = caster:GetAbsOrigin(),
				Target = units[1],
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = 700,
				bReplaceExisting = false,
				bProvidesVision = false
			}
		ProjectileManager:CreateTrackingProjectile(projectile_info)
		ParticleManager:DestroyParticle(caster.A35E[caster.A35Ecount],true)
		caster.A35Ecount = caster.A35Ecount - 1
		if caster.A35Ecount == 0 then
			caster.A35Ecount = nil
			caster:RemoveModifierByName("modifier_A35E_old")
		end
	end
end

function A35E_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	AMHC:Damage(caster,target,250,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ))
	ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = 1})
	local particleName = "particles/a35/a35t_h.vpcf"
	local pfx2 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl(pfx2,3,target:GetAbsOrigin())
end

function A35T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]
	local dmg = ability:GetSpecialValueFor("dmg")
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")

	local dummy = CreateUnitByName("npc_dummy_unit",target,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=duration})
	dummy:SetOwner(caster)
	dummy:AddAbility("majia"):SetLevel(1)
	local particleName = "particles/a35/a35t_old.vpcf"
	local pfx2 = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, dummy )
	local particleName = "particles/a35/a35t.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, dummy )
	local tsum = 0
	Timers:CreateTimer(0.2, function()
		tsum = tsum + 0.2
		if tsum > duration then
			ParticleManager:DestroyParticle(pfx2,true)
			return nil
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			target,			-- 搜尋的中心點
			nil, 			
			radius,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		-- 處理搜尋結果
		for _,unit in ipairs(units) do
			local dt = {
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = ability:GetAbilityDamage(),
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			if unit:IsBuilding() then
				dt.damage = dt.damage*0.2
			end
			if not caster:IsAlive() then
				dt.attacker = dummy
			end
			ApplyDamage(dt)
		end
		return 0.2
		end)
end