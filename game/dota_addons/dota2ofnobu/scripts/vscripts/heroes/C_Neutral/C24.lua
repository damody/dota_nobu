
function C24W_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = ability:GetAbilityDamage()
	local ifx = ParticleManager:CreateParticle("particles/c19e/c19e.vpcf",PATTACH_ABSORIGIN,target)
	ParticleManager:SetParticleControl(ifx,0,target:GetAbsOrigin())
	ParticleManager:SetParticleControl(ifx,1,target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(ifx)
	AMHC:Damage(caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	ability:ApplyDataDrivenModifier( caster, target, "modifier_rooted", {duration=0.5} )
end

function C24E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local center = caster:GetAbsOrigin()	
	local dir = (point-center):Normalized()
	local speed = 1500
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir
	end
	local fake_center = center - dir
	local distance = (point-center):Length()
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
	caster:RemoveGesture(ACT_DOTA_FLAIL)
	--caster:SetAbsOrigin(point)
	caster:AddNewModifier(caster,ability,"modifier_phased",{duration=duration+0.1})
	Timers:CreateTimer(duration,function()
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			point,			-- 搜尋的中心點
			nil,
			300,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in ipairs(units) do
			ability:ApplyDataDrivenModifier( caster, unit, "modifier_C24E_debuff", {} )
			local ifx = ParticleManager:CreateParticle("particles/c19e/c19e.vpcf",PATTACH_ABSORIGIN,unit)
			ParticleManager:SetParticleControl(ifx,0,unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(ifx,1,unit:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(ifx)
		end
	end)
end


function C24E_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stun_time = ability:GetSpecialValueFor("stime")
	if caster.C24E == nil then
		caster.C24E = 0
	end
	caster.C24E = caster.C24E + 1
	if caster.C24E >= 3 then
		caster.C24E = 0
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			caster:GetAbsOrigin(),			-- 搜尋的中心點
			nil,
			300,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false)
		for _,unit in ipairs(units) do
			if unit:IsMagicImmune() then
				ability:ApplyDataDrivenModifier( caster, unit, "modifier_stunned", {duration=stun_time*0.5} )
			else
				ability:ApplyDataDrivenModifier( caster, unit, "modifier_stunned", {duration=stun_time} )
			end
			AMHC:Damage(caster, unit, keys.dmg, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			local ifx = ParticleManager:CreateParticle("particles/c19e/c19e.vpcf",PATTACH_ABSORIGIN,unit)
			ParticleManager:SetParticleControl(ifx,0,unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(ifx,1,unit:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(ifx)
		end
	end
end

function C24T_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local regen = ability:GetSpecialValueFor("regen")*0.01
	caster:SetHealth(caster:GetHealth() + caster:GetMaxHealth()*regen)
	target:SetHealth(target:GetHealth() + target:GetMaxHealth()*regen)
	caster:SetAbsOrigin(target:GetAbsOrigin())
	caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.5})
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C24T",nil)
	ability:ApplyDataDrivenModifier(caster,target,"modifier_C24T",nil)
	local ifx = ParticleManager:CreateParticle("particles/c24/c24t.vpcf",PATTACH_ABSORIGIN,target)
	ParticleManager:ReleaseParticleIndex(ifx)
end

-- 11.2B

function C24W_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = ability:GetAbilityDamage()
	local ifx = ParticleManager:CreateParticle("particles/c19e/c19e.vpcf",PATTACH_ABSORIGIN,target)
	ParticleManager:SetParticleControl(ifx,0,target:GetAbsOrigin())
	ParticleManager:SetParticleControl(ifx,1,target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(ifx)
end


function C24E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local center = caster:GetAbsOrigin()	
	local dir = (point-center):Normalized()
	local speed = 2500
	point = center + dir*700
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir*700
	end
	local fake_center = center - dir
	local distance = (point-center):Length()
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
	caster:RemoveGesture(ACT_DOTA_FLAIL)
	--caster:SetAbsOrigin(point)
	caster:AddNewModifier(caster,ability,"modifier_phased",{duration=duration+0.1})
	
end

function C24E_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_C24E_old") then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C24E_old",nil)
		local handle = caster:FindModifierByName("modifier_C24E_old")
		if handle then
			handle:SetStackCount(1)
		end
	else
		local handle = caster:FindModifierByName("modifier_C24E_old")
		if handle then
			local c = handle:GetStackCount()
			c = c + 1
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_C24E_old",nil)
			handle:SetStackCount(c)
		end
	end
end

function C24R_old_OnAttackStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local crit_chance = ability:GetLevelSpecialValueFor("crit_chance",ability:GetLevel()-1)
	caster:RemoveModifierByName("modifier_C24R2_old")
	if caster.C21R_old == nil then
		caster.C21R_old = 0
	end
	caster.C21R_old = caster.C21R_old + 1
	print("caster.C21R_old", caster.C21R_old)
	if RandomInt(1,100)<=crit_chance or caster.C21R_old > 9 then
		local rate = caster:GetAttackSpeed()+0.1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C24R2_old",{duration=rate})
		caster.C21R_old = 0
	end
end

require('libraries/animations')

function C24T_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()
	local damage_type = ability:GetAbilityDamageType()
	local play_time = ability:GetSpecialValueFor("play_time")

	caster:Stop()
	target:Stop()
	ApplyDamage({
		attacker=caster,
		victim=target,
		damage_type=damage_type,
		damage=1
	})

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C24T_old_stunned",{duration=play_time+1})
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C24T_old_playing",{duration=play_time})
	Timers:CreateTimer(0.15, function ()
		ability:ApplyDataDrivenModifier(caster,target,"modifier_C24T_old_stunned",{duration=play_time+1})
		ability:ApplyDataDrivenModifier(caster,target,"modifier_C24T_old_playing",{duration=play_time})
		end)
	ability:ApplyDataDrivenModifier(caster,target,"modifier_C24T_old_stunned",{duration=play_time+1})
	ability:ApplyDataDrivenModifier(caster,target,"modifier_C24T_old_playing",{duration=play_time})

	local arena = ParticleManager:CreateParticle("particles/C24/C24t_old_arena.vpcf",PATTACH_ABSORIGIN,target)

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
		target:RemoveModifierByNameAndCaster("modifier_C24T_old_playing",caster)
		
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
		caster:EmitSound( "C24T.end")
		target:SetAbsOrigin(center_ori)
		-- 延遲一個frame在移除暈眩狀態
		Timers:CreateTimer(0, function ()
			if IsValidEntity(caster) then caster:RemoveModifierByNameAndCaster("modifier_C24T_old_stunned",caster) end
			if IsValidEntity(target) then target:RemoveModifierByNameAndCaster("modifier_C24T_old_stunned",caster) end
			local tsum = 0.1
			Timers:CreateTimer(0.0, function()
				if IsValidEntity(target) and not target:HasModifier("modifier_C24T_old_slow") then
					ability:ApplyDataDrivenModifier(caster,target,"modifier_C24T_old_slow",{duration = 7})
				end
				tsum = tsum + 0.1
				if tsum < 7 then
					return 0.1
				end
			end)
		end)
	end)
end
