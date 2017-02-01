--林之卷


LinkLuaModifier( "modifier_transparency", "scripts/vscripts/items/Addon_Items/item_ninja_sword.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "forest_crit", "items/Addon_Items/item_forest_scroll.lua",LUA_MODIFIER_MOTION_NONE )
--野太刀


forest_crit = class({})

function forest_crit:IsHidden()
	return true
end

function forest_crit:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function forest_crit:GetModifierPreAttack_CriticalStrike()
	return 150
end

function forest_crit:CheckState()
	local state = {
	}
	return state
end



function forest_crit_Shock( keys )
	local caster = keys.caster
	local skill = keys.ability
	local ran =  RandomInt(0, 100)
	caster:RemoveModifierByName("forest_crit")
	if (caster.forest_crit_count == nil) then
		caster.forest_crit_count = 0
	end
	print("forest_crit_Shock")
	if (ran > 50) then
		caster.forest_crit_count = caster.forest_crit_count + 1
	end
	if (caster.forest_crit_count > 1 or ran <= 50) then
		caster.forest_crit_count = 0
		StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
		local rate = caster:GetAttackSpeed()
		caster:AddNewModifier(caster, skill, "forest_crit", { duration = rate+0.1 } )
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

	end

end


function dispear( keys )
	local caster = keys.caster
	if caster.nodispear == nil then
		caster:AddNewModifier(caster,ability,"modifier_transparency",{duration=2})
	end
end

function dispear2( keys )
	local caster = keys.caster
	caster:AddNewModifier(caster,ability,"modifier_transparency",{})
end

function nodispear( keys )
	local caster = keys.caster
	if caster.nodispear == nil then
		Timers:CreateTimer(0.5, function()
			caster.nodispear = caster.nodispear - 1
			if caster.nodispear < 0 then
				caster.nodispear = nil
				return nil
			end
			return 0.5
		end)
	end
	caster.nodispear = 2
end

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local monster1 = CreateUnitByName("forest_soldier1",caster:GetAbsOrigin()+caster:GetForwardVector()*100 ,false,caster,caster,caster:GetTeamNumber())
	monster1:SetControllableByPlayer(caster:GetPlayerID(),false)
	monster1:AddNewModifier(monster1,ability,"modifier_phased",{duration=0.1})
	monster1:FindAbilityByName("forest_soldier_W"):SetLevel(1)
	ability:ApplyDataDrivenModifier(monster1, monster1,"modifier_dead", {duration=30})
	caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	
	local monster2 = CreateUnitByName("forest_xcaster1",caster:GetAbsOrigin()+caster:GetForwardVector()*100 ,false,caster,caster,caster:GetTeamNumber())
	monster2:SetControllableByPlayer(caster:GetPlayerID(),false)
	monster2:FindAbilityByName("forest_caster_W"):SetLevel(1)
	monster2:AddNewModifier(monster2,ability,"modifier_phased",{duration=0.1})
	ability:ApplyDataDrivenModifier(monster2, monster2,"modifier_dead", {duration=30})
end

function Shock2( keys )
	local caster = keys.caster
	local ability = keys.ability
	for i=1,2 do
		local monster1 = CreateUnitByName("forest_soldier2",caster:GetAbsOrigin()+caster:GetForwardVector()*100 ,false,caster,caster,caster:GetTeamNumber())
		monster1:SetControllableByPlayer(caster:GetPlayerID(),false)
		monster1:AddNewModifier(monster1,ability,"modifier_phased",{duration=0.1})
		monster1:FindAbilityByName("forest_soldier_W"):SetLevel(2)
		monster1:FindAbilityByName("forest_soldier_E"):SetLevel(1)
		ability:ApplyDataDrivenModifier(monster1, monster1,"modifier_dead", {duration=30})
		caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	end
	local monster2 = CreateUnitByName("forest_xcaster2",caster:GetAbsOrigin()+caster:GetForwardVector()*100 ,false,caster,caster,caster:GetTeamNumber())
	monster2:SetControllableByPlayer(caster:GetPlayerID(),false)
	monster2:FindAbilityByName("forest_caster_W"):SetLevel(2)
	monster2:FindAbilityByName("forest_caster_E"):SetLevel(2)
	monster2:FindAbilityByName("forest_caster_R"):SetLevel(1)
	monster2:AddNewModifier(monster2,ability,"modifier_phased",{duration=0.1})
	ability:ApplyDataDrivenModifier(monster2, monster2,"modifier_dead", {duration=30})
end


function Shock3( keys )
	local caster = keys.caster
	local ability = keys.ability
	for i=1,3 do
		local monster1 = CreateUnitByName("forest_soldier3",caster:GetAbsOrigin()+caster:GetForwardVector()*200 ,false,caster,caster,caster:GetTeamNumber())
		monster1:SetControllableByPlayer(caster:GetPlayerID(),false)
		monster1:AddNewModifier(monster1,ability,"modifier_phased",{duration=0.1})
		monster1:FindAbilityByName("forest_soldier_W"):SetLevel(3)
		monster1:FindAbilityByName("forest_soldier_E"):SetLevel(1)
		monster1:FindAbilityByName("forest_soldier_R"):SetLevel(1)
		ability:ApplyDataDrivenModifier(monster1, monster1,"modifier_dead", {duration=30})
		caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	end
	local monster2 = CreateUnitByName("forest_xcaster3",caster:GetAbsOrigin()+caster:GetForwardVector()*200 ,false,caster,caster,caster:GetTeamNumber())
	monster2:SetControllableByPlayer(caster:GetPlayerID(),false)
	monster2:FindAbilityByName("forest_caster_W"):SetLevel(3)
	monster2:FindAbilityByName("forest_caster_E"):SetLevel(3)
	monster2:FindAbilityByName("forest_caster_R"):SetLevel(2)
	monster2:AddNewModifier(monster2,ability,"modifier_phased",{duration=0.1})
	ability:ApplyDataDrivenModifier(monster2, monster2,"modifier_dead", {duration=30})
end

function Shock4( keys )
	local caster = keys.caster
	local ability = keys.ability
	for i=1,4 do
		local monster1 = CreateUnitByName("forest_soldier4",caster:GetAbsOrigin()+caster:GetForwardVector()*300 ,false,caster,caster,caster:GetTeamNumber())
		monster1:SetControllableByPlayer(caster:GetPlayerID(),false)
		monster1:AddNewModifier(monster1,ability,"modifier_phased",{duration=0.1})
		monster1:FindAbilityByName("forest_soldier_W"):SetLevel(4)
		monster1:FindAbilityByName("forest_soldier_E"):SetLevel(1)
		monster1:FindAbilityByName("forest_soldier_R"):SetLevel(1)
		ability:ApplyDataDrivenModifier(monster1, monster1,"modifier_dead", {duration=30})
		caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	end
	local monster2 = CreateUnitByName("forest_xcaster4",caster:GetAbsOrigin()+caster:GetForwardVector()*300 ,false,caster,caster,caster:GetTeamNumber())
	monster2:SetControllableByPlayer(caster:GetPlayerID(),false)
	monster2:FindAbilityByName("forest_caster_W"):SetLevel(4)
	monster2:FindAbilityByName("forest_caster_E"):SetLevel(4)
	monster2:FindAbilityByName("forest_caster_R"):SetLevel(3)
	monster2:AddNewModifier(monster2,ability,"modifier_phased",{duration=0.1})
	ability:ApplyDataDrivenModifier(monster2, monster2,"modifier_dead", {duration=30})
end

function soldier1(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()

	--【Varible】
	--local duration = ability:GetLevelSpecialValueFor("duration",level)
	--local radius = ability:GetLevelSpecialValueFor("radius",level)
	local time = 2
	if target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_soldier_W", {duration = 0.5} )
	else
		ability:ApplyDataDrivenModifier( caster, target, "modifier_soldier_W", {duration = 1} )
	end

	for i=0,3 do
		local particle2 = ParticleManager:CreateParticle("particles/b02r3/b02r3.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle2,0, point2+Vector(0,0,i*40))
		ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
		ParticleManager:SetParticleControl(particle2,3, point2)	
		Timers:CreateTimer(1,function ()
			ParticleManager:DestroyParticle(particle2,true)
		end	)
	end
end


function Death(keys)
    keys.caster:ForceKill(false)
end
