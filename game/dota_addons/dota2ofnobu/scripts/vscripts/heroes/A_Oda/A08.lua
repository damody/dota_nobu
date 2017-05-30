
function A08E_OnSpellStart( event )
	-- Variables
	local ability = event.ability
	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("stun")
	local caster = event.caster
	caster:Heal(caster:GetMaxHealth()*0.2,caster)	
	caster:EmitSound( "Hero_Nevermore.ROS_Flames")
	local ifx = ParticleManager:CreateParticle( "particles/c20r_real/c20r.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 550, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		damageTable = {
		victim = unit,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if not unit:IsBuilding() then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned", {duration=duration})
			ApplyDamage(damageTable)
		end
	end
end

function A08R_OnAttackLanded( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local dmg1 = ability:GetSpecialValueFor("dmg1")
	local dmg2 = ability:GetSpecialValueFor("dmg2")

	local buff = math.floor((100-caster:GetHealthPercent())*0.1)
	local dmg = dmg1+dmg2*buff
	if target:IsMagicImmune() then
		AMHC:Damage( caster,target,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	else
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
end

