-- 蜂須賀政勝 by Nian Chen
-- 2017.5.5

function A09W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local treant1Duration = ability:GetSpecialValueFor("A09W_treant1Duration")

	local unit = CreateUnitByName("A09W_treant1", point, true, caster, caster, caster:GetTeamNumber())
	unit:SetOwner(caster)
	unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	ability:ApplyDataDrivenModifier( caster , unit , "modifier_A09W_treant1" , { duration = treant1Duration } )	

	EmitSoundOn( "Tree.GrowBack" , unit )
end

function modifier_A09W_treant_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point = target:GetAbsOrigin()
	local treant2Duration = ability:GetSpecialValueFor("A09W_treant2Duration")

	local unit = CreateUnitByName("A09W_treant2", point, false, caster, caster, caster:GetTeamNumber())
	unit:SetOwner(caster)
	ability:ApplyDataDrivenModifier( caster , unit , "modifier_A09W_treant2" , { duration = treant2Duration } )	

	EmitSoundOn( "Tree.GrowBack" , unit )

	Timers:CreateTimer(0.06, function ()
		ExecuteOrderFromTable( { UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = unit:GetAbsOrigin() })
	end)

	Timers:CreateTimer( treant2Duration , function ()
		EmitSoundOn( "Hero_Treant.Death" , unit )
	end)

end

function modifier_A09W_treant_OnDestroy( keys )
	keys.target:ForceKill(false)
end

function modifier_A09W_treant_OnAttackLanded( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local target = keys.target
	local dotDuration = ability:GetSpecialValueFor("A09W_dotDuration")
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier( attacker , target , "modifier_A09W_treant_dot" , { duration = dotDuration } )
		EmitSoundOn( "Hero_Treant.Attack.Impact" , attacker )
	else
		EmitSoundOn( "Hero_Treant.Attack" , attacker )
	end
	local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_viper/viper_poison_attack_explosion.vpcf" , PATTACH_CUSTOMORIGIN , nil )
	ParticleManager:SetParticleControl( particle , 0 , target:GetAbsOrigin() + Vector(0,0,50) )
	ParticleManager:SetParticleControl( particle , 3 , target:GetAbsOrigin() + Vector(0,0,50) )
end

LinkLuaModifier( "modifier_A09E", "heroes/A_Oda/A09.lua",LUA_MODIFIER_MOTION_NONE )
modifier_A09E = class({})

function modifier_A09E:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_A09E:GetModifierModelChange()
	local res = math.random(1,7)
	if res == 1 then
		return "models/items/furion/treant_flower_1.vmdl"
	elseif res == 2 then
		return "models/items/furion/treant_stump.vmdl"
	elseif res == 3 then
		return "models/items/furion/treant/furion_treant_nelum_red/furion_treant_nelum_red.vmdl"
	elseif res == 4 then
		return "models/items/furion/treant/hallowed_horde/hallowed_horde.vmdl"
	elseif res == 5 then
		return "models/items/furion/treant/primeval_treant/primeval_treant.vmdl"
	elseif res == 6 then
		return "models/items/furion/treant/ravenous_woodfang/ravenous_woodfang.vmdl"
	elseif res == 7 then
		return "models/items/furion/treant/shroomling_treant/shroomling_treant.vmdl"
	end
end

function modifier_A09E:GetModifierMoveSpeedOverride()
	return 50
end

function modifier_A09E:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true,
		[MODIFIER_STATE_BLOCK_DISABLED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_HEXED] = true
	}

	return state
end

function modifier_A09E:IsHidden() 
	return false
end

function modifier_A09E:IsDebuff()
	return true
end

function modifier_A09E:IsPurgable()
	return true
end

function A09E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("A09E_duration")

	local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_rhasta/rhasta_spell_hex.vpcf" , PATTACH_CUSTOMORIGIN , nil )
	ParticleManager:SetParticleControl( particle , 0 , target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle , 1 , target:GetAbsOrigin() )

	--EmitSoundOn( "Tree.GrowBack" , target )
	EmitSoundOn( "Hero_ShadowShaman.SheepHex.Target" , target )

	ability:ApplyDataDrivenModifier( caster , target , "modifier_A09E" , { duration = duration } )
	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = 1,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	})
