
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local eff1 = ParticleManager:CreateParticle("particles/b05t3/b05t3_j0.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(eff1, 0, caster:GetAbsOrigin())

end

