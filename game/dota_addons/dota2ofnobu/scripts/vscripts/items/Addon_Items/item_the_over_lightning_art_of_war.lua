
function Shock( keys )
	local caster = keys.caster
	local point = caster:GetAbsOrigin()
	local ability = keys.ability
	GridNav:DestroyTreesAroundPoint(point, 500, false)

	
	local sumtime = 0
	Timers:CreateTimer(0.2, function ()
		sumtime = sumtime + 0.2
		local pp = point + RandomVector(RandomInt(1, 250))

		local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN, caster)
		-- Raise 1000 if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 0, Vector(pp.x,pp.y,1000 ))
		ParticleManager:SetParticleControl(particle, 1, Vector(pp.x,pp.y,pp.z + 10 ))
		ParticleManager:SetParticleControl(particle, 2, Vector(pp.x,pp.y,pp.z + 10 ))
		
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		      point,
		      nil,
		      500,
		      DOTA_UNIT_TARGET_TEAM_ENEMY,
		      DOTA_UNIT_TARGET_ALL,
		      DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		      FIND_ANY_ORDER,
		      false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				if it:IsMagicImmune() then
					AMHC:Damage(caster,it, it:GetMaxHealth()*0.011,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				else
					AMHC:Damage(caster,it, it:GetMaxHealth()*0.022,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				end
			end
		end

		if sumtime < 11.1 then
			return 0.2
		else
			return nil
		end
	end)

	
end


