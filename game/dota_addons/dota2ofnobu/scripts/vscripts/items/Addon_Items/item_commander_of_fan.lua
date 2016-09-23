
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
          point,
          nil,
          300,
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
          0,
          false)
	for _,target in pairs(direUnits) do
		if not target:IsBuilding() then
			if (target:IsMagicImmune()) then
				ability:ApplyDataDrivenModifier(caster,target,"modifier_commander_of_fan1",nil)
			elseif (target:IsHero()) then
				ability:ApplyDataDrivenModifier(caster,target,"modifier_commander_of_fan2",nil)
			else
				ability:ApplyDataDrivenModifier(caster,target,"modifier_commander_of_fan3",nil)
			end
		end
	end
end


