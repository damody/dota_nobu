
LinkLuaModifier( "A27R_critical", "scripts/vscripts/heroes/A_Oda/A27_Shibata_Katsuie.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "A27W_speed", "scripts/vscripts/heroes/A_Oda/A27_Shibata_Katsuie.lua",LUA_MODIFIER_MOTION_NONE )

A27W_speed = class({})

function A27W_speed:IsHidden()
	return false
end

function A27W_speed:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function A27W_speed:GetModifierAttackSpeedBonus_Constant( params)
	return 2000
end

function A27W_speed:CheckState()
	local state = {
	}
	return state
end

function A27W( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "A27W_Duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "A27W_attack", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

	local people = ability:GetLevel() + 1
	local eachAngle = 6.28 / people
	local illusion = {}
	local target_pos = {}
	local radius = 700
	local people = 1
	local origin_pos = caster:GetOrigin()
	caster:AddNewModifier(caster, nil, "modifier_invulnerable", {duration=0.5})

	for i=1,people do
			-- handle_UnitOwner needs to be nil, else it will crash the game.
			illusion[i] = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
			illusion[i]:SetOwner(caster)
			illusion[i]:SetControllableByPlayer(player, true)
			
			-- Level Up the unit to the casters level
			local casterLevel = caster:GetLevel()
			for j=1,casterLevel-1 do
				illusion[i]:HeroLevelUp(false)
			end

			-- Set the skill points to 0 and learn the skills of the caster
			illusion[i]:SetAbilityPoints(0)
			for abilitySlot=0,15 do
				local ability = illusion[i]:GetAbilityByIndex(abilitySlot)
				if ability ~= nil then 
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					local illusionAbility = illusion[i]:FindAbilityByName(abilityName)
					if (illusionAbility ~= nil) then
						illusion[i]:RemoveAbility(abilityName)
					end
				end
			end
			for abilitySlot=0,15 do
				local ability = caster:GetAbilityByIndex(abilitySlot)
				if ability ~= nil then 
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					illusion[i]:AddAbility(abilityName):SetLevel(abilityLevel)
				end
			end

			-- Recreate the items of the caster
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					local itemName = item:GetName()
					local newItem = CreateItem(itemName, illusion[i], illusion[i])
					illusion[i]:AddItem(newItem)
				end
			end
			-- Set the unit as an illusion
			-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
			illusion[i]:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })

			-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
			illusion[i]:MakeIllusion()

			illusion[i]:SetHealth(caster:GetHealth())
			--illusion[i]:SetRenderColor(255,0,255)

	end
	caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	for i=1,people do
		if IsValidEntity(illusion[i]) then
			illusion[i]:AddNewModifier(illusion[i],ability,"modifier_phased",{duration=0.1})
			local am = caster:FindAllModifiers()
			for _,v in pairs(am) do
				if IsValidEntity(v:GetCaster()) and IsValidEntity(v:GetAbility()) then
					if (not v:GetAbility():IsItem()) then
						v:GetAbility():ApplyDataDrivenModifier(illusion[i],illusion[i],v:GetName(),{duration=v:GetDuration()})
					end
				end
			end
		end
	end
end

