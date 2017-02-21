-- 稻姬

function A02W_OnToggleOn( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A02W",{})

	-- 儲存當前的法球
	ability.save_nobu_orb = caster.nobuorb1
	caster.nobuorb1 = "A02W"
end

function A02W_OnToggleOff( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_A02W")

	-- 還原法球效果
	caster.nobuorb1 = ability.save_nobu_orb
end

function A02W_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local mana_cost = ability:GetSpecialValueFor("mana_cost")

	-- 當玩家裝備新的法球時，自動關閉技能
	if caster.nobuorb1 ~= "A02W" then
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
	if not target:IsBuilding() and not target:IsMagicImmune() then
		caster:SpendMana(mana_cost,ability)
	else
		caster:PerformAttack(target,false,false,false,false,true,false,false)
	end
end

function A02W_OnOrbImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()
	if not target:IsBuilding() and not target:IsMagicImmune() then
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			-- damage_flags = DOTA_DAMAGE_FLAG_NONE
		})
		ability:ApplyDataDrivenModifier(caster,target,"modifier_A02W_debuff",{})
		SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,target,damage,nil)
	end
end

function A02E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local hp_recover = ability:GetSpecialValueFor("hp_recover")

	caster:Heal(hp_recover,caster)
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_HEAL,caster,hp_recover,nil)
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A02E_buff",{})

	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(ifx,1,caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster:GetAbsOrigin(),true)
	ParticleManager:ReleaseParticleIndex(ifx)
end

-- 稻姬 11.2B

function A02W_old_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local mana_cost = ability:GetSpecialValueFor("mana_cost")

	-- 當玩家裝備新的法球時，自動關閉技能
	if caster.nobuorb1 ~= "A02W" then
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
	if not target:IsBuilding() and not target:IsMagicImmune() then
		caster:SpendMana(mana_cost,ability)
	else
		caster:PerformAttack(target,false,false,false,false,true,false,false)
	end
end

function A02W_old_apply_dot( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()
	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		-- damage_flags = DOTA_DAMAGE_FLAG_NONE
	})
	SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,target,damage,nil)
end

function A02R_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local buff_duration = ability:GetSpecialValueFor("buff_duration")

	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_enchantress/enchantress_natures_attendants_heal.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(ifx,1,caster,PATTACH_ABSORIGIN_FOLLOW,nil,caster:GetAbsOrigin(),true)
	ParticleManager:ReleaseParticleIndex(ifx)

	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_enchantress/enchantress_natures_attendants_lvl2.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
	ParticleManager:SetParticleControlEnt(ifx,3,target,PATTACH_OVERHEAD_FOLLOW,nil,target:GetAbsOrigin(),true)
	ParticleManager:SetParticleControlEnt(ifx,4,target,PATTACH_OVERHEAD_FOLLOW,nil,target:GetAbsOrigin(),true)
	ParticleManager:SetParticleControlEnt(ifx,5,target,PATTACH_OVERHEAD_FOLLOW,nil,target:GetAbsOrigin(),true)
	ParticleManager:SetParticleControlEnt(ifx,6,target,PATTACH_OVERHEAD_FOLLOW,nil,target:GetAbsOrigin(),true)
	ParticleManager:SetParticleControlEnt(ifx,7,target,PATTACH_OVERHEAD_FOLLOW,nil,target:GetAbsOrigin(),true)

	Timers:CreateTimer(buff_duration, function() 
		ParticleManager:DestroyParticle(ifx,false) 
	end)

	ability:ApplyDataDrivenModifier(caster,target,"modifier_A02R_old",{duration=buff_duration})
end