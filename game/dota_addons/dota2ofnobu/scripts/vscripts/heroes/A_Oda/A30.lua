
function A30W_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local count = ability:GetSpecialValueFor("count")

 	local player = caster:GetPlayerID()
 	local time = caster:FindAbilityByName("A30R"):GetLevel()*2
 	for i=1,count do
	 	local wolf = CreateUnitByName("A30W_wolf",target:GetAbsOrigin() ,false,caster,caster,caster:GetTeam())
	 	wolf.master = caster
		wolf:SetHealth(wolf:GetMaxHealth())
		wolf:AddNewModifier(wolf,ability,"modifier_phased",{duration=0.1})
	 	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_invulnerable",{duration = 8+time})
	 	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_kill",{duration = 8+time})
	 	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_A30W_summend",{duration = 8+time})
	 	ability:ApplyDataDrivenModifier(caster,target,"modifier_A30W_view",{duration = 8+time})
	 	Timers:CreateTimer(1, function() 
	 		wolf:AddAbility("for_no_collision"):SetLevel(1)
	 		end)
		local order = {UnitIndex = wolf:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
						TargetIndex = target:entindex()}
		ExecuteOrderFromTable(order)
		Timers:CreateTimer(1, function() 
			if wolf:IsAlive() and target:IsAlive() then
				wolf:SetForceAttackTarget(target)
				return 1
			else
				wolf:SetForceAttackTarget(nil)
			end
			end)
		
	end
end

function A30W_OnAttackLanded(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local dmg = caster.master:GetIntellect()*0.5
	target:ReduceMana(12)
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
end

function A30E_OnSpellStart(keys)
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
			nil,
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

function A30R_OnAttackLanded(keys)
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local targetpos = keys.target:GetAbsOrigin()
	local particle = ParticleManager:CreateParticle("particles/a28/a28te_old_burning_pathedge.vpcf", PATTACH_CUSTOMORIGIN, nil)
	local dir = (targetpos-caster:GetAbsOrigin()):Normalized()
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	local distance = 1000
	local tsum = 0
	ParticleManager:SetParticleControl(particle, 0, targetpos)
	Timers:CreateTimer(0, function()
		if IsValidEntity(caster) then
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				targetpos,							-- 搜尋的中心點
				nil,
				radius,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				0,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 
			for _,it in pairs(units) do
				if it:IsBuilding() then
					ability:ApplyDataDrivenModifier(caster,it,"modifier_A30R2",{duration = 1.1})
				else
					ability:ApplyDataDrivenModifier(caster,it,"modifier_A30R2",{duration = 1.1})
				end
			end
			tsum = tsum + 1
	    	if tsum > duration then
	    		return nil
	    	end
		    return 1
		end
    end)
    Timers:CreateTimer(duration,function()
    	ParticleManager:DestroyParticle(particle,false)
    	end)
end


function A30T_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local targetpos = keys.target_points[1]
	local dir = (targetpos-caster:GetAbsOrigin()):Normalized()
	local wave = ability:GetSpecialValueFor("wave")
	local radius = ability:GetSpecialValueFor("radius")
	local stun = ability:GetSpecialValueFor("stun")
	local distance = 1000
	local tsum = 0
	local dummy = CreateUnitByName("npc_dummy_unit",targetpos,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=(wave*0.5)})

	local particle = ParticleManager:CreateParticle("particles/a30/a30t.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, targetpos)
	AddFOWViewer(DOTA_TEAM_GOODGUYS, targetpos, 300, 1, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, targetpos, 300, 1, false)
	Timers:CreateTimer(1, function()
		if caster:IsChanneling() then
			dummy:EmitSound("A30T.sound1")
			local particle = ParticleManager:CreateParticle("particles/a30/a30t.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(particle, 0, targetpos)
			local particle2 = ParticleManager:CreateParticle("particles/a30/a30t2flame.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(particle2, 0, targetpos)
			
			AddFOWViewer(DOTA_TEAM_GOODGUYS, targetpos, 300, 1, false)
	        AddFOWViewer(DOTA_TEAM_BADGUYS, targetpos, 300, 1, false)
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				targetpos,							-- 搜尋的中心點
				nil,
				radius,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 
			for _,it in pairs(units) do
				if it:IsBuilding() then
					ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = stun})
				else
					AMHC:Damage(caster, it, ability:GetAbilityDamage(), AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
					ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = stun})
				end
			end
		else
			return nil
		end
		tsum = tsum + 1
    	if tsum > wave then
    		return nil
    	end
	    return 0.5
    end)
end

