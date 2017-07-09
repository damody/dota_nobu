--九鬼嘉隆


function A20W_OnUpgrade( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local max = ability:GetSpecialValueFor("max")
	local radius = ability:GetSpecialValueFor("radius")
	--caster.A20W_point=max
	--if caster.A20W_count==nil then
		--caster.A20W_count=1
	--caster.A20W_point=1
		--caster.A20W_table={}
	--end
	
end
function A20W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local max = ability:GetSpecialValueFor("max")
	--print("max="..max)
	local radius = ability:GetSpecialValueFor("radius")

	if caster.A20W_first==nil then
		caster.A20W_first=1
		caster.A20W_last=0
		caster.A20W_table={}
	end
  	local tablecount=0
  	for i,v in pairs(caster.A20W_table) do
        tablecount=tablecount+1
  	end
	--print(caster.A20W_first.."count")
  	--print("caster.A20W_table_size"..tablecount)
  	--for i,v in pairs(caster.A20W_table) do
       -- print(tostring(i).."="..tostring(v))
  	--end
	if tablecount>=max then
		--print("remove"..caster.A20W_first)
		caster.A20W_table[caster.A20W_first]:AddNewModifier( dummy, nil, "modifier_kill", {duration=0.1} )
		caster.A20W_table[caster.A20W_first]:RemoveModifierByName("modifier_A20W_aura")
		caster.A20W_table[caster.A20W_first]= nil
		caster.A20W_first=caster.A20W_first+1
	end
	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	--dummy:AddNewModifier( dummy, nil, "modifier_kill", {} )
	dummy:SetOwner( caster)
	dummy:AddAbility( "majia"):SetLevel(1)
	ability:ApplyDataDrivenModifier( dummy, dummy, "modifier_A20W_aura", nil)
	caster.A20W_last=caster.A20W_last+1
	caster.A20W_table[caster.A20W_last]= dummy

	--ParticleManager:DestroyParticle(ifx,true)
	
end

function modifier_A20W_self_OnCreated( keys )
	local caster = keys.caster
	local target = keys.target
	local ability =keys.ability
	caster.A20W_modifier_invisible_count=0
	if caster.a20w_refresh==nil then
		caster.a20w_refresh=true
		caster.A20W_modifier_invisible_count=0
	end
	--1.85
	--print("OnCreated(table)")

	
	if caster.A20W_timername then
		Timers:RemoveTimer(caster.A20W_timername)
	end
	caster.A20W_timername=Timers:CreateTimer(0, function ()

		--print("count")
      	if caster:FindModifierByName("modifier_A20W_self") and caster.A20W_modifier_invisible_count>14 then
      		--print("modifier_invisible")
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_A20W_transparent", {} )
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_invisible", {} )
			return nil
		end
		if not caster:FindModifierByName("modifier_A20W_self") and caster.A20W_modifier_invisible_count>14 then
			return nil
		end
		caster.A20W_modifier_invisible_count=caster.A20W_modifier_invisible_count+1
		return 0.1
    end)


end



function modifier_A20W_OnCreated( keys )

	local ability = keys.ability
	local caster = ability:GetCaster()
	local target = keys.target
	if target==caster then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A20W_self",{})
	end
end

function modifier_A20W_OnDestroy( keys )
	local ability = keys.ability
	local target = keys.target
	local caster = ability:GetCaster()
	if target==caster then
		caster:RemoveModifierByName("modifier_A20W_self")
		if caster:FindModifierByName("modifier_A20W_transparent") then
			caster:RemoveModifierByName("modifier_A20W_transparent")
			caster:RemoveModifierByName("modifier_invisible")
		end
	end
end



function modifier_A20W_aura_OnIntervalThink( keys )

	local caster = keys.caster
	local target = keys.target
	-- 持續提供視野
	local point = caster:GetAbsOrigin()
	local ifx = ParticleManager:CreateParticle( "particles/a20w/a20w_5.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,50))
	ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,50))
	AddFOWViewer(caster:GetTeamNumber(),caster:GetAbsOrigin(),700,5.0,false)
