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
	local int = 0

	if not caster:IsIllusion() and not target:IsBuilding() then
		if (not keys.target:IsMagicImmune() and keys.target.the_great_sword_of_toxic == nil) then
			keys.target.the_great_sword_of_toxic = 1
			Timers:CreateTimer(0.1, function() 
				keys.target.the_great_sword_of_toxic = nil
			end)
			Timers:CreateTimer( 0,function ()
				local mod = "particles/b33/b33r_old_poison.vpcf"
				if int <= 1 then
					int = int + 1
					AMHC:Damage( caster,target,55,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
					ability:ApplyDataDrivenModifier(caster,target,"modifier_the_great_sword_of_toxic",nil)
					local part = ParticleManager:CreateParticle(mod, PATTACH_ABSORIGIN, target)
					Timers:CreateTimer(2.9, function ()
						ParticleManager:DestroyParticle(part, false)
					end)
					PopupDamageOverTime(target, 55)
					return 1
				else
					return nil
				end
			end)
		end
	end
end