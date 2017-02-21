
function Shock( keys )
	local caster = keys.caster
	if caster~=nil and IsValidEntity(caster) and not caster:IsIllusion() then
		if keys.target:CanEntityBeSeenByMyTeam(caster) then
			AMHC:Damage(caster,keys.target, keys.Damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			local flame = ParticleManager:CreateParticle("particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger_flames_b.vpcf", PATTACH_ABSORIGIN, keys.target)
			Timers:CreateTimer(0.9, function ()
				ParticleManager:DestroyParticle(flame, false)
			end)
		end
	end
end


