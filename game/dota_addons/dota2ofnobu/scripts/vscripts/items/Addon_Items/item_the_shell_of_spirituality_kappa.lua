--妖化河童殼

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	          caster:GetAbsOrigin(),
	          nil,
	          800,
	          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	          DOTA_UNIT_TARGET_FLAG_NONE,
	          0,
	          false)
	for _,target in pairs(direUnits) do
		target:SetMana(target:GetMana()+250)
		ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
	end

end

function Shock2( keys )
	local caster = keys.caster
	local ability = keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	          caster:GetAbsOrigin(),
	          nil,
	          800,
	          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	          DOTA_UNIT_TARGET_FLAG_NONE,
	          0,
	          false)

	for _,target in pairs(direUnits) do
		target:SetMana(target:GetMana()+350)
		ability:ApplyDataDrivenModifier( caster, target, "modifier_shell_of_last_kappa", {duration = 10} )
		ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
	end

end


function last_kappa_spell_start( event )
	-- Variables
	local target = event.target
	local max_damage_absorb = event.ability:GetLevelSpecialValueFor("damage_absorb", event.ability:GetLevel() - 1 )
	local shield_size = 75 -- could be adjusted to model scale

	-- Reset the shield
	target.AphoticShieldRemaining = max_damage_absorb


	target.ShieldParticle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(target.ShieldParticle, 1, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(target.ShieldParticle, 2, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(target.ShieldParticle, 4, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(target.ShieldParticle, 5, Vector(shield_size,0,0))

	-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
	ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

end

function last_kappa_damage_check( event )
	-- Variables
	local damage = event.DamageTaken
	local unit = event.unit
	local ability = event.ability
	
	-- Track how much damage was already absorbed by the shield
	local shield_remaining = unit.AphoticShieldRemaining

	-- -- Check if the unit has the borrowed time modifier
	-- if not unit:HasModifier("modifier_borrowed_time") then
		-- If the damage is bigger than what the shield can absorb, heal a portion
	if damage > shield_remaining then
		local newHealth = unit:GetHealth() + shield_remaining
		unit:SetHealth(newHealth)
	else
		local newHealth = unit:GetHealth() + damage			
		unit:SetHealth(newHealth)
	end

	-- Reduce the shield remaining and remove
	unit.AphoticShieldRemaining = unit.AphoticShieldRemaining-damage
	if unit.AphoticShieldRemaining <= 0 then
		unit.AphoticShieldRemaining = nil
		--移除特效
		unit:RemoveModifierByName("modifier_shell_of_last_kappa")
	end
end

function last_kappa_EndShieldParticle( event )
	local target = event.target
	local ability = event.ability
	ParticleManager:DestroyParticle(target.ShieldParticle,false)
end