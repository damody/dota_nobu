
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	

	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/item/item_rockfall_bookinvoker_chaos_meteor_fly2.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, point + Vector (0, 0, 1000))
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(0.2, 0, 0))

	Timers:CreateTimer(0.2, function ()
		local rock_effect = ParticleManager:CreateParticle("particles/item/item_rockfall_book.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(rock_effect, 0, point)
	end)

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
			AMHC:Damage(caster,it,ability:GetLevelSpecialValueFor("damage", 0 ),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			ability:ApplyDataDrivenModifier(caster, it,"modifier_rockfall",nil)
		end
	end
end


