
LinkLuaModifier( "C21R_critical", "scripts/vscripts/heroes/C_Neutral/C21_Miyamoto Musashi.lua",LUA_MODIFIER_MOTION_NONE )

--global
	udg_C21T_LV = {}
	udg_C21T_Table  = {}
	udg_C21T_Boolean = {}
	udg_C21T_Index = {}
	udg_C21T_LV = {}


	bj_PI                            = 3.14159
	bj_RADTODEG                      = 180.0/bj_PI
	bj_DEGTORAD                      = bj_PI/180.0
--ednglobal

function C21T_Effect(u,u2,i)
	if not IsValidEntity(u2) then return end
	local  r = 0
	local  point = u:GetAbsOrigin()
	local  x = point.x
	local  y = point.y
	local  point2 = u2:GetAbsOrigin()
	local  x2 	  = point2.x
	local  y2     = point2.y
	local  a      = bj_RADTODEG *math.atan2(y-y2,x-x2) + RandomInt(-90,90)
	local  SE_string =   "particles/c19t/c19t_3.vpcf" --"particles/c19t/c19t.vpcf"
	local  ANI_string = "c19_model_ani_attack"
	local  point3

	--particle

    --//閃爍的粒子特效
    local p1 = ParticleManager:CreateParticle(SE_string,PATTACH_ABSORIGIN,u)
    local p2 = ParticleManager:CreateParticle(SE_string,PATTACH_ABSORIGIN,u2)
	-- ParticleManager:SetParticleControl(p1,0,vec)               
	-- ParticleManager:SetParticleControl(p1,1,Vector(5,5,5))  
	-- ParticleManager:SetParticleControl(p1,3,vec)      
	-- ParticleManager:SetParticleControl( p2, 0, Vector(10,0,0))               --第2個參數為0時，Vector(x1,y1,z1)設置粒子的起始坐標
	-- ParticleManager:SetParticleControl( p2, 1, Vector(10,0,0))                --第2個參數為1時，Vector(x2,y2,z2)設置粒子的結束坐標
	-- ParticleManager:SetParticleControl( p2, 2, Vector(10,0,0))      --第2個參數為2時，Vector(v,0,0)設置粒子的發射速度，只有參數v有效。
	-- ParticleManager:SetParticleControl( p2, 3, Vector(10,0,0))  
	ParticleManager:ReleaseParticleIndex(p1)
	ParticleManager:ReleaseParticleIndex(p2)

	--讓創造單位移動、轉向目標單位
	point3 = Vector(x2+100*math.cos(a*bj_DEGTORAD) ,  y2+100*math.sin(a*bj_DEGTORAD), point2.z)--需要Z軸 要不然會低於地圖
	u:SetOrigin(point3)
	u:SetForwardVector((point-point2):Normalized())

	--傷害
	if not u2:IsMagicImmune() then
		AMHC:Damage( u,u2,125,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	else
		AMHC:Damage( u,u2,62,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
	if IsValidEntity(u2) then
		u:PerformAttack(u2, true, true, true, true, true, false, true)
	end

    --播放動畫
    u:StartGesture( ACT_DOTA_CAST_ABILITY_4 )	

end


function C21T_Copy(u,i, u2)
	local  team  = u:GetTeamNumber()
	local  point = u:GetAbsOrigin()
	local  tu   = CreateUnitByName("C21T_SE",point,true,nil,nil,team)

	-- --播放動畫(透明度50%,顏色要改金),隨機播放攻擊動作	
	--tu: SetRenderColor(255,255,122)
	-- call SetUnitTimeScale(u,3)
	-- call SetUnitAnimation(u,"Attack Slam")
	-- --紀錄特效單位在群組
	table.insert(udg_C21T_Table[i],tu)
	tu:SetForwardVector((u2:GetAbsOrigin()-point):Normalized())
    --播放動畫
    local count = 0
    Timers:CreateTimer(
    	function()
    		count = count + 1
    		if (tu:IsAlive()) then
    			tu:StartGesture( ACT_DOTA_ATTACK  )	
    		end
    		if (count > 4) then
    			tu:ForceKill(false)
                tu:Destroy()
    			return nil
    		else
    			return 0.4
    		end
    	end)

end

function Trig_C21TActions( keys )
	local  u 	 = keys.caster --施法單位
	local  u2 	 = keys.target --目標單位
    local  i 	 = u:GetPlayerID() --獲取玩家ID
    local  point = u:GetAbsOrigin() --獲取單位的座標
    local  point2 = u2:GetAbsOrigin() --獲取目標的座標
    local  ti 		= 0
    local ability = keys.ability

    --global set
    udg_C21T_Table[i]={}
	udg_C21T_Index[i] = 1
	udg_C21T_LV[i]  = keys.ability:GetLevel()--獲取技能等級

	--call function
	C21T_Effect(u,u2,i)

	--斬擊次數判斷
	ti = ability:GetSpecialValueFor("acount")

	--timer
	AMHC:Timer( "C21T_T1"..tostring(i),function( )
    	ti = ti - 1 
		--重新抓點的位子
		point = u:GetAbsOrigin()

	    --獲取攻擊範圍
	    local group = {}
        local radius = 400
        local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
        local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO     --+DOTA_UNIT_TARGET_BUILDING
        local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES 

        --獲取周圍的單位
        group = FindUnitsInRadius(u:GetTeamNumber(),point,nil,radius,teams,types,flags,FIND_ANY_ORDER,true)

        --如果元素大於0個單位才隨機抓取
        if #group > 0 and ti ~= 0 then
        	u2 = group[RandomInt(1,#group)]
        	if u2:HasModifier("modifier_majia") then
        		for _,xx in pairs(group) do
        			if u2:HasModifier("modifier_majia") then
        				u2 = xx
        				break
        			end
        		end
        	end
        	--call function
			C21T_Copy(u,i, u2)
			C21T_Effect(u,u2,i)
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			return 0.1    
		else 
			u:AddNewModifier(u,keys.ability,"modifier_phased",{duration=0.1})
            --刪除無敵
            u:RemoveModifierByName("modifier_C21T")
			return nil 	
        end	

	end,0.5 )
end


function C21E_OnSpellStart(keys)
	local  u 	 = keys.caster --施法單位
	local  u2 	 = keys.target --目標單位
    local  id	 = u:GetPlayerID() --獲取玩家ID
    local  point = u:GetAbsOrigin() --獲取單位的座標
    local  point2 = u2:GetAbsOrigin() --獲取目標的座標
    local  time = keys.ability:GetLevel()+1--獲取技能等級
    keys.ability:ApplyDataDrivenModifier(u,u2,"modifier_C21EStun",{duration = 0.5})
    --timer2
    u:FindAbilityByName("C21W"):SetActivated(false)
    Timers:CreateTimer(0.5*(time+1), function()
    	u:FindAbilityByName("C21W"):SetActivated(true)
    	end)
	AMHC:Timer( "C21T_E1"..tostring(id),function( )

			if time == 0 or not IsValidEntity(u2) or not(u2:IsAlive()) or not(u:IsAlive()) then
				--刪除無敵
                u:RemoveModifierByName("modifier_C21E")
                u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.5})

                local order_target = 
				{
					UnitIndex = u:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = u2:entindex(), Queue = false
				}
		 
		        ExecuteOrderFromTable(order_target)
				return nil 
			else
				u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.5})
				point = u:GetAbsOrigin()
				local  x = point.x
				local  y = point.y
				point2 = u2:GetAbsOrigin()
				local  x2 	  = point2.x
				local  y2     = point2.y
				local  a      = bj_RADTODEG *math.atan2(y-y2,x-x2) + RandomInt(-90,90)

				--讓創造單位移動、轉向目標單位
				point3 = Vector(x2+100*math.cos(a*bj_DEGTORAD) ,  y2+100*math.sin(a*bj_DEGTORAD), point2.z)--需要Z軸 要不然會低於地圖
				if (point3-point):Length2D() > 1500 then
					u:RemoveModifierByName("modifier_C21E")
                	u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.5})
                	return nil
                end
				u:SetOrigin(point3)
				u:SetForwardVector((point-point2):Normalized())


				--發動攻擊	 
				local order_target = 
				{
					UnitIndex = u:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = u2:entindex(), Queue = false
				}
		 		if IsValidEntity(u2) then
		        	ExecuteOrderFromTable(order_target)
		        end

				--紀錄次數
				time = time - 1

				--閃爍的粒子特效
				if IsValidEntity(u2) then
	    			local p1 = ParticleManager:CreateParticle("particles/c19e/c19e.vpcf",PATTACH_ABSORIGIN,u2)
	    			ParticleManager:ReleaseParticleIndex(p1)
	    		end

				return 0.5
			end	



		end,0.50 )