-- 11.2B
function A30W_old_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local count = ability:GetSpecialValueFor("count")
	local hp = ability:GetSpecialValueFor("hp")

 	local player = caster:GetPlayerID()
 	for i=1,count do
	 	local wolf = CreateUnitByName("A30W_old_wolf",caster:GetAbsOrigin()+caster:GetForwardVector()*200 ,false,caster,caster,caster:GetTeam())
	 	wolf.master = caster
	 	wolf:SetBaseMaxHealth(hp)
	 	wolf:SetHealth(hp)
	 	wolf:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		wolf:SetHealth(wolf:GetMaxHealth())
		wolf:AddNewModifier(wolf,ability,"modifier_phased",{duration=0.1})
	 	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_kill",{duration = 50})
	 	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_A30W_summend",nil)
	end
end

function A30E_old_OnSpellStart(keys)
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
			nil,
			200,					-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			0,-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false) 
		for _,it in pairs(units) do
			if it.A30E == nil then
				it.A30E = true
				AMHC:Damage(caster, it, ability:GetAbilityDamage(), AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				if IsValidEntity(it) then
					Physics:Unit(it)
					ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = duration})
					ability:ApplyDataDrivenModifier(caster,it,"modifier_invulnerable",{duration = 1})
					it:SetPhysicsVelocity(Vector(0,0,2000))
					Timers:CreateTimer(0.5, function() 
						if IsValidEntity(it) then
							it:SetPhysicsVelocity(Vector(0,0,-2000))
						end
						end)
					
					Timers:CreateTimer(1, function()
						it.A30E = nil
					end)
				end
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

function A30R_old_OnAttackLanded(keys)
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local targetpos = keys.target:GetAbsOrigin()
	local particle = ParticleManager:CreateParticle("particles/a28/a28te_old_burning_pathedge.vpcf", PATTACH_CUSTOMORIGIN, nil)
	local dir = (targetpos-caster:GetAbsOrigin()):Normalized()
	local duration = ability:GetSpecialValueFor("duration")
	local radius = ability:GetSpecialValueFor("radius")
	local build_dmg = ability:GetSpecialValueFor("build_dmg")
	local distance = 1000
	local tsum = 0
	if target:IsBuilding() then
		AMHC:Damage(caster, target, keys.dmg*build_dmg, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
	ParticleManager:SetParticleControl(particle, 0, targetpos)
	Timers:CreateTimer(0, function()
		if IsValidEntity(caster) then
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				targetpos,							-- 搜尋的中心點
				nil,
				radius,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				0,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 
			for _,it in pairs(units) do
				if it:IsBuilding() then
					ability:ApplyDataDrivenModifier(caster,it,"modifier_A30R2",{duration = 1.1})
				else
					ability:ApplyDataDrivenModifier(caster,it,"modifier_A30R2",{duration = 1.1})
				end
			end
			tsum = tsum + 1
	    	if tsum > duration then
	    		return nil
	    	end
		    return 1
		end
    end)
    Timers:CreateTimer(duration,function()
    	ParticleManager:DestroyParticle(particle,false)
    	end)
end

function A30T_old_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local targetpos = keys.target_points[1]
	local dir = (targetpos-caster:GetAbsOrigin()):Normalized()
	local wave = ability:GetSpecialValueFor("wave")
	local radius = ability:GetSpecialValueFor("radius")
	local stun = ability:GetSpecialValueFor("stun")
	local distance = 1000
	local tsum = 0
	
	local dummy = CreateUnitByName("npc_dummy_unit",targetpos,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=wave})

	local particle = ParticleManager:CreateParticle("particles/a30/a30t.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, targetpos)
	AddFOWViewer(DOTA_TEAM_GOODGUYS, targetpos, 300, 1, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, targetpos, 300, 1, false)
	Timers:CreateTimer(1, function()
			dummy:EmitSound("A30T.sound1")
			local particle = ParticleManager:CreateParticle("particles/a30/a30t.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(particle, 0, targetpos)
			local particle2 = ParticleManager:CreateParticle("particles/a30/a30t2flame.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(particle2, 0, targetpos)
			
			AddFOWViewer(DOTA_TEAM_GOODGUYS, targetpos, 300, 1, false)
	        AddFOWViewer(DOTA_TEAM_BADGUYS, targetpos, 300, 1, false)
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				targetpos,							-- 搜尋的中心點
				nil,
				radius,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 
			for _,it in pairs(units) do
				if it:IsBuilding() then
					AMHC:Damage(caster, it, ability:GetAbilityDamage()*0.5, AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
					ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = stun})
				else
					AMHC:Damage(caster, it, ability:GetAbilityDamage(), AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
					ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = stun})
				end
			end
		tsum = tsum + 1
    	if tsum >= wave then
    		return nil
    	end
	    return 1
    end)
end