end

function A09R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local damage = ability:GetSpecialValueFor("A09R_damage")
	local radius = ability:GetSpecialValueFor("A09R_radius")
	local buffDuration = ability:GetSpecialValueFor("A09R_buffDuration")
	local maxStack = ability:GetSpecialValueFor("A09R_maxStack")
	local damageIncrease = ability:GetSpecialValueFor("A09R_damageIncrease")
	local stackCount = 0

	local modifier_A09R = caster:FindModifierByName("modifier_A09R")
	if modifier_A09R then
		stackCount = modifier_A09R:GetStackCount()
		caster:RemoveModifierByName("modifier_A09R")
		ability:ApplyDataDrivenModifier( caster , caster , "modifier_A09R" , { duration = buffDuration } )
		modifier_A09R = caster:FindModifierByName("modifier_A09R")
		if stackCount < maxStack then
			modifier_A09R:SetStackCount( stackCount + 1 )
		else
			modifier_A09R:SetStackCount( stackCount )
		end
	else
		ability:ApplyDataDrivenModifier( caster , caster , "modifier_A09R" , { duration = buffDuration } )
		modifier_A09R = caster:FindModifierByName("modifier_A09R")
		modifier_A09R:SetStackCount(1)
	end
	caster:SpendMana(stackCount*damageIncrease*ability:GetManaCost(-1) ,ability)
	damage = damage * math.pow( 1 + damageIncrease, stackCount )

	local units = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		EmitSoundOn( "Hero_MonkeyKing.Spring.Target" , unit )
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		ApplyDamage(damageTable)
	end

	local particle = ParticleManager:CreateParticle( "particles/a09r/a09rdeath/monkey_king_spring_arcana_death.vpcf" , PATTACH_CUSTOMORIGIN , nil )
	ParticleManager:SetParticleControl( particle , 0 , point )
	ParticleManager:SetParticleControl( particle , 3 , point )
	ParticleManager:SetParticleControl( particle , 4 , point )
	ParticleManager:SetParticleControl( particle , 6 , point )
end

function A09T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local duration = ability:GetSpecialValueFor("A09T_duration")
	local count = ability:GetSpecialValueFor("A09T_unitCount")

	for i=1,count do
		local unit = CreateUnitByName("A09T_tentacle", point, false, caster, caster, caster:GetTeamNumber())
		unit:SetOwner(caster)
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		unit:AddNewModifier( caster , ability , "modifier_phased" , { duration = 0.01 } )
		ability:ApplyDataDrivenModifier( caster , unit , "modifier_A09T_tentacle" , { duration = duration } )
		EmitSoundOn( "Hero_ShadowShaman.SerpentWard" , unit )
		ExecuteOrderFromTable( { UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = unit:GetAbsOrigin() })
	end
end

