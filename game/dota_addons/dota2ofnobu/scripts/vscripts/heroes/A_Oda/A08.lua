
function A08E( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster:Heal((caster:GetMaxHealth()-caster:GetHealth())*0.2,caster)	
end





