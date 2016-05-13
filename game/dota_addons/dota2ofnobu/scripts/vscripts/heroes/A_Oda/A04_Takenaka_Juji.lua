--[[
	學習:dummy不能同時段用 要不然會斷線? (這啥文法= =)
]]

--<<global>>
	A04T_UNIT={}
	A04R_FLOAT={}
--<<endglobal>>


function A04T_ANIMATION( keys )
	local caster = keys.caster

	--播放動畫
    caster:StartGesture( ACT_DOTA_CAST_ABILITY_1 )
end

function A04T_STOP_SPELL( keys )
	--如果停止施法就殺掉單位
	local caster = keys.caster
	local id 	= caster:GetPlayerID() --獲取玩家ID
	A04T_UNIT[id]:ForceKill( true )
end

function A04T_HIDEUNIT_SPELLABLILITY( keys )
	--debug
	--DeepPrintTable(keys) --詳細打印傳遞進來的表

	local point = keys.target_points[1] 
	local caster = keys.caster
	local id 	= caster:GetPlayerID() --獲取玩家ID
	local dummy2 = CreateUnitByName( "hide_unit", point, false, caster, caster, caster:GetTeamNumber() )
	local level  = keys.ability:GetLevel()--獲取技能等級

	--記錄在全局
	A04T_UNIT[id]	=	dummy2

	--添加馬甲技能
	local DummyAbility=dummy2:AddAbility("majia")
	DummyAbility:SetLevel(1)

	--添加技能
	dummy2:AddAbility("A04T_HIDE")  
    local spell = dummy2: FindAbilityByName("A04T_HIDE")
    spell:SetLevel(level)
    spell:SetActivated(true) 

    --命令 
	local order = { UnitIndex = dummy2:entindex(),
            AbilityIndex = dummy2:FindAbilityByName("A04T_HIDE"):entindex(),
            OrderType =  DOTA_UNIT_ORDER_CAST_NO_TARGET,
            Queue = true }
	ExecuteOrderFromTable(order)

end

--[[
	CHANGELIST:
	09.01.2015 - Standandized variables and remove ReleaseParticleIndex( .. )
]]

--[[
	Author: kritth
	Date: 5.1.2015.
	Order the explosion in clockwise direction
]]
function A04T_freezing_field_order_explosion( keys )
	Timers:CreateTimer( 0.1, function()
		keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_freezing_field_northwest_thinker_datadriven", {} )
		return nil
		end )
		
	Timers:CreateTimer( 0.2, function()
		keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_freezing_field_northeast_thinker_datadriven", {} )
		return nil
		end )
	
	Timers:CreateTimer( 0.3, function()
		keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_freezing_field_southeast_thinker_datadriven", {} )
		return nil
		end )
	
	Timers:CreateTimer( 0.4, function()
		keys.ability:ApplyDataDrivenModifier( keys.caster, keys.caster, "modifier_freezing_field_southwest_thinker_datadriven", {} )
		return nil
		end )
end

--[[
	Author: kritth
	Date: 09.01.2015.
	Apply the explosion
]]
function A04T_freezing_field_explode( keys )
	local ability = keys.ability
	local caster = keys.caster
	local casterLocation = keys.caster:GetAbsOrigin()
	local abilityDamage = ability:GetLevelSpecialValueFor( "damage", ( ability:GetLevel() - 1 ) )
	local minDistance = ability:GetLevelSpecialValueFor( "explosion_min_dist", ( ability:GetLevel() - 1 ) )
	local maxDistance = ability:GetLevelSpecialValueFor( "explosion_max_dist", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "explosion_radius", ( ability:GetLevel() - 1 ) )
	local directionConstraint = keys.section
	local modifierName = "modifier_freezing_field_debuff_datadriven"
	local refModifierName = "modifier_freezing_field_ref_point_datadriven"
	local particleName = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
	local soundEventName = "hero_Crystal.freezingField.explosion" --  Hero_TemplarAssassin.Trap.Explode
	local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local damageType = ability:GetAbilityDamageType()
	
	-- Get random point
	local castDistance = RandomInt( minDistance, maxDistance )
	local angle = RandomInt( 0, 90 )
	local dy = castDistance * math.sin( angle )
	local dx = castDistance * math.cos( angle )
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
	
	-- From here onwards might be possible to port it back to datadriven through modifierArgs with point but for now leave it as is
	-- Loop through units
	local units = FindUnitsInRadius( caster:GetTeamNumber(), attackPoint, caster, radius,
			targetTeam, targetType, targetFlag, 0, false )
	for k, v in pairs( units ) do
		local dmg = abilityDamage

		--判斷是不是建築物:如果是傷害減半
		if v:IsTower() or v:IsBuilding() then
			dmg = 0.55 * dmg
		end

		local damageTable =
		{
			victim = v,
			attacker = caster,
			damage = dmg,
			damage_type = damageType
		}
		ApplyDamage( damageTable )
	end
	
	-- Fire effect
	local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, attackPoint )
	
	-- Fire sound at dummy
	local dummy = CreateUnitByName( "hide_unit", attackPoint, false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, refModifierName, {} )
	StartSoundEvent( soundEventName, dummy )
	Timers:CreateTimer( 0.1, function()
		dummy:ForceKill( true )
		return nil
	end )
