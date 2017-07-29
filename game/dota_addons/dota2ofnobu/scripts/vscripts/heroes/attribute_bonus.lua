

function attribute_bonus(keys)
	local level = keys.ability:GetLevel() - 1
	local upvalue = 2
	if (keys.caster.bonus == nil) then
		keys.caster.bonus = level
		keys.caster:ModifyStrength( upvalue*level )
		keys.caster:ModifyAgility( upvalue*level )
		keys.caster:ModifyIntellect( upvalue*level )
		keys.caster:CalculateStatBonus()  --This is needed to update Morphling's maximum HP when his STR is changed, for example.
	else
		local up = level - keys.caster.bonus
		keys.caster.bonus = level
		keys.caster:ModifyStrength( upvalue*up )
		keys.caster:ModifyAgility( upvalue*up )
		keys.caster:ModifyIntellect( upvalue*up )
		keys.caster:CalculateStatBonus()
	end
end

function show_lv(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.focus > 50 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_lv2_1", nil )
	elseif caster.focus > 20 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_lv1_1", nil )
	end
end

function bonusx_lock( keys )
	keys.ability:SetActivated(false)
end

function bonusx_unlock( keys )
	keys.ability:SetActivated(true)
	keys.ability:ToggleAbility()
end