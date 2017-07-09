-- 瑞龍院日秀


function A21D_OnSpellStart( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local current_mana = target:GetMana()
	local burn_amount = ability:GetSpecialValueFor("mana")
	local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
	local burn_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"
	local damageType = keys.ability:GetAbilityDamageType()
	
	-- Calculation
	local mana_to_burn = math.min( current_mana,  burn_amount)
	local life_time = 2.0
	local digits = string.len( math.floor( mana_to_burn ) ) + 1
		
	-- Apply effect of ability
	target:ReduceMana( mana_to_burn )
	caster:SetMana(caster:GetMana() + mana_to_burn)
	
	-- Show VFX
	if mana_to_burn ~= 0 then
		local numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
		ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
	    ParticleManager:SetParticleControl( numberIndex, 2, Vector( life_time, digits, 0 ) )
		local burnIndex = ParticleManager:CreateParticle( burn_particle_name, PATTACH_ABSORIGIN, target )
		
		-- Create timer to properly destroy particles
		Timers:CreateTimer( life_time, function()
				ParticleManager:DestroyParticle( numberIndex, false )
				ParticleManager:DestroyParticle( burnIndex, false)
				return nil
			end
		)
	end
end


function A21W_OnAttackStart( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local spe_value = keys.ability:GetLevelSpecialValueFor("mana", keys.ability:GetLevel() - 1 )
	if (caster.nobuorb1 == nil) then
		if not target:IsBuilding() then
		--【扣魔】
			if caster:GetMana() < spe_value then
				caster:CastAbilityToggle(ability,-1)		
				caster:SetMana(0)
			else
				caster:SetMana(caster:GetMana() - spe_value)
			end
		end
	end
end

function A21W_OnAttackLanded( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	local radius = ability:GetSpecialValueFor("radius")
	if (caster.nobuorb1 == nil) then
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			target:GetAbsOrigin(),			-- 搜尋的中心點
			nil,
			radius,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in pairs(units) do
			if unit:IsBuilding() then
				AMHC:Damage( caster,unit,dmg*0.35,ability:GetAbilityDamageType() )
			else
				AMHC:Damage( caster,unit,dmg,ability:GetAbilityDamageType() )
			end
		end
	end
end

function A21W_upgrade( keys )
  	keys.caster:FindAbilityByName("A21D"):SetLevel(keys.ability:GetLevel()+1)
end

function A21E_OnSpellStart( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local current_mana = target:GetMana() * ability:GetSpecialValueFor("mana")
	local radius = ability:GetSpecialValueFor("radius")
	local stun = ability:GetSpecialValueFor("stun")
	local damageType = keys.ability:GetAbilityDamageType()
	
	-- Calculation
	local mana_to_burn = current_mana
	local life_time = 2.0
	local digits = string.len( math.floor( mana_to_burn ) ) + 1
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			target:GetAbsOrigin(),			-- 搜尋的中心點
			nil,
			radius,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
	for _,unit in pairs(units) do
		AMHC:Damage( caster,unit,mana_to_burn+100,ability:GetAbilityDamageType() )
	end
	-- Apply effect of ability
	target:ReduceMana( mana_to_burn )
	
	ability:ApplyDataDrivenModifier(caster, target,"modifier_stunned", {duration = stun})
	local burnIndex = ParticleManager:CreateParticle( "particles/a21/a21e.vpcf", PATTACH_ABSORIGIN, target )
	
	-- Create timer to properly destroy particles
	Timers:CreateTimer( life_time, function()
			ParticleManager:DestroyParticle( burnIndex, false)
			return nil
		end
	)
end

function A21R_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local targetLoc = keys.target_points[1]
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local radius = ability:GetLevelSpecialValueFor( "radius", level - 1 )
	local dmg = ability:GetSpecialValueFor("dmg")
 	local player = caster:GetPlayerID()
 	local roubang = CreateUnitByName("a21_weapon",targetLoc ,false,caster,caster,caster:GetTeam())
 	AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 300, 3, true)
 	AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 300, 3, true)
	roubang:SetControllableByPlayer(player, true)
	caster.A21R_unit = roubang
	roubang:SetBaseMaxHealth(800+level*150)
	roubang:SetBaseDamageMin(dmg)
	roubang:SetBaseDamageMax(dmg)
	roubang:SetHealth(roubang:GetMaxHealth())
	roubang:AddNewModifier(roubang,ability,"modifier_phased",{duration=0.1})
 	ability:ApplyDataDrivenModifier(roubang,roubang,"modifier_A21R",{duration = 25})
 	ability:ApplyDataDrivenModifier(roubang,roubang,"modifier_A21R2",{duration = 25})
 	roubang:AddNewModifier(roubang,nil,"modifier_kill",{duration=25})
 	roubang:AddNewModifier(roubang,nil,"modifier_magic_immune",{duration=25})
 	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),							-- 搜尋的中心點
		nil,
		ability:GetSpecialValueFor("radius"),					-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 

 	for _,unit in pairs(units) do
		ability:ApplyDataDrivenModifier(caster, unit,"modifier_stunned", {duration = 0.1})
	end
	Timers:CreateTimer(1, function()
		if IsValidEntity(roubang) and roubang:IsAlive() then
			AddFOWViewer(DOTA_TEAM_GOODGUYS, roubang:GetAbsOrigin(), 300, 3, true)
 			AddFOWViewer(DOTA_TEAM_BADGUYS, roubang:GetAbsOrigin(), 300, 3, true)
 			return 1
		end
	end)
end

function A21R_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),							-- 搜尋的中心點
		nil,
		ability:GetSpecialValueFor("radius"),					-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)
	if #units > 0 then
		local v = units[RandomInt(1,#units)]
		local split_shot_projectile = "particles/a21/a21r.vpcf"
		local projectile_info = 
			{
				EffectName = split_shot_projectile,
				Ability = ability,
				vSpawnOrigin = caster:GetAbsOrigin(),
				Target = v,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = 1400,
				bReplaceExisting = false,
				bProvidesVision = false
			}
		ProjectileManager:CreateTrackingProjectile(projectile_info)
	end
end

function A21T_OnSpellStart( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	ability:ApplyDataDrivenModifier(caster, target,"modifier_A21T", {duration = duration})
	local ancient =  Entities:FindByName( nil, "dota_goodguys_fort" )
	if target:GetTeamNumber() == 3 then
		ancient =  Entities:FindByName( nil, "dota_badguys_fort" )
	end
	local tc = 0
	Timers:CreateTimer(0, function()
		tc = tc + 0.1
		target.A21T = false
		ExecuteOrderFromTable({
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = ancient:GetAbsOrigin(),
			Queue = false
		})
		target.A21T = true
		if tc < duration then
			return 0.1
		end
	end)
	Timers:CreateTimer(duration+0.2, function()
		if IsValidEntity(target) then
			target.A21T = nil
		end
	end)
end

-- 11.2B

function A21W_old_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local targetLoc = keys.target_points[1]
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor( "radius")
	local duration = ability:GetSpecialValueFor( "duration")

 	local player = caster:GetPlayerID()
 	local roubang = CreateUnitByName("A19W_old_SUMMEND_UNIT",targetLoc ,false,caster,caster,caster:GetTeam())
 	AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 300, 3, true)
 	AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 300, 3, true)
	roubang:SetControllableByPlayer(player, true)
	roubang:SetBaseMaxHealth(900+level*100)
	roubang:SetHealth(roubang:GetMaxHealth())
	roubang:AddNewModifier(roubang,ability,"modifier_phased",{duration=0.1})
 	ability:ApplyDataDrivenModifier(roubang,roubang,"modifier_A21W",{duration = duration})
 	roubang:AddNewModifier(roubang,nil,"modifier_kill",{duration=duration})
 	roubang:AddNewModifier(roubang,nil,"modifier_magic_immune",{duration=duration})
 	ability:ApplyDataDrivenModifier(roubang,roubang,"Passive_A21W_old3",{duration = duration})
end


function A21W_old_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),							-- 搜尋的中心點
		nil,
		ability:GetSpecialValueFor("radius"),					-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		0,-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)
	print("A21W_old_OnIntervalThink", dmg)
	for i,unit in pairs(units) do
		AMHC:Damage( caster,unit,dmg, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end

function A21E_old_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local targetLoc = keys.target_points[1]
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor( "radius")
	local duration = ability:GetSpecialValueFor("duration")

 	local player = caster:GetPlayerID()
 	local roubang = CreateUnitByName("a21_weapon",targetLoc ,false,caster,caster,caster:GetTeam())
 	AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 300, 3, true)
 	AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 300, 3, true)
	roubang:SetControllableByPlayer(player, true)
	roubang:SetBaseMaxHealth(800+level*150)
	roubang:SetHealth(roubang:GetMaxHealth())
	roubang:AddNewModifier(roubang,ability,"modifier_phased",{duration=0.1})
 	ability:ApplyDataDrivenModifier(roubang,roubang,"modifier_A21E_old",{duration = duration})
 	roubang:AddNewModifier(roubang,nil,"modifier_kill",{duration=duration})
 	roubang:AddNewModifier(roubang,nil,"modifier_magic_immune",{duration=duration})
 	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),							-- 搜尋的中心點
		nil,
		ability:GetSpecialValueFor("radius"),					-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 

 	for _,unit in pairs(units) do
		ability:ApplyDataDrivenModifier(caster, unit,"modifier_stunned", {duration = 0.1})
	end
	Timers:CreateTimer(1, function()
		if IsValidEntity(roubang) and roubang:IsAlive() then
			AddFOWViewer(DOTA_TEAM_GOODGUYS, roubang:GetAbsOrigin(), 300, 3, true)
 			AddFOWViewer(DOTA_TEAM_BADGUYS, roubang:GetAbsOrigin(), 300, 3, true)
 			return 1
		end
	end)
