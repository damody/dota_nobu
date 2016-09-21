
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local roubang = CreateUnitByName("healing_totem_unit",point ,false,caster,caster,caster:GetTeamNumber())
	roubang:FindAbilityByName("healing_totem"):SetLevel(1)
	Timers:CreateTimer(30, function ()
		roubang:ForceKill(true)
	end)
end


