
function Shock( keys )
	local caster = keys.caster
	
	local flame = ParticleManager:CreateParticle("particles/item/item_the_great_sword_of_hurricane.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer(20, function ()
		ParticleManager:DestroyParticle(flame, false)
	end)
	local ctime = 0
	local pos = caster:GetAbsOrigin()
	Timers:CreateTimer(0, function ()
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                          pos,
	                          nil,
	                          800,
	                          DOTA_UNIT_TARGET_TEAM_ENEMY,
	                          DOTA_UNIT_TARGET_ALL,
	                          DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                          FIND_ANY_ORDER,
	                          false)
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_great_sword_of_hurricane", {duration=0.5})
			end
		end
		ctime = ctime + 0.5
		if (ctime <= 20) then
			return 0.5
		else
			return nil
		end
	end)
end

function OnEquip( keys )
	local caster = keys.caster
	caster:AddAbility("ability_great_sword_of_hurricane"):SetLevel(1)
end

function OnUnequip( keys )
	local caster = keys.caster
	caster:RemoveAbility("ability_great_sword_of_hurricane")
end


--[[Author: Pizzalol
	Date: 04.03.2015.
	Creates additional attack projectiles for units within the specified radius around the caster]]
function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	if ability ~= nil then
		local ability_level = ability:GetLevel() - 1

		-- Targeting variables
		local target_type = ability:GetAbilityTargetType()
		local target_team = ability:GetAbilityTargetTeam()
		local target_flags = ability:GetAbilityTargetFlags()
		local attack_target = caster:GetAttackTarget()

		-- Ability variables
		local radius = ability:GetLevelSpecialValueFor("range", ability_level)
		local max_targets = ability:GetLevelSpecialValueFor("arrow_count", ability_level)
		local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
		local split_shot_projectile = "particles/units/heroes/hero_invoker/invoker_tornado_funnel.vpcf"

		local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, radius, target_team, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, target_flags, FIND_CLOSEST, false)

		-- Create projectiles for units that are not the casters current attack target
		for _,v in pairs(split_shot_targets) do
			if v ~= attack_target and not v:HasModifier("modifier_invisible") and caster:CanEntityBeSeenByMyTeam(v) then
				local count = 0
				local tornado = ParticleManager:CreateParticle(split_shot_projectile, PATTACH_ABSORIGIN, caster)
				Timers:CreateTimer(0, function()
					count = count + 0.1
					ParticleManager:SetParticleControl(tornado, 3, caster_location+(v:GetAbsOrigin()-caster_location)*count)
					
					if (count > 1) then
						local projectile_info = 
						{
							EffectName = split_shot_projectile,
							Ability = ability,
							vSpawnOrigin = caster_location,
							Target = v,
							Source = caster,
							bHasFrontalCone = false,
							iMoveSpeed = projectile_speed,
							bReplaceExisting = false,
							bProvidesVision = false
						}
						ProjectileManager:CreateTrackingProjectile(projectile_info)
						ParticleManager:DestroyParticle(tornado, true)
						return nil
					else
						return 0.1
					end
				end)
				
				max_targets = max_targets - 1
			end
			-- If we reached the maximum amount of targets then break the loop
			if max_targets == 0 then break end
		end
	end
end

-- Apply the auto attack damage to the hit unit
function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	AMHC:Damage(caster, target, 400, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
end

