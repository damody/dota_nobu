

function attribute_bonus(keys)
	local level = keys.ability:GetLevel()
	keys.caster:ModifyStrength( 3 )
	keys.caster:ModifyAgility( 3 )
	keys.caster:ModifyIntellect( 3 )
	keys.caster:CalculateStatBonus()  --This is needed to update Morphling's maximum HP when his STR is changed, for example.
end