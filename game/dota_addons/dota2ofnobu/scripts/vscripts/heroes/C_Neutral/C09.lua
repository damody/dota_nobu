-- 立花誾千代 by Nian Chen
-- 2017.4.27

function C09W_OnToggleOn( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C09W",{})

	-- 儲存當前的法球
	ability.save_nobu_orb = caster.nobuorb1
	caster.nobuorb1 = "C09W"
end

function C09W_OnToggleOff( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_C09W")

	-- 還原法球效果
	caster.nobuorb1 = ability.save_nobu_orb
end

function C09W_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local mana_cost = ability:GetSpecialValueFor("mana_cost")

	-- 當玩家裝備新的法球時，自動關閉技能
	if caster.nobuorb1 ~= "C09W" then
		ability.save_nobu_orb = caster.nobuorb1
		ability:ToggleAbility()
		return
	end

	-- 當魔力不足時自動關閉技能
	if caster:GetMana() < mana_cost then
		ability:ToggleAbility()
		return
	end

	-- 當目標是英雄或小兵才作用
	if not target:IsBuilding() then
		caster:SpendMana(mana_cost,ability)
	else
		caster:PerformAttack(target,false,false,false,false,true,false,false)
	end
end

function C09W_OnOrbImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	if not target:IsBuilding() then
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			-- damage_flags = DOTA_DAMAGE_FLAG_NONE
		})
		ability:ApplyDataDrivenModifier(caster,target,"modifier_C09W_debuff",{})
		if not target:IsMagicImmune() then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_C09W_debuff2",{})
			PopupNumbers(target, "damage", Vector(0, 255, 255), 1.0, damage, POPUP_SYMBOL_PRE_MINUS , nil )
		end
	end
end

function C09E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local healPoint = ability:GetSpecialValueFor("C09E_heal")
	local duration = ability:GetSpecialValueFor("C09E_duration")
	ability:ApplyDataDrivenModifier( caster , caster, "modifier_C09E" , { duration = duration } )
	PopupNumbers(caster, "heal", Vector(0, 255, 0), 1.0, healPoint, POPUP_SYMBOL_PRE_PLUS, nil)
end