end



function A20E_OnSpellStart( keys )

	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local radius = ability:GetLevelSpecialValueFor("radius",level)
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  700 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for _, it in pairs(group) do
		if it:IsHero() then
			ParticleManager:CreateParticle("particles/shake1.vpcf", PATTACH_ABSORIGIN, it)
		end
		ability:ApplyDataDrivenModifier(caster,it,"modifier_A20E", nil)
		Timers:CreateTimer(5.9, function ()
			if IsValidEntity(it) and AMHC:IsAlive(it) == true and it:HasModifier("modifier_A20E") then
				print("stun")
				ability:ApplyDataDrivenModifier(it,it,"modifier_A20E_stun",{duration=0.7})
 	 		end
   		end)
	end
end


function modifier_A20R_OnAttackLanded( event )
	-- Variables
  --for i,v in pairs(event) do
     --   print(tostring(i).."="..tostring(v))
    --end
	local damage = event.DamageTaken
	local ability = event.ability
	local caster = event.caster
	local attacker= event.attacker
	local target= event.target
	if ability and not caster.a20r_lock then
		local crit_chance = ability:GetSpecialValueFor("chance")
		local rnd = RandomInt(1,100)
		if caster.A20R_count == nil then
			caster.A20R_count = 0
		end
		caster.A20R_count = caster.A20R_count + 1
		if crit_chance >= rnd then
		--if crit_chance >= rnd or caster.A20R_count > (100/crit_chance) then
			caster.a20r_lock=true
			--print("trigger")
			local casterLoc = caster:GetAbsOrigin()
			local targetLoc = -1*caster:GetForwardVector():Normalized()*100
			--local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
			local distance = 1600
			local radius =  400
			local collision_radius = 100
			local projectile_speed = 1000
			
			-- Find forward vector
			local forwardVec =  caster:GetAbsOrigin()-target:GetAbsOrigin()
			forwardVec = forwardVec:Normalized()
			
			-- Find backward vector
			local backwardVec = target:GetAbsOrigin()-caster:GetAbsOrigin()
			backwardVec = backwardVec:Normalized()
			
			-- Find middle point of the spawning line
			local middlePoint = casterLoc + ( distance * 0.5 * backwardVec )
			
			-- Find perpendicular vector
			local v = middlePoint - casterLoc
			local dx = -v.y
			local dy = v.x
			local perpendicularVec = Vector( dx, dy, v.z )
			perpendicularVec = perpendicularVec:Normalized()
			
			local sumtime = 0
			-- Create timer to spawn projectile
			Timers:CreateTimer( function()

				
					-- Get random location for projectile
					for c = 1,3 do
						local random_distance = RandomInt( -radius, radius )
						local spawn_location = middlePoint + perpendicularVec * random_distance
						
						local velocityVec = Vector( forwardVec.x, forwardVec.y, 0 )
						
						-- Spawn projectiles
						local projectileTable = {
							Ability = ability,
							EffectName = "particles/a20r/a20r.vpcf",
							vSpawnOrigin = spawn_location,
							fDistance = distance-200,
							fStartRadius = collision_radius,
							fEndRadius = collision_radius,
							Source = caster,
							bHasFrontalCone = false,
							bReplaceExisting = false,
							bProvidesVision = false,
							iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
							iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
							iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
							vVelocity = velocityVec * projectile_speed
						}
						ProjectileManager:CreateLinearProjectile( projectileTable )
					end
					-- Check if the number of machines have been reached
					if sumtime >1 then
						return nil
					else
						sumtime = sumtime + 0.3
						return 0.3
					end
				end
			)
		end
		Timers:CreateTimer(0.3, function ()
			caster.a20r_lock=nil
			return nil
   		end)
	end
end


