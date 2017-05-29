
function B18W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local casterLocation = keys.target_points[1]
	local range = ability:GetLevelSpecialValueFor( "B18W_range", ability:GetLevel() - 1 )
	local randonint = 5
	local dura = ability:GetLevelSpecialValueFor( "B18W_Duration", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor( "B18W_damage", ability:GetLevel() - 1 )
	local damage2 = ability:GetLevelSpecialValueFor( "B18W_damage2", ability:GetLevel() - 1 )
	local spike_amount = ability:GetLevelSpecialValueFor( "B18W_spike_amount", ability:GetLevel() - 1 )
	for i=1,spike_amount do
		local pos = casterLocation + RandomVector(RandomInt(randonint , range-randonint))
		local spike = ParticleManager:CreateParticle("particles/A25E/A25E.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(spike, 0, pos)
		Timers:CreateTimer(5, function() 
			ParticleManager:DestroyParticle(spike,true)
		end)
	end
	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), casterLocation, nil, range+50, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _,it in pairs(enemies) do
		if (not(it:IsBuilding())) then
			ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = dura})
			AMHC:Damage(caster,it, damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
	local count = 0
	Timers:CreateTimer(1, function()
		for i=1,spike_amount do
			local pos = casterLocation + RandomVector(RandomInt(randonint , range-randonint))
			local spike = ParticleManager:CreateParticle("particles/A25E/A25E.vpcf", PATTACH_ABSORIGIN, keys.caster)
			ParticleManager:SetParticleControl(spike, 0, pos)
			Timers:CreateTimer(5, function() 
				ParticleManager:DestroyParticle(spike,true)
			end)
		end
		local enemies = FindUnitsInRadius( caster:GetTeamNumber(), casterLocation, nil, range+50, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		for _,it in pairs(enemies) do
			if (not(it:IsBuilding())) then
				AMHC:Damage(caster,it, damage2,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
			count = count + 1
			if count < 5 then
				return 1
			end
		end)
	local dummy = CreateUnitByName( "npc_dummy", casterLocation, false, caster, caster, caster:GetTeamNumber() )
	dummy:EmitSound( "B18W.spiked_carapace" )
	Timers:CreateTimer( 0.5, function()
			dummy:ForceKill( true )
			return nil
		end)
end

function B18E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster.B18E = 0
end

function B18E_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local radius2 = ability:GetSpecialValueFor("radius2")
	local dmg = ability:GetSpecialValueFor("dmg")
	caster.B18E = caster.B18E + 1
	if caster.B18E <= 9 then
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				caster:GetAbsOrigin(),							-- 搜尋的中心點
				nil, 							-- 好像是優化用的參數不懂怎麼用
				radius,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 
		if #units > 0 then
			local unit = units[RandomInt(1,#units)]
			local spike = ParticleManager:CreateParticle("particles/A25E/A25E.vpcf", PATTACH_ABSORIGIN, unit)
			ParticleManager:SetParticleControl(spike, 0, unit:GetAbsOrigin())
			Timers:CreateTimer(5, function() 
				ParticleManager:DestroyParticle(spike,true)
			end)
			local units2 = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				unit:GetAbsOrigin(),							-- 搜尋的中心點
				nil, 							-- 好像是優化用的參數不懂怎麼用
				radius2,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				0,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 
			for _,unit2 in pairs(units2) do
				AMHC:Damage(caster, unit2, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				ability:ApplyDataDrivenModifier(caster,unit2,"modifier_stunned",{duration = 0.3})
			end
		end
	end
end

function B18T_OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local duration = ability:GetSpecialValueFor("duration")
 	local wolf = CreateUnitByName("B18T_unit",caster:GetAbsOrigin()+Vector(100,0,0) ,false,caster,caster,caster:GetTeam())
 	wolf:SetOwner(caster)
 	wolf:AddAbility("for_no_collision"):SetLevel(1)
 	wolf:SetBaseMoveSpeed(800)
	wolf:AddNewModifier(wolf,ability,"modifier_phased",{duration=0.1})
	wolf:AddNewModifier(wolf,ability,"modifier_invulnerable",nil)
	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_kill",{duration = duration})
	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_B18T",nil)
end


function B18T_OnAttackLanded( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local dmg = ability:GetSpecialValueFor("dmg")
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			caster:GetAbsOrigin(),							-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			radius,					-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false) 
	for _,unit in pairs(units) do
		local spike = ParticleManager:CreateParticle("particles/b18/b18tikes.vpcf", PATTACH_ABSORIGIN, unit)
		ParticleManager:SetParticleControl(spike, 3, unit:GetAbsOrigin())
		Timers:CreateTimer(2, function() 
				ParticleManager:DestroyParticle(spike,true)
			end)
		if unit:IsBuilding() then
			AMHC:Damage(caster, unit, dmg*0.3,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		else
			AMHC:Damage(caster, unit, dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end
	end
	caster:EmitSound("B18T.sound1")
end

function B18T_OnIntervalThink( keys )
	local caster = keys.caster
	caster:SetForceAttackTarget(nil)
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
			nil,  2000 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	if #group > 0 then
		local order = {UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = group[1]:entindex()}
		if not caster:CanEntityBeSeenByMyTeam(group[1]) then
			order = {UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = group[1]:GetAbsOrigin(),
				}
		end
		ExecuteOrderFromTable(order)
		caster:SetForceAttackTarget(group[1])
		return
	end
	group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
			nil,  2000 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	if #group > 0 then
		local order = {UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = group[1]:entindex()}
		if not caster:CanEntityBeSeenByMyTeam(group[1]) then
			order = {UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
					Position = group[1]:GetAbsOrigin(),
				}
		end
		ExecuteOrderFromTable(order)
		caster:SetForceAttackTarget(group[1])
	else
		caster:SetForceAttackTarget(nil)
	end
end


function B18E_old_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local targetpos = keys.target_points[1]
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_impale_soil_rupture.vpcf", PATTACH_CUSTOMORIGIN, nil)
	local dir = (targetpos-caster:GetAbsOrigin()):Normalized()
	local start_pos = caster:GetAbsOrigin()
	local duration = ability:GetSpecialValueFor("duration")
	local distance = 1000
	local tsum = 0
	ParticleManager:SetParticleControl(particle, 3, start_pos)
	local poke_pos = start_pos
	Timers:CreateTimer(0.05, function()
		tsum = tsum + 0.1
		poke_pos = start_pos + dir*distance*tsum
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			poke_pos,							-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			200,					-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			0,-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false) 
		for _,it in pairs(units) do
			if it.A30E == nil then
				it.A30E = true
				Physics:Unit(it)
				keys.ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = duration})
				it:SetPhysicsVelocity(Vector(0,0,1000))
				Timers:CreateTimer(0.25, function() 
					if IsValidEntity(it) then
						it:SetPhysicsVelocity(Vector(0,0,-1000))
					end
					end)
				AMHC:Damage(caster, it, ability:GetAbilityDamage(), AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				Timers:CreateTimer(1, function()
					it.A30E = nil
				end)
			end
		end
    	if tsum < 1 then
    		ParticleManager:SetParticleControl(particle, 3, poke_pos)
    	else
    		ParticleManager:DestroyParticle(particle,false)
    		return nil
    	end
	    return 0.05
    end)
end

function B18T_old_OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local duration = ability:GetSpecialValueFor("duration")
 	local wolf = CreateUnitByName("B18T_unit",caster:GetAbsOrigin()+Vector(100,0,0) ,false,caster,caster,caster:GetTeam())
 	wolf:SetOwner(caster)
 	wolf:SetBaseMoveSpeed(800)
 	wolf:AddAbility("for_no_collision"):SetLevel(1)
	wolf:AddNewModifier(wolf,ability,"modifier_phased",{duration=0.1})
	wolf:AddNewModifier(wolf,ability,"modifier_invulnerable",nil)
	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_kill",{duration = duration})
	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_B18T",nil)
	ability:ApplyDataDrivenModifier(wolf,wolf,"Passive_insight_gem",nil)
end

