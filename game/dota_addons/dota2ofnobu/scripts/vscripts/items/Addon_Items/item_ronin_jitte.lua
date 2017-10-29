--浪人十手

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = keys.dmg
	
	AMHC:Damage( caster,target,dmg + caster:GetMaxMana()*0.12,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	ParticleManager:CreateParticle("particles/generic_gameplay/illusion_killed_halo.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:CreateParticle("particles/generic_gameplay/illusion_killed_halo.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
end