function A27E(keys)
	--【Basic】
	local caster = keys.caster
	local targetLoc = keys.target_points[1]
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local cd = ability:GetLevelSpecialValueFor( "A27EE_cd", level - 1 )
	local radius = ability:GetLevelSpecialValueFor( "radius", level - 1 )

 	local player = caster:GetPlayerID()
 	local roubang = CreateUnitByName("a27_weapon",targetLoc ,false,caster,caster,caster:GetTeam())
 	AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 300, 3, true)
 	AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 300, 3, true)
	roubang:SetControllableByPlayer(player, true)
	roubang:SetBaseMaxHealth(600+level*300)
	roubang:SetHealth(roubang:GetMaxHealth())
	roubang:AddNewModifier(roubang,ability,"modifier_phased",{duration=0.1})
 	ability:ApplyDataDrivenModifier(roubang,roubang,"modifier_A27E",{duration = 20})
 	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A27EE",{duration = 20})
 	Timers:CreateTimer(0, function()
 		local units = FindUnitsInRadius(caster:GetTeamNumber(), targetLoc, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, FIND_ANY_ORDER, 0, false)
 		for i,unit in ipairs(units) do
			unit:SetHealth(unit:GetMaxHealth()*0.01*level + unit:GetHealth())
		end
		if roubang:IsAlive() then
			--print("roubang:IsAlive()"..radius)
			return 1
		else
			return nil
		end
 	end)
 	Timers:CreateTimer(cd, function()
 		local units = FindUnitsInRadius(caster:GetTeamNumber(), targetLoc, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, FIND_ANY_ORDER, 0, false)
 		for i,unit in ipairs(units) do
			if (not unit:HasModifier("modifier_A27EE")) then
				ability:ApplyDataDrivenModifier(unit,unit,"modifier_A27EE",{duration = 20})
				break
			end
		end
 		if roubang:IsAlive() then
			return cd
		else
			return nil
		end
 	end)
				
end


function A27E_dead(keys)
	local caster = keys.caster
	local dead_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_sphere_model.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(dead_effect, 0, caster:GetAbsOrigin())

	Timers:CreateTimer(0.5, function()
		local dead_effect2 = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_shockwave.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(dead_effect2, 0, caster:GetAbsOrigin() + Vector (0, 0, 100))
		end)
	caster:ForceKill(false)
	Timers:CreateTimer(1.5, function()
		if IsValidEntity(caster) then
			caster:Destroy()
		end
		end)
	local count = 0
	Timers:CreateTimer(function()
		count = count + 1
		caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector (0, 0, 10))
		if (count < 30) then
			return 0.05
		else
			return nil
		end
		end)
	
end


A27R_critical = class({})

function A27R_critical:IsHidden()
	return true
end

function A27R_critical:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function A27R_critical:GetModifierPreAttack_CriticalStrike()
	return self.A27R_level*50 + 150
end

function A27R_critical:CheckState()
	local state = {
	}
	return state
end


function A27R_Levelup( keys )
	local caster = keys.caster
	caster.A27R_noncrit_count = 0
			-- 	local particle = ParticleManager:CreateParticle("particles/A27r/A27r.vpcf", PATTACH_POINT, caster)
			-- ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_attack2", Vector(0,0,0), true)
end

