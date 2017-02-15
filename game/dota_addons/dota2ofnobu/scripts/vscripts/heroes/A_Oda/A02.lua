-- 稻姬

function A02W_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local mana_cost = ability:GetManaCost(-1)

	-- 判斷魔力與法球刀
	if caster.nobuorb1 or caster:GetMana() < mana_cost then
		ability:ToggleAbility()
	else
		caster:SpendMana(mana_cost,ability)
	end
end

function A02W_OnOrbImpact( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()

	if target:IsHero() or target:IsCreep() then
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