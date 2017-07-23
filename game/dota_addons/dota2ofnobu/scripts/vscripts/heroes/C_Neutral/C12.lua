function C12D_OnSpellStart( keys )
	local ability = keys.ability
	local caster = ability:GetCaster()
	local target = keys.target
	ability:ApplyDataDrivenModifier(caster,target,"modifier_C12D_debuff",nil)
	caster.C12D_target = target
	target.C12D_count = 0
end

function C12D_OnUnitMoved( keys )
	local ability = keys.ability
	local caster = ability:GetCaster()
	local heroPosition = keys.unit:GetOrigin()
	if ability then
		local len = (caster:GetOrigin() - heroPosition):Length()
		if len > 1000 then
			keys.unit:RemoveModifierByName("modifier_C12D_debuff")
			caster.C12D_target = nil
			keys.unit.C12D_count = nil
		end
	end
end

function C12W_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	AMHC:Damage(caster,target,ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ))
	if target.C12D_count and math.mod(target.C12D_count, 2) == 0 then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = 1.5})
	end
	if target.C12D_count then
		AMHC:Damage(caster,target,ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ))
	end
	target:EmitSound("A17T.sound1")
end

function C12W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	if IsValidEntity(caster.C12D_target) and caster.C12D_target:HasModifier("modifier_C12D_debuff") then
			caster.C12D_target.C12D_count = caster.C12D_target.C12D_count + 1
			local split_shot_projectile = "particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf"
			local projectile_info = 
				{
					EffectName = split_shot_projectile,
					Ability = ability,
					vSpawnOrigin = caster:GetAbsOrigin(),
					Target = caster.C12D_target,
					Source = caster,
					bHasFrontalCone = false,
					iMoveSpeed = 1000,
					bReplaceExisting = false,
					bProvidesVision = false
				}
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		
	else
		if ability.aim_effect then
			ParticleManager:DestroyParticle(ability.aim_effect, true)
			ability.aim_effect = nil
		end
		caster.C12D_target = nil
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			caster:GetAbsOrigin(),			-- 搜尋的中心點
			nil,
			ability:GetCastRange(),			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)

		-- 處理搜尋結果
		local split_shot_projectile = "particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf"
			
		for _,unit in ipairs(units) do
			--基礎傷害
			local projectile_info = 
				{
					EffectName = split_shot_projectile,
					Ability = ability,
					vSpawnOrigin = caster:GetAbsOrigin(),
					Target = unit,
					Source = caster,
					bHasFrontalCone = false,
					iMoveSpeed = 1000,
					bReplaceExisting = false,
					bProvidesVision = false
				}
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end
end