function A27R( keys )
	local caster = keys.caster
	local ability = keys.ability
	local id  = caster:GetPlayerID()
	local ran =  RandomInt(0, 100)
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local crit = ability:GetLevelSpecialValueFor( "crit_persent", level - 1 )

	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > crit) then
			caster.A27R_noncrit_count = caster.A27R_noncrit_count + 1
		end
		if (caster.A27R_noncrit_count > (100/crit) or ran <= crit) then
			caster.A27R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			caster:AddNewModifier(caster, ability, "A27R_critical", { duration = 0.1 } )
			local hModifier = caster:FindModifierByNameAndCaster("A27R_critical", caster)
			--SE
			-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur_impact.vpcf", PATTACH_POINT, keys.target)
			-- ParticleManager:SetParticleControlEnt(particle, 0, keys.target, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
			--動作
				local rate = caster:GetAttackSpeed()
				--print(tostring(rate))

				--播放動畫
			    --caster:StartGesture( ACT_SLAM_TRIPMINE_ATTACH )
				if rate < 1 then
				    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
				else
				    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
				end

			if (hModifier ~= nil) then
				hModifier.A27R_level = keys.ability:GetLevel()
			end
		end
	end
end

function A27T( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = keys.target_points[1]
	local level = keys.ability:GetLevel()
	local hp = ability:GetLevelSpecialValueFor( "healthb", level - 1 )
	local ability = caster:FindAbilityByName("A27D")
	ability:SetLevel(1)
	ability:SetActivated(true)
	Timers:CreateTimer(0, function()
		if (not caster:HasModifier("modifier_A27T")) then
			ability:SetActivated(false)
			return nil
		end
		return 1
	end)
	caster:SetHealth(caster:GetHealth()+hp)
end

function A27D( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	AMHC:Damage(caster,keys.target, 1,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	ability:ApplyDataDrivenModifier(caster,target,"modifier_A27D",nil)
end

-- 11.2B
--------------------------------------------------------------

function A27R_old_crit_judgment( keys )
	local caster = keys.caster
	local ability = keys.ability
	local crit_chance = ability:GetLevelSpecialValueFor("crit_chance",ability:GetLevel()-1)

	if RandomInt(1,100)<=crit_chance then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A27R_old_critical_strike",nil)
	end
end

--[[
	Author: Noya
	Date: 18.01.2015.
	Creates Illusions, making use of the built in modifier_illusion

	Note: The positions weren't random in the original ability. Fix later
]]
--[[
	Author: Ractidous
	Date: 27.01.2015.
	Fixed the random spawn positions.
]]
function MirrorImage( event )
	local caster = event.caster
	local ability = event.ability
	local illusions_count = ability:GetLevelSpecialValueFor( "illusions_count", ability:GetLevel() - 1 )
	caster:AddNewModifier(caster, nil, "modifier_invulnerable", {duration=1})
	if illusions_count < 1 then
		return -- wtf
	end
	
	-- Stop any actions of the caster otherwise its obvious which unit is real
	caster:Stop()

	local center = caster:GetAbsOrigin()

	local pi = 3.14159
	local model_radius = ability:GetLevelSpecialValueFor("model_radius",ability:GetLevel()-1)
	local total = illusions_count+1
	local delta_theta = pi*2/total
	local spawn_radius = model_radius/math.sin(delta_theta*0.5)
	local start_theta = RandomFloat(0,2*pi)
	local real_index = RandomInt(0,illusions_count)
	local create_delay = ability:GetLevelSpecialValueFor("create_delay",ability:GetLevel()-1)
	-- Spawn illusions
	for i=0, illusions_count do
		local dx = spawn_radius * math.cos(start_theta+delta_theta*i)
		local dy = spawn_radius * math.sin(start_theta+delta_theta*i)
		-- 慢慢產生
		Timers:CreateTimer(i*create_delay, function()
			local spawn_point = center + Vector(dx,dy,0)
			if i == real_index then
				-- At first, move the main hero to one of the random spawn positions.
				FindClearSpaceForUnit(caster,spawn_point,true)
			else
				CreateMirror(caster,ability,spawn_point)
			end
		end)
	end
end

function CreateMirror( caster, ability, spawn_point )
	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(caster:GetUnitName(), spawn_point, true, caster, nil, caster:GetTeamNumber())

	local forword = caster:GetForwardVector()
	local player_id = caster:GetPlayerID()

	illusion:SetForwardVector(forword)
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)
		
	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)

	-- 清空鏡像的技能
	for abilitySlot=0,15 do
		local ability = illusion:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if illusionAbility ~= nil then
				illusion:RemoveAbility(abilityName)
			end
		end
	end

	-- 安裝技能至鏡像
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusion:AddAbility(abilityName):SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	local level = ability:GetLevel()-1
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", level )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", level )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", level )
	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and IsValidEntity(v:GetAbility()) then
			if (not v:GetAbility():IsItem()) then
				v:GetAbility():ApplyDataDrivenModifier(illusion,illusion,v:GetName(),{duration=v:GetDuration()})
			end
		end
	end
	-- Set the illusion hp to be the same as the caster
	illusion:SetHealth(caster:GetHealth())
	illusion:SetMana(caster:GetMana())
end