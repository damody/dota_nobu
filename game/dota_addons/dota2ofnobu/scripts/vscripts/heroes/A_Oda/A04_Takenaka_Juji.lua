--[[
	學習:dummy不能同時段用 要不然會斷線? (這啥文法= =)
]]

--<<global>>
	A04T_UNIT={}
	A04R_FLOAT={}
--<<endglobal>>

function FireEffect_IcePath( event )
	local caster		= event.caster
	local ability		= event.ability
	local pathLength	= ability:GetCastRange()
	local pathDelay		= event.path_delay
	local pathDuration	= event.duration
	local pathRadius	= event.path_radius

	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + caster:GetForwardVector() * pathLength

	ability.ice_path_stunStart	= GameRules:GetGameTime() + pathDelay
	ability.ice_path_stunEnd	= GameRules:GetGameTime() + pathDelay + 0.01

	ability.ice_path_startPos	= startPos * 1
	ability.ice_path_endPos		= endPos * 1

	ability.ice_path_startPos.z = 0
	ability.ice_path_endPos.z = 0

	-- Create ice_path
	local particleName = "particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, startPos )

	ability.pfxIcePath = pfx
	Timers:CreateTimer(0.1, function() 
		ParticleManager:DestroyParticle( ability.pfxIcePath, true )
	end)

	-- Create ice_path_b
	particleName = "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, Vector( pathDelay + pathDuration, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 9, startPos )

	-- Generate projectiles
	if pathRadius < 32 then
		--print( "Set the proper value of path_radius in ice_path_datadriven." )
		return
	end

	local projectileRadius = pathRadius * math.sqrt(2)
	local numProjectiles = math.floor( pathLength / (pathRadius*2) ) + 1
	local stepLength = pathLength / ( numProjectiles - 1 )

	for i=1, numProjectiles do
		local projectilePos = startPos + caster:GetForwardVector() * (i-1) * stepLength
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                              projectilePos,
                              nil,
                              projectileRadius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				ability:ApplyDataDrivenModifier(caster, it,"modifier_A04E",nil)
			end
		end
	end
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Distance between a point and a segment.
]]
function DistancePointSegment( p, v, w )
	local l = w - v
	local l2 = l:Dot( l )
	t = ( p - v ):Dot( w - v ) / l2
	if t < 0.0 then
		return ( v - p ):Length2D()
	elseif t > 1.0 then
		return ( w - p ):Length2D()
	else
		local proj = v + t * l
		return ( proj - p ):Length2D()
	end
end

function A04T_ANIMATION( keys )
	local caster = keys.caster

	--播放動畫
    caster:StartGesture( ACT_DOTA_CAST_ABILITY_1 )
end