function modifier_A09T_tentacle_OnAttackLanded( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local target = keys.target
	local dotDuration = ability:GetSpecialValueFor("A09T_dotDutaion")
	local dmg = ability:GetSpecialValueFor("A09T_dotDamage")
	
	if not target:IsBuilding() then
		AMHC:Damage(caster, target, dmg, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		local handle = target:FindModifierByName("modifier_A09T_tentacle_dot")
		local c = 1
		if handle then
			c = handle:GetStackCount()+1
		end
		ability:ApplyDataDrivenModifier( attacker , target , "modifier_A09T_tentacle_dot" , { duration = dotDuration } )
		handle = target:FindModifierByName("modifier_A09T_tentacle_dot")
		if handle then
			handle:SetStackCount(c)
		end
		EmitSoundOn( "ShadowShaman_Ward.ProjectileImpact" , attacker )
	else
		AMHC:Damage(caster, target, dmg*0.5, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		EmitSoundOn( "ShadowShaman_Ward.Attack" , attacker )
	end
	local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_viper/viper_poison_attack_explosion.vpcf" , PATTACH_CUSTOMORIGIN , nil )
	ParticleManager:SetParticleControl( particle , 0 , target:GetAbsOrigin() + Vector(0,0,50) )
	ParticleManager:SetParticleControl( particle , 3 , target:GetAbsOrigin() + Vector(0,0,50) )
end

function modifier_A09T_passive_OnAbilityExecuted( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("A09T_passiveDuration")
	local lockDuration = ability:GetSpecialValueFor("A09T_passiveLock")
	local count = ability:GetSpecialValueFor("A09T_passiveUnit")
	local radius = 800

	if not caster:HasModifier("modifier_A09T_passive_lock") and string.match(keys.event_ability:GetName(), "A09") then
		local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, 
			ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for _,unit in ipairs(units) do
			for i=1,count do
				local tentacle = CreateUnitByName("A09T_tentacle", unit:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
				tentacle:SetOwner(caster)
				tentacle:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
				tentacle:AddNewModifier( caster , ability , "modifier_phased" , { duration = 0.01 } )
				ability:ApplyDataDrivenModifier( caster , tentacle , "modifier_A09T_tentacle" , { duration = duration } )
				ExecuteOrderFromTable( { UnitIndex = tentacle:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = tentacle:GetAbsOrigin() })
				EmitSoundOn( "Hero_ShadowShaman.SerpentWard" , tentacle )
			end
			ability:ApplyDataDrivenModifier( caster , caster , "modifier_A09T_passive_lock" , { duration = lockDuration } )
			break
		end
	end
end

function A09T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local duration = ability:GetSpecialValueFor("A09T_old_duration")
	local count = ability:GetSpecialValueFor("A09T_old_unitCount")

	for i=1,count do
		local unit = CreateUnitByName("A09T_old_tentacle", point, false, caster, caster, caster:GetTeamNumber())
		unit:SetOwner(caster)
		unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
		unit:AddNewModifier( caster , ability , "modifier_phased" , { duration = 0.01 } )
		ability:ApplyDataDrivenModifier( caster , unit , "modifier_A09T_old_tentacle" , { duration = duration } )
		ExecuteOrderFromTable( { UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = unit:GetAbsOrigin() })
		EmitSoundOn( "Hero_ShadowShaman.SerpentWard" , unit )
	end
end

function modifier_A09T_old_tentacle_OnAttackLanded( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local target = keys.target
	local dotDuration = ability:GetSpecialValueFor("A09T_old_dotDutaion")
	local dmg = ability:GetSpecialValueFor("A09T_old_dotDamage")
	
	if not target:IsBuilding() then
		local handle = target:FindModifierByName("modifier_A09T_old_tentacle_dot")
		local c = 1
		if handle then
			c = handle:GetStackCount()+1
		end
		ability:ApplyDataDrivenModifier( attacker , target , "modifier_A09T_old_tentacle_dot" , { duration = dotDuration } )
		handle = target:FindModifierByName("modifier_A09T_old_tentacle_dot")
		if handle then
			handle:SetStackCount(c)
		end
		EmitSoundOn( "ShadowShaman_Ward.ProjectileImpact" , attacker )
	else
		AMHC:Damage(caster, target, dmg*0.5, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		EmitSoundOn( "ShadowShaman_Ward.Attack" , attacker )
	end
	local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_viper/viper_poison_attack_explosion.vpcf" , PATTACH_CUSTOMORIGIN , nil )
	ParticleManager:SetParticleControl( particle , 0 , target:GetAbsOrigin() + Vector(0,0,50) )
	ParticleManager:SetParticleControl( particle , 3 , target:GetAbsOrigin() + Vector(0,0,50) )
end

function modifier_A09T_OnIntervalThink( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local dmg = ability:GetSpecialValueFor("A09T_dotDamage")
	local handle = target:FindModifierByName("modifier_A09T_tentacle_dot")
	dmg = dmg * handle:GetStackCount()
	if dmg > target:GetHealth() then
		dmg = target:GetHealth() - 10
	end
	AMHC:Damage(caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
end

function modifier_A09T_old_OnIntervalThink( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local dmg = ability:GetSpecialValueFor("A09T_old_dotDamage")
	local handle = target:FindModifierByName("modifier_A09T_old_tentacle_dot")
	AMHC:Damage(caster,target,dmg * handle:GetStackCount(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
end