function C12E_OnSpellStart(keys)
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
	local caster = keys.caster
	local ability = keys.ability
	local dummy = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin(),false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(nil,nil,"modifier_kill",{duration=5})
	local ifx = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, dummy)
	ParticleManager:ReleaseParticleIndex(ifx)
	EmitSoundOn("DOTA_Item.BlinkDagger.Activate", dummy)
	
	local origin_point = keys.caster:GetAbsOrigin()
	local target_point = caster:GetAbsOrigin() + caster:GetForwardVector()*600
	local difference_vector = target_point - origin_point
	
	if difference_vector:Length2D() > keys.MaxBlinkRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
		target_point = origin_point + (target_point - origin_point):Normalized() * keys.MaxBlinkRange
	end
	keys.caster:AddNewModifier(keys.caster,keys.ability,"modifier_phased",{duration=0.1})
	keys.caster:SetAbsOrigin(target_point)
	
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, keys.caster)
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		250,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
	if #units > 0 then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C12E",{duration = 10})
		local max_damage_absorb = caster:GetIntellect()*5
		local shield_size = 75 -- could be adjusted to model scale

		-- Reset the shield
		caster.AphoticShieldRemaining = max_damage_absorb


		caster.ShieldParticle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(caster.ShieldParticle, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 5, Vector(shield_size,0,0))

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(caster.ShieldParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end
end

function C12E_EndShieldParticle( event )
	local caster = event.caster
	local ability = event.ability
	ParticleManager:DestroyParticle(caster.ShieldParticle,false)
end

function C12R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local len = (caster:GetOrigin() - target:GetAbsOrigin()):Length()
	if len < 400 then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_invisible",{duration = 3})
	else
		local time = 3-((len-400)/100)*0.2
		if time < 0.8 then
			time = 0.8
		end
		ability:ApplyDataDrivenModifier(caster,target,"modifier_invisible",{duration = time})
	end
end


function C12T_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	
	local cs1	=	math.cos(20* bj_DEGTORAD)
	local sn1	=	math.sin(20* bj_DEGTORAD)
	local cs2	=	math.cos(-20* bj_DEGTORAD)
	local sn2	=	math.sin(-20* bj_DEGTORAD)
	local cs3	=	math.cos(10* bj_DEGTORAD)
	local sn3	=	math.sin(10* bj_DEGTORAD)
	local cs4	=	math.cos(-10* bj_DEGTORAD)
	local sn4	=	math.sin(-10* bj_DEGTORAD)
	
	
	local vec = caster:GetForwardVector()
	local projectileTable =
		{
			EffectName = "particles/c12/c12t_2/b08t.vpcf",
			Ability = ability,
			vSpawnOrigin = caster:GetAbsOrigin(),
			vVelocity = vec * 2000,
			fDistance = 2000,
			fStartRadius = 100,
			fEndRadius = 100,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_NONE 
		}
	local count = 0
	
	Timers:CreateTimer(0, function()
		local vec = caster:GetForwardVector()
		local pointx = vec.x
		local pointy = vec.y
		local pointx1 	=  pointx * cs1 - pointy * sn1
		local pointy1 	=  pointx * sn1 + pointy * cs1
		local pointx2 	=  pointx * cs2 - pointy * sn2
		local pointy2 	=  pointx * sn2 + pointy * cs2
		local pointx3 	=  pointx * cs3 - pointy * sn3
		local pointy3 	=  pointx * sn3 + pointy * cs3
		local pointx4 	=  pointx * cs4 - pointy * sn4
		local pointy4 	=  pointx * sn4 + pointy * cs4
			
		local vec1 = Vector(pointx1 ,pointy1 , 0)
		local vec2 = Vector(pointx2 ,pointy2 , 0)
		local vec3 = Vector(pointx3 ,pointy3 , 0)
		local vec4 = Vector(pointx4 ,pointy4 , 0)
		projectileTable.vSpawnOrigin = caster:GetAbsOrigin()
		projectileTable.vVelocity = vec1 * 2000
		ProjectileManager:CreateLinearProjectile(projectileTable)
		projectileTable.vVelocity = vec2 * 2000
		ProjectileManager:CreateLinearProjectile(projectileTable)
		projectileTable.vVelocity = vec3 * 2000
		ProjectileManager:CreateLinearProjectile(projectileTable)
		projectileTable.vVelocity = vec4 * 2000
		ProjectileManager:CreateLinearProjectile(projectileTable)
		if count < 5 and caster:IsAlive() then
			count = count + 1
			return 0.2
		end
		end)
	Timers:CreateTimer(1, function()
		local vec = caster:GetForwardVector()
		projectileTable.vSpawnOrigin = caster:GetAbsOrigin()
		projectileTable.vVelocity = vec * 2000
		ProjectileManager:CreateLinearProjectile(projectileTable)
		ProjectileManager:CreateLinearProjectile(projectileTable)
		if count < 29 and caster:IsAlive() then
			count = count + 1
			return 0.33
		end
		end)
end

function C12E_damage_check( event )
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
		unit:RemoveModifierByName("modifier_C12E")
		--爆炸
		local caster = event.caster
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_C12E_Boom",nil)
	end
end