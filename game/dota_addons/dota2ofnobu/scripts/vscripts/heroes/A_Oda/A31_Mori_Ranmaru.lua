--[[ ============================================================================================================
	Author: Rook, with help from some of Pizzalol's SpellLibrary code
	Date: January 25, 2015
	Called when Blink Dagger is cast.  Blinks the caster in the targeted direction.
	Additional parameters: keys.MaxBlinkRange and keys.BlinkRangeClamp
================================================================================================================= ]]
function A31E(keys)
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
	
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, keys.caster)
	keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	
	local origin_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local difference_vector = target_point - origin_point
	
	if difference_vector:Length2D() > keys.MaxBlinkRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
		target_point = origin_point + (target_point - origin_point):Normalized() * keys.BlinkRangeClamp
	end
	
	keys.caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(keys.caster, target_point, false)
	
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, keys.caster)
end

function A31W( keys )
	local count = 0;
	Timers:CreateTimer( 0, function()
		A31W_2(keys)
		count = count + 1
		if (count < 100) then
			return 0.1
		else
			return nil
		end
		end )

	local ability = keys.ability
	local caster = keys.caster
	local casterLocation = keys.target_points[1]
	local radius =  ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
	local abilityDamage = ability:GetLevelSpecialValueFor( "abilityDamage", ( ability:GetLevel() - 1 ) )
	local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local damageType = ability:GetAbilityDamageType()
	local second = 0
	caster:StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	keys.ability:ApplyDataDrivenModifier(caster, caster,"modifier_A31W", {duration = 10})
	Timers:CreateTimer( 1, 
		function()
			second = second + 1
			local units = FindUnitsInRadius(caster:GetTeamNumber(),
	                              casterLocation,
	                              nil,
	                              radius,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
			for _, it in pairs( units ) do
				if (not(it:IsBuilding())) then
					AMHC:Damage(caster, it, abilityDamage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				end
			end
			if (second <= 10) then
				return 1
			else
				return nil
			end
		end)
	
end

function A31W_2( keys )
	local ability = keys.ability
	local caster = keys.caster
	local casterLocation = keys.target_points[1]
	local radius =  ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
	local directionConstraint = keys.section
	local modifierName = "modifier_freezing_field_debuff_datadriven"
	local refModifierName = "modifier_freezing_field_ref_point_datadriven"
	local particleName = "particles/a23w/a23w.vpcf"
	
	-- Get random point
	local castDistance = RandomInt( 0, radius )
	local angle = RandomInt( 0, 90 )
	local vec = RandomVector(castDistance)
	local dy = vec.y
	local dx = vec.x
	local attackPoint = Vector( 0, 0, 0 )
	
	if directionConstraint == 0 then			-- NW
		attackPoint = Vector( casterLocation.x - dx, casterLocation.y + dy, casterLocation.z )
	elseif directionConstraint == 1 then		-- NE
		attackPoint = Vector( casterLocation.x + dx, casterLocation.y + dy, casterLocation.z )
	elseif directionConstraint == 2 then		-- SE
		attackPoint = Vector( casterLocation.x + dx, casterLocation.y - dy, casterLocation.z )
	else										-- SW
		attackPoint = Vector( casterLocation.x - dx, casterLocation.y - dy, casterLocation.z )
	end
	
	
	-- Fire effect
	local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, attackPoint )
	
end
