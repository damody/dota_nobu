function A17R( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel()
	local dmg = keys.dmg
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_A17R",nil)
		AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
	end
end



function A17W2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_A17W_2",nil)
	end
end


function shrapnel_fire( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local modifierName = "modifier_shrapnel_stack_counter_datadriven"
	local dummyModifierName = "modifier_shrapnel_dummy_datadriven"
	local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
	local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
	local damage_delay = ability:GetLevelSpecialValueFor( "damage_delay", ( ability:GetLevel() - 1 ) ) + 0.1
	local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
	local launch_sound_name = "Hero_Sniper.ShrapnelShoot"

	-- Create particle at caster
	local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
	ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )

	StartSoundEvent( launch_sound_name, caster )

	-- create dummy to do damage and apply debuff modifier
	--dummy:FindAbilityByName("majia"):SetLevel(1)
	--StartSoundEventFromPosition("Hero_Sniper.ShrapnelShatter",target)	
	local dummy = CreateUnitByName( "hide_unit", target, false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, "modifier_A17W", {} )			
	StartSoundEvent( "Hero_Sniper.ShrapnelShatter", dummy )	
	Timers:CreateTimer( damage_delay, function()

			local dummy2 = CreateUnitByName( "hide_unit", target, false, caster, caster, caster:GetTeamNumber() )	
			ability:ApplyDataDrivenModifier( caster, dummy2, dummyModifierName, {} )
			ability:ApplyDataDrivenModifier( caster, dummy2, "modifier_A17W", {} )
			Timers:CreateTimer( dummy_duration, function()
					StopSoundOn("Hero_Sniper.ShrapnelShatter",dummy)
					dummy:ForceKill( true )
					dummy2:ForceKill( true )
					--StopSoundEvent("Hero_Sniper.ShrapnelShatter",dummy)
					--dummy:Destroy()
					return nil
				end
			)
			return nil
		end
	)

end

function A17T( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local point = caster:GetAbsOrigin() 
	--local radius =  ability:GetLevelSpecialValueFor( "radius" , ability:GetLevel() - 1  )
	--local projectile_count =  ability:GetLevelSpecialValueFor( "projectile_count" , ability:GetLevel() - 1  )
	local projectile_speed =  ability:GetLevelSpecialValueFor( "projectile_speed" , ability:GetLevel() - 1  )
	local particleName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"

	local projTable = {
		EffectName = particleName,
		Ability = ability,
		Target = target,
		Source = caster,
		bDodgeable = false,
		bProvidesVision = false,
		vSpawnOrigin = point,
		iMoveSpeed = projectile_speed,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projTable )

	--print(projTable)
end

function A17T_lock( keys )
	keys.ability:SetActivated(false)
end

function A17T_unlock( keys )
	keys.ability:SetActivated(true)
end

function A17T_Succes_Attack( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	local level = ability:GetLevel() - 1
	local dmg = keys.dmg
    local group = {}
    local radius = ability:GetLevelSpecialValueFor("attacked_range",level)
   	local group = FindUnitsInRadius(caster:GetTeamNumber(), point2, nil, radius ,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
   	local eff1 = ParticleManager:CreateParticle("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_explosion_flash_c.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(eff1, 3, point2)
	target:EmitSound("A17T.sound1")
	for i,v in ipairs(group) do
		if v:IsHero() then
			ParticleManager:CreateParticle("particles/shake1.vpcf", PATTACH_ABSORIGIN, v)
		end
		if v~=target then
			AMHC:Damage( caster,v,dmg*0.6,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )	
		end
	end	
end

function A17T_Succes_Attack2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	local level = ability:GetLevel() - 1
	local dmg = keys.dmg
    local group = {}
    local radius = ability:GetLevelSpecialValueFor("attacked_range",level)
   	group = FindUnitsInRadius(caster:GetTeamNumber(), point2, nil, radius ,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for i,v in ipairs(group) do
			AMHC:Damage( caster,v,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )	
	end	
end

-- 11.2B
----------------------------------------------------------------------------------------------------------------------

function A17E_old_on_attack_landed( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local chance = ability:GetLevelSpecialValueFor("chance",ability:GetLevel()-1)
	local rnd = RandomInt(1,100)

	if rnd <= chance then
		ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
	end
end

function A17E_old_on_buff_created( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration",ability:GetLevel()-1)

	local ifx = ParticleManager:CreateParticle("particles/a17/a17e_old_buff.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,14,Vector(1.2,1.2,1.0)) -- scale
	ParticleManager:SetParticleControl(ifx,15,Vector(255,50,50)) -- color
	ability.pBuff = ifx
end

function A17E_old_on_buff_ended( keys )
	local ability = keys.ability
	ParticleManager:DestroyParticle(ability.pBuff,false)
end

function A17R_old_on_attack_landed( keys )
	local dmg = keys.dmg
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability	
	local level = ability:GetLevel()-1
	local chance = ability:GetLevelSpecialValueFor("add_chance",level)
	local rnd = RandomInt(1,100)

	--if rnd <= chance then
		local add_rate = 0
		if target:IsHero() then 
			add_rate = ability:GetLevelSpecialValueFor("add_for_hero",level)
		elseif target:IsCreep() then
			add_rate = ability:GetLevelSpecialValueFor("add_for_creep",level)
		elseif target:IsBuilding() then
			add_rate = ability:GetLevelSpecialValueFor("add_for_building",level)
		end
		ApplyDamage({victim = target, attacker = caster, damage = dmg*add_rate, damage_type = ability:GetAbilityDamageType()})
	--end
end