end


function Trig_C21WActions(keys)
	local caster = keys.caster --unit
	keys.ability:ApplyDataDrivenModifier(caster, caster,"modifier_C21W",nil)

	--debug
	GameRules: SendCustomMessage("Hello World",DOTA_TEAM_GOODGUYS,0)
end




--RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR

C21R_critical = class({})

function C21R_critical:IsHidden()
	return true
end

function C21R_critical:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function C21R_critical:GetModifierPreAttack_CriticalStrike()
	return self.C21R_level*20 + 130
end

function C21R_critical:CheckState()
	local state = {
	}
	return state
end


function C21R_Levelup( keys )
	local caster = keys.caster
	caster.C21R_noncrit_count = 0
			-- 	local particle = ParticleManager:CreateParticle("particles/C21R/C21R.vpcf", PATTACH_POINT, caster)
			-- ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_attack2", Vector(0,0,0), true)
end

function C21R( keys )
	local caster = keys.caster
	local skill = keys.ability
	local id  = caster:GetPlayerID()
	local ran =  RandomInt(0, 100)
	caster:RemoveModifierByName("C21R_critical")
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > 20) then
			caster.C21R_noncrit_count = caster.C21R_noncrit_count + 1
		end
		if (caster.C21R_noncrit_count > 2 or ran <= 40) then
			caster.C21R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			local rate = caster:GetAttackSpeed()
			caster:AddNewModifier(caster, skill, "C21R_critical", { duration = rate+0.1 } )
			local hModifier = caster:FindModifierByNameAndCaster("C21R_critical", caster)
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

			if (hModifier ~= nil) then
				hModifier.C21R_level = keys.ability:GetLevel()
			end
		end
	end
