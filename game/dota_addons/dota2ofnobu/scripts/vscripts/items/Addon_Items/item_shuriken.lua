function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not target:IsBuilding() then
		AMHC:Damage(caster,target,250,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		ability:ApplyDataDrivenModifier(caster,target,"modifier_shuriken",nil)
	end
end