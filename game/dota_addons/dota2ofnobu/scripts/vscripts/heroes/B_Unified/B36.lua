--直江兼續

B36D_point=Vector(0,0,0)

function B36W_OnSpellStart( keys )
	local caster=keys.caster
	B36D_point = keys.target_points[1]
	local particle = ParticleManager:CreateParticle("particles/b36w/b36w.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, B36D_point+Vector(0,0,200))
	caster:FindAbilityByName("B36D"):SetLevel(1)
	caster:FindAbilityByName("B36D"):SetActivated(true)
	Timers:CreateTimer(5, function ()
		caster:FindAbilityByName("B36D"):SetActivated(false)
		ParticleManager:DestroyParticle(particle,true)
	end)
end


function B36W_DelayedAction( keys )
	local point = keys.target_points[1]
	local ability=keys.ability
	local caster = keys.caster            
	local particle = ParticleManager:CreateParticle("particles/econ/events/winter_major_2016/blink_dagger_start_sparkles_wm.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, point)
	local particle2= ParticleManager:CreateParticle("particles/econ/events/winter_major_2016/blink_dagger_start_sparkles_wm.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle2,0, point+Vector(-150,-150,0))
	local particle3= ParticleManager:CreateParticle("particles/econ/events/winter_major_2016/blink_dagger_start_sparkles_wm.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle3,0, point+Vector(150,-150,0))
	local particle4= ParticleManager:CreateParticle("particles/econ/events/winter_major_2016/blink_dagger_start_sparkles_wm.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle4,0, point+Vector(0,150,0))
	local targets=FindUnitsInRadius( caster:GetTeamNumber(), point, nil, ability:GetSpecialValueFor("radius"), 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for i,unit in pairs(targets) do
		local damageTable = {victim=unit,   
			attacker=caster,         
			damage=ability:GetSpecialValueFor("damage"),   
			damage_type=ability:GetAbilityDamageType()} 
		if not unit:IsMagicImmune() then
			ApplyDamage(damageTable)   
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_B36W",nil)
		end
	end

end


function B36D_OnSpellStart( keys )
	local caster = keys.caster
	caster:FindAbilityByName("B36D"):SetActivated(false)
	FindClearSpaceForUnit(caster,B36D_point,false)
end





function B36E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetSpecialValueFor("radius"),					-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
	local counter=0
	for _,unit in ipairs(units) do
		if unit ~= caster then
			counter=counter+1
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_B36E",nil)
		end
	end
	if counter ==0 then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_B36E_aromr",nil)
	end
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_B36E",nil)
end



function modifier_B36E_OnCreated( event )
	local unit = event.target
	local ability=event.ability
	local caster =ability:GetCaster()
	local max_damage_absorb = ability:GetSpecialValueFor("damage_absorb")+caster:GetMana()*ability:GetSpecialValueFor("addition_absord_mul_mana_percent")/100
	-- Reset the shield

	unit.AphoticShieldRemaining = max_damage_absorb

end

function modifier_B36E_OnTakeDamage( event )
	-- Variables
	local damage = event.DamageTaken
	local unit = event.unit
	local ability = event.ability
	local caster =ability:GetCaster()
	
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
		unit:RemoveModifierByName("modifier_B36E")
		--本尊噸爆掉移除護甲
		if unit == caster then
			unit:RemoveModifierByName("modifier_B36E_aromr")
		end
	end
end


function B36R_OnSpellStart( event )
	local ability = event.ability
	local caster = event.caster 
	local target =event.target
	local vec = caster:GetOrigin()
	local point = target:GetAbsOrigin()
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin()+Vector(0,30,0))
	local particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, target:GetAbsOrigin()+Vector(-30,-30,0))
	local particle3 = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle3, 0, target:GetAbsOrigin()+Vector(30,-30,0))
	local damageTable = {victim=target,   
			attacker=caster,         
			damage=ability:GetSpecialValueFor("B36R_damage")*caster:GetIntellect(),   
			damage_type=ability:GetAbilityDamageType()} 
	ApplyDamage(damageTable)   
	local knockbackProperties =
	{
		center_x = point.x,
		center_y = point.y,
		center_z = point.z,
		duration = ability:GetSpecialValueFor("B36R_flyTime"),
		knockback_duration = ability:GetSpecialValueFor("B36R_flyTime"),
		knockback_distance = 0,
		knockback_height = 500,
		should_stun = 1
	}
	target:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
end



function B36R_DelayedAction( keys )
	local caster = keys.caster            
	local target = keys.target
	local ability =keys.ability
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_blast.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
	local damageTable = {victim=target,   
		attacker=caster,         
		damage=target:GetHealthDeficit()*ability:GetSpecialValueFor("B36R_damage_on_ground")/100,   
		damage_type=keys.ability:GetAbilityDamageType()}   
		--print(keys.ability:GetLevelSpecialValueFor("A32W2_damage", al))
	ApplyDamage(damageTable)   
		--print("applystun")
end




function modifier_B36T_OnAttackLanded( event )
	local target = event.target
	local ability = event.ability
	local caster =ability:GetCaster()
	local damageTable = {victim=target,   
		attacker=caster,         
		damage=target:GetMaxHealth()*ability:GetSpecialValueFor("damage")/100,   
		damage_type=ability:GetAbilityDamageType()} 
	ApplyDamage(damageTable)   

end