end


--[[
	Author: kritth
	Date: 31.12.2015.
	Provide vision post-attack
]]
function A04E_crystal_nova_post_vision( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	--local target = caster:GetAbsOrigin() --keys.target_points[ 1 ]
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "vision_radius", ( ability:GetLevel() - 1 ) )

	-- Create unobstructed vision around the point
	AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), radius, duration, false)
end


--[[
	Author: LINWEIHAN
	Date: 04.05.2016.
]]

function A04R_spell_start( event )
	-- Variables
	local target = event.target
	local max_damage_absorb = event.ability:GetLevelSpecialValueFor("damage_absorb", event.ability:GetLevel() - 1 )
	local shield_size = 75 -- could be adjusted to model scale

	-- Reset the shield
	target.AphoticShieldRemaining = max_damage_absorb

	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.ShieldParticle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(target.ShieldParticle, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 5, Vector(shield_size,0,0))

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	end)

end

function A04R_boom( keys )
	-- Variables
	local caster = keys.unit
	local ability = keys.ability
	local point = caster:GetAbsOrigin()

	--如何獲取準確的竹中ID，又不能用hash

	--馬甲
	local dummy = CreateUnitByName( "hide_unit", point, false, caster, caster, caster:GetTeamNumber() )
	local level  = keys.ability:GetLevel()--獲取技能等級
	local DummyAbility=dummy:AddAbility("A04R_HIDE")
	DummyAbility:SetLevel(level)
	DummyAbility:SetActivated(true)

	--添加馬甲技能
	DummyAbility=dummy:AddAbility("majia")
	DummyAbility:SetLevel(1)

	dummy:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位

    --命令 
	local order = { UnitIndex = dummy:entindex(),
            AbilityIndex = dummy:FindAbilityByName("A04R_HIDE"):entindex(),
            OrderType =  DOTA_UNIT_ORDER_CAST_NO_TARGET,
            Queue = true }
	ExecuteOrderFromTable(order)

end


function A04R_damage_check( event )
	-- Variables
	local damage = event.DamageTaken
	local unit = event.unit
	local ability = event.ability
	
	-- Track how much damage was already absorbed by the shield
	local shield_remaining = unit.AphoticShieldRemaining

	-- -- Check if the unit has the borrowed time modifier
	-- if not unit:HasModifier("modifier_borrowed_time") then
		-- If the damage is bigger than what the shield can absorb, heal a portion
		if damage > shield_remaining then
			local newHealth = unit:GetHealth() + shield_remaining
			unit:SetHealth(newHealth)
		else
			local newHealth = unit:GetHealth() + damage			
			unit:SetHealth(newHealth)
		end

		-- Reduce the shield remaining and remove
		unit.AphoticShieldRemaining = unit.AphoticShieldRemaining-damage
		if unit.AphoticShieldRemaining <= 0 then
			unit.AphoticShieldRemaining = nil
			--移除特效
			unit:RemoveModifierByName("modifier_A04R")
			--爆炸
			A04R_boom(event)
		end
	-- end

end

function A04R_EndShieldParticle( event )
	local target = event.caster
	ParticleManager:DestroyParticle(target.ShieldParticle,false)
end


--[[
	Author: Noya
	Date: April 5, 2015
	Get a point at a distance in front of the caster
]]
function GetFrontPoint( event )
	local caster = event.caster
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = event.Distance
	
	local front_position = origin + fv * distance
	local result = {}
	table.insert(result, front_position)

	return result
end

-- Set the units looking at the same point of the caster
function SetUnitsMoveForward( event )
	local caster = event.caster
	local target = event.target
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	target:SetForwardVector(fv)
end

--[[
	Author: Noya
	Date: 16.01.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function A04W_ATTACK_BUILDING( event )
	--如果攻擊單位是建築物 就結凍
	local unit = event.target
	local ability = event.ability
	if unit:IsBuilding() then
		ability:ApplyDataDrivenModifier(unit,unit,"modifier_A04W_AttackBuilding",nil)
	end
end

function A04W_Bonus( event )
	--隨著英雄等級提升
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	--獲取英雄等級
	local level = caster:GetLevel()

	local hModifier = target:FindModifierByNameAndCaster("modifier_A04W_Tech", caster)
	hModifier:SetStackCount(level)

	--debug
	GameRules: SendCustomMessage(tostring(level),DOTA_TEAM_GOODGUYS,0)

end

function A04D_ATTACK_UNIT( event )
	--如果攻擊單位是建築物 就結凍
	local unit = event.target
	local ability = event.ability
	if not unit:IsBuilding() then
		ability:ApplyDataDrivenModifier(unit,unit,"modifier_A04D_ATTACK_UNIT",nil)
	end
end