
function C15W( keys )
	local caster = keys.caster
	local target = keys.target
	local mana = target:GetMana()
	local time = keys.ability:GetLevel() + 2
	target:SetMana(0)
	Timers:CreateTimer( time, function()
		target:SetMana(mana+target:GetMana())
		return nil
	end )
end

function C15E( keys )
	local caster = keys.caster
	local target = keys.target
	local heal = 200 + 100 * keys.ability:GetLevel()

	if caster == target then
		caster:Heal(heal,caster)
		--AMHC:CreateNumberEffect(caster,miss,2,AMHC.MSG_MISS ,"red",10)
		--PopupNumbers(target, "miss", Vector(255, 0, 0), 1.0, nil, POPUP_SYMBOL_PRE_MISS, nil ,true)
		AMHC:CreateNumberEffect(caster,heal,2,AMHC.MSG_HEAL,"green",0)
	else
		target:Heal(heal,caster)
		AMHC:CreateNumberEffect(target,heal,2,AMHC.MSG_HEAL,"green",0)
		caster:Heal(heal/2,caster)
		AMHC:CreateNumberEffect(caster,heal/2,2,AMHC.MSG_HEAL,"green",0)
	end
end

--[[
	Author: Noya
	Date: April 5, 2015.
	FURION CAN YOU TP TOP? FURION CAN YOU TP TOP? CAN YOU TP TOP? FURION CAN YOU TP TOP? 
]]
function Teleport( event )
	local caster = event.caster
	local ability = event.ability
	--local point = event.target_points[1]
	local point = event.target:GetAbsOrigin()
	
    FindClearSpaceForUnit(caster, point, true)
    caster:Stop() 
    EndTeleport(event)
    local units1 = FindUnitsInRadius(caster:GetTeamNumber(),	
				caster:GetAbsOrigin(),nil,500,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		0, 
				false) 	
	for _,unit in ipairs(units1) do
    	ability:ApplyDataDrivenModifier(caster,unit,"modifier_C19D2",nil)
    end
end

function CreateTeleportParticles( event )
	local caster = event.caster
	local point = event.target:GetAbsOrigin()
	local particleName = "particles/units/heroes/hero_furion/furion_teleport_end.vpcf"
	caster.teleportParticle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.teleportParticle, 1, point)	

	--紀錄單位
	caster.C15D_Target = event.target
end

function EndTeleport( event )
	local caster = event.caster
	local target = event.target
	ParticleManager:DestroyParticle(caster.teleportParticle, false)
	caster:StopSound("Hero_Furion.Teleport_Grow")

	--刪除buff
	if (caster.C15D_Target ~= nil) then
		caster.C15D_Target:RemoveModifierByName("modifier_C15D")
	end
end

function Teleport2( event )
	local caster = event.caster
	local point = event.target_points[1]
	local ability = event.ability
	
    FindClearSpaceForUnit(caster, point, true)
    caster:Stop() 
    EndTeleport(event)  
    local units1 = FindUnitsInRadius(caster:GetTeamNumber(),	
				caster:GetAbsOrigin(),nil,500,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		0, 
				false) 	
	for _,unit in ipairs(units1) do
    	ability:ApplyDataDrivenModifier(caster,unit,"modifier_C19R_old2",nil)
    end 
end

function CreateTeleportParticles2( event )
	local caster = event.caster
	local point = event.target_points[1]
	local particleName = "particles/units/heroes/hero_furion/furion_teleport_end.vpcf"
	
	local group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 1500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
  	
	for _,v in ipairs(group) do
		if v:GetUnitName() == "com_towera" then
			caster:Interrupt()
			break
		end
	end
	caster.teleportParticle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.teleportParticle, 1, point)
end

function C19W_old( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local spe_value = keys.ability:GetLevelSpecialValueFor("mana", keys.ability:GetLevel() - 1 )
	if not target:IsBuilding() then
	--【扣魔】
		if caster:GetMana() < spe_value then
			caster:CastAbilityToggle(ability,-1)		
			caster:SetMana(0)
		else
			caster:SetMana(caster:GetMana() - spe_value)
		end
	end
end


function C19E_old( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local level = keys.ability:GetLevel()
	local skillcount = 0
	AddFOWViewer(caster:GetTeamNumber(), point, 600, 6.0, false)
	local heal_value = keys.ability:GetLevelSpecialValueFor("healv", keys.ability:GetLevel() - 1 )
	--轉半徑
	local particle = ParticleManager:CreateParticle("particles/c19/c19e.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle,1,(point-caster:GetAbsOrigin()))
	Timers:CreateTimer(0, function()
		local group = FindUnitsInRadius(caster:GetTeamNumber(), point,
		nil,  500 , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

		for _, it in pairs(group) do
			it:Heal(heal_value,it)
		end
		if caster:IsChanneling() then
			caster:StartGesture( ACT_DOTA_CAST_ABILITY_1 )
			skillcount = skillcount + 1
			return 0.5
		else
			ParticleManager:DestroyParticle(particle, false)
			return nil
		end
	end)
end

function C19T_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_ninja_cloth") then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_ninja_cloth",nil)
	else
		local nc = caster:FindModifierByName("modifier_ninja_cloth")
		if nc:GetStackCount() < 1 then
			caster:RemoveModifierByName("modifier_ninja_cloth")
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_ninja_cloth",nil)
			nc = caster:FindModifierByName("modifier_ninja_cloth")
			nc:SetStackCount(1)
		end
	end
end


function C19T_OnOnCreated( keys )
	local caster = keys.caster
	local ability = keys.ability
	local nc = caster:FindModifierByName("modifier_ninja_cloth")
	nc:SetStackCount(1)
end

function C19T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_ninja_cloth")
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_ninja_cloth",nil)
	nc = caster:FindModifierByName("modifier_ninja_cloth")
	nc:SetStackCount(2)
	Timers:CreateTimer(20,function()
		nc:SetStackCount(1)
		end)
end