
function Shock( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	if (target:GetTeamNumber() == caster:GetTeamNumber()) then
		keys.ability:ApplyDataDrivenModifier(caster, target,"modifier_spell_book_friendly", nil)
	else
		keys.ability:ApplyDataDrivenModifier(caster, target,"modifier_spell_book_enemy", nil)
	end
end
