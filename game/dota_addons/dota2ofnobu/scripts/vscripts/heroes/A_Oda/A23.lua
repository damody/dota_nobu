-- 宇喜多秀家 by Nian Chen
-- 2017.3.26

function A23W( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("A23W_radius")
	local damage = ability:GetSpecialValueFor("A23W_damage")
	local duration = ability:GetSpecialValueFor("A23W_stun")

	local particleHit = ParticleManager:CreateParticle( "particles/a23w_1/a23w_1.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)

	if target:HasModifier("modifier_A23E") then
		Timers:CreateTimer(2, function ()
			local particle = ParticleManager:CreateParticle( "particles/a23w_2/a23w_2.vpcf", PATTACH_CUSTOMORIGIN, target)
			ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl( particle, 3, target:GetAbsOrigin())
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
			for _,unit in ipairs(units) do
				unit:AddNewModifier( caster, ability, "modifier_stunned", { duration = duration })
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		end)
	else
		Timers:CreateTimer(2, function ()
			local particle = ParticleManager:CreateParticle( "particles/a23w_2/a23w_2.vpcf", PATTACH_CUSTOMORIGIN, target)
			ParticleManager:SetParticleControl( particle, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl( particle, 1, target:GetAbsOrigin())
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
			for _,unit in ipairs(units) do
				unit:AddNewModifier( caster, ability, "modifier_stunned", { duration = duration })
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		end)
	end
end

function A23E( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("A23E_duration")
	local increaseDistance = ability:GetSpecialValueFor("A23E_increaseDistance")

	local stick = CreateUnitByName( "A32E_stick", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeamNumber())
	stick:SetOwner(caster)
	ability:ApplyDataDrivenModifier( caster, stick, "modifier_A23E_stick", nil)
	ability:ApplyDataDrivenModifier( stick, target, "modifier_A23E", { duration = duration } )
	AddFOWViewer(DOTA_TEAM_GOODGUYS, stick:GetAbsOrigin(), 300, duration, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, stick:GetAbsOrigin(), 300, duration, false)

	ability.particle = ParticleManager:CreateParticle("particles/a23e/a23e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(ability.particle, 0, stick, PATTACH_POINT_FOLLOW, "attach_hitloc", stick:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

	ability.state = "NONE"

	local time = 0.1 + duration
	local count = 0
	Timers:CreateTimer(0,function()
		count = count + 1
		if count > time then
			return nil
		end
		if ability.state ~= "PURGE" then
			local damageCount = (100 + caster:GetIntellect())*( 1 + 0.05*math.floor(((target:GetOrigin() - stick:GetOrigin()):Length() / increaseDistance)) )
			if target:IsMagicImmune() then
				damageCount = damageCount *0.5
			end
			ApplyDamage({
				victim = target,
				attacker = caster,
				ability = ability,
				damage = damageCount,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			})
		end
		return 1
	end)
	local count2 = 0
	Timers:CreateTimer(0,function()
		count2 = count2 + 0.2
		if count2 > time then
			return nil
		end
		AddFOWViewer(DOTA_TEAM_GOODGUYS, target:GetAbsOrigin(), 100, 0.5, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, target:GetAbsOrigin(), 100, 0.5, false)
		return 0.2
	end)

	Timers:CreateTimer(duration,function()
		stick:ForceKill(true)
		if ability.particle then
			ParticleManager:DestroyParticle( ability.particle, false )
		end
	end)
end

function A23E_OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:IsMagicImmune() then
		ability.state = "MAGIC_IMMUNE"
	else
		ability.state = "PURGE"
		if ability.particle then
			ParticleManager:DestroyParticle( ability.particle, false )
		end
	end
end

function A23R( keys )
	local caster = keys.caster
	local ability = keys.ability
	local adjust_damage_at_building = ability:GetSpecialValueFor("adjust_damage_at_building")
	local aoe_radius	= ability:GetSpecialValueFor("A23R_aoeRadius")
	local max_wave		= ability:GetSpecialValueFor("A23R_maxWave")
	local channelTime 	= ability:GetChannelTime()
	local aoe_damage 	= ability:GetSpecialValueFor("A23R_damage")
	local aoe_damage_type = ability:GetAbilityDamageType()
	local wave_delay 	= 0.3

	-- 搜尋參數
	local iTeam = caster:GetTeamNumber()
	local center = keys.target_points[1]
	local tTeam = ability:GetAbilityTargetTeam()
	local tType = ability:GetAbilityTargetType()
	local tFlag = ability:GetAbilityTargetFlags()

	Timers:CreateTimer(0, function()
		-- 停止施法則中斷
		if not caster:IsChanneling() then
			return nil
		end
		AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 1, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 1, false)
		-- 照亮目標周圍
		AddFOWViewer(iTeam,center,aoe_radius*1.1,1.0,false)
		-- 搜尋敵人
		local units = FindUnitsInRadius(iTeam,center,nil,aoe_radius,tTeam,tType,tFlag,FIND_ANY_ORDER,false)
		for _,unit in ipairs(units) do
			local adjust = 1.0
			if unit:IsBuilding() then
				adjust = adjust_damage_at_building
			end
			-- 傷害參數
			local damage_table = {
				attacker = caster,
				victim = unit,
				damage = aoe_damage*adjust,
				damage_type = aoe_damage_type
			}
			-- 配合特效延遲傷害造成時間
			Timers:CreateTimer(0.3, function()
				if not unit:IsBuilding() and IsValidEntity(unit) then
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_A23R_dot",nil)
				else
					--ability:ApplyDataDrivenModifier(caster,unit,"modifier_A23R_dot_building",nil)
				end
				if IsValidEntity(unit) then
					ApplyDamage(damage_table)
				end
			end)
		end
		-- 特效
		A23R_create_meteor_particle_effect(caster, center, aoe_radius)
		return wave_delay
	end)

	-- 配合特效延遲砍樹
	Timers:CreateTimer(0.45, function()
		GridNav:DestroyTreesAroundPoint(center, aoe_radius, false)
	end)
end

function A23R_create_meteor_particle_effect( caster, target_pos, radius )
	local caster_pos = caster:GetAbsOrigin()
	for i=1,10 do
		local ifx = ParticleManager:CreateParticle("particles/a23r/a23rfly.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(ifx, 0, caster_pos + Vector (0, 0, 1000)) -- 隕石產生的位置
		ParticleManager:SetParticleControl(ifx, 1, target_pos + RandomVector(RandomInt(0,radius))) -- 命中位置
		ParticleManager:SetParticleControl(ifx, 2, Vector(0.5, 0, 0)) -- 效果存活時間
	end
end

function A23T( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, target, "modifier_A23T", nil)
end