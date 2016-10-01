
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
	AMHC:Damage( u,u2,110.0,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	AMHC:Damage( u,u2,u:GetAttackDamage(),AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )

	--發動攻擊	 
	local order_target = 
	{
		UnitIndex = u:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = u2:entindex()
	}

    --ExecuteOrderFromTable(order_target)

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

    --global set
    udg_C21T_Table[i]={}
	udg_C21T_Index[i] = 1
	udg_C21T_LV[i]  = keys.ability:GetLevel()--獲取技能等級

	--call function
	C21T_Effect(u,u2,i)

	--斬擊次數判斷
	if udg_C21T_LV[i] ==1 then
		ti=11
	elseif udg_C21T_LV[i] ==2 then
		ti=16
	elseif udg_C21T_LV[i] ==3 then
		ti=23
	end	

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
        local flags = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES 

        --獲取周圍的單位
        group = FindUnitsInRadius(u:GetTeamNumber(),point,nil,radius,teams,types,flags,FIND_ANY_ORDER,true)

        --如果元素大於0個單位才隨機抓取
        if #group > 0 and ti ~= 0 then
        	u2 = group[RandomInt(1,#group)]

        	--call function
			C21T_Copy(u,i, u2)
			C21T_Effect(u,u2,i)
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			return 0.1    
		else 

			--清理分身
			for ii,unit in pairs(udg_C21T_Table[i]) do

            	u:AddNewModifier(u,keys.ability,"modifier_phased",{duration=0.1})
                --刪除無敵
                u:RemoveModifierByName("modifier_C21T")

            end


			return nil 	
        end	

	end,0.5 )
end


function Trig_C21EActions(keys)
	local  u 	 = keys.caster --施法單位
	local  u2 	 = keys.target --目標單位
    local  id	 = u:GetPlayerID() --獲取玩家ID
    local  point = u:GetAbsOrigin() --獲取單位的座標
    local  point2 = u2:GetAbsOrigin() --獲取目標的座標
    local  time = keys.ability:GetLevel()--獲取技能等級
    keys.ability:ApplyDataDrivenModifier(u,u2,"modifier_C21EStun",{duration = 0.5})
    --timer2
    u:FindAbilityByName("C21W"):SetActivated(false)
	AMHC:Timer( "C21T_E1"..tostring(id),function( )

			if time == 0 or not(u2:IsAlive()) or not(u:IsAlive()) then
				--刪除無敵
                u:RemoveModifierByName("modifier_C21E")
                u:AddNewModifier(nil,nil,"modifier_phased",{duration=1})
                u:FindAbilityByName("C21W"):SetActivated(true)
				return nil 
			else
				u:AddNewModifier(nil,nil,"modifier_phased",{duration=1})
				point = u:GetAbsOrigin()
				local  x = point.x
				local  y = point.y
				point2 = u2:GetAbsOrigin()
				local  x2 	  = point2.x
				local  y2     = point2.y
				local  a      = bj_RADTODEG *math.atan2(y-y2,x-x2) + RandomInt(-90,90)

				--讓創造單位移動、轉向目標單位
				point3 = Vector(x2+100*math.cos(a*bj_DEGTORAD) ,  y2+100*math.sin(a*bj_DEGTORAD), point2.z)--需要Z軸 要不然會低於地圖
				u:SetOrigin(point3)
				u:SetForwardVector((point-point2):Normalized())


				--發動攻擊	 
				local order_target = 
				{
					UnitIndex = u:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = u2:entindex()
				}
		 
		        ExecuteOrderFromTable(order_target)

				--紀錄次數
				time = time - 1

				--閃爍的粒子特效
    			local p1 = ParticleManager:CreateParticle("particles/c19e/c19e.vpcf",PATTACH_ABSORIGIN,u2)
    			ParticleManager:ReleaseParticleIndex(p1)

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
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > 20) then
			caster.C21R_noncrit_count = caster.C21R_noncrit_count + 1
		end
		if (caster.C21R_noncrit_count > 2 or ran <= 40) then
			caster.C21R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			caster:AddNewModifier(caster, skill, "C21R_critical", { duration = 0.1 } )
			local hModifier = caster:FindModifierByNameAndCaster("C21R_critical", caster)
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
