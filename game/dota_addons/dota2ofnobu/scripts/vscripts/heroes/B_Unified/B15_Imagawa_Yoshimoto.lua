function B15W_on_spell_start(keys)
	-- keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_black_king_bar_datadriven_active", nil)
	keys.caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
	
	local final_model_scale = (30 / 100) + 1  --This will be something like 1.3.
	local model_scale_increase_per_interval = 100 / (final_model_scale - 1)
	local duration = keys.ability:GetLevelSpecialValueFor("duration", keys.ability:GetLevel() - 1 )

	--Scale the model up over time.
	for i=1,100 do
		Timers:CreateTimer(i/75, 
		function()
			keys.caster:SetModelScale(1 + i/model_scale_increase_per_interval)
		end)
	end

	--Scale the model back down around the time the duration ends.
	for i=1,100 do
		Timers:CreateTimer(duration - 1 + (i/50),
		function()
			keys.caster:SetModelScale(final_model_scale - i/model_scale_increase_per_interval)
		end)
	end
end

function B15R(keys)
	local caster = keys.caster
	local level  = keys.ability:GetLevel()
	print("@@ B15R")
	print(caster:GetUnitName())
	caster:AddNewModifier(caster, keys.ability, "modifier_item_stout_shield", { damage_reduction=1000, damage_cleanse=600, damage_reset_interval=6.0 })
	-- caster:AddNewModifier(caster,self,"modifier_tidehunter_kraken_shell",{damage_reduction=100})
	if caster:FindModifierByName("modifier_item_stout_shield") ~= nil then
		print("@@ B15R2")
	end
end


function B15R_Damage(keys)
	local caster = keys.caster
	local level  = keys.ability:GetLevel()
	local damage = keys.DamageTaken
	local damagetype = caster.damagetype
	local block_dmg = keys.ability:GetLevelSpecialValueFor("Damage_Income", keys.ability:GetLevel() - 1 )

	print("damage2")

	if damagetype == 1 then
		if damage < caster:GetHealth() then
			--物理傷害
			AMHC:CreateNumberEffect(caster,block_dmg,1,AMHC.MSG_BLOCK ,{124,124,124},7)

			if block_dmg < damage then
				--caster:Heal(block_dmg,caster)
				caster:SetHealth(caster:GetHealth() + block_dmg)
			else
				caster:SetHealth(caster:GetHealth() + damage)
				--caster:Heal(damage,caster)
			end
		end
	end
end


--[[Author: Pizzalol
	Date: 04.03.2015.
	Creates additional attack projectiles for units within the specified radius around the caster]]
function SplitShotLaunch( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
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
	local split_shot_projectile = keys.split_shot_projectile

	local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, radius, target_team, target_type, target_flags, FIND_CLOSEST, false)

	-- Create projectiles for units that are not the casters current attack target
	for _,v in pairs(split_shot_targets) do
		if v ~= attack_target then
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
			max_targets = max_targets - 1
		end
		-- If we reached the maximum amount of targets then break the loop
		if max_targets == 0 then break end
	end
end

-- Apply the auto attack damage to the hit unit
function SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = caster:GetAttackDamage()

	ApplyDamage(damage_table)
end


function create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local player_id = keys.caster:GetPlayerID()
	local caster_team = keys.caster:GetTeam()
	
	local illusion = CreateUnitByName(keys.caster:GetUnitName(), illusion_origin, true, keys.caster, nil, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = keys.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = keys.caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil and illusion_ability:GetAbilityName() ~= "B15D" then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = keys.caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
		end
	end
	
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = 10, outgoing_damage = 30, incoming_damage = 300})
	
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.

	illusion:SetRenderColor(0,0,200)

	ParticleManager:CreateParticle("particles/generic_gameplay/illusion_killed.vpcf", PATTACH_ABSORIGIN_FOLLOW, illusion)
	
	return illusion
end

function B15T(keys)
	AMHC:CreateParticle("particles/b15t/b15t.vpcf",PATTACH_ABSORIGIN,false,keys.caster,2.0,nil)

	-- local ability = event.ability
	-- local duration = ability:GetLevelSpecialValueFor( "A13W_Duration", ability:GetLevel() - 1 )
	local time = 0.90 - ( 0.20 * keys.ability:GetLevel() )
	local num = 12
	AMHC:Timer( "amhc",function( )
				local caster_origin = keys.caster:GetAbsOrigin()
				
				--Illusions are created to the North, South, East, or West of the hero (obviously, both cannot be created in the same direction).
				local illusion1_direction = RandomInt(1, 4)
				local illusion2_direction = (RandomInt(1, 3) + illusion1_direction) % 4  --This will ensure that the illusions will spawn in different directions.
				
				local illusion1_origin = nil
				local illusion2_origin = nil
				
				if illusion1_direction == 1 then  --North
					illusion1_origin = caster_origin + Vector(0, 100, 0)
				elseif illusion1_direction == 2 then  --South
					illusion1_origin = caster_origin + Vector(0, -100, 0)
				elseif illusion1_direction == 3 then  --East
					illusion1_origin = caster_origin + Vector(100, 0, 0)
				else  --West
					illusion1_origin = caster_origin + Vector(-100, 0, 0)
				end
				
				if illusion2_direction == 1 then  --North
					illusion2_origin = caster_origin + Vector(0, 100, 0)
				elseif illusion2_direction == 2 then  --South
					illusion2_origin = caster_origin + Vector(0, -100, 0)
				elseif illusion2_direction == 3 then  --East
					illusion2_origin = caster_origin + Vector(100, 0, 0)
				else  --West
					illusion2_origin = caster_origin + Vector(-100, 0, 0)
				end

				if keys.caster:IsRangedAttacker() then  --We don't have to worry about illusions switching from melee to ranged or vice versa because they can't use abilities.
					local illusion1 = create_illusion(keys, illusion1_origin, keys.IllusionIncomingDamageRanged, keys.IllusionOutgoingDamageRanged, keys.IllusionDuration)
				else  --keys.caster is melee.
					local illusion1 = create_illusion(keys, illusion1_origin, keys.IllusionIncomingDamageMelee, keys.IllusionOutgoingDamageMelee, keys.IllusionDuration)
				end	

				if num < 0 or not keys.caster:IsAlive() then
					return nil
				else
					num = num - 1
		        	return time
		        end
	end,time )	
end