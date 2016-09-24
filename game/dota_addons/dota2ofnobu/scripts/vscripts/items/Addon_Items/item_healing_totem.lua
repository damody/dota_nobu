
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local roubang = CreateUnitByName("healing_totem_unit",point ,false,caster,caster,caster:GetTeamNumber())
	roubang:FindAbilityByName("healing_totem"):SetLevel(1)
	Timers:CreateTimer(30, function ()
		roubang:ForceKill(true)
	end)
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	          roubang:GetAbsOrigin(),
	          nil,
	          250,
	          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	          DOTA_UNIT_TARGET_FLAG_NONE,
	          0,
	          false)
	for _,target in pairs(direUnits) do
		target:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	end
end


