require('libraries/animations')

function B35E_OnSpellStart( keys )
	local ability = keys.ability
	local caster = keys.caster
	local targetpoint = keys.target_points[1]
	local dir=targetpoint-caster:GetAbsOrigin()
	caster:SetForwardVector(dir:Normalized())
	--local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local distance = 3000
	local radius =  400
	local collision_radius = 150
	local projectile_speed = 2000
	local projectileTable = {
			Ability = ability,
			EffectName =  "particles/b35/b35e.vpcf",
			vSpawnOrigin = caster:GetAbsOrigin(),
			fDistance = distance,
			fStartRadius = collision_radius,
			fEndRadius = collision_radius,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			bProvidesVision = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE,
			vVelocity = caster:GetForwardVector():Normalized() * projectile_speed
		}
	ProjectileManager:CreateLinearProjectile( projectileTable )
end

function B35E_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point =target:GetAbsOrigin()
	local ifx = ParticleManager:CreateParticle("particles/b35w2.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 1, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 2, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 4, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 5, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 6, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 20, point + Vector(0,0,100))

	Timers:CreateTimer(1, function ()
		ParticleManager:DestroyParticle(ifx,false)
	end)
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		target:GetAbsOrigin(),
		nil,
		500,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false)
	for _,it in pairs(direUnits) do
		if _G.EXCLUDE_TARGET_NAME[it:GetUnitName()] == nil then
			if it:IsMagicImmune() then
				ability:ApplyDataDrivenModifier(caster,it,"modifier_B35E", {})
			else
				ability:ApplyDataDrivenModifier(caster,it,"modifier_B35E", {})
				AMHC:Damage(caster,it, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
	end
end

function B35R_lock( keys )
	keys.ability:SetActivated(false)
end

function B35R_unlock( keys )
	keys.ability:SetActivated(true)
end

function B35R_OnAttacked( keys )
	local caster = keys.caster
	local ability = keys.ability
	local silence_time = ability:GetSpecialValueFor("silence_time")
	local heal = ability:GetSpecialValueFor("heal")
	if not caster:IsIllusion() then
		local target = keys.target
		local skill = keys.ability
		local ran =  RandomInt(0, 100)
		local dmg = keys.dmg
		--local dmg = ability:GetSpecialValueFor("dmg")
		if (caster.B35R_count == nil) then
			caster.B35R_count = 0
		end
		
		if (ran > 20) then
			caster.B35R_count = caster.B35R_count + 1
		end
		if (caster.B35R_count > 5 or ran <= 20) then
			caster.B35R_count = 0
			caster:Heal(heal,ability)
				StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
				local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		                              target:GetAbsOrigin(),
		                              nil,
		                              200,
		                              DOTA_UNIT_TARGET_TEAM_ENEMY,
		                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		                              FIND_ANY_ORDER,
		                              false)

			
				for _,it in pairs(direUnits) do
					if (not(it:IsBuilding())) then
						local flame = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_flames.vpcf", PATTACH_OVERHEAD_FOLLOW, it)
						Timers:CreateTimer(0.3, function ()
							ParticleManager:DestroyParticle(flame, false)
						end)
						ability:ApplyDataDrivenModifier(caster, it,"modifier_silence", {duration=silence_time})
						if it:IsMagicImmune() then
						else
							AMHC:Damage(target,it,ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
						end
					end
				end
				local rate = caster:GetAttackSpeed()
				caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK,2)
		end
	end
end

