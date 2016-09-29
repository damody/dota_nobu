--鬼之籠手--

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	caster:SetHealth(target:GetHealth() + caster:GetHealth())
	target:ForceKill(false)
	local particle1 = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf",PATTACH_ABSORIGIN,target)
	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_assassinate_impact_blood.vpcf",PATTACH_ABSORIGIN,target)
	local particle3 = ParticleManager:CreateParticle("particles/econ/events/battlecup/battle_cup_summer2016_destroy_a.vpcf",PATTACH_ABSORIGIN,caster)
	Timers:CreateTimer(5, function ()
		ParticleManager:DestroyParticle(particle1, true)
		ParticleManager:DestroyParticle(particle2, true)
		ParticleManager:DestroyParticle(particle3, true)
		end)
end