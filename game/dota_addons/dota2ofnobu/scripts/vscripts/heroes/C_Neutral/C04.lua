
function C04E_lock( keys )
	keys.ability:SetActivated(false)
end

function C04E_unlock( keys )
	keys.ability:SetActivated(true)
end


function C04E_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local dmghp = ability:GetSpecialValueFor("dmghp") + (caster:GetIntellect()/50*0.01)
	local mana = ability:GetSpecialValueFor("mana")
	if caster:GetMana() < mana then
		ability:ToggleAbility()
		return
	end
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
			damage = ability:GetAbilityDamage()+unit:GetMaxHealth()*dmghp,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		if IsValidEntity(unit) then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_C04E_2",{duration = 1.1})
		end
	end
end

function C04R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local pos = keys.target_points[1]
	local radius = ability:GetSpecialValueFor("radius")

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		pos,			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		radius,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 	

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_weave_circle_ray.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, pos)
	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if IsValidEntity(unit) then
			unit:SetAbsOrigin(pos)
			unit:AddNewModifier(unit,ability,"modifier_phased",{duration=0.1})
			unit:AddNewModifier(unit,ability,"modifier_stunned",{duration=0.1})
		end
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

function C04T( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point  = keys.caster:GetAbsOrigin()

	--se
	-- local particle = ParticleManager:CreateParticle( "particles/C04T3/C04T3.vpcf", PATTACH_POINT, caster )
	-- ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_attack1", target:GetAbsOrigin(), true)
	-- ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT, "attach_attack1", target:GetAbsOrigin(), true)

	--se2
	local particle = ParticleManager:CreateParticle("particles/c04/c04tshield.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl(particle,0,target:GetAbsOrigin()+Vector(0,0,220))
	-- ParticleManager:SetParticleControl(particle,1,target:GetAbsOrigin()+Vector(0,0,220))
	caster.C04T_target = target
	--
	caster.C04T_P = particle
	Timers:CreateTimer(0.5, function ()
			caster:StartGestureWithPlaybackRate(ACT_DOTA_SPAWN,2)
          	if target ~= nil and IsValidEntity(target) and target:HasModifier("modifier_C04T") and caster:HasModifier("modifier_C04T2") then
          		target:StartGestureWithPlaybackRate(ACT_DOTA_SPAWN,2)
          		return 0.5
          	end
          	end)
	Timers:CreateTimer(0.2, function ()
          if target ~= nil and IsValidEntity(target) and target:HasModifier("modifier_C04T") and caster:HasModifier("modifier_C04T2") and caster:IsChanneling() then
          	return 0.2
          else
          	if IsValidEntity(target) then
      			target:RemoveModifierByName("modifier_C04T")
      		end
          	caster.C04T_target = nil
          	ParticleManager:DestroyParticle(particle,false)
          	return nil
          end
        end)
end

function C04E_old_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local mana = ability:GetSpecialValueFor("mana")
	if caster:GetMana() < mana then
		ability:ToggleAbility()
		return
	end
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
		if IsValidEntity(unit) then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_C04E_2",{duration = 1.1})
		end
	end
end

--11.2b

function C04R_old_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local dir = ability:GetCursorPosition() - caster:GetOrigin()
	local duration = ability:GetSpecialValueFor("duration")

	for i=1,3 do
		local pos = caster:GetOrigin() + dir:Normalized() * (i * 300)
		local ifx = ParticleManager:CreateParticle( "particles/c04/c04r_old.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( ifx, 0, pos + Vector(0,0,50))
		ParticleManager:SetParticleControl( ifx, 3, pos + Vector(0,0,50))

		local SEARCH_RADIUS = 300
		GridNav:DestroyTreesAroundPoint(pos, SEARCH_RADIUS, false)
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              pos,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				if it.b09e == nil then
					AMHC:Damage(caster,it, ability:GetSpecialValueFor("damage"),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
					ability:ApplyDataDrivenModifier(caster, it,"modifier_stunned",{duration=duration})
					it.b09e = 1
				end
			end
		end
	end

	for i=1,3 do
		local pos = caster:GetOrigin() + dir:Normalized() * (i * 300)
		local SEARCH_RADIUS = 300
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              pos,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				it.b09e = nil
			end
		end
	end
end

