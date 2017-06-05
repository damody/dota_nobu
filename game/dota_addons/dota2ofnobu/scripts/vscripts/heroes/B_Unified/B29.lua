
--村上



function B29W_OnSpellStart( event )
	-- Variables
	local ability = event.ability
	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("stun")
	local caster = event.caster
	caster:EmitSound( "Hero_Nevermore.ROS_Flames")
	local ifx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 550, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		damageTable = {
		victim = unit,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if not unit:IsBuilding() then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_B29W", {duration=duration})
			ApplyDamage(damageTable)
		end
	end
end
function B29E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	caster:StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT_END,2)
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

	local damage_table = {
		--victim = unit,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		damage_table.victim = unit
		ApplyDamage(damage_table)
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_B29E_debuff", nil)
	end
end


function B29R_OnSpellStart( keys )
	local caster = keys.caster
	local ability= keys.ability
	if (caster:FindModifierByName("modifier_B29R_aura")) then
		caster:RemoveModifierByName("modifier_B29R_aura")
	end
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
	Timers:CreateTimer(0.2,function()
		local order = {UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()}
		ExecuteOrderFromTable(order)
		end)
	local ifx = ParticleManager:CreateParticle("particles/a19/a19_wfire/monkey_king_spring_arcana_fire.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(ifx)
	local targets=FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 500, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for i,unit in pairs(targets) do
		local damageTable = {victim=unit,   
			attacker=caster,         
			damage=ability:GetAbilityDamage(),   
			damage_type=ability:GetAbilityDamageType()} 
		if not unit:IsMagicImmune() then
			ApplyDamage(damageTable)   
		end
	end

	Timers:CreateTimer(9, function ()
		--caster:FindAbilityByName("B31W"):SetActivated(true)
		if not(caster:FindModifierByName("modifier_B29R_aura")) then
			ability:ApplyDataDrivenModifier(caster, caster,"modifier_B29R_aura",nil)
		end
		return nil
	end)
end

function B29T_Effect( keys, point )
	local dmg = 84
	local SEARCH_RADIUS = 240
	local caster = keys.caster
	local level = keys.ability:GetLevel()

	Timers:CreateTimer(0.45, function()
		local dummy = CreateUnitByName( "npc_dummy", point, false, caster, caster, caster:GetTeamNumber() )
		dummy:EmitSound( "C01T.sound" )
		Timers:CreateTimer( 0.5, function()
						dummy:ForceKill( true )
						return nil
					end
				)
		-- 砍樹
		GridNav:DestroyTreesAroundPoint(point, SEARCH_RADIUS, false)
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              point,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				if it:IsHero() then
					ParticleManager:CreateParticle("particles/shake1.vpcf", PATTACH_ABSORIGIN, it)
				end
				AMHC:Damage(caster,it,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_B29T",nil)
			else
				AMHC:Damage(caster,it,dmg*0.3,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		return nil
	end)


	--particle
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/invoker_chaos_meteor_fly2.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, point + Vector (1000, 0, 1000))
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(0.5, 0, 0))

end


function B29T( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local level = keys.ability:GetLevel()
	local skillcount = 0
	local skillmax = keys.ability:GetLevelSpecialValueFor("B29T_Amount",level-1)
	--大絕直徑
	local sk_radius = keys.ability:GetLevelSpecialValueFor("B29T_Radius",level-1)
	sk_radius = sk_radius + 100
	AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 6.0, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 6.0, false)
	--轉半徑
	sk_radius = sk_radius*0.5
	Timers:CreateTimer(0.1, function()
		AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 0.5, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 0.5, false)
		AddFOWViewer(caster:GetTeamNumber(), point, sk_radius+100, 0.5, false)
		if ( RandomInt(1, 10) > 3) then
			B29T_Effect(keys, point + RandomVector(RandomInt(sk_radius*0.7, sk_radius)))
		else
			B29T_Effect(keys, point + RandomVector(RandomInt(1, sk_radius*0.5)))
		end

		if  ( (skillcount < skillmax) and caster:IsChanneling() ) then
			skillcount = skillcount + 1
			return 0.1
		else
			return nil
		end
	end)
end







function B29W_old_OnSpellStart( event )
	-- Variables
	local ability = event.ability
	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("stun")
	local caster = event.caster
	caster:EmitSound( "Hero_Nevermore.ROS_Flames")
	local ifx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 550, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		damageTable = {
		victim = unit,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if not unit:IsBuilding() then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_B29W_old", {duration=duration})
			ApplyDamage(damageTable)
		end
	end
end


function B29E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	caster:StartGestureWithPlaybackRate(ACT_DOTA_TELEPORT_END,2)
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

	local damage_table = {
		--victim = unit,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		damage_table.victim = unit
		ApplyDamage(damage_table)
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_B29E_old_debuff", nil)
	end
end




function B29T_old_Effect( keys, point )
	local dmg = 84
	local SEARCH_RADIUS = 240
	local caster = keys.caster
	local level = keys.ability:GetLevel()

	Timers:CreateTimer(0.45, function()
		local dummy = CreateUnitByName( "npc_dummy", point, false, caster, caster, caster:GetTeamNumber() )
		dummy:EmitSound( "C01T.sound" )
		Timers:CreateTimer( 0.5, function()
						dummy:ForceKill( true )
						return nil
					end
				)
		-- 砍樹
		GridNav:DestroyTreesAroundPoint(point, SEARCH_RADIUS, false)
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              point,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				if it:IsHero() then
					ParticleManager:CreateParticle("particles/shake1.vpcf", PATTACH_ABSORIGIN, it)
				end
				AMHC:Damage(caster,it,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_B29T_old",nil)
			else
				AMHC:Damage(caster,it,dmg*0.3,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		return nil
	end)


	--particle
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/invoker_chaos_meteor_fly2.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, point + Vector (1000, 0, 1000))
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(0.5, 0, 0))

end


function B29T_old( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local level = keys.ability:GetLevel()
	local skillcount = 0
	local skillmax = keys.ability:GetLevelSpecialValueFor("B29T_old_Amount",level-1)
	--大絕直徑
	local sk_radius = keys.ability:GetLevelSpecialValueFor("B29T_old_Radius",level-1)
	sk_radius = sk_radius + 100
	AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 6.0, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 6.0, false)
	--轉半徑
	sk_radius = sk_radius*0.5
	Timers:CreateTimer(0.1, function()
		AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 0.5, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 0.5, false)
		AddFOWViewer(caster:GetTeamNumber(), point, sk_radius+100, 0.5, false)
		if ( RandomInt(1, 10) > 3) then
			B29T_old_Effect(keys, point + RandomVector(RandomInt(sk_radius*0.7, sk_radius)))
		else
			B29T_old_Effect(keys, point + RandomVector(RandomInt(1, sk_radius*0.5)))
		end

		if  ( (skillcount < skillmax) and caster:IsChanneling() ) then
			skillcount = skillcount + 1
			return 0.1
		else
			return nil
		end
	end)
end