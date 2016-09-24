
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability

	caster:SetHealth(caster:GetHealth()*0.9+1)
end

