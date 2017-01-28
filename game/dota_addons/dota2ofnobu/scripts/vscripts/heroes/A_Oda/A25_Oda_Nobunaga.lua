--global
local A25R_level = 0
--ednglobal

LinkLuaModifier( "A25R_critical", "scripts/vscripts/heroes/A_Oda/A25_Oda_Nobunaga.lua",LUA_MODIFIER_MOTION_NONE )


function A25W( keys )
	local caster = keys.caster
	local ability	= keys.ability
	local point = ability:GetCursorPosition()

	--AMHC:CreateParticle(particleName,PATTACH_CUSTOMORIGIN,false,caster,3,nil)
	local particle = ParticleManager:CreateParticle("particles/a25w2/a25w2.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_attack3", Vector(0,0,0), true)

	Timers:CreateTimer( 0.1, function()
				ParticleManager:DestroyParticle(particle,false)
				return nil
			end
		)
end

function BladeFuryStop( event )
	local caster = event.caster
	
	caster:StopSound("Hero_Juggernaut.BladeFuryStart")
end
--EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
function A25E( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local casterLocation = keys.target_points[1]
	local range = ability:GetLevelSpecialValueFor( "A25E_range", ability:GetLevel() - 1 )
	local randonint = 5
	local dura = ability:GetLevelSpecialValueFor( "A25E_Duration", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor( "A25E_damage", ability:GetLevel() - 1 )
	local spike_amount = ability:GetLevelSpecialValueFor( "A25E_spike_amount", ability:GetLevel() - 1 )
	for i=1,spike_amount do
		local pos = casterLocation + RandomVector(RandomInt(randonint , range-randonint))
		local spike = ParticleManager:CreateParticle("particles/a25e/a25e.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(spike, 0, pos)
		Timers:CreateTimer(5, function() 
			ParticleManager:DestroyParticle(spike,true)
		end)
	end
	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), casterLocation, nil, range+50, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _,it in pairs(enemies) do
		if (not(it:IsBuilding())) then
			AMHC:Damage(caster,it, damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			ability:ApplyDataDrivenModifier( caster, it, "modifier_A25E", {duration = dura} )
		end
	end
	local dummy = CreateUnitByName( "npc_dummy", casterLocation, false, caster, caster, caster:GetTeamNumber() )
	dummy:EmitSound( "A25E.spiked_carapace" )
	Timers:CreateTimer( 0.5, function()
			dummy:ForceKill( true )
			return nil
		end)
end

function A25E_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local casterLocation = keys.target_points[1]
	local range = ability:GetLevelSpecialValueFor( "A25E_range", ability:GetLevel() - 1 )
	local randonint = 5
	local dura = ability:GetLevelSpecialValueFor( "A25E_Duration", ability:GetLevel() - 1 )
	local damage = ability:GetLevelSpecialValueFor( "A25E_damage", ability:GetLevel() - 1 )
	local spike_amount = ability:GetLevelSpecialValueFor( "A25E_spike_amount", ability:GetLevel() - 1 )
	for i=1,spike_amount do
		local pos = casterLocation + RandomVector(RandomInt(randonint , range-randonint))
		local spike = ParticleManager:CreateParticle("particles/a25e/a25e.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(spike, 0, pos)
		Timers:CreateTimer(5, function() 
			ParticleManager:DestroyParticle(spike,true)
		end)
	end
	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), casterLocation, nil, range+50, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _,it in pairs(enemies) do
		if (not(it:IsBuilding())) then
			AMHC:Damage(caster,it, damage*0.5,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			ability:ApplyDataDrivenModifier( caster, it, "modifier_A25E", {duration = dura} )
		end
	end
	local dummy = CreateUnitByName( "npc_dummy", casterLocation, false, caster, caster, caster:GetTeamNumber() )
	dummy:EmitSound( "A25E.spiked_carapace" )
	Timers:CreateTimer( 0.5, function()
			dummy:ForceKill( true )
			return nil
		end)
	Timers:CreateTimer( 1, function()
		local enemies = FindUnitsInRadius( caster:GetTeamNumber(), casterLocation, nil, range+50, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		for _,it in pairs(enemies) do
			if (not(it:IsBuilding())) then
				AMHC:Damage(caster,it, damage*0.5,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				ability:ApplyDataDrivenModifier( caster, it, "modifier_A25E", {duration = dura} )
			end
		end
		return nil
		end)
end

--[[
	Author: kritth
	Date: 9.1.2015.
	Bubbles seen only to ally as pre-effect
]]
function torrent_bubble_allies( keys )
	local caster = keys.caster
	
	local allHeroes = HeroList:GetAllHeroes()
	local delay = keys.ability:GetLevelSpecialValueFor( "delay", keys.ability:GetLevel() - 1 )
	local particleName = "particles/a25e3/a25e3.vpcf"  --"particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf"
	local target = keys.target_points[1]
	
	for k, v in pairs( allHeroes ) do
		if v:GetPlayerID() and v:GetTeam() == caster:GetTeam() then
			local fxIndex = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, v, PlayerResource:GetPlayer( v:GetPlayerID() ) )
			ParticleManager:SetParticleControl( fxIndex, 0, target )
			
			EmitSoundOnClient( "Ability.pre.Torrent", PlayerResource:GetPlayer( v:GetPlayerID() ) )
			
			-- Destroy particle after delay
			Timers:CreateTimer( delay, function()
					ParticleManager:DestroyParticle( fxIndex, false )
					return nil
				end
			)
		end
	end

	A25E( keys )
end

--[[
	Author: kritth
	Date: 9.1.2015.
	Emit sound at location
]]
function torrent_emit_sound( keys )
	local dummy = CreateUnitByName( "hide_unit", keys.target_points[1], false, keys.caster, keys.caster, keys.caster:GetTeamNumber() )
	EmitSoundOn( "Ability.Torrent", dummy )
	dummy:ForceKill( true )
end

--[[
	Author: kritth, Pizzalol
	Date: February 24, 2016
	Provides obstructed vision of the area
]]
function torrent_vision( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[1]
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
	
	AddFOWViewer(caster:GetTeamNumber(),target,radius,duration,true)
end



--RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR

A25R_critical = class({})

function A25R_critical:IsHidden()
	return true
end

function A25R_critical:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function A25R_critical:GetModifierPreAttack_CriticalStrike()
	return self.A25R_level*50 + 150
end

function A25R_critical:CheckState()
	local state = {
	}
	return state
end


function A25R_Levelup( keys )
	local caster = keys.caster
	caster.A25R_noncrit_count = 0
	
end

function A25R( keys )
	local caster = keys.caster
	local skill = keys.ability
	local ran =  RandomInt(0, 100)
	caster:RemoveModifierByName("A25R_critical")
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > 20) then
			caster.A25R_noncrit_count = caster.A25R_noncrit_count + 1
		end
		if (caster.A25R_noncrit_count > 5 or ran <= 20) then
			caster.A25R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			local rate = caster:GetAttackSpeed()
			caster:AddNewModifier(caster, skill, "A25R_critical", { duration = rate+0.1 } )
			local hModifier = caster:FindModifierByNameAndCaster("A25R_critical", caster)
			--SE
			-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur_impact.vpcf", PATTACH_POINT, keys.target)
			-- ParticleManager:SetParticleControlEnt(particle, 0, keys.target, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
			--動作
				local rate = caster:GetAttackSpeed()
				--print(tostring(rate))

				--播放動畫
			    --caster:StartGesture( ACT_SLAM_TRIPMINE_ATTACH )
				if rate < 1.00 then
				    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1.00)
				else
				    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
				end

			if (hModifier ~= nil) then
				hModifier.A25R_level = keys.ability:GetLevel()
			end
		end
	end
end

function A25T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local ran =  RandomInt(0, 100)
	local tornado = ParticleManager:CreateParticle("particles/a17t/a17t_funnel.vpcf", PATTACH_ABSORIGIN, keys.caster)
	local timecount = 0
	local small_tornado_count = 0
	local AbilityDamage = ability:GetLevelSpecialValueFor( "Damage", ability:GetLevel() - 1 )
	Timers:CreateTimer(0, function()
		local pos = caster:GetAbsOrigin()
		ParticleManager:SetParticleControl(tornado, 3, pos)
		timecount = timecount + 0.1
		small_tornado_count = small_tornado_count + 1
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                              caster:GetAbsOrigin(),
                              nil,
                              400,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                              FIND_ANY_ORDER,
                              false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				AMHC:Damage(caster,it,AbilityDamage*0.2,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
			else
				AMHC:Damage(caster,it,AbilityDamage*0.1,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
			end
		end
		if (small_tornado_count % 4 == 0) then
			A25T2(keys)
		end
		if (caster:HasModifier("modifier_A25T")) then
			return 0.1
		else
			ParticleManager:DestroyParticle(tornado, false)
			return nil
		end
	end)
	
end

function A25T2( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local ran =  RandomInt(0, 100)
	local tornado = ParticleManager:CreateParticle("particles/a17t/a17t2_funnel.vpcf", PATTACH_ABSORIGIN, keys.caster)
	local timecount = 0
	local movedir = RandomVector(10)
	local pos = caster:GetAbsOrigin()

	Timers:CreateTimer(0, function()
		pos = pos + movedir
		ParticleManager:SetParticleControl(tornado, 3, pos)
		local enemies = FindUnitsInRadius( caster:GetTeamNumber(), pos, nil, 150, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,it in pairs(enemies) do
			AMHC:Damage(caster,it, 6,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end

		timecount = timecount + 0.1
		if (timecount < 7) then
			return 0.1
		else
			ParticleManager:DestroyParticle(tornado, false)
			return nil
		end
	end)
	
end

-- 11.2B
--------------------------------------------------------

function A25R_old_on_attack_start( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local crit_chance = ability:GetLevelSpecialValueFor("crit_chance",ability:GetLevel()-1)
	local rnd =  RandomInt(1, 100)

	if not target:IsBuilding() and rnd <= crit_chance then
		-- 爆傷修改器
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A25R_old_crit",{})

		-- 動畫
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,caster:GetAttackSpeed())

		-- 音效
		StartSoundEvent("Hero_SkeletonKing.CriticalStrike", target)
	end
end

function A25D_old( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Finds the units in a given radius with the given flags. ( iTeamNumber, vPosition, hCacheUnit, flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(),
		Vector(0,0,0),
		nil,
		99999,
		ability:GetAbilityTargetTeam(),
		ability:GetAbilityTargetType(),
		ability:GetAbilityTargetFlags(),
		FIND_ANY_ORDER,
		false)

	local i = 1
	local last = #units

	-- 慢慢加
	Timers:CreateTimer( 0, function()
		if i <= last then
			local unit = units[i]
			if IsValidEntity(unit) then
				if unit:IsHero() then
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_A25D_old_buff_for_hero",{})
				else
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_A25D_old_buff_for_soldier",{})
				end
			end
			i = i + 1
			return 0.01
		else
			return nil
		end
	end)
end