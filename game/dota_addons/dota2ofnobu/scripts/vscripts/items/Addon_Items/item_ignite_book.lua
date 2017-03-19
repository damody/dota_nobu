
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local particle = ParticleManager:CreateParticle("particles/item/item_ignite_book.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(particle,3,point)
	Timers:CreateTimer(2, function ()
		ParticleManager:DestroyParticle(particle, false)
	end)
	local SEARCH_RADIUS = 800
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
          point,
          nil,
          SEARCH_RADIUS,
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_ALL,
          0,
          0,
          false)
	for _,target in pairs(direUnits) do
		if not target:IsBuilding() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_ignite_book", {duration = 5})
			AMHC:Damage(caster,target,600,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			if IsValidEntity(it) then
				local flame = ParticleManager:CreateParticle("particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger_flames_b.vpcf", PATTACH_ABSORIGIN, it)
				Timers:CreateTimer(4.5, function ()
					ParticleManager:DestroyParticle(flame, false)
				end)
			end
		else
			AMHC:Damage(caster,target,200,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end