function modifier_A20R_OnAttacked( event )
	-- Variables
  --for i,v in pairs(event) do
        --print(tostring(i).."="..tostring(v))
    --end
	local damage = event.DamageTaken
	local ability = event.ability
	local caster = event.caster
	local attacker= event.attacker
	local target= event.attacker
	if ability and not caster.a20r_lock then
		local crit_chance = ability:GetSpecialValueFor("chance")
		local rnd = RandomInt(1,100)
		if caster.A20R_count == nil then
			caster.A20R_count = 0
		end
		caster.A20R_count = caster.A20R_count + 1
		if crit_chance >= rnd  then
		--if crit_chance >= rnd or caster.A20R_count > (100/crit_chance) then
			caster.a20r_lock=true
			--print("trigger")
			local casterLoc = caster:GetAbsOrigin()
			local targetLoc = -1*caster:GetForwardVector():Normalized()*100
			--local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
			local distance = 1800
			local radius =  400
			local collision_radius = 100
			local projectile_speed = 1000
			
			-- Find forward vector
			local forwardVec =  caster:GetAbsOrigin()-target:GetAbsOrigin()
			forwardVec = forwardVec:Normalized()
			
			-- Find backward vector
			local backwardVec = target:GetAbsOrigin()-caster:GetAbsOrigin()
			backwardVec = backwardVec:Normalized()
			
			-- Find middle point of the spawning line
			local middlePoint = casterLoc + ( distance * 0.5 * backwardVec )
			
			-- Find perpendicular vector
			local v = middlePoint - casterLoc
			local dx = -v.y
			local dy = v.x
			local perpendicularVec = Vector( dx, dy, v.z )
			perpendicularVec = perpendicularVec:Normalized()
			
			local sumtime = 0
			-- Create timer to spawn projectile
			Timers:CreateTimer( function()

				
					-- Get random location for projectile
					for c = 1,3 do
						local random_distance = RandomInt( -radius, radius )
						local spawn_location = middlePoint + perpendicularVec * random_distance
						
						local velocityVec = Vector( forwardVec.x, forwardVec.y, 0 )
						
						-- Spawn projectiles
						local projectileTable = {
							Ability = ability,
							EffectName = "particles/a20r/a20r.vpcf",
							vSpawnOrigin = spawn_location,
							fDistance = distance-200,
							fStartRadius = collision_radius,
							fEndRadius = collision_radius,
							Source = caster,
							bHasFrontalCone = false,
							bReplaceExisting = false,
							bProvidesVision = false,
							iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
							iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
							iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
							vVelocity = velocityVec * projectile_speed
						}
						ProjectileManager:CreateLinearProjectile( projectileTable )
					end
					-- Check if the number of machines have been reached
					if sumtime > 1 then
						return nil
					else
						sumtime = sumtime + 0.3
						return 0.3
					end
				end
			)
		end
		Timers:CreateTimer(0.3, function ()
			caster.a20r_lock=nil
			return nil
   		end)
	end
end