end

function BladeFuryStop( event )
	local caster = event.caster
	
	caster:StopSound("Hero_Juggernaut.BladeFuryStart")
end

-- 11.2B
---------------------------------------------------------------------------------------

function C21W_old_start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration",ability:GetLevel()-1)

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C21W_old",{duration=duration})
end

function C21W_old_apply_damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local aoe_radius = ability:GetLevelSpecialValueFor("aoe_radius",level)
	local aoe_damage = ability:GetAbilityDamage()

	local center = caster:GetAbsOrigin()
	local target_team = ability:GetAbilityTargetTeam()
	local target_type = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local damage_type = ability:GetAbilityDamageType()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係
                             center,			-- 搜尋的中心點
                             nil, 				-- 好像是優化用的參數不懂怎麼用
                             aoe_radius,		-- 搜尋半徑
                             target_team,		-- 目標隊伍
                             target_type,		-- 目標類型
                             target_flags,		-- 額外選擇或排除特定目標
                             FIND_ANY_ORDER,	-- 結果的排列方式
                             false) 			-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		-- 製造傷害
		local damage_table = {}
		damage_table.victim = unit
  		damage_table.attacker = caster					
 		damage_table.damage_type = damage_type
 		damage_table.damage = aoe_damage
		ApplyDamage(damage_table)		
	end

	if #units > 0 then
		EmitSoundOn("Hero_Juggernaut.BladeFury.Impact",caster)
	end
end

