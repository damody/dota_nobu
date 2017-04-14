function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local current_mana = target:GetMana()
	local burn_amount = 1500
	local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
	local burn_particle_name = "particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_impact_notarget_moonfall.vpcf"
	local damageType = keys.ability:GetAbilityDamageType()

	local mana_to_burn = math.min( current_mana,  burn_amount)
	local life_time = 2.0
	local digits = string.len( math.floor( mana_to_burn ) ) + 1

	if target:IsMagicImmune() then
		mana_to_burn = 0
	end

	target:ReduceMana(mana_to_burn)
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = mana_to_burn,
		damage_type = damageType
	}
	ApplyDamage( damageTable )

	if mana_to_burn ~= 0 then
		local numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
		ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
	    ParticleManager:SetParticleControl( numberIndex, 2, Vector( life_time, digits, 0 ) )
		local flame = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5/luna_eclipse_impact_notarget_moonfall.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(flame,0,target:GetAbsOrigin()+Vector(0, 0, 100))
		ParticleManager:SetParticleControl(flame,1,target:GetAbsOrigin()+Vector(0, 0, 100))
		ParticleManager:SetParticleControl(flame,2,target:GetAbsOrigin()+Vector(0, 0, 100))
		ParticleManager:SetParticleControl(flame,5,target:GetAbsOrigin()+Vector(0, 0, 100))
		Timers:CreateTimer(0.5, function ()
			ParticleManager:DestroyParticle(flame, false)
		end)
		
		-- Create timer to properly destroy particles
		Timers:CreateTimer( life_time, function()
				ParticleManager:DestroyParticle( numberIndex, false )
				return nil
			end)
	end
end