function B35R_OnToggleOn( event )
	local ability = event.ability
	local caster = event.caster
	caster.attackvoid = 1	
	Timers:CreateTimer(0.1,function()
		if caster.next_attack ~= nil then
			caster.next_attack.ability = ability
			--[[
			local targetArmor = caster.next_attack.victim:GetPhysicalArmorValue()
			local damageReduction = ((0.06 * targetArmor) / (1 + 0.06* targetArmor))
			caster.next_attack.damage = caster.next_attack.damage/(1-damageReduction)
			]]
			ApplyDamage(caster.next_attack)
			caster.next_attack = nil
		end
		return 0.1
		end)
end

function B35R_OnToggleOff( event )
	local ability = event.ability
	local caster = event.caster
	caster.attackvoid = nil	
end

function B35R_lock( keys )
	keys.ability:SetActivated(false)
end

function B35R_unlock( keys )
	keys.ability:SetActivated(true)
end

function Shock( keys )
	local caster = keys.caster
	if not caster:IsIllusion() then
		local target = keys.target
		local skill = keys.ability
		local ran =  RandomInt(0, 100)
		local dmg = keys.dmg
		--local dmg = ability:GetSpecialValueFor("dmg")
		if (caster.great_spear_of_dragonfly_count == nil) then
			caster.great_spear_of_dragonfly_count = 0
		end
		
		if (ran > 20) then
			caster.great_spear_of_dragonfly_count = caster.great_spear_of_dragonfly_count + 1
		end
		if (caster.great_spear_of_dragonfly_count > 5 or ran <= 20) then
			caster.great_spear_of_dragonfly_count = 0
			if (caster.great_spear_of_dragonfly == nil) then
				caster.great_spear_of_dragonfly = 1
				Timers:CreateTimer(0.1, function() 
						caster.great_spear_of_dragonfly = nil
					end)
				StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
				local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		                              target:GetAbsOrigin(),
		                              nil,
		                              250,
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
						if it:IsMagicImmune() then
							--AMHC:Damage(caster,it,"dmg",AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) ) 
							AMHC:Damage(target,it,"100",AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
						else
							--AMHC:Damage(caster,it,"dmg",AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
							AMHC:Damage(target,it,"100",AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
						end
					end
				end
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
			end
		end
	end
end


function B35T( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster.B35T = caster.B35T - 1
	if caster.B35T == 0 then
		caster:RemoveModifierByName("modifier_B35T")
	end
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
	print("caster.C21R", caster.C21R)
	if RandomInt(1,100)<=crit_chance or caster.C21R > 9 then
		local rate = caster:GetAttackSpeed()+0.1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_B35R2",{duration=rate})
		caster.C21R = 0
	end
end

function B35T_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()
	local damage_type = ability:GetAbilityDamageType()
	local play_time = ability:GetSpecialValueFor("play_time")
	print("B35T_old_OnSpellStart")
	caster:Stop()
	target:Stop()
	ApplyDamage({
		attacker=caster,
		victim=target,
		damage_type=damage_type,
		damage=1
	})

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_B35T_old_stunned",{duration=play_time+1})
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_B35T_old_playing",{duration=play_time})
	Timers:CreateTimer(0.15, function ()
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B35T_old_stunned",{duration=play_time+1})
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B35T_old_playing",{duration=play_time})
		end)
	ability:ApplyDataDrivenModifier(caster,target,"modifier_B35T_old_stunned",{duration=play_time+1})
	ability:ApplyDataDrivenModifier(caster,target,"modifier_B35T_old_playing",{duration=play_time})

	local arena = ParticleManager:CreateParticle("particles/B35/B35t_old_arena.vpcf",PATTACH_ABSORIGIN,target)

	local hit_num = 30
	local hit_delay = (play_time-0.5)/hit_num
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
			local attack_point = center_ori-dir*150+Vector(0,0,100+i*10)
			local cast_point = attack_point-Vector(0,0,100)
			caster:SetAbsOrigin(cast_point)
			caster:SetForwardVector(dir)
			target:SetForwardVector(-dir)
			local tar_pos = center
			tar_pos.z = center_ori.z + i*10
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
				activity=ACT_DOTA_CAST_ABILITY_2, 
				rate=4
			})
			local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_odds_hero_arrow_parent.vpcf",PATTACH_POINT,target)
			ParticleManager:SetParticleControl(ifx,0,center+dir*RandomFloat(0,100))
			ParticleManager:SetParticleControl(ifx,6,attack_point)
			ParticleManager:ReleaseParticleIndex(ifx)
			Timers:CreateTimer(0.1, function ()
				local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf",PATTACH_POINT,target)
				ParticleManager:SetParticleControlForward(ifx,0,dir)
				ParticleManager:SetParticleControl(ifx,1,center)
				ParticleManager:SetParticleControlForward(ifx,1,dir)
				ParticleManager:ReleaseParticleIndex(ifx)
			end)
		end)
	end

	Timers:CreateTimer(play_time-0.5,function ()
		local diff = center-caster:GetAbsOrigin()
		diff.z = 0
		caster:SetForwardVector( diff:Normalized() )
		-- 跳砍動畫
		StartAnimation(caster, {
			duration=0.5,
			activity=ACT_DOTA_ATTACK, 
			translate="duel_kill"
		})
		Timers:CreateTimer(0.5,function ()
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
		-- 命令攻擊
		ExecuteOrderFromTable({
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex(),
			Queue = false
		})
		caster:EmitSound( "B35T.end")
		target:SetAbsOrigin(center_ori)
		-- 延遲一個frame在移除暈眩狀態
		Timers:CreateTimer(0, function ()
			if IsValidEntity(caster) then caster:RemoveModifierByNameAndCaster("modifier_B35T_old_stunned",caster) end
			if IsValidEntity(target) then target:RemoveModifierByNameAndCaster("modifier_B35T_old_stunned",caster) end
		end)
	end)
end