function A04T_HIDEUNIT_SPELLABLILITY( keys )
	--debug
	--DeepPrintTable(keys) --詳細打印傳遞進來的表

	local point = keys.target_points[1] 
	local caster = keys.caster
	local id 	= caster:GetPlayerID() --獲取玩家ID
	local dummy2 = CreateUnitByName( "npc_dummy_unit_Ver2", point, false, caster, caster, caster:GetTeamNumber() )
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
		if v:IsBuilding() then
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
	local dummy = CreateUnitByName( "npc_dummy_unit_Ver2", attackPoint, false, caster, caster, caster:GetTeamNumber() )
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


	target.ShieldParticle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(target.ShieldParticle, 1, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(target.ShieldParticle, 2, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(target.ShieldParticle, 4, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(target.ShieldParticle, 5, Vector(shield_size,0,0))

	-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
	ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

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
			local caster = event.caster
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_A04R_Boom",nil)
		end
	-- end

end

function A04R_EndShieldParticle( event )
	local target = event.target
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
	target:SetBaseMaxHealth(600+40*level)
	target:SetHealth(target:GetMaxHealth())
end

function A04D_ATTACK_UNIT( event )
	--如果攻擊單位是建築物 就結凍
	local unit = event.target
	local ability = event.ability
	if not unit:IsBuilding() and IsValidEntity(unit) then
		ability:ApplyDataDrivenModifier(unit,unit,"modifier_A04D_ATTACK_UNIT",nil)
	end
end

function A04T_End( keys )
	keys.caster.dummy:ForceKill(false)
end

function A04T( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target_points[1]
	-- local dummy = CreateUnitByName( "npc_dummy_unit", target, false, caster, caster, caster:GetTeamNumber() ) 舊單位的技能名稱ability_dummy_unit似乎有問題
	local dummy = CreateUnitByName( "npc_dummy_unit_new", target, false, caster, caster, caster:GetTeamNumber() )
	local level  = keys.ability:GetLevel()--獲取技能等級
	local radius = keys.ability:GetLevelSpecialValueFor("radius",level-1)
	local damage_scepter = keys.ability:GetLevelSpecialValueFor("damage_scepter",level-1)
	ability:ApplyDataDrivenModifier( dummy, dummy, "modifier_freezing_field_caster_datadriven",{duration=8} )
	caster.dummy = dummy
	Timers:CreateTimer(function()
		if  ( caster:IsChanneling() ) then
			local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              target,
	                              nil,
	                              radius,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)

			--effect:傷害+暈眩
			for _,it in pairs(direUnits) do
				if (not(it:IsBuilding())) then
					if (not it:HasModifier("modifier_freezing_field_debuff_datadriven")) then
						ability:ApplyDataDrivenModifier(caster,it,"modifier_freezing_field_debuff_datadriven", {duration=5})
					end
					AMHC:Damage(caster,it,damage_scepter,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				else
					AMHC:Damage(caster,it,damage_scepter*0.5,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				end
			end
			return 0.7
		else
			return nil
		end
	end)
end

-- 11.2B
---------------------------------------------------------------------------------------

-- 當法術啟動時觸發
function A04D_old_init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()-1
	
	-- 預先儲存參數給A04D_old_aoe_attack使用
	ability.attack_damage = ability:GetLevelSpecialValueFor("attack_damage",level)
	ability.attack_radius = ability:GetLevelSpecialValueFor("attack_radius", level)
	ability.cast_radius = ability:GetLevelSpecialValueFor("cast_radius",level)

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A04D_old",nil)
end

function A04D_old_aoe_attack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	local attack_damage = ability.attack_damage
	local attack_radius = ability.attack_radius
	local cast_radius = ability.cast_radius

	-- 計算攻擊座標
	local castDistance = RandomInt(0, cast_radius)
	local angle = RandomInt(0,360)
	local dx = castDistance*math.cos(angle)
	local dy = castDistance*math.sin(angle)
	local attackPoint = center+Vector(dx,dy,100)

	-- 特效
	
	--local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
	local fxIndex = ParticleManager:CreateParticle( "particles/a04/a04d_old_ice_boom.vpcf", PATTACH_WORLDORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, attackPoint )

	local units = FindUnitsInRadius(
		caster:GetTeamNumber(),
		attackPoint,
		nil,
		attack_radius,
		ability:GetAbilityTargetTeam(),
		ability:GetAbilityTargetType(),
		ability:GetAbilityTargetFlags(),
		0,
		false)

	for _,unit in pairs(units) do
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_A04D_old_debuff",nil)
		AMHC:Damage(caster,unit,attack_damage,AMHC:DamageType("DAMAGE_TYPE_MAGICAL"))
	end
end

function A04W_old_init( keys )
	local target = keys.target
	local ability = keys.ability
	local base_hp = keys.ability:GetLevelSpecialValueFor("base_hp",ability:GetLevel()-1)
	target:SetBaseMaxHealth(base_hp)
end

function A04W_old_Bonus( keys )
	--隨著英雄等級提升
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	--獲取英雄等級
	local level = caster:GetLevel()
	local base_hp = keys.ability:GetLevelSpecialValueFor("base_hp",ability:GetLevel()-1)
	local hModifier = target:FindModifierByNameAndCaster("modifier_A04W_Tech", caster)
	hModifier:SetStackCount(level)
	target:SetBaseMaxHealth(base_hp)
	target:SetHealth(target:GetMaxHealth())
end

function A04R_old_on_attack_landed( keys )
	local unit = keys.target
	local ability = keys.ability
	if not unit:IsBuilding() then
		ability:ApplyDataDrivenModifier(unit,unit,"modifier_A04R_old_debuff",nil)
	end
end

function A04T_old_freezing_field_explode( keys )
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

		-- 調整對建築物的傷害
		if v:IsBuilding() then
			dmg = dmg * ability:GetLevelSpecialValueFor("adjust_damage_on_building",ability:GetLevel()-1)
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

-- 普通攻擊命中時觸發，用來判斷是否要增加傷害
function A04F_old_damage_bonus( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- ***當身上有法球效果則直接跳出***
	if caster.nobuorb1 ~= nil then
		return
	end

	local dmg = keys.dmg
	local per_atk = 50

	if not target:IsHero() then 
		local particle = ParticleManager:CreateParticle("particles/b01r/b01r.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(particle, 3, target:GetAbsOrigin()+Vector(0, 0, 100))
		Timers:CreateTimer(1, function()
			ParticleManager:DestroyParticle(particle,false)
		end)
		dmg = dmg * per_atk / 100
		AMHC:Damage(caster,target,dmg,AMHC:DamageType("DAMAGE_TYPE_PHYSICAL"))
	end
end