--逝者之笏

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = keys.dmg
	if target:IsMagicImmune() then
		AMHC:Damage( caster,target, target:GetHealth()*0.15,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
	else
		AMHC:Damage( caster,target, target:GetHealth()*0.35,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
	ParticleManager:CreateParticle("particles/generic_gameplay/illusion_killed_halo.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:CreateParticle("particles/generic_gameplay/dust_impact_medium.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
end

