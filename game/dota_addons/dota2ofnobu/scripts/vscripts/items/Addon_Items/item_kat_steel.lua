
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local dir = ability:GetCursorPosition() - caster:GetOrigin()
	local dmg = ability:GetSpecialValueFor("damage")

	for i=1,4 do
		local pos = caster:GetOrigin() + dir:Normalized() * (i * 200)
		local eff1 = ParticleManager:CreateParticle("particles/a07e/a07e_t.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(eff1, 0, pos)
		local eff2 = ParticleManager:CreateParticle("particles/a07r/a07r_c.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(eff2, 0, pos)
		local SEARCH_RADIUS = 250
		GridNav:DestroyTreesAroundPoint(pos, SEARCH_RADIUS, false)
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              pos,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				if it.kat_steel == nil then
					AMHC:Damage(caster,it, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
					ability:ApplyDataDrivenModifier(caster, it,"modifier_kat_steel", {duration=1.5})
					it.kat_steel = 1
				end
			end
		end
	end

	for i=1,4 do
		local pos = caster:GetOrigin() + dir:Normalized() * (i * 200)
		local SEARCH_RADIUS = 250
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              pos,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				it.kat_steel = nil
			end
		end
	end

end


