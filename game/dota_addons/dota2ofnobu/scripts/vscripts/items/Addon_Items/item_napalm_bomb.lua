--爆烈彈
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	

	local explosion_effect = ParticleManager:CreateParticle("particles/econ/courier/courier_snapjaw/courier_snapjaw_ambient_rocket_explosion_flash_c.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(explosion_effect, 3, point+Vector(100, 0, 0))
	explosion_effect = ParticleManager:CreateParticle("particles/econ/courier/courier_snapjaw/courier_snapjaw_ambient_rocket_explosion_flash_c.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(explosion_effect, 3, point+Vector(-50, 50, 0))
	explosion_effect = ParticleManager:CreateParticle("particles/econ/courier/courier_snapjaw/courier_snapjaw_ambient_rocket_explosion_flash_c.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(explosion_effect, 3, point+Vector(-50, -50, 0))

	local SEARCH_RADIUS = 300
	GridNav:DestroyTreesAroundPoint(point, SEARCH_RADIUS, false)
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              point,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)

	--effect:傷害+暈眩
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) then
			AMHC:Damage(caster,it,600,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end