function B35T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:IsMagicImmune() then
		AMHC:Damage(caster,target,ability:GetAbilityDamage()*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	else
		AMHC:Damage(caster,target,ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
	caster:SetAbsOrigin(target:GetAbsOrigin())
	caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	local order = {UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()}
	ExecuteOrderFromTable(order)
end

function B35E_old_OnSpellStart( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local speed = ability:GetSpecialValueFor("B35E_speed")
	local dir = (point-center):Normalized()
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir
	end
	local fake_center = center - dir
	local distance = ability:GetSpecialValueFor("B35E_distance")
	local duration = distance/speed
	-- 把自己踢過去
	local knockbackProperties = {
	    center_x = fake_center.x,
	    center_y = fake_center.y,
	    center_z = fake_center.z,
	    duration = duration,
	    knockback_duration = duration,
	    knockback_distance = distance,
	    knockback_height = 0,
	    should_stun = 0,
	}
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_knockback",knockbackProperties)

	EmitSoundOn("Hero_Clinkz.WindWalk",caster)

	local projectileTable =
	{
		EffectName = "particles/item/dragon.vpcf",
		Ability = ability,
		vSpawnOrigin = center,
		vVelocity = dir * speed,
		fDistance = distance,
		fStartRadius = 175,
		fEndRadius = 175,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bProvidesVision = true,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	Timers:CreateTimer(0.1, function()
		ProjectileManager:CreateLinearProjectile(projectileTable)
		end)
	
end

function B35E_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:PerformAttack(keys.target, true, true, true, true, true, false, true)
end

function B35E_old_OnAttackLanded( keys )
	local caster = keys.caster
	local ability = keys.ability
	local handle = caster:FindAbilityByName("B35E_old")
	if handle then
		if not handle:IsCooldownReady() then
			local t = handle:GetCooldownTimeRemaining()
			handle:EndCooldown()
			handle:StartCooldown(t-ability:GetLevel()*0.5)
		end
	end
end

function B35R_old_OnAttackStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local crit_chance = ability:GetLevelSpecialValueFor("crit_chance",ability:GetLevel()-1)
	caster:RemoveModifierByName("modifier_B35R2")
	if caster.C21R == nil then
		caster.C21R = 0
	end
	caster.C21R = caster.C21R + 1
	if RandomInt(1,100)<=crit_chance or caster.C21R > 9 then
		local rate = caster:GetAttackSpeed()+0.1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_B35R2",{duration=rate})
		caster.C21R = 0
	end
end

function B35T_Copy(u, u2, ability)
	local  team  = u:GetTeamNumber()
	local  point = u:GetAbsOrigin()
	local  tu   = CreateUnitByName("B35T_SE",point,true,nil,nil,team)
	ability:ApplyDataDrivenModifier(tu, tu,"modifier_invulnerable", nil)
	ability:ApplyDataDrivenModifier(tu, tu,"modifier_B35T_old_stunned2", nil)
	-- --播放動畫(透明度50%,顏色要改金),隨機播放攻擊動作	
	--tu: SetRenderColor(255,255,122)
	-- call SetUnitTimeScale(u,3)
	-- call SetUnitAnimation(u,"Attack Slam")
	-- --紀錄特效單位在群組
	tu:SetForwardVector((u2:GetAbsOrigin()-point):Normalized())
	--tu:SetPlaybackRate(3)
    --播放動畫
    local count = 0
    Timers:CreateTimer(
    	function()
    		count = count + 1
    		if (tu:IsAlive()) then
    			tu:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_1, 1 )	
    		end
    		if (count > 25) then
    			tu:ForceKill(false)
                tu:Destroy()
    			return nil
    		else
    			return 0.2
    		end
    	end)
end

function B35T_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()
	local damage_type = ability:GetAbilityDamageType()
	local play_time = ability:GetSpecialValueFor("play_time")
	local direction = (target:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized()
	local spos = target:GetAbsOrigin() - direction * 400
	local epos = target:GetAbsOrigin() + direction * 400
	print("B35T_old_OnSpellStart")
	caster:Stop()
	target:Stop()
	ApplyDamage({
		attacker=caster,
		victim=target,
		damage_type=damage_type,
		damage=1
	})

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_B35T_old_stunned",{duration=play_time+2})
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_B35T_old_playing",{duration=play_time})
	Timers:CreateTimer(0.15, function ()
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B35T_old_stunned",{duration=play_time+2})
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B35T_old_playing",{duration=play_time})
		end)
	ability:ApplyDataDrivenModifier(caster,target,"modifier_B35T_old_stunned",{duration=play_time+2})
	ability:ApplyDataDrivenModifier(caster,target,"modifier_B35T_old_playing",{duration=play_time})

	local arena = ParticleManager:CreateParticle("particles/B35/B35t_old_arena.vpcf",PATTACH_ABSORIGIN,target)

	local hit_num = 30
	local hit_delay = (play_time-1.1)/hit_num
	local center = target:GetAbsOrigin()
	local center_ori = target:GetAbsOrigin()
	AddFOWViewer(caster:GetTeamNumber(),center,500,play_time,false)
	local maxrock = 12

	for i=1,hit_num-2 do
		Timers:CreateTimer((i-1)*hit_delay, function()
			local angle = ((360.0/maxrock)*i	)* bj_DEGTORAD
			local dx = math.cos(angle)
			local dy = math.sin(angle)
			local dir = Vector(dx,dy,0)
			local attack_point = center_ori-dir*150+Vector(0,0,100)
			local cast_point = attack_point-Vector(0,0,100)
			caster:SetAbsOrigin(cast_point)
			caster:SetForwardVector(dir)
			target:SetForwardVector(-dir)
			local tar_pos = center
			target:SetAbsOrigin(tar_pos)
			-- 失能動畫
			caster:EmitSound( "C01W.sound"..RandomInt(1, 3))
			StartAnimation(target, {
				duration=hit_delay-0.1,
				activity=ACT_DOTA_IDLE,
			})
			-- 攻擊動畫
			StartAnimation(caster, {
				duration=0.1,
				activity=ACT_DOTA_ATTACK, 
				rate=4
			})
			Timers:CreateTimer(0.1, function ()
				local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf",PATTACH_POINT,target)
				ParticleManager:SetParticleControlForward(ifx,0,dir)
				ParticleManager:SetParticleControl(ifx,1,center)
				ParticleManager:SetParticleControlForward(ifx,1,dir)
				ParticleManager:ReleaseParticleIndex(ifx)
			end)
		end)
	end

	Timers:CreateTimer(play_time-1.1,function ()
		caster:SetAbsOrigin(spos)
		local knockbackProperties =
		{
			center_x = epos.x,
			center_y = epos.y,
			center_z = epos.z,
			duration = 1,
			knockback_duration = 1,
			knockback_distance = -800,--負數往目標點移動
			knockback_height = 300,
			should_stun = 0
		}
		caster:SetForwardVector(direction)
		caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 1 )
		caster:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
		
		Timers:CreateTimer(1.1,function ()
			FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
			end)
	end)
	Timers:CreateTimer(play_time, function()
		ParticleManager:DestroyParticle(arena,false)
		-- 爆炸特效
		local ifx = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_apex/invoker_sun_strike_immortal1.vpcf",PATTACH_ABSORIGIN,target)
		ParticleManager:SetParticleControl(ifx,1,Vector(1))
		ParticleManager:ReleaseParticleIndex(ifx)
		target:RemoveModifierByNameAndCaster("modifier_B35T_old_playing",caster)
		
		ApplyDamage({
			attacker=caster,
			victim=target,
			damage_type=damage_type,
			damage=damage
		})
		caster:EmitSound( "B35T.end")
		

		-- 延遲一個frame在移除暈眩狀態
		Timers:CreateTimer(0, function ()
			if IsValidEntity(caster) then caster:RemoveModifierByNameAndCaster("modifier_B35T_old_stunned",caster) end
			if IsValidEntity(target) then target:RemoveModifierByNameAndCaster("modifier_B35T_old_stunned",caster) end
		end)
	end)

	local maxrock = 6
	local pointx2
	local pointy2
	local opoint = target:GetAbsOrigin()
	local pointx = opoint.x
	local pointy = opoint.y
	local pos = {}
	local dir = {}
	for i=1,maxrock do
		a	=	(	(360.0/maxrock)	*	i	)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	300 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	300 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)
		local direction = (opoint - point):Normalized()
		pos[i] = point
		dir[i] = direction
		--Timers:CreateTimer(0.1*i, function()
			caster:SetAbsOrigin(pos[i])
			B35T_Copy(caster, target, ability)
		--	end)
	end
end
