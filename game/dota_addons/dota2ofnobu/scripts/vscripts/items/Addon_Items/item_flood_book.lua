
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local particle = ParticleManager:CreateParticle("particles/item/item_flood_book.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(particle,0,point)
	local SEARCH_RADIUS = 400
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
          point,
          nil,
          SEARCH_RADIUS,
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
          0,
          false)
	for _,target in pairs(direUnits) do
		if not target:IsBuilding() then
			Physics:Unit(target)
			target:SetPhysicsVelocity((target:GetAbsOrigin() - point):Normalized()*700)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_flood_book", {duration = 0.5})
			AMHC:Damage(caster,target,300,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end


