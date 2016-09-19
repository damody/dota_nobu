

function Shock( keys )
	local caster = keys.caster
	local skill = keys.ability
	local ran =  RandomInt(0, 100)
	skill:ApplyDataDrivenModifier(caster, keys.target,"modifier_spear_of_saddle",{ duration = 3.5 })
end


