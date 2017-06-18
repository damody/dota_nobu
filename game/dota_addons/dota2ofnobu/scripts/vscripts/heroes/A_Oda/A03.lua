-- 石川樹正
function A03W_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local projTable = {
		EffectName = "particles/b33r/b33r.vpcf",
		Ability = ability,
		Target = target,
		Source = caster,
		bDodgeable = false,
		bProvidesVision = false,
		vSpawnOrigin = caster:GetAbsOrigin(),
		iMoveSpeed = 1200,
		iVisionRadius = 0,
		iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projTable )
	
end

function A03W_OnUnitMoved( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit
	local pos = target:GetOrigin()
	local lastpos = target.lastpos
	local triggerlen = ability:GetSpecialValueFor("triggerlen")
	local dmg = ability:GetSpecialValueFor("dmg")
	
	if lastpos == nil then
		lastpos = pos
		target.A03W_len = 0
	else
		if target:IsMagicImmune() then
			dmg = dmg *0.5
		end
		local dis = (pos-lastpos):Length2D()
		target.A03W_len = target.A03W_len + dis
		if target.A03W_len > triggerlen then
			AMHC:Damage( caster,target,dmg, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			target.A03W_len = target.A03W_len - triggerlen
		end
	end
	target.lastpos = pos
end

function A03W_OnDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	target.A03W_len = nil
	target.lastpos = nil
end

function A03E_OnToggleOn( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	caster:SetModel("models/creeps/nian/nian_creep.vmdl")
	caster:SetOriginalModel("models/creeps/nian/nian_creep.vmdl")
	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	caster:NotifyWearablesOfModelChange(true)
	caster:SetModelScale(0.5)
end

function A03E_OnToggleOff( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	caster:SetModel("models/heroes/lone_druid/lone_druid.vmdl")
	caster:SetOriginalModel("models/heroes/lone_druid/lone_druid.vmdl")
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	caster:SetModelScale(1)
end

function A03R_OnAttackLanded( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_A03R_debuff",{duration = duration})
	end
end

function A03W_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	ability:ApplyDataDrivenModifier(caster,target,"modifier_A03W_debuff",{duration = duration})
	local tsum = 0
	Timers:CreateTimer(0.1, function()
		if IsValidEntity(target) and target:IsHero() and target:IsAlive() then
			if not target:HasModifier("modifier_A03W_debuff") and target:IsMagicImmune() then
				ability:ApplyDataDrivenModifier(caster,target,"modifier_A03W_debuff",{duration = duration-tsum})
			end
		else
			return nil
		end
		tsum = tsum + 0.1
		if tsum < duration then
			return 0.1
		end
		end)
end

function A03W_old_OnDeath( keys )
	local ability = keys.ability
	local caster = ability:GetCaster()
	local target = keys.unit
	local wolf = CreateUnitByName("A03W_old",target:GetAbsOrigin() ,false,caster,caster,caster:GetTeam())
 	wolf.master = caster
 	wolf:SetOwner(caster)
 	wolf:SetBaseMaxHealth(target:GetMaxHealth()*2)
 	wolf:SetHealth(wolf:GetMaxHealth())
 	wolf:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
 	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_kill",{duration = 150})
 	wolf:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
end


function A03T_old_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local dir = caster:GetForwardVector()
	local point2 = point + dir * 300
 	local player = caster:GetPlayerID()
 	local level = ability:GetLevel()
 	local life_time = ability:GetLevelSpecialValueFor("life_time",level)
 	local base_hp = ability:GetLevelSpecialValueFor("base_hp",level)

 	local Kagutsuchi = CreateUnitByName("A03T_old",point2 ,true,caster,caster,caster:GetTeam())
 	-- 設定火神數值
 	Kagutsuchi:AddAbility("A03TW_old"):SetLevel(ability:GetLevel())
 	Kagutsuchi:SetForwardVector(dir)
	Kagutsuchi:SetControllableByPlayer(player, true)
	Kagutsuchi:SetBaseMaxHealth(base_hp)
	Kagutsuchi:SetHealth(base_hp)
	Kagutsuchi:SetBaseDamageMax(110+level*110)
	Kagutsuchi:SetBaseDamageMin(90+level*90)
	Kagutsuchi:AddAbility("for_magic_immune"):SetLevel(1)
	Kagutsuchi:AddNewModifier(Kagutsuchi,nil,"modifier_kill",{duration=life_time})
	ability:ApplyDataDrivenModifier(caster,Kagutsuchi,"modifier_A03T_old",nil)
	local hModifier = Kagutsuchi:FindModifierByNameAndCaster("modifier_A03T_old", caster)
	hModifier:SetStackCount(level)
	Kagutsuchi:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	
	local ifx = ParticleManager:CreateParticle( "particles/a03t_old.vpcf", PATTACH_CUSTOMORIGIN, Kagutsuchi)
	ParticleManager:SetParticleControl( ifx, 0, Kagutsuchi:GetAbsOrigin())
end

function A03TW_OnSpellStart( event )
	-- Variables
	local ability = event.ability
	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("stun")
	local caster = event.caster
	caster:EmitSound( "Hero_Nevermore.ROS_Flames")
	local ifx = ParticleManager:CreateParticle( "particles/a03t_old.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 400, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		damageTable = {
		victim = unit,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if not unit:IsBuilding() then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned", {duration=duration})
			ApplyDamage(damageTable)
		end
	end
end
