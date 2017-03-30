-- 島津義弘


function C03W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	AMHC:AddModelScale(caster, 1.3, 6)
end

function C03W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	AMHC:AddModelScale(caster, 1.3, 13)
end


function C03E_OnSpellStart( keys )
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
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_C03E_debuff", nil)
	end
end

function C03R_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not target:IsBuilding() then
		local rnd = RandomInt(1,100)
		caster:RemoveModifierByName("modifier_C03R_nomiss")
		if caster.C03E == nil then
			caster.C03E = 0
		end
		caster.C03E = caster.C03E + 1
		if rnd <= 31 or caster.C03E > 3 then
			caster.C03E = 0
			caster.C03E_go = 1
			local rate = caster:GetAttackSpeed()+0.1
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_C03R_nomiss",{duration=rate})
		end
	end
end

function C03R_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	if not target:IsBuilding() then
		if caster.C03E_go == 1 then
			caster.C03E_go = 0
			caster:EmitSound("ITEM_D09.sound")
			local ifx = ParticleManager:CreateParticle("particles/a07t2/a07t2.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
			ParticleManager:SetParticleControl(ifx,0,target:GetAbsOrigin())
			
			Timers:CreateTimer(0.3,function()
				ParticleManager:DestroyParticle(ifx, true)
			end)
			if not target:IsMagicImmune() then
				ability:ApplyDataDrivenModifier( caster, target, "modifier_stunned", {duration=0.4} )
				AMHC:Damage(caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			else
				AMHC:Damage(caster,target, dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			end
		end
	end
end


function C03T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local center = caster:GetAbsOrigin()
	local dir = (point-center):Normalized()
	local robon = CreateUnitByName("C03T_UNIT",caster:GetAbsOrigin(),false,nil,nil,caster:GetTeamNumber())

	local stun_time = ability:GetSpecialValueFor("stun_time")
	local stun_time2 = ability:GetSpecialValueFor("stun_time2")
	local check_time = ability:GetSpecialValueFor("check_time")
	local total_time = ability:GetSpecialValueFor("total_time")
	
	robon:SetOwner(caster)
	robon:FindAbilityByName("majia"):SetLevel(1)
	
	local rp = robon:GetAbsOrigin()
	rp.z = rp.z + 300
	robon:SetAbsOrigin(rp)
	local speed = 100
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir
	end
	robon:SetForwardVector(dir)
	local fake_center = center - dir
	local distance = 2000
	local duration = distance/speed
	-- 把自己踢過去
	local knockbackProperties = {
	    center_x = fake_center.x,
	    center_y = fake_center.y,
	    center_z = fake_center.z,
	    duration = duration,
	    knockback_duration = duration,
	    knockback_distance = distance,
	    knockback_height = 0,
	    should_stun = 0,
	}
	ability:ApplyDataDrivenModifier(robon,robon,"modifier_knockback",knockbackProperties)
	caster:RemoveGesture(ACT_DOTA_FLAIL)
	Timers:CreateTimer(0,function()
		if IsValidEntity(robon) then
			robon:EmitSound("A07T.attack")
			local pos = robon:GetAbsOrigin()
			pos = pos + dir * 300
			-- 搜尋
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				pos,							-- 搜尋的中心點
				nil, 							-- 好像是優化用的參數不懂怎麼用
				500,			-- 搜尋半徑
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
				if unit:IsMagicImmune() then
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned", {duration=stun_time2})
				else
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned", {duration=stun_time})
				end
			end
			return check_time
		end
	end)
	Timers:CreateTimer(total_time,function()
		robon:ForceKill(false)
		robon:Destroy()
	end)
end




function C03T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local center = caster:GetAbsOrigin()
	local dir = (point-center):Normalized()
	local robon = CreateUnitByName("C03T_UNIT",caster:GetAbsOrigin(),false,nil,nil,caster:GetTeamNumber())

	local stun_time = ability:GetSpecialValueFor("stun_time")
	local check_time = ability:GetSpecialValueFor("check_time")
	local total_time = ability:GetSpecialValueFor("total_time")
	
	robon:SetOwner(caster)
	robon:FindAbilityByName("majia"):SetLevel(1)
	
	local rp = robon:GetAbsOrigin()
	rp.z = rp.z + 300
	robon:SetAbsOrigin(rp)
	local speed = 100
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir
	end
	robon:SetForwardVector(dir)
	local fake_center = center - dir
	local distance = 2000
	local duration = distance/speed
	-- 把自己踢過去
	local knockbackProperties = {
	    center_x = fake_center.x,
	    center_y = fake_center.y,
	    center_z = fake_center.z,
	    duration = duration,
	    knockback_duration = duration,
	    knockback_distance = distance,
	    knockback_height = 0,
	    should_stun = 0,
	}
	ability:ApplyDataDrivenModifier(robon,robon,"modifier_knockback",knockbackProperties)
	caster:RemoveGesture(ACT_DOTA_FLAIL)
	Timers:CreateTimer(0,function()
		if IsValidEntity(robon) then
			robon:EmitSound("A07T.attack")
			local pos = robon:GetAbsOrigin()
			pos = pos + dir * 300
			-- 搜尋
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				pos,							-- 搜尋的中心點
				nil, 							-- 好像是優化用的參數不懂怎麼用
				500,			-- 搜尋半徑
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
				ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned", {duration=stun_time})
			end
			return check_time
		end
	end)
	Timers:CreateTimer(total_time,function()
		robon:ForceKill(false)
		robon:Destroy()
	end)
end