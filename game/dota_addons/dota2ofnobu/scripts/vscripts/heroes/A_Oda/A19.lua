-- 黑田孝高

function A19W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local dummy = CreateUnitByName("npc_dummy_unit",point,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=7})
	dummy:SetOwner(caster)
	dummy:AddAbility("majia"):SetLevel(1)
	local ifx = ParticleManager:CreateParticle("particles/a19/a19_wfire/monkey_king_spring_arcana_fire.vpcf",PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl(ifx,0,point)
	ParticleManager:ReleaseParticleIndex(ifx)
	-- 處理搜尋結果
	local time = 0.1 + ability:GetSpecialValueFor("time")
	local count = 0
	Timers:CreateTimer(0,function()
		count = count + 1
		if count > time then
			return nil
		end
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			point,			-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			450,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in ipairs(units) do
			local tbl = {
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = ability:GetSpecialValueFor("dmg"),
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			if unit:IsBuilding() then
				tbl.damage = tbl.damage * 0.2
			end
			ApplyDamage(tbl)
			ability:ApplyDataDrivenModifier( caster, unit, "modifier_A19W", {} )
		end		
		return 1
	end)
	local count2 = 0
	Timers:CreateTimer(2,function()
		count2 = count2 + 1
		if count2 > 5 then
			return nil
		end
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			point,			-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			450,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in ipairs(units) do
			ability:ApplyDataDrivenModifier( caster, unit, "modifier_A19W", {} )
		end		
		return 1
	end)
end

function A19E_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local center = ability:GetCursorPosition()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		target:GetAbsOrigin(),							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		450,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		ability:ApplyDataDrivenModifier( caster, unit, "modifier_A19E", {} )
	end
end


function A19R_OnAbilityExecuted( keys )
	local caster = keys.caster
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	-- 搜尋
	if keys.event_ability:IsToggle() then return end
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
	local dmgx = caster:GetIntellect() * dmg
	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if unit:IsMagicImmune() then
			AMHC:Damage(caster,unit, dmgx*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		else
			AMHC:Damage(caster,unit, dmgx,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end
end


function A19T_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = (point2-point):Normalized()
	local pointx = vec.x
	local pointy = vec.y
	local cs1	=	math.cos(30* bj_DEGTORAD)
	local sn1	=	math.sin(30* bj_DEGTORAD)
	local cs2	=	math.cos(-30* bj_DEGTORAD)
	local sn2	=	math.sin(-30* bj_DEGTORAD)
	
	local pointx1 	=  pointx * cs1 - pointy * sn1
	local pointy1 	=  pointx * sn1 + pointy * cs1
	local pointx2 	=  pointx * cs2 - pointy * sn2
	local pointy2 	=  pointx * sn2 + pointy * cs2
		
	local vec1 = Vector(pointx1 ,pointy1 , 0)
	local vec2 = Vector(pointx2 ,pointy2 , 0)
	print(pointx2 ,pointy2)
	--【Varible】
	--local duration = ability:GetLevelSpecialValueFor("duration",level)
	--local radius = ability:GetLevelSpecialValueFor("radius",level)

	--【Varible Of Tem】
	local point_tem = point + Vector(100*vec.x,100*vec.y) 
	local point_tem1 = point + Vector(100*vec.x,100*vec.y) 
	local point_tem2 = point + Vector(100*vec.x,100*vec.y) 
	local distance = 200

	--【Timer】
	local num = 0
	Timers:CreateTimer(0.03,function()
		if num == 15 then
			return nil
		else
			point_tem = Vector(point_tem.x+distance*vec.x ,  point_tem.y+distance*vec.y , point_tem.z)
			local z = GetGroundHeight(point_tem, nil)
			point_tem.z = z
			local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point_tem ,false,caster,caster,caster:GetTeam())	
			dummy:SetOwner(caster)
			dummy:FindAbilityByName("majia"):SetLevel(1)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_A19T_2",nil)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_A19T_4",nil)
			dummy:SetAbsOrigin(point_tem)
			AddFOWViewer ( caster:GetTeam(), point_tem, 200, 12, true)
			num = num + 1
			Timers:CreateTimer(13, function()
				if IsValidEntity(dummy) then
					dummy:ForceKill(true)
				end
				end)
			return 0.03
		end
	end)
	Timers:CreateTimer(0.03,function()
		if num == 15 then
			return nil
		else
			point_tem1 = Vector(point_tem1.x+distance*vec1.x ,  point_tem1.y+distance*vec1.y , point_tem1.z)
			local z = GetGroundHeight(point_tem1, nil)
			point_tem1.z = z
			local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point_tem1 ,false,caster,caster,caster:GetTeam())	
			dummy:SetOwner(caster)
			dummy:FindAbilityByName("majia"):SetLevel(1)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_A19T_2",nil)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_A19T_4",nil)
			dummy:SetAbsOrigin(point_tem1)
			AddFOWViewer ( caster:GetTeam(), point_tem1, 200, 12, true)
			Timers:CreateTimer(13, function()
				if IsValidEntity(dummy) then
					dummy:ForceKill(true)
				end
				end)
			return 0.03
		end
	end)
	Timers:CreateTimer(0.03,function()
		if num == 15 then
			return nil
		else
			point_tem2 = Vector(point_tem2.x+distance*vec2.x ,  point_tem2.y+distance*vec2.y , point_tem2.z)
			local z = GetGroundHeight(point_tem2, nil)
			point_tem2.z = z
			local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point_tem2 ,false,caster,caster,caster:GetTeam())	
			dummy:SetOwner(caster)
			dummy:FindAbilityByName("majia"):SetLevel(1)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_A19T_2",nil)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_A19T_4",nil)
			dummy:SetAbsOrigin(point_tem2)
			AddFOWViewer ( caster:GetTeam(), point_tem2, 200, 12, true)
			Timers:CreateTimer(13, function()
				if IsValidEntity(dummy) then
					dummy:ForceKill(true)
				end
				end)
			return 0.03
		end
	end)
