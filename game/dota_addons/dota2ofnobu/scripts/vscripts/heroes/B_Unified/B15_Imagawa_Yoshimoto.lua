function B15W_on_spell_start(keys)
	local caster = keys.caster
	local ability = keys.ability
	AMHC:AddModelScale(caster, 1.3, ability:GetSpecialValueFor("duration"))
end

function OnToggleOn( keys )
	local caster = keys.caster
	caster.nobuorb1 = "B15E_1"
end

function OnToggleOff( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == "B15E_1") then
		caster.nobuorb1 = nil
	end
end

function OnToggleOn_B15E_old( keys )
	local caster = keys.caster
	caster.nobuorb1 = "B15E_1"
end

function OnToggleOff_B15E_old( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == "B15E_1") then
		caster.nobuorb1 = nil
	end
end


function B15E_attack1( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dmg = keys.ability:GetLevelSpecialValueFor("damage_bonus", keys.ability:GetLevel() - 1 )
	local target = keys.target
	if (caster.nobuorb1 == "B15E_1") then
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end

function B15E_attack3( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local b15e = caster:FindAbilityByName("B15E_old")

	if b15e ~= nil and b15e:GetLevel() > 0 and caster.nobuorb1 == "B15E_1" then
		local dmg = b15e:GetLevelSpecialValueFor("damage_bonus", b15e:GetLevel() - 1 )
		if target:IsBuilding() then
			AMHC:Damage( caster,target,dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		else
			AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end

function B15E_attack2( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dmg = keys.ability:GetLevelSpecialValueFor("damage_bonus2", keys.ability:GetLevel() - 1 )
	local target = keys.target
	if (caster.nobuorb1 == "B15E_1") then
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end

function B15E( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local spe_value = ability:GetSpecialValueFor("mana_cost")

	--【扣魔】
	if caster:GetMana() < spe_value then
		caster:CastAbilityToggle(ability,-1)
		caster:SpendMana(spe_value, ability)
	else
		caster:SpendMana(spe_value, ability)
	end
end

function B15R(keys)
end

function B15R_Damage(keys)
	--【Basic】	
	local caster = keys.caster
	local level  = keys.ability:GetLevel()
	local damage = keys.DamageTaken
	local block_dmg = keys.ability:GetLevelSpecialValueFor("Damage_Income", keys.ability:GetLevel() - 1 )

	--【Damage】
	local damagetype = caster.damagetype
	if damagetype == 1 then
		if damage < caster:GetHealth() then
			--物理傷害減免
			AMHC:CreateNumberEffect(caster,block_dmg,1,AMHC.MSG_BLOCK ,{124,124,124},7)

			if block_dmg < damage then
				caster:SetHealth(caster:GetHealth() + block_dmg)
			else
				caster:SetHealth(caster:GetHealth() + damage)
			end
		end
	end
end


--[[Author: Pizzalol
	Date: 04.03.2015.
	Creates additional attack projectiles for units within the specified radius around the caster]]
function B15D_SplitShotLaunch( keys )
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

	local b15e = caster:FindAbilityByName("B15E_old")
	if b15e ~= nil and b15e:GetLevel() > 0 and caster.nobuorb1 == "B15E_1" then
		split_shot_projectile = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf"
	end
	-- Create projectiles for units that are not the casters current attack target
	for _,v in pairs(split_shot_targets) do
		if v ~= attack_target and caster:CanEntityBeSeenByMyTeam(v) and not v:HasModifier("modifier_invisible") then
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
function B15D_SplitShotDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = ability:GetAbilityDamageType()
	if caster:IsIllusion() then
		damage_table.damage = caster:GetAttackDamage() * 0.3
	else
		damage_table.damage = caster:GetAttackDamage()
	end
	ApplyDamage(damage_table)

	local b15e = caster:FindAbilityByName("B15E_old")
	if b15e ~= nil and b15e:GetLevel() > 0 and caster.nobuorb1 == "B15E_1" then
		local dmg = b15e:GetLevelSpecialValueFor("damage_bonus", b15e:GetLevel() - 1 )
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
	
end


function B15D_create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)	
	local caster = keys.caster
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
			if illusion_ability ~= nil then
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

	if (caster:HasModifier("modifier_b15w")) then
		caster:FindAbilityByName("B15W"):ApplyDataDrivenModifier(illusion,illusion,"modifier_b15w",{duration=999})
		AMHC:AddModelScale(illusion, 1.3, 20)
	end
	if (caster:HasModifier("modifier_searing_arrow")) then
		caster:FindAbilityByName("B15E"):ApplyDataDrivenModifier(illusion,illusion,"modifier_searing_arrow2",{duration=999})
	else
		--分身不能用法球
		--illusion.nobuorb1 = "illusion"
	end
	
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = 10, outgoing_damage = -70, incoming_damage = 200})
	
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.
	illusion:SetHealth(keys.caster:GetHealth())

	--ParticleManager:CreateParticle("particles/generic_gameplay/illusion_killed.vpcf", PATTACH_ABSORIGIN_FOLLOW, illusion)
	
	return illusion
end

function B15T(keys)
	local caster = keys.caster
	local ability = keys.ability
	AMHC:CreateParticle("particles/b15t/b15t.vpcf",PATTACH_ABSORIGIN_FOLLOW,false,keys.caster,2.0,nil)

	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              caster:GetAbsOrigin(),
	                              nil,
	                              500,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)

	--effect:傷害+暈眩
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) then
			keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_B15T",nil)
		end
	end
	-- local ability = event.ability
	-- local duration = ability:GetLevelSpecialValueFor( "A13W_Duration", ability:GetLevel() - 1 )
	local time = 0.90 - ( 0.20 * keys.ability:GetLevel() )
	local num = 12
	Timers:CreateTimer(time,function( )
		if not keys.caster:IsAlive() then
			return nil
		end
		local caster_origin = keys.caster:GetAbsOrigin()
		
		--Illusions are created to the North, South, East, or West of the hero (obviously, both cannot be created in the same direction).
		local illusion1_direction = RandomInt(1, 4)
		
		local illusion1_origin
		
		if illusion1_direction == 1 then  --North
			illusion1_origin = caster_origin + Vector(0, 100, 0)
		elseif illusion1_direction == 2 then  --South
			illusion1_origin = caster_origin + Vector(0, -100, 0)
		elseif illusion1_direction == 3 then  --East
			illusion1_origin = caster_origin + Vector(100, 0, 0)
		else  --West
			illusion1_origin = caster_origin + Vector(-100, 0, 0)
		end
		if keys.caster:IsAlive() then
			B15D_create_illusion(keys, illusion1_origin)
		end
		if num < 0 or not keys.caster:IsAlive() then
			return nil
		else
			num = num - 1
        	return time
        end
	end)	
end
