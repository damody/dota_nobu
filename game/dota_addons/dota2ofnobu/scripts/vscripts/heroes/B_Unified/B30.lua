-- 柿崎景家 by Nian Chen
-- 2017.4.21

function B30W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("B30W_duration")
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B30W", { duration = duration } )
	local particle = ParticleManager:CreateParticle("particles/b30w/b30w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl( particle, 1, Vector(duration,0,0))
	caster.B30W = 0
end

function B30W_old_OnAttackLanded( keys )
		local caster = keys.caster
		local ability = keys.ability
		local handle = caster:FindAbilityByName("B30W_old")
		if handle then
			if not handle:IsCooldownReady() then
				local t = handle:GetCooldownTimeRemaining()
				handle:EndCooldown()
				handle:StartCooldown(t-ability:GetLevel())
			end
		end
end

function B30W_OnTakeDamage( keys )
	if IsServer() then
		local caster = keys.caster
		local damage = keys.Damage
		local attacker = keys.attacker
		if attacker:GetUnitName() ~= "dota_fountain" then
			caster:SetHealth( caster:GetHealth() + damage )
		end
		caster.B30W = caster.B30W + damage
	end
end

function B30W_OnDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("B30W_radius")
	local damage
	if caster.B30W > caster:GetMaxHealth() then
		damage = caster:GetMaxHealth()
	else
		damage = caster.B30W
	end

	local ifx = ParticleManager:CreateParticle("particles/b30w/b30w2fire/monkey_king_spring_arcana_fire.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl( ifx , 0 , caster:GetAbsOrigin() )
	ParticleManager:ReleaseParticleIndex( ifx )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	local damageTable = {
			attacker = caster,
			ability = ability,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
	for _,unit in ipairs(units) do
		damageTable.victim = unit
		if unit:IsMagicImmune() then
			damageTable.damage = damage * 0.5
		else
			damageTable.damage = damage
		end
		ApplyDamage(damageTable)
	end
end

function B30R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	FindClearSpaceForUnit( caster , target:GetAbsOrigin() , true )
	caster:AddNewModifier( caster, ability, "modifier_phased", { duration = 0.1 } )
	EmitSoundOn("Hero_Clinkz.WindWalk",caster)
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		if target:GetHealthPercent() < 60 then
			local hpmpRegen = ability:GetSpecialValueFor("B30R_hpmpRegen")
			caster:Heal( caster:GetMaxHealth() * hpmpRegen , ability )
			caster:GiveMana( caster:GetMaxMana() * hpmpRegen )
		end
		local damage = ability:GetSpecialValueFor("B30R_damage")
		local agiBonus = ability:GetSpecialValueFor("B30R_agiBonus")
		local damageTable = {
			victim = target,
			attacker = caster,
			ability = ability,
			damage = damage + agiBonus * caster:GetAgility(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		ExecuteOrderFromTable( { UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET , TargetIndex = target:GetEntityIndex() })
		ApplyDamage(damageTable)
	end
end

function B30W_old_OnSpellStart( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local speed = ability:GetSpecialValueFor("B30W_speed")
	local dir = (point-center):Normalized()
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir
	end
	local fake_center = center - dir
	local distance = ability:GetSpecialValueFor("B30W_distance")
	local duration = distance/speed
	-- 把自己踢過去
	local knockbackProperties = {
	    center_x = fake_center.x,
	    center_y = fake_center.y,
	    center_z = fake_center.z,
	    duration = duration,
	    knockback_duration = duration,
	    knockback_distance = distance,
	    knockback_height = 0,
	    should_stun = 0,
	}
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_knockback",knockbackProperties)

	EmitSoundOn("Hero_Clinkz.WindWalk",caster)
end

function B30R_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("B30R_duration")
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_B30R_old", { duration = duration } )
end

function B30T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer( 0.1, function()
		local ifx = ParticleManager:CreateParticle("particles/b30/b30t.vpcf",PATTACH_POINT,caster)
		ParticleManager:SetParticleControl( ifx , 0 , caster:GetAbsOrigin()+Vector(0, 0, 100) )
		ParticleManager:SetParticleControl( ifx , 1 , caster:GetForwardVector() )
		ParticleManager:SetParticleControl( ifx , 2 , -caster:GetForwardVector()*1000 )
		ParticleManager:ReleaseParticleIndex( ifx )
		end)
end

function B30T_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("B30T_dotDuration")
	tsum = 0.1
	Timers:CreateTimer(0.1, function()
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B30T_debuff",{duration = duration-tsum})
		tsum = tsum + 0.1
		end)
end
