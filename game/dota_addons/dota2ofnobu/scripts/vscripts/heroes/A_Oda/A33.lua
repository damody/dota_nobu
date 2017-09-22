-- 本多正信 by Jerry Yao
-- 2017.4.14

function A33W_OnSpellStart( keys )
	local caster = keys.caster
	caster.a33w_count=0
	caster.a33w_point=keys.target_points[1]
end

function modifier_A33W_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = caster.a33w_point
	local stunDuration = ability:GetSpecialValueFor("stun")
	local count = ability:GetSpecialValueFor("skeleton_number")
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),	
				point,nil,400,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		FIND_ANY_ORDER, 
				false) 
	caster.a33w_count=caster.a33w_count+1
	if caster.a33w_count <count+1 then
		for _,v in pairs(targets) do
			if not v:IsBuilding() then
				local damageTable = {victim=v,   
					attacker=caster,          
					damage=80,
					damage_type=keys.ability:GetAbilityDamageType()}
				if not v:IsMagicImmune() then
					ability:ApplyDataDrivenModifier( caster, v , "modifier_stunned", { duration = stunDuration } )
					ApplyDamage(damageTable)
				end
			end
		end

		local skeleton = CreateUnitByName("A33W_SKELETON", point + RandomVector(RandomInt(0,400)), true, nil, nil , caster:GetTeamNumber())
		skeleton:SetOwner(caster)
		skeleton:SetControllableByPlayer(caster:GetPlayerID(), true)
		skeleton:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})
		skeleton:AddNewModifier(caster,nil,"modifier_kill",{duration=50})
		ability:ApplyDataDrivenModifier( caster, skeleton , "modifier_A33W_skeleton", { duration = 50 } )
		skeleton:SetRenderColor(RandomInt(1,255),RandomInt(1,255),RandomInt(1,255))
	end
end

function modifier_A33W_OnChannelInterrupted( keys )
	if IsValidEntity(keys.caster) then
		if keys.caster:FindModifierByName("modifier_A33W") then
			keys.caster:RemoveModifierByName("modifier_A33W")
		end
	end
end


function A33E_OnSpellStart( keys )
	local caster = keys.caster
	caster.a33e_count=keys.ability:GetSpecialValueFor("count")
	Timers:CreateTimer(0.1, function ()
		local handle = caster:FindModifierByName("modifier_A33E2")
		if handle then
			handle:SetStackCount(caster.a33e_count+1)
		end
		end)
end


function modifier_A33E_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		local caster = event.caster
		local attacker= event.attacker
		if ability then
			local caster =ability:GetCaster() 
			if damage >= 50 and caster.a33e_count>0 and (attacker:IsBuilding() or attacker:IsHero()) then
				local newHealth = caster:GetHealth() + damage
				caster:SetHealth(newHealth)
				caster.a33e_count=caster.a33e_count-1
			elseif caster.a33e_count==0 and (attacker:IsBuilding() or attacker:IsHero()) then
				if caster:FindModifierByName("modifier_A33E") then
					caster:RemoveModifierByName("modifier_A33E")
					caster:RemoveModifierByName("modifier_A33E2")
				end
			end
			local handle = caster:FindModifierByName("modifier_A33E2")
			if handle then
				handle:SetStackCount(caster.a33e_count+1)
			end
		end
	end
end



function A33T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] == nil then
		if target:IsHero() then
			ability:ApplyDataDrivenModifier( caster, target, "modifier_A33T", { duration = 30 } )
		elseif not target:IsBuilding() and not target:IsHero() then
			ability:ApplyDataDrivenModifier( caster, target, "modifier_A33T", { duration = 60 } )
		end
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
		Timers:CreateTimer(0.2,function()
			local order = {UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()}
			ExecuteOrderFromTable(order)
			end)
	else
		ability:EndCooldown()
	end
end



function A33W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	target:IsBuilding()
	if target:IsHero() then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_A33T", { duration = 15 } )
	elseif not target:IsBuilding() and not target:IsHero() then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_A33T", { duration = 15 } )
	end
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
	Timers:CreateTimer(0.2,function()
		local order = {UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()}
		ExecuteOrderFromTable(order)
		end)
end




function A33E_old_OnSpellStart( keys )
	local caster = keys.caster             
	local ability = keys.ability
	local point =keys.target_points[1]
	caster.a33e_old_point=point
	local particle = ParticleManager:CreateParticle("particles/a33e_old/a33e_old.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, point)
	AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 300, 2, false)
    AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 300, 2, false)
end

function A33E_old_DelayedAction( keys )

	local caster = keys.caster             
	local ability = keys.ability
	local point =caster.a33e_old_point
	local radius = ability:GetSpecialValueFor("radius")
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),	
				point,nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		0, 
		   		FIND_ANY_ORDER, 
				false)

	for i,unit in pairs(targets) do
		--對目標傷害
		if not unit:IsBuilding() then
			local damageTable = {victim=unit,   
				attacker=caster,          
				damage=ability:GetSpecialValueFor("damage")*unit:GetMaxHealth()/100,
				damage_type=keys.ability:GetAbilityDamageType()}
			if not unit:IsMagicImmune() then
				ApplyDamage(damageTable)
			end
		end
	end
	GridNav:DestroyTreesAroundPoint(point, radius, false)
end


function A33T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local caster = keys.caster
	local point=keys.target_points[1]
	local count = ability:GetSpecialValueFor("skeleton_number")
	local particle = ParticleManager:CreateParticle("particles/a33t_old/a33t_old.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, point)
	local dummy = CreateUnitByName("npc_dummy_unit",point,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=14})
	dummy:SetOwner(caster)
	dummy:AddAbility("majia"):SetLevel(1)
	ability:ApplyDataDrivenModifier( caster, dummy , "modifier_A33T_old_aura", { duration = 14 } )
		
	for i=1,count do
		local skeleton = CreateUnitByName("A33T_old_SKELETON", point + RandomVector(RandomInt(0,200)), true, nil, nil , caster:GetTeamNumber())
		skeleton:SetOwner(caster)
		skeleton:SetControllableByPlayer(caster:GetPlayerID(), true)
		skeleton:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})
		ability:ApplyDataDrivenModifier( skeleton, skeleton , "modifier_A33T_old_skeleton", nil )
		skeleton:SetRenderColor(RandomInt(1,255),RandomInt(1,255),RandomInt(1,255))
	end
end



