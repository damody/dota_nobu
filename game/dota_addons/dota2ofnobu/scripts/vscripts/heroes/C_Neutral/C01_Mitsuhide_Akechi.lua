LinkLuaModifier( "C01R_critical", "scripts/vscripts/heroes/C_Neutral/C01_Mitsuhide_Akechi.lua",LUA_MODIFIER_MOTION_NONE )


C01R_critical = class({})

function C01R_critical:IsHidden()
	return true
end

function C01R_critical:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function C01R_critical:GetModifierPreAttack_CriticalStrike()
	return self.C01R_crit
end

function C01R_critical:CheckState()
	local state = {
	}
	return state
end

--global
	C01E_B = {}
	C01R_B = {}
--ednglobal

function C01W2( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:EmitSound( "C01W.sound"..RandomInt(1, 3) )
	local level = ability:GetLevel()-1
	local damage	= ability:GetLevelSpecialValueFor("C01W_DMG",level)
	local caster = keys.caster
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  400 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for _,enemy in pairs(group) do
		if enemy:IsMagicImmune() then
			AMHC:Damage(caster,enemy, damage*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		else
			AMHC:Damage(caster,enemy, damage,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end
end

function C01Wjump( keys )
	local caster = keys.caster
	local skill = keys.ability
	local rate = caster:GetAttackSpeed()
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
end

function C01W( keys )
	local caster = keys.caster
	local skill = keys.ability

	--判斷有沒有R技的modifier
	if caster:HasModifier("modifier_C01R_4") then

		local handle = caster:FindModifierByName("modifier_C01R_4")
		if handle then
			local c = handle:GetStackCount()-1
			if c > 0 then
				handle:SetStackCount(c)
			else
				caster:RemoveModifierByName("modifier_C01R_4")
			end
		end

		--給予攻速技能
		skill:ApplyDataDrivenModifier(caster, caster,"modifier_C01W_2",nil)

	end
end

function C01E_Mitsuhide_Akechi_Effect( keys, skillcount )
	local dmg = 0
	local SEARCH_RADIUS = 300
	local caster = keys.caster
	local point = keys.target_points[1] 
	local level = keys.ability:GetLevel()

	--判斷是不是第一波火焰
	if skillcount == 0 then
		dmg = 100 + 100 * level
	else
		dmg = 100 
	end
	AddFOWViewer(caster:GetTeamNumber(), point, 300.0, 3.0, false)

	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                              point,
                              nil,
                              SEARCH_RADIUS,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

	--effect:傷害+暈眩
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) then
			if it:IsHero() then
				ParticleManager:CreateParticle("particles/shake1.vpcf", PATTACH_ABSORIGIN, it)
			end
			AMHC:Damage(caster,it,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			if skillcount == 0 then
				keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_C01E", {duration=level*0.5})
			else
				keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_C01E", {duration=0.8})
			end
		end
	end

	--particle
	local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf",PATTACH_WORLDORIGIN,caster)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,1,Vector(5,5,5))
	ParticleManager:SetParticleControl(particle,3,point)
	ParticleManager:ReleaseParticleIndex(particle)

end




-- 傳入單位盡量統一名稱用keys
function C01E_Mitsuhide_Akechi( keys )
	local caster = keys.caster --unit
	local caster_abs = caster:GetAbsOrigin() -- vectorv
	local point = keys.target_points[1] 
	local time = 2
	local b = false --boolean
	local level = keys.ability:GetLevel()
	local skillcount = 0

	local dummy = CreateUnitByName("npc_dummy_unit_new",point,false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
	local ifx = ParticleManager:CreateParticleForTeam("particles/c01/c01e_aoe_hint.vpcf",PATTACH_ABSORIGIN,dummy, caster:GetTeamNumber())
	ParticleManager:ReleaseParticleIndex(ifx)
	
	--timer : 第一次火焰
    Timers:CreateTimer(time, function()
    	C01E_Mitsuhide_Akechi_Effect(keys, skillcount, caster,level,point)
        return nil -- 每秒再次调用
    end)

	--timer : 第二次火焰 時間+0.7
    Timers:CreateTimer(time + 0.7 , function()

    	if skillcount >= 3 then
        	return nil -- 每秒再次调用
        else
        	if caster:HasModifier("modifier_C01R_4") then
				local handle = caster:FindModifierByName("modifier_C01R_4")
				if handle then
					local c = handle:GetStackCount()-1
					if c > 0 then
						handle:SetStackCount(c)
					else
						caster:RemoveModifierByName("modifier_C01R_4")
					end
				end
        		skillcount = skillcount + 1
        		b 	= false

        		--效果
        		C01E_Mitsuhide_Akechi_Effect(keys, skillcount, caster,level,point)

        		return 0.7
        	else
        		return nil
    		end
        end

    end)

end


function C01R_OnIntervalThink( keys )
	local caster = keys.caster
	local skill = keys.ability
	if not caster:HasModifier("modifier_C01R_4") then
    	skill:ApplyDataDrivenModifier(caster,caster,"modifier_C01R_4",nil)
    	local handle = caster:FindModifierByName("modifier_C01R_4")
		if handle then
			handle:SetStackCount(1)
		end
    else
    	local handle = caster:FindModifierByName("modifier_C01R_4")
		local c = 1
		if handle then
			c = handle:GetStackCount()+1
			if c > 3 then
				c = 3
			end
			handle:SetStackCount(c)
		end
    end
end


function C01T_Mitsuhide_Akechi_Effect( keys, point )
	local dmg = 84
	local SEARCH_RADIUS = 240
	local caster = keys.caster
	local level = keys.ability:GetLevel()

	Timers:CreateTimer(0.45, function()
		local dummy = CreateUnitByName( "npc_dummy", point, false, caster, caster, caster:GetTeamNumber() )
		dummy:EmitSound( "C01T.sound" )
		Timers:CreateTimer( 0.5, function()
						dummy:ForceKill( true )
						return nil
					end
				)
		-- 砍樹
		GridNav:DestroyTreesAroundPoint(point, SEARCH_RADIUS, false)
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              point,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				if it:IsHero() then
					ParticleManager:CreateParticle("particles/shake1.vpcf", PATTACH_ABSORIGIN, it)
				end
				AMHC:Damage(caster,it,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_C01T",nil)
			else
				AMHC:Damage(caster,it,dmg*0.3,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		return nil
	end)


	--particle
	local chaos_meteor_fly_particle_effect = ParticleManager:CreateParticle("particles/invoker_chaos_meteor_fly2.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 0, point + Vector (1000, 0, 1000))
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 1, point)
	ParticleManager:SetParticleControl(chaos_meteor_fly_particle_effect, 2, Vector(0.5, 0, 0))

end


function C01T_Mitsuhide_Akechi( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local level = keys.ability:GetLevel()
	local skillcount = 0
	local skillmax = keys.ability:GetLevelSpecialValueFor("C01T_Amount",level-1)
	--大絕直徑
	local sk_radius = keys.ability:GetLevelSpecialValueFor("C01T_Radius",level-1)
	sk_radius = sk_radius + 100
	AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 6.0, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 6.0, false)
	--轉半徑
	sk_radius = sk_radius*0.5
	Timers:CreateTimer(0.1, function()
		AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 0.5, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 0.5, false)
		AddFOWViewer(caster:GetTeamNumber(), point, sk_radius+100, 0.5, false)
		if ( RandomInt(1, 10) > 3) then
			C01T_Mitsuhide_Akechi_Effect(keys, point + RandomVector(RandomInt(sk_radius*0.7, sk_radius)))
		else
			C01T_Mitsuhide_Akechi_Effect(keys, point + RandomVector(RandomInt(1, sk_radius*0.5)))
		end

		if  ( (skillcount < skillmax) and caster:IsChanneling() ) then
			skillcount = skillcount + 1
			return 0.1
		else
			return nil
		end
	end)
end


-- 11.2B
----------------------------------------------------------------------------------

function C01W_old_action_on_target( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:EmitSound( "C01W.sound"..RandomInt(1, 3) )
	local level = ability:GetLevel()-1
	local damage	= ability:GetLevelSpecialValueFor("aoe_damage",level)
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  400 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for _,enemy in pairs(group) do
		local ifx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_hit_blood.vpcf",PATTACH_POINT,enemy)
		ParticleManager:SetParticleControl(ifx,1,Vector((level+1)*1.5,0,0)) -- 出血量
		ParticleManager:SetParticleControl(ifx,2,Vector(0,0,1500)) -- 血液濺射方向與速度
		if enemy:IsMagicImmune() then
			AMHC:Damage(caster,enemy, damage*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		else
			AMHC:Damage(caster,enemy, damage,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end
end

function C01E_old_spell_start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local adjust_damage_at_building = ability:GetLevelSpecialValueFor("adjust_damage_at_building",level)
	local aoe_radius	= ability:GetLevelSpecialValueFor("aoe_radius",level)
	local max_wave		= ability:GetLevelSpecialValueFor("max_wave",level)
	local channelTime 	= ability:GetChannelTime()
	local aoe_damage 	= ability:GetAbilityDamage()
	local aoe_damage_type = ability:GetAbilityDamageType()
	local wave_delay 	= (channelTime-0.2)/(max_wave-1)

	-- 搜尋參數
	local iTeam = caster:GetTeamNumber()
	local center = keys.target_points[1]
	local tTeam = ability:GetAbilityTargetTeam()
	local tType = ability:GetAbilityTargetType()
	local tFlag = ability:GetAbilityTargetFlags()

	Timers:CreateTimer(0, function()
		-- 停止施法則中斷
		if not caster:IsChanneling() then
			return nil
		end
		AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 1, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 1, false)
		-- 照亮目標周圍
		AddFOWViewer(iTeam,center,aoe_radius*1.1,1.0,false)
		-- 搜尋敵人
		local units = FindUnitsInRadius(iTeam,center,nil,aoe_radius,tTeam,tType,tFlag,FIND_ANY_ORDER,false)
		for _,unit in ipairs(units) do
			local adjust = 1.0
			if unit:IsBuilding() then
				adjust = adjust_damage_at_building
			end
			-- 傷害參數
			local damage_table = {
				attacker = caster,
				victim = unit,
				damage = aoe_damage*adjust,
				damage_type = aoe_damage_type
			}
			-- 配合特效延遲傷害造成時間
			Timers:CreateTimer(0.5, function()
				ApplyDamage(damage_table)
				ability:ApplyDataDrivenModifier(caster,unit,"modifier_C01E_old_debuff",{})
			end)
		end
		-- 特效
		C01E_old_create_meteor_particle_effect(caster, center, aoe_radius)
		return wave_delay
	end)

	-- 配合特效延遲砍樹
	Timers:CreateTimer(0.45, function()
		GridNav:DestroyTreesAroundPoint(center, aoe_radius, false)
	end)
end

function C01E_old_create_meteor_particle_effect( caster, target_pos, radius )
	local caster_pos = caster:GetAbsOrigin()
	local ifx = ParticleManager:CreateParticle("particles/c01/c01e_old_fly.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(ifx, 0, caster_pos + Vector (0, 0, 1000)) -- 隕石產生的位置
	ParticleManager:SetParticleControl(ifx, 1, target_pos) -- 命中位置
	ParticleManager:SetParticleControl(ifx, 2, Vector(0.5, 0, 0)) -- 效果存活時間
end

function C01E_old_apply_debuff_damage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local debuff_damage = ability:GetLevelSpecialValueFor("debuff_damage",level)
	local adjust = 1.0

	if target:IsBuilding() then
		adjust = ability:GetLevelSpecialValueFor("adjust_damage_at_building",level)
	end

	ApplyDamage({
		attacker = caster,
		victim = target,
		damage = debuff_damage*adjust,
		damage_type = DAMAGE_TYPE_MAGICAL
	})
end

function C01R_old_on_attack_start( keys )
	local caster = keys.caster
	local target = keys.target
	local Damage = keys.Damage
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local chance = ability:GetLevelSpecialValueFor("chance",level)
	local damage_bonus = ability:GetLevelSpecialValueFor("damage_bonus",level)
	local ran =  RandomInt(0, 100)
	if caster.C01R_noncrit_count == nil then
		caster.C01R_noncrit_count = 0
	end
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > chance) then
			caster.C01R_noncrit_count = caster.C01R_noncrit_count + 1
		end
		if (caster.C01R_noncrit_count > 5 or ran <= chance) then
			caster.C01R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			caster:AddNewModifier(caster, ability, "C01R_critical", { duration = 0.1 } )
			local hModifier = caster:FindModifierByNameAndCaster("C01R_critical", caster)
			ParticleManager:CreateParticle("particles/c01/c01r_old_basher_cast.vpcf",PATTACH_POINT_FOLLOW,target)
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
				hModifier.C01R_crit = damage_bonus
			end
		end
	end
end



function C01R_on_attack_start( keys )
	local caster = keys.caster
	local target = keys.target
	local Damage = keys.Damage
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local chance = 18
	local damage_bonus = ability:GetLevelSpecialValueFor("C01R_Crit",level)
	local ran =  RandomInt(0, 100)
	if caster.C01R_noncrit_count == nil then
		caster.C01R_noncrit_count = 0
	end
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > chance) then
			caster.C01R_noncrit_count = caster.C01R_noncrit_count + 1
		end
		if (caster.C01R_noncrit_count > 5 or ran <= chance) then
			caster.C01R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			caster:AddNewModifier(caster, ability, "C01R_critical", { duration = 0.1 } )
			local hModifier = caster:FindModifierByNameAndCaster("C01R_critical", caster)
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
				hModifier.C01R_crit = damage_bonus
			end
		end
	end
end