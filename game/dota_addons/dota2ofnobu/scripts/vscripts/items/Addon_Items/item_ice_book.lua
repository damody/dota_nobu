-- 冰計之書
-- item_ice_book
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local aoe_delay = ability:GetLevelSpecialValueFor("aoe_delay",0)
	local aoe_radius = ability:GetLevelSpecialValueFor("aoe_radius",0)
	local aoe_count = ability:GetLevelSpecialValueFor("aoe_count",0)
	local target_point = keys.target_points[1]
	local start_point = caster:GetAbsOrigin()
	local start2end = target_point-start_point
	local cast_range = ability:GetCastRange()
	local cast_dir = Vector(start2end.x, start2end.y, 0):Normalized()

	local duration = aoe_delay * aoe_count
	local hack_duration = duration+aoe_delay*0.5
	local speed = ability:GetLevelSpecialValueFor("speed",0)

	local unit = CreateUnitByName("npc_dummy_unit_new",start_point,false,caster,caster,caster:GetTeamNumber())
	unit:AddNewModifier(caster,nil,"modifier_kill",{duration=hack_duration})

	Physics:Unit(unit)
	--unit:SetAutoUnstuck(false)
	unit:SetPhysicsFriction (0)
	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	unit:SetPhysicsVelocity(cast_dir*speed)
	
	ability:ApplyDataDrivenModifier(caster,unit,"modifier_ice_creator",nil)
	local ifx = ParticleManager:CreateParticle("particles/item/item_ice_book/ball.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
	Timers:CreateTimer(hack_duration, function ()
		ParticleManager:DestroyParticle(ifx,false)
	end)
	
end

function getIce( keys )
	local caster = keys.caster
	local target = keys.target
	keys.ability:ApplyDataDrivenModifier(caster,target,"modifier_slow_ice",{duration = 3})
end

function CreateIce( keys )
	local caster = keys.caster
	local target = keys.target
	local center = target:GetAbsOrigin()
	local ability = keys.ability
	local ice_count = ability:GetLevelSpecialValueFor("ice_count",0)
	local aoe_radius = ability:GetLevelSpecialValueFor("aoe_radius",0)

	local projectile_speed = 500

	local delta_theta = 3.14 * 2.0 / ice_count 
	for i=1,ice_count do
		local dx = math.cos(delta_theta*i)
		local dy = math.sin(delta_theta*i)

		-- Launch the projectile
		ProjectileManager:CreateLinearProjectile( {
			Ability				= ability,
			EffectName			= "particles/item/item_ice_book/ice.vpcf",
			vSpawnOrigin		= center+Vector(0,0,100),
			fDistance			= aoe_radius,
			fStartRadius		= 100,
			fEndRadius			= 100,
			Source				= caster,
			bHasFrontalCone		= false,
			bReplaceExisting	= false,
			iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
			iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
			iUnitTargetType		= ability:GetAbilityTargetType(),
			--fExpireTime			= GameRules:GetGameTime() + 2,
			bDeleteOnHit		= false,
			vVelocity			= Vector(dx * projectile_speed, dy * projectile_speed, 0),
			bProvidesVision		= false,
			--iVisionRadius		= travel_vision,
			--iVisionTeamNumber	= caster:GetTeamNumber(),
		} )
	end
end