function C21E_old_start( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local attack_count = ability:GetLevelSpecialValueFor("attack_count",level)
	local attack_delay = ability:GetLevelSpecialValueFor("attack_delay",level)

	-- 安裝無敵修改器！
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C21E_old",{duration=attack_count*attack_delay})

	local counter = 0
	Timers:CreateTimer(0, function()
		counter = counter + 1

		-- 目標或施法者死亡則停止
		if not IsValidEntity(target) or not target:IsAlive() or not IsValidEntity(caster) or not caster:IsAlive() then
			caster:RemoveModifierByName("modifier_C21E_old")
			return nil
		end

		C21E_old_jump_attack(caster, target)

		-- 判斷是否結束追擊
		if counter >= attack_count then
			caster:RemoveModifierByName("modifier_C21E_old")
			return nil
		else	
			return attack_delay
		end
	end)
end

function C21E_old_jump_attack( caster, target )
	local radius = 100
	local theta = RandomFloat(0,3.14*2)
	local dx = radius * math.cos(theta)
	local dy = radius * math.sin(theta)
	local offset = Vector(dx,dy,0)

	-- 移至目標周圍
	FindClearSpaceForUnit(caster,target:GetAbsOrigin()+offset,true)

	-- 面向目標
	local dir = (target:GetAbsOrigin()-caster:GetAbsOrigin())
	dir.z = 0
	caster:SetForwardVector(dir:Normalized())

	-- 命令攻擊
	local order = { UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()}
	ExecuteOrderFromTable(order)

	local ifx = ParticleManager:CreateParticle("particles/c19e/c19e.vpcf",PATTACH_ABSORIGIN,target)
    ParticleManager:ReleaseParticleIndex(ifx)
end

function C21R_old_crit_judgment( keys )
	local caster = keys.caster
	local ability = keys.ability
	local crit_chance = ability:GetLevelSpecialValueFor("crit_chance",ability:GetLevel()-1)
	caster:RemoveModifierByName("modifier_C21R_old_critical_strike")
		
	if RandomInt(1,100)<=crit_chance then
		local rate = caster:GetAttackSpeed()+0.1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C21R_old_critical_strike",{duration=rate})
		if rate < 1 then
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
		else
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end
	end
end

C21T_OLD_STATE_GO_UP 	= 0
C21T_OLD_STATE_GO_DOWN 	= 1
C21T_OLD_STATE_END		= 2

function C21T_old_start( keys )
	local caster = keys.caster
	local ability = keys.ability

	local particle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_fallen/legion_fallen_press.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControlEnt(particle,1,caster,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
	caster.C21T_old_particle = particle
	local ifx = ParticleManager:CreateParticle("particles/econ/items/effigies/status_fx_effigies/base_statue_destruction_generic.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:ReleaseParticleIndex(ifx)

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C21T_old_on_move",nil)

	local unit = caster

	-- 讓單位能被物理Lib控制
	Physics:Unit(unit)

	-- 儲存預設值
	local friction = unit:GetPhysicsFriction()

	-- 改變基本設定
	unit:PreventDI(true) -- 阻斷玩家操作
	unit:SetAutoUnstuck(false) -- 取消自動移動至合法區
	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING) -- 無視碰撞
	unit:FollowNavMesh(false) -- 不跟隨Nav
	unit:SetPhysicsVelocityMax(10000)
	unit:SetPhysicsFriction(0)
	unit:Hibernate(false) -- 取消休眠(靜止不動的物體不會執行OnPhysicsFrame)
	unit:SetGroundBehavior(PHYSICS_GROUND_NOTHING) -- 不理會地面

	local veclocityFactor = 1000
	local begin_pos = caster:GetAbsOrigin()
	local end_pos = keys.target_points[1]
	local mid_pos = Vector(0,0,0)
	mid_pos.x = begin_pos.x * 0.8 + end_pos.x * 0.2
	mid_pos.y = begin_pos.y * 0.8 + end_pos.y * 0.2
	mid_pos.z = end_pos.z + 450

	local initSpeed = 6000
	local midSpeed = 3000
	local begin2mid = mid_pos-begin_pos
	local begin2mid_dir = begin2mid:Normalized()
	local begin2mid_length = begin2mid:Length()
	local mid2end = end_pos-mid_pos
	local mid2end_dir = mid2end:Normalized()
	local mid2end_length = mid2end:Length()

	AddFOWViewer(caster:GetTeamNumber(),mid_pos,3000.0,1.5,false)

	ability.state = C21T_OLD_STATE_GO_UP
	unit:OnPhysicsFrame(function(unit)
		local now_pos = unit:GetAbsOrigin()
		local now_velocity = unit:GetPhysicsVelocity()
		local now2end = end_pos - now_pos
		local now2mid = mid_pos - now_pos

		-- C21T_OLD_STATE_GO_UP
 		if ability.state == C21T_OLD_STATE_GO_UP then
 			local rate = now2mid:Length()/begin2mid_length
 			rate = rate * rate
 			unit:SetPhysicsVelocity(begin2mid_dir*initSpeed*rate)
 			if now_pos.z > mid_pos.z-50 then 
 				ability.state = C21T_OLD_STATE_GO_DOWN
 				caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
 			end
 		end

 		-- C21T_OLD_STATE_GO_DOWN
 		if ability.state == C21T_OLD_STATE_GO_DOWN then
 			unit:AddPhysicsAcceleration(mid2end_dir*midSpeed)
 			if now_pos.z < end_pos.z then
 				ability.state = C21T_OLD_STATE_END
 			end
 		end

 		-- C21T_OLD_STATE_END
 		if ability.state == C21T_OLD_STATE_END then
 			unit:SetPhysicsAcceleration(Vector(0,0,0))
    		unit:SetPhysicsVelocity(Vector(0,0,0))
    		unit:OnPhysicsFrame(nil)
    		unit:SetAbsOrigin(end_pos)

    		-- 還原基本設定
			unit:PreventDI(false) -- 阻斷玩家操作
			unit:SetAutoUnstuck(true) -- 取消自動移動至合法區
			unit:SetNavCollisionType(PHYSICS_NAV_SLIDE) -- 無視碰撞
			unit:FollowNavMesh(true) -- 不跟隨Nav
			unit:SetPhysicsVelocityMax(0)
			unit:SetPhysicsFriction(friction)
			-- unit:Hibernate(true) -- 這有點奇怪，理論上應該要設定回True可是這麼做之後物理就再也不會生效了，即使改回false也一樣
			unit:SetGroundBehavior(PHYSICS_GROUND_ABOVE) -- 不理會地面

    		-- caster:RemoveModifierByName("modifier_rooted")
    		caster:RemoveModifierByName("modifier_C21T_old_on_move")

    		local ifx = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_egset.vpcf",PATTACH_WORLDORIGIN,caster)
    		ParticleManager:SetParticleControl(ifx,0,end_pos)
    		ParticleManager:ReleaseParticleIndex(ifx)

    		local ifx = ParticleManager:CreateParticle("particles/econ/items/dragon_knight/dk_immortal_dragon/dragon_knight_dragon_tail_iron_dragon.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
    		ParticleManager:SetParticleControlEnt(ifx,2,caster,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
    		ParticleManager:SetParticleControlEnt(ifx,4,caster,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
    		ParticleManager:ReleaseParticleIndex(ifx)

    		ParticleManager:DestroyParticle(particle,false)

    		C21T_old_apply_damage(keys)
 		end
	end)

	Timers:CreateTimer(3, function ()
		if ability.state ~= C21T_OLD_STATE_END then
			ability.state = C21T_OLD_STATE_END
			unit:SetPhysicsAcceleration(Vector(0,0,0))
			unit:SetPhysicsVelocity(Vector(0,0,0))
			unit:OnPhysicsFrame(nil)
			unit:SetAbsOrigin(end_pos)

			-- 還原基本設定
			unit:PreventDI(false) -- 阻斷玩家操作
			unit:SetAutoUnstuck(true) -- 取消自動移動至合法區
			unit:SetNavCollisionType(PHYSICS_NAV_SLIDE) -- 無視碰撞
			unit:FollowNavMesh(true) -- 不跟隨Nav
			unit:SetPhysicsVelocityMax(0)
			unit:SetPhysicsFriction(friction)
			-- unit:Hibernate(true) -- 這有點奇怪，理論上應該要設定回True可是這麼做之後物理就再也不會生效了，即使改回false也一樣
			unit:SetGroundBehavior(PHYSICS_GROUND_ABOVE) -- 不理會地面

			-- caster:RemoveModifierByName("modifier_rooted")
			caster:RemoveModifierByName("modifier_C21T_old_on_move")

			local ifx = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_egset.vpcf",PATTACH_WORLDORIGIN,caster)
			ParticleManager:SetParticleControl(ifx,0,end_pos)
			ParticleManager:ReleaseParticleIndex(ifx)

			local ifx = ParticleManager:CreateParticle("particles/econ/items/dragon_knight/dk_immortal_dragon/dragon_knight_dragon_tail_iron_dragon.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
			ParticleManager:SetParticleControlEnt(ifx,2,caster,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
			ParticleManager:SetParticleControlEnt(ifx,4,caster,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
			ParticleManager:ReleaseParticleIndex(ifx)

			ParticleManager:DestroyParticle(particle,false)

			C21T_old_apply_damage(keys)
		end
		if caster:HasModifier("modifier_C21T_old_on_move") then
			caster:RemoveModifierByName("modifier_C21T_old_on_move")
			ParticleManager:DestroyParticle(particle,false)
		end
		end)

	local tm = caster:FindAllModifiers()
	
end

function C21T_old_apply_damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local aoe_radius = ability:GetLevelSpecialValueFor("aoe_radius",level)
	local aoe_damage = ability:GetAbilityDamage()

	local center = caster:GetAbsOrigin()
	local target_team = ability:GetAbilityTargetTeam()
	local target_type = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local damage_type = ability:GetAbilityDamageType()

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係
                              center,		-- 搜尋的中心點
                              nil, 				-- 好像是優化用的參數不懂怎麼用
                              aoe_radius,		-- 搜尋半徑
                              target_team,		-- 目標隊伍
                              target_type,		-- 目標類型
                              target_flags,		-- 額外選擇或排除特定目標
                              FIND_ANY_ORDER,	-- 結果的排列方式
                              false) 			-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do

		-- 製造傷害
		local damage_table = {}
		damage_table.victim = unit
		damage_table.attacker = caster					
		damage_table.damage_type = damage_type
		damage_table.damage = aoe_damage
		ApplyDamage(damage_table)
	end

	-- 砍樹
	GridNav:DestroyTreesAroundPoint(center, aoe_radius, false)
end