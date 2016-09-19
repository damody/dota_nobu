
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability

	local SEARCH_RADIUS = keys.range
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
			local flame = ParticleManager:CreateParticle("particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger_flames_b.vpcf", PATTACH_ABSORIGIN, it)
			AMHC:Damage(caster,it, keys.damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			Timers:CreateTimer(0.9, function ()
				ParticleManager:DestroyParticle(flame, false)
			end)
		end
	end
end


