
function ShowEffect( keys )
	local caster = keys.caster
	local ability = keys.ability

	local flame = ParticleManager:CreateParticle("particles/a07t2/a07t2.vpcf", PATTACH_ABSORIGIN, caster)
	
	Timers:CreateTimer(0.5, function ()
		ParticleManager:DestroyParticle(flame, false)
	end)
end

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	if (caster:GetMana() >= 75) then
		caster:SpendMana(75, ability)
		local SEARCH_RADIUS = 405
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              caster:GetAbsOrigin(),
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
				local flame = ParticleManager:CreateParticle("particles/a07t2/a07t2.vpcf", PATTACH_ABSORIGIN, it)
				AMHC:Damage(caster,it, 190,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				Timers:CreateTimer(0.5, function ()
					ParticleManager:DestroyParticle(flame, false)
				end)
			end
		end
	end
end


