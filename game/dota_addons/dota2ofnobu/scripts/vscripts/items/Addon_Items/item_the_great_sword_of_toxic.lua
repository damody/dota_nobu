function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = 560
	local int = 0
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	Timers:CreateTimer( 0,function ()
		local mod = "particles/b33/b33r_old_poison.vpcf"
		if int <= 4 then
			int = int + 1
			AMHC:Damage( caster,target,50,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			local part = ParticleManager:CreateParticle(mod, PATTACH_ABSORIGIN, target)
			Timers:CreateTimer(2.9, function ()
				ParticleManager:DestroyParticle(part, false)
			end)
			PopupDamageOverTime(target, 50)
			return 1
		else
			return nil
		end
	end)
end

function OnEquip( keys )
	local caster = keys.caster
end

function OnUnequip( keys )
	local caster = keys.caster
end

function Shock2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(target,target,"modifier_the_great_sword_of_toxic",nil)
		ability:ApplyDataDrivenModifier(caster,target,"modifier_the_great_sword_of_toxic2",nil)
		AMHC:Damage( caster,target,85,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end

function Shock_puffer_poison( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_puffer_poison",nil)
		AMHC:Damage( caster,target,45,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )	
	end
end

function Shock_poisonous_ring( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	print("Shock_poisonous_ring")
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_poisonous_ring",nil)
		AMHC:Damage( caster,target,20,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )	
	end
end