function A20R_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              target:GetAbsOrigin(),
	                              nil,
	                              ability:GetSpecialValueFor( "splash_radius" ),
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) then
			if it:IsMagicImmune() then
				AMHC:Damage(caster,it, ability:GetSpecialValueFor( "damage")*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			else
				AMHC:Damage(caster,it, ability:GetSpecialValueFor( "damage"),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			end
		end
	end
end


LinkLuaModifier( "modifier_A20T_model", "scripts/vscripts/heroes/A_Oda/A20.lua",LUA_MODIFIER_MOTION_NONE )

modifier_A20T_model = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_A20T_model:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}

	return funcs
end

function modifier_A20T_model:GetModifierModelChange()
	return "models/heroes/tidehunter/tidehunter.vmdl"
end

function modifier_A20T_model:GetModifierModelScale()
	return 85
end

function modifier_A20T_model:IsHidden() 
	return false
end

function modifier_A20T_model:IsDebuff()
	return false
end


function modifier_A20T_model:IsPurgable()
	return false
end




function A20T_OnSpellStart( event )
	-- Variables
	local ability = event.ability
	local caster = event.caster
	local duration = ability:GetSpecialValueFor("During")
	--local ifx = ParticleManager:CreateParticle( "particles/c20r_real/c20r.vpcf", PATTACH_CUSTOMORIGIN, caster)
	--ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A20T_model", {duration=duration})
end


function A20W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local duration = ability:GetSpecialValueFor("A11W_duration")
	local radius = ability:GetSpecialValueFor("A11W_radius")
	local A11W_damage = ability:GetSpecialValueFor("A11W_damage")
	local A11W_adjustOnBuilding = ability:GetSpecialValueFor("A11W_adjustOnBuilding")

	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=duration} )
	ability:ApplyDataDrivenModifier( dummy, dummy, "modifier_A20W_old_aura", nil)
	dummy:SetOwner( caster)
	dummy:AddAbility( "majia"):SetLevel(1)

	local time = 0.1 + duration
	local count = 0
	local count2 = 0
	Timers:CreateTimer(0,function()
		count2 = count2 + 0.1
		if count2 > time then
			return nil
		end

		local ifx = ParticleManager:CreateParticle( "particles/a20/a20w_oldonkey_king_spring_water_base.vpcf", PATTACH_CUSTOMORIGIN, nil)
		local random=RandomVector(RandomInt(0,300))
		ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,50)+random)
		ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,50)+random)
		Timers:CreateTimer(duration, function ()
			ParticleManager:DestroyParticle(ifx,true)
		end)
		StartSoundEvent("Hero_Slark.Pounce.Impact",dummy)
		return 0.1
	end)
	Timers:CreateTimer(0,function()
		count = count + 0.5
		if count > time then
			return nil
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
		for _,unit in ipairs(units) do
			damageTable = {
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = A11W_damage,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			if not caster:IsAlive() then
				damageTable.attacker = dummy
			end
			if unit:IsBuilding() then
				damageTable.damage = damageTable.damage * A11W_adjustOnBuilding
			end
			ApplyDamage(damageTable)
		end
		return 0.5
	end)
end





function A20E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	--dummy:AddNewModifier( dummy, nil, "modifier_kill", {} )
	dummy:SetOwner( caster)
	dummy:AddAbility( "majia"):SetLevel(1)
	ability:ApplyDataDrivenModifier( dummy, dummy, "modifier_A20E_old_aura", nil)
	--ability:ApplyDataDrivenModifier( dummy, dummy, "modifier_A20E_old_aura_enemy", nil)
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=duration} )

end



function modifier_A20E_old_self_OnCreated( keys )

	local ability = keys.ability
	local caster = ability:GetCaster()
	local target = keys.target
	if target==caster then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A20E_self",{})
	end
end

function modifier_A20E_old_self_OnDestroy( keys )
	local ability = keys.ability
	local target = keys.target
	local caster = ability:GetCaster()
	if target==caster then
		caster:RemoveModifierByName("modifier_A20E_self")
	end
end



function modifier_A20E_old_aura_OnIntervalThink( keys )

	local caster = keys.caster
	local ability =keys.ability
	local target = keys.target
	-- 持續提供視野
	local point = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("radius")
	local ifx = ParticleManager:CreateParticle( "particles/a20w/a20w_2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,50))
	ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,50))
	AddFOWViewer(caster:GetTeamNumber(),caster:GetAbsOrigin(),700,5.0,false)
		local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES , 0, false)

	for _,enemy in pairs(group) do
		ability:ApplyDataDrivenModifier(caster, enemy,"modifier_A20E_2", {duration = 1})
	end

end

function A20T_old_OnIntervalThink( keys )
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
				caster:RemoveModifierByName(v:GetName())
			end
		end
	end
end
