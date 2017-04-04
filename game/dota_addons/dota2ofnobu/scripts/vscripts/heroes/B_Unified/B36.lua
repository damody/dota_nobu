--直江兼續
LinkLuaModifier("modifier_voodoo_lua", "heroes/modifier_voodoo_lua.lua", LUA_MODIFIER_MOTION_NONE)
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
		if unit ~= caster and unit:IsRealHero() then
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
	if IsServer() then
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
end


function B36R_OnSpellStart( event )
	local ability = event.ability
	local caster = event.caster
	
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
	for _,unit in pairs(units) do
		B36R_Dmage(event, unit)
	end
end

function B36R_Dmage( event, target )
	local ability = event.ability
	local caster = event.caster
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
			damage=ability:GetSpecialValueFor("B36R_damage"),
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
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap_blast.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
end

function B36R_DelayedAction( keys )
	local caster = keys.caster            
	local target = keys.target
	local ability =keys.ability
	
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
	if not target:IsBuilding() then
		local ability = event.ability
		local caster =ability:GetCaster()
		local damageTable = {victim=target,   
			attacker=caster,         
			damage=ability:GetSpecialValueFor("damage"),
			damage_type=ability:GetAbilityDamageType()}
		if target:IsMagicImmune() then
			damageTable.damage = damageTable.damage*0.5
		end
		ApplyDamage(damageTable)   
	end
end

-- 直江 11.2b

function B36W_old_OnSpellStart( keys )
	local caster=keys.caster
	local ability=keys.ability
	B36D_point = keys.target_points[1]
	local particle = ParticleManager:CreateParticle("particles/b36w/b36w.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, B36D_point+Vector(0,0,200))
	local dummy = CreateUnitByName("npc_dummy_unit",keys.target_points[1],false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=10})
	dummy:SetOwner(caster)
	dummy:AddAbility("majia_vison"):SetLevel(1)
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_B36W_old",nil)
	Timers:CreateTimer(10, function ()
		ParticleManager:DestroyParticle(particle,true)
	end)
end



function B36E_old_OnIntervalThink( keys )
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
	for _,unit in ipairs(units) do
		AMHC:Damage(caster,unit,ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
	units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetSpecialValueFor("radius2"),					-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
	if #units > 0 then
		local v = units[RandomInt(1,#units)]
		local split_shot_projectile = "particles/b36/b36e_old.vpcf"
		local projectile_info = 
			{
				EffectName = split_shot_projectile,
				Ability = ability,
				vSpawnOrigin = caster:GetAbsOrigin(),
				Target = v,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = 700,
				bReplaceExisting = false,
				bProvidesVision = false
			}
		ProjectileManager:CreateTrackingProjectile(projectile_info)
	end
end

function B36R_old_OnSpellStart(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local duration = ability:GetLevelSpecialValueFor("duration", ( ability:GetLevel() - 1 ))

	keys.target:AddNewModifier(caster, ability, "modifier_voodoo_lua", {duration = duration})
	ability:ApplyDataDrivenModifier(caster,target,"modifier_B36R",{duration = duration})
end

function B36T_old_OnSpellStart( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local ability = keys.ability
	local ice_count = ability:GetLevelSpecialValueFor("ice_count",0)
	local aoe_radius = ability:GetLevelSpecialValueFor("aoe_radius",0)

	local projectile_speed = 500

	local delta_theta = 3.14 * 2.0 / ice_count 
	for i=1,ice_count do
		local dx = math.cos(delta_theta*i)
		local dy = math.sin(delta_theta*i)

		-- Launch the projectile
		ProjectileManager:CreateLinearProjectile( {
			Ability				= ability,
			EffectName			= "particles/item/item_ice_book/ice.vpcf",
			vSpawnOrigin		= center+Vector(0,0,100),
			fDistance			= aoe_radius,
			fStartRadius		= 100,
			fEndRadius			= 100,
			Source				= caster,
			bHasFrontalCone		= false,
			bReplaceExisting	= false,
			iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
			iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
			iUnitTargetType		= ability:GetAbilityTargetType(),
			--fExpireTime			= GameRules:GetGameTime() + 2,
			bDeleteOnHit		= false,
			vVelocity			= Vector(dx * projectile_speed, dy * projectile_speed, 0),
			bProvidesVision		= false,
			--iVisionRadius		= travel_vision,
			--iVisionTeamNumber	= caster:GetTeamNumber(),
		} )
	end
end

