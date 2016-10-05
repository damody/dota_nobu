
function Shock( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local flame = ParticleManager:CreateParticle("particles/econ/items/templar_assassin/templar_assassin_focal/ta_focal_base_attack_explosion.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(flame,3,target:GetAbsOrigin()+Vector(0, 0, 100))
	Timers:CreateTimer(1, function ()
		ParticleManager:DestroyParticle(flame, false)
	end)
	if (target:IsMagicImmune()) then
		AMHC:Damage( caster,target,250,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	else
		AMHC:Damage( caster,target,500,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
	caster:Heal(500,caster)
	ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
end
