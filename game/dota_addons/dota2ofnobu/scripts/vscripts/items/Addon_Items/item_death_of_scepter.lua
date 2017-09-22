--逝者之笏

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = keys.dmg
	AMHC:Damage( caster,target, target:GetMaxHealth()*0.2,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	ParticleManager:CreateParticle("particles/generic_gameplay/illusion_killed_halo.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:CreateParticle("particles/generic_gameplay/dust_impact_medium.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
end