end

function A21E_old_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability

	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),							-- 搜尋的中心點
		nil,
		ability:GetSpecialValueFor("radius"),					-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)
	if #units > 0 then
		local v = units[RandomInt(1,#units)]
		local split_shot_projectile = "particles/a21/a21r.vpcf"
		local projectile_info = 
			{
				EffectName = split_shot_projectile,
				Ability = ability,
				vSpawnOrigin = caster:GetAbsOrigin(),
				Target = v,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = 1400,
				bReplaceExisting = false,
				bProvidesVision = false
			}
		ProjectileManager:CreateTrackingProjectile(projectile_info)
	end
end

function A21R_Sound( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if IsValidEntity(caster.A21R_unit) then
		--caster.A21R_unit:PerformAttack(target, true, true, true, true, true, false, true)
	end
	if ability.A21R == nil then
		target:EmitSound("A21R.vo1")
		ability.A21R = 1
		Timers:CreateTimer(0.4-RandomFloat(0, 0.3), function()
			ability.A21R = nil
		end)
	end
end

function A21T_old_OnAbilityPhaseStart( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local mana = ability:GetSpecialValueFor("mana")
	if target:GetMana() > mana then
		caster:Interrupt()
	end
end

function A21T_old_OnSpellStart( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	ability:ApplyDataDrivenModifier(caster, target,"modifier_A21T", {duration = duration})
	local ancient =  Entities:FindByName( nil, "dota_goodguys_fort" )
	if target:GetTeamNumber() == 3 then
		ancient =  Entities:FindByName( nil, "dota_badguys_fort" )
	end
	local tc = 0
	Timers:CreateTimer(0, function()
		tc = tc + 0.1
		target.A21T = false
		ExecuteOrderFromTable({
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = ancient:GetAbsOrigin(),
			Queue = false
		})
		target.A21T = true
		if tc < duration then
			return 0.1
		end
	end)
	
	Timers:CreateTimer(duration+0.2, function()
		if IsValidEntity(target) then
			target.A21T = nil
		end
	end)
end
