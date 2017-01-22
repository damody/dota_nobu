
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
	
	local flame = ParticleManager:CreateParticle("particles/item/item_commander_of_fantop.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(flame,4,point+Vector(0, 0, 20))
	Timers:CreateTimer(0.5, function ()
		ParticleManager:DestroyParticle(flame, false)
	end)
	
	for _,target in pairs(direUnits) do
		AMHC:Damage(caster,target, 1,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
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