end


-- 11.2B 


function A19W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local dummy = CreateUnitByName("npc_dummy_unit",point,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=11})
	dummy:SetOwner(caster)
	dummy:AddAbility("majia"):SetLevel(1)
	
	local ifx = ParticleManager:CreateParticle("particles/a19/a19_wfire/monkey_king_spring_arcana_fire.vpcf",PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl(ifx,0,point)
	ParticleManager:ReleaseParticleIndex(ifx)
	local ifx2 = ParticleManager:CreateParticle("particles/a19/a19w_oldchar.vpcf",PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl(ifx2,3,point)
	ParticleManager:ReleaseParticleIndex(ifx2)

	-- 處理搜尋結果
	local time1 = 0.1 + ability:GetSpecialValueFor("time1")
	local time2 = 0.1 + ability:GetSpecialValueFor("time2")
	local count = 0
	local count2 = 0
	local dmg1 = ability:GetSpecialValueFor("dmg1")
	local dmg2 = ability:GetSpecialValueFor("dmg2")
	Timers:CreateTimer(0,function()
		count = count + 1
		if count > time1 then
			return nil
		end
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			point,			-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			450,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in ipairs(units) do
			tbl={
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = dmg1,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			if unit:IsBuilding() then
				tbl.damage = tbl.damage * 0.2
			end
			ApplyDamage(tbl)
		end		
		return 1
	end)
	local count2 = 0
	Timers:CreateTimer(5,function()
		count2 = count2 + 1
		if count2 > time2 then
			return nil
		end
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			point,			-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			450,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in ipairs(units) do
			tbl={
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = dmg2,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			if unit:IsBuilding() then
				tbl.damage = tbl.damage * 0.2
			end
			ApplyDamage(tbl)
		end		
		return 1
	end)
end

function A19E_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	local knockback_speed = ability:GetSpecialValueFor("knockback_speed")
	local center = ability:GetCursorPosition()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		target:GetAbsOrigin(),							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		250,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		ability:ApplyDataDrivenModifier( caster, unit, "modifier_A19E_old", {} )
	end
end


function A19R_old_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	if not target:IsBuilding() and not caster:IsIllusion() then
		if not target:HasModifier("modifier_A19R_old") then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_A19R_old",nil)
			local handle = target:FindModifierByName("modifier_A19R_old")
			if handle then
				handle:SetStackCount(1)
			end
			AMHC:Damage(caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		else
			ability:ApplyDataDrivenModifier(caster,target,"modifier_A19R_old",nil)
			local handle = target:FindModifierByName("modifier_A19R_old")
			if handle then
				local sc = handle:GetStackCount()
				sc = sc + 1
				handle:SetStackCount(sc)
				if target:IsMagicImmune() then
					AMHC:Damage(caster,target, dmg*sc*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				else
					AMHC:Damage(caster,target, dmg*sc,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				end
			end
		end
	end
end

function A19R_old_OnDeath( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg2")
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		target:GetAbsOrigin(),							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		400,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		AMHC:Damage(caster,unit, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end


function A19T_old_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local vec = (point2-point):Normalized()
	local pointx = vec.x
	local pointy = vec.y
	local cs1	=	math.cos(30* bj_DEGTORAD)
	local sn1	=	math.sin(30* bj_DEGTORAD)
	local cs2	=	math.cos(-30* bj_DEGTORAD)
	local sn2	=	math.sin(-30* bj_DEGTORAD)
	
	local pointx1 	=  pointx * cs1 - pointy * sn1
	local pointy1 	=  pointx * sn1 + pointy * cs1
	local pointx2 	=  pointx * cs2 - pointy * sn2
	local pointy2 	=  pointx * sn2 + pointy * cs2
		
	local vec1 = Vector(pointx1 ,pointy1 , 0)
	local vec2 = Vector(pointx2 ,pointy2 , 0)
	print(pointx2 ,pointy2)
	--【Varible】
	--local duration = ability:GetLevelSpecialValueFor("duration",level)
	--local radius = ability:GetLevelSpecialValueFor("radius",level)

	--【Varible Of Tem】
	local point_tem = point + Vector(100*vec.x,100*vec.y) 
	local point_tem1 = point + Vector(100*vec.x,100*vec.y) 
	local point_tem2 = point + Vector(100*vec.x,100*vec.y) 
	local distance = 100

	--【Timer】
	local num = 0
	Timers:CreateTimer(0.03,function()
		if num == 40 then
			return nil
		else
			point_tem = Vector(point_tem.x+distance*vec.x ,  point_tem.y+distance*vec.y , point_tem.z)
			local z = GetGroundHeight(point_tem, nil)
			point_tem.z = z
			local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point_tem ,false,caster,caster,caster:GetTeam())	
			dummy:SetOwner(caster)
			dummy:FindAbilityByName("majia"):SetLevel(1)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_A19T_old_2",nil)
			ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_A19T_old_4",nil)
			dummy:SetAbsOrigin(point_tem)
			AddFOWViewer ( caster:GetTeam(), point_tem, 200, 12, true)
			num = num + 1
			Timers:CreateTimer(13, function()
				if IsValidEntity(dummy) then
					dummy:ForceKill(true)
				end
				end)
			return 0.03
		end
	end)
end