function C09R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local distance = ability:GetSpecialValueFor("C09R_distance")
	local damage = ability:GetSpecialValueFor("C09R_damage")
	local radius = ability:GetSpecialValueFor("C09R_radius")
	local debuffDuration = ability:GetSpecialValueFor("C09R_debuffDuration")

	if (point - caster:GetAbsOrigin()):Length() > distance then
		point = (point - caster:GetAbsOrigin()):Normalized() * distance + caster:GetAbsOrigin()
	end

	FindClearSpaceForUnit( caster , point , true )
	caster:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.1 } )

	local particle = ParticleManager:CreateParticle("particles/a34e2/a34e2.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex( particle )

	StartSoundEvent( "Ability.FrostNova" , caster )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		ability:ApplyDataDrivenModifier( caster , unit , "modifier_C09R_debuff" , { duration = debuffDuration } )
		unit.C09R_state = "NONE"
		ApplyDamage(damageTable)
		local timeleft = debuffDuration
		Timers:CreateTimer(0.1, function()
			timeleft = timeleft - 0.1
			if timeleft > 0 then
				if (not unit:HasModifier("modifier_C09R_debuff")) and IsValidEntity(unit) then
					if unit.C09R_state ~= "PURGE" then
						ability:ApplyDataDrivenModifier( caster, unit , "modifier_C09R_debuff" , { duration = timeleft } )
					else
						return nil
					end
				end
				return 0.1
			else
				return nil
			end
		end)
	end
end

function C09R_debuff_OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	if target:IsMagicImmune() then
		target.C09R_state = "MAGIC_IMMUNE"
	else
		target.C09R_state = "PURGE"
	end
end

function C09T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("C09T_radius")
	local debuffDuration = ability:GetSpecialValueFor("C09T_duration")

	local eff1 = ParticleManager:CreateParticle("particles/b05t3/b05t3_j0.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(eff1, 0, caster:GetAbsOrigin())

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		if _G.EXCLUDE_TARGET_NAME[unit:GetUnitName()] == nil then
			ability:ApplyDataDrivenModifier( caster , unit , "modifier_C09T_debuff" , { duration = debuffDuration } )
		end
	end
end

function C09W_old_OnToggleOn( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C09W_old",{})

	-- 儲存當前的法球
	ability.save_nobu_orb = caster.nobuorb1
	caster.nobuorb1 = "C09W_old"
end

function C09W_old_OnToggleOff( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_C09W_old")

	-- 還原法球效果
	caster.nobuorb1 = ability.save_nobu_orb
end

function C09W_old_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local mana_cost = ability:GetSpecialValueFor("mana_cost")

	-- 當玩家裝備新的法球時，自動關閉技能
	if caster.nobuorb1 ~= "C09W_old" then
		ability.save_nobu_orb = caster.nobuorb1
		ability:ToggleAbility()
		return
	end

	-- 當魔力不足時自動關閉技能
	if caster:GetMana() < mana_cost then
		ability:ToggleAbility()
		return
	end

	-- 當目標是英雄或小兵才作用
	if not target:IsBuilding() then
		caster:SpendMana(mana_cost,ability)
	else
		caster:PerformAttack(target,false,false,false,false,true,false,false)
	end
end

function C09W_old_OnOrbImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("damage")
	if not target:IsBuilding() then
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			-- damage_flags = DOTA_DAMAGE_FLAG_NONE
		})
		ability:ApplyDataDrivenModifier(caster,target,"modifier_C09W_old_debuff",{})
		if not target:IsMagicImmune() then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_C09W_old_debuff2",{})
			PopupNumbers(target, "damage", Vector(0, 255, 255), 1.0, damage, POPUP_SYMBOL_PRE_MINUS , nil )
		end
	end
end

function C09E_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local healPoint = ability:GetSpecialValueFor("C09E_heal")
	local duration = ability:GetSpecialValueFor("C09E_duration")
	if _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] == nil then
		ability:ApplyDataDrivenModifier( caster , target, "modifier_C09E_old" , { duration = duration } )
	else
		ability:EndCooldown()
	end
	--PopupNumbers(caster, "heal", Vector(0, 255, 0), 1.0, healPoint, POPUP_SYMBOL_PRE_PLUS, nil)
end

function C09R_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local distance = ability:GetSpecialValueFor("C09R_distance")
	local damage = ability:GetSpecialValueFor("C09R_damage")
	local radius = ability:GetSpecialValueFor("C09R_radius")
	local debuffDuration = ability:GetSpecialValueFor("C09R_debuffDuration")

	if (point - caster:GetAbsOrigin()):Length() > distance then
		point = (point - caster:GetAbsOrigin()):Normalized() * distance + caster:GetAbsOrigin()
	end

	FindClearSpaceForUnit( caster , point , true )
	caster:AddNewModifier( nil, nil , "modifier_phased" , { duration = 0.1 } )

	ExecuteOrderFromTable( { UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = point })

	local particle = ParticleManager:CreateParticle("particles/a34e2/a34e2.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex( particle )

	StartSoundEvent( "Ability.FrostNova" , caster )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		ability:ApplyDataDrivenModifier( caster , unit , "modifier_C09R_old_debuff" , { duration = debuffDuration } )
		unit.C09R_old_state = "NONE"
		ApplyDamage(damageTable)
		local timeleft = debuffDuration
		Timers:CreateTimer(0.1, function()
			timeleft = timeleft - 0.1
			if timeleft > 0 then
				if (not unit:HasModifier("modifier_C09R_old_debuff")) and IsValidEntity(unit) then
					if unit.C09R_old_state ~= "PURGE" then
						ability:ApplyDataDrivenModifier( caster, unit , "modifier_C09R_old_debuff" , { duration = timeleft } )
					else
						return nil
					end
				end
				return 0.1
			else
				return nil
			end
		end)
	end
end

function C09R_old_debuff_OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	if target:IsMagicImmune() then
		target.C09R_old_state = "MAGIC_IMMUNE"
	else
		target.C09R_old_state = "PURGE"
	end
end

function C09T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("C09T_radius")
	local debuffDuration = ability:GetSpecialValueFor("C09T_duration")

	local eff1 = ParticleManager:CreateParticle("particles/b05t3/b05t3_j0.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(eff1, 0, caster:GetAbsOrigin())

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		if _G.EXCLUDE_TARGET_NAME[unit:GetUnitName()] == nil then
			ability:ApplyDataDrivenModifier( caster , unit , "modifier_C09T_old_debuff" , { duration = debuffDuration } )
		end
	end
end
