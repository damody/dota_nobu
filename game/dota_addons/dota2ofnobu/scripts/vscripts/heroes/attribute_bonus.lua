

function attribute_bonus(keys)
	local level = keys.ability:GetLevel()
	local upvalue = 3
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