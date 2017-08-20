
flash_items = {
	["item_magic_ring"] = true,
	["item_flash_ring"] = true,
	["item_flash_shoes"] = true,
}

function C13W_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	local interval = ability:GetSpecialValueFor("interval")
	local move = ability:GetSpecialValueFor("move")
	local count = ability:GetSpecialValueFor("count")
	ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = 0.5})
	local sum = 0
	Timers:CreateTimer(interval, function()
		if IsValidEntity(target) then
			AMHC:Damage(caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			local dir = -(target:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized()
			target:SetAbsOrigin(target:GetAbsOrigin()+dir*move)
			target:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
			sum = sum + 1
			if sum < count then
				return interval
			end
		end
		end)
end

function C13E_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local dir = (target-caster:GetAbsOrigin()):Normalized()
	local projectileTable = {
		Ability = ability,
		EffectName = "particles/item/wind.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = 1200,
		fStartRadius = 200,
		fEndRadius = 200,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		bProvidesVision = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags  = DOTA_UNIT_TARGET_FLAG_NONE,
		vVelocity = dir * 1000
	}
	ProjectileManager:CreateLinearProjectile( projectileTable )
end

function C13R_OnKill( keys )
	local ability = keys.ability
	local caster = ability:GetCaster()
	local duration = 15
	if caster.C13Rcount == nil then caster.C13Rcount = 0 end
	if caster.C13Rcount < 6 then
		caster.C13Rcount = caster.C13Rcount + 1
		local Kagutsuchi = CreateUnitByName("c13r_wind",caster:GetAbsOrigin() ,true,caster,caster,caster:GetTeam())
	 	Kagutsuchi:SetOwner(caster)
	 	ability:ApplyDataDrivenModifier(Kagutsuchi,Kagutsuchi,"modifier_kill",{duration = duration})
	 	ability:ApplyDataDrivenModifier(Kagutsuchi,Kagutsuchi,"modifier_invulnerable",{duration = duration})
	 	ability:ApplyDataDrivenModifier(Kagutsuchi,Kagutsuchi,"modifier_C13R2",{duration = duration})
	 	Kagutsuchi:SetBaseDamageMin(70+caster:GetLevel()*5)
		Kagutsuchi:SetBaseDamageMax(70+caster:GetLevel()*5)
		Kagutsuchi:AddAbility("for_no_collision"):SetLevel(1)
		local ifx = ParticleManager:CreateParticle("particles/c13/c13r.vpcf",PATTACH_ABSORIGIN_FOLLOW,Kagutsuchi)
		ParticleManager:SetParticleControl(ifx,0,Kagutsuchi:GetAbsOrigin())
		Timers:CreateTimer(duration, function ()
			caster.C13Rcount = caster.C13Rcount - 1
			ParticleManager:DestroyParticle(ifx,true)
		end)
	end
end

function C13R_OnAttackLanded( keys )
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local targetArmor = target:GetPhysicalArmorValue()
	--print("steal "..dmg*keys.StealPercent*0.02*(1-damageReduction))
	if target:IsBuilding() then
		local hp = target:GetHealth()
		Timers:CreateTimer(0.01, function()
			local hp2 = hp-target:GetHealth()
			target:SetHealth(hp-hp2*0.2)
			end)
	end
end

function C13R_OnIntervalThink( keys )
	local caster = keys.caster
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
			nil,  1000 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
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

function C13T_OnSpellStart( keys )
	local ability = keys.ability
	local caster = ability:GetCaster()
	local dmg = ability:GetSpecialValueFor("dmg")
	local radius = ability:GetSpecialValueFor("radius")
	local ifx = ParticleManager:CreateParticle("particles/c13/c13r.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	local tsum = 0
	Timers:CreateTimer(0, function()
		if caster:IsChanneling() then
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				caster:GetAbsOrigin(),			-- 搜尋的中心點
				nil,
				radius,			-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false)

			-- 處理搜尋結果
			for _,unit in ipairs(units) do
				
				if IsValidEntity(unit) and _G.EXCLUDE_TARGET_NAME[unit:GetUnitName()] == nil then
					local dir = -(unit:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized()
					local right = Vector(0,0,0)
					right.x = dir.y
					right.y = -dir.x
					unit:SetAbsOrigin(unit:GetAbsOrigin()+dir*50+right*100)
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_C13T",{duration = 0.2})
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_phased",{duration = 0.2})
					if unit:IsHero() and not unit:IsIllusion() then
						for itemSlot=0,5 do
							local item = unit:GetItemInSlot(itemSlot)
							if item ~= nil then
								local itemName = item:GetName()
								if flash_items[itemName] then
									item:StartCooldown(0.3)
								end
							end
						end
					end
				end
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = dmg,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		else
			ParticleManager:DestroyParticle(ifx,false)
			return nil
		end
		tsum = tsum + 0.1
		if tsum < 5.5 then
			return 0.1
		else
			ParticleManager:DestroyParticle(ifx,false)
		end
		end)
end

function C13D_old_OnSpellStart( keys )
	local ability = keys.ability
	local caster = ability:GetCaster()
	local target = keys.target
	ability:ApplyDataDrivenModifier(caster,target,"modifier_C13D_old",{duration = 2})
end

function C13W_old_OnSpellStart( keys )
	local ability = keys.ability
	local caster = ability:GetCaster()
	local duration = ability:GetSpecialValueFor("duration")
	local damage = ability:GetSpecialValueFor("damage")
	local Kagutsuchi = CreateUnitByName("c13r_wind",caster:GetAbsOrigin() ,true,caster,caster,caster:GetTeam())
 	Kagutsuchi:SetOwner(caster)
 	ability:ApplyDataDrivenModifier(Kagutsuchi,Kagutsuchi,"modifier_kill",{duration = duration})
 	ability:ApplyDataDrivenModifier(Kagutsuchi,Kagutsuchi,"modifier_invulnerable",{duration = duration})
 	ability:ApplyDataDrivenModifier(Kagutsuchi,Kagutsuchi,"modifier_C13W_old",{duration = duration})
 	Kagutsuchi:SetBaseDamageMin(damage+caster:GetLevel()*5)
	Kagutsuchi:SetBaseDamageMax(damage+caster:GetLevel()*5)
	Kagutsuchi:AddAbility("for_no_collision"):SetLevel(1)
	local ifx = ParticleManager:CreateParticle("particles/c13/c13r.vpcf",PATTACH_ABSORIGIN_FOLLOW,Kagutsuchi)
	ParticleManager:SetParticleControl(ifx,0,Kagutsuchi:GetAbsOrigin())
	Timers:CreateTimer(duration, function ()
		ParticleManager:DestroyParticle(ifx,true)
	end)
end


function C13T_old_OnSpellStart( keys )
	local ability = keys.ability
	local caster = ability:GetCaster()
	local dmg = ability:GetSpecialValueFor("dmg")
	local radius = ability:GetSpecialValueFor("radius")
	local ifx = ParticleManager:CreateParticle("particles/c13/c13r.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	local tsum = 0
	Timers:CreateTimer(0, function()
		if caster:IsChanneling() then
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				caster:GetAbsOrigin(),			-- 搜尋的中心點
				nil,
				radius,			-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false)

			-- 處理搜尋結果
			for _,unit in ipairs(units) do
				if IsValidEntity(unit) and _G.EXCLUDE_TARGET_NAME[unit:GetUnitName()] == nil then
					local dir = -(unit:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized()
					local right = Vector(0,0,0)
					right.x = dir.y
					right.y = -dir.x
					unit:SetAbsOrigin(unit:GetAbsOrigin()+dir*30+right*50)
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_C13T",{duration = 0.1})
					if unit:IsHero() and not unit:IsIllusion() then
						for itemSlot=0,5 do
							local item = unit:GetItemInSlot(itemSlot)
							if item ~= nil then
								local itemName = item:GetName()
								if flash_items[itemName] then
									item:StartCooldown(0.3)
								end
							end
						end
					end
				end
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = dmg,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		else
			ParticleManager:DestroyParticle(ifx,false)
			return nil
		end
		tsum = tsum + 0.03
		if tsum < 4 then
			return 0.03
		else
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				caster:GetAbsOrigin(),			-- 搜尋的中心點
				nil,
				300,			-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false)

			-- 處理搜尋結果
			for _,unit in ipairs(units) do
				if IsValidEntity(unit) and _G.EXCLUDE_TARGET_NAME[unit:GetUnitName()] == nil then
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_C13T",{duration = 1.5})
				
					local point = caster:GetAbsOrigin()
					local knockbackProperties =
					{
						center_x = point.x,
						center_y = point.y,
						center_z = point.z,
						duration = 0.3,
						knockback_duration = 0.3,
						knockback_distance = 800,
						knockback_height = 0,
						should_stun = 1
					}
					unit:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
					print("modifier_knockback")
				end
			end
			ParticleManager:DestroyParticle(ifx,false)
		end
		end)
end
