--print ('[Nobu-lua] chubing lua script Starting..' )
if _G.nobu_chubing_b then --"Nobu" then
	print("[Nobu-lua]".."_G.nobu_chubing_b")
	--[[
	IDEA:
		O先把秒數用全局紀錄下來，可以作成動態管理出兵秒數
		O中路尋路用攻擊指令，不用自動尋路
		O記得換足輕兩個單位
	BUG
		o問題超多
		O移動速度會莫名其妙lag --解決
		O尋路系統效能耗超大 --解決
	]]


	--用於記錄波數
	ShuaGuai_bo=0

	--紀錄出兵的兵量
	ShuaGuai_Of_Archer_num=2 --弓箭手
	ShuaGuai_Of_Walker_num=3 --武士
	ShuaGuai_Of_Cavalry_num=1 --騎兵
	ShuaGuai_Of_Gunner_num=2 --火槍兵

	--紀錄出兵起始點、路徑 (必須要用計時器，初始化時物體還沒建造)
	Timers:CreateTimer( 2.00, function()
		ShuaGuai_entity={
			Entities:FindByName(nil,"chubinluxian_location_of_nobu_button"),
			Entities:FindByName(nil,"chubinluxian_location_of_nobu_middle"),
			Entities:FindByName(nil,"chubinluxian_location_of_nobu_top"),
			Entities:FindByName(nil,"chubinluxian_location_of_wl_button"),
			Entities:FindByName(nil,"chubinluxian_location_of_wl_middle"),
			Entities:FindByName(nil,"chubinluxian_location_of_wl_top")
		}
		ShuaGuai_entity_point={} --誕生點
		ShuaGuai_entity_forvec={} --誕生方向
		for i=1,6 do
			ShuaGuai_entity_point[i] = ShuaGuai_entity[i]:GetAbsOrigin()
			--print(ShuaGuai_entity_point[i])
			ShuaGuai_entity_forvec[i] = ShuaGuai_entity[i]:GetForwardVector()
		end
		return nil
	end
	)

	function ShuaGuai( )
		--ShuaGuai_Of_A( )

		--出兵觸發:武士+弓箭手
		--50秒出第一波，之後每26秒出一波
		local speedup = 0.01
		local ShuaGuai_count = -1
	 	Timers:CreateTimer( function()--50
	 		ShuaGuai_count = ShuaGuai_count + 1
	 		--強化箭塔
	 		local allBuildings = Entities:FindAllByClassname('npc_dota_tower')
			for k, ent in pairs(allBuildings) do
			    if ent:IsTower() then
			    	ent:SetMaxHealth(ent:GetBaseMaxHealth()+ShuaGuai_count*10)
			    	ent:SetHealth(ent:GetHealth()+10)
			    	ent:SetBaseDamageMax(ent:GetBaseDamageMax() + 2)
			    	ent:SetBaseDamageMin(ent:GetBaseDamageMin() + 2)
			    	ent:SetPhysicalArmorBaseValue(ent:GetPhysicalArmorBaseValue() + 0.1)
				end
			end

		  	ShuaGuai_Of_A()
		  	
		    local time =  26.00 - 0.1*ShuaGuai_count
		    if time < 10 then
		    	return 10
		  	else
		  		return time
		  	end
		 end)

		--出兵觸發:火槍兵
	 	Timers:CreateTimer( 93,function()
	  		ShuaGuai_Of_B()
		    local time =  143.00 - 1*ShuaGuai_count
		    if time < 30 then
		    	return 30
		  	else
		  		return time
		  	end
		end)

		--出兵觸發:騎兵
	 	Timers:CreateTimer( 48, function()
	  		ShuaGuai_Of_C()
		    local time =  98.00 - 0.5*ShuaGuai_count
		    if time < 30 then
		    	return 20
		  	else
		  		return time
		  	end
		end)
	end

	local A_count = -1
	local B_count = -1
	local C_count = -1
	function ShuaGuai_Of_A( )
		--print("[Nobu-lua]Run ShuaGuaiA")
		A_count = A_count + 1
		local tem_count = 0
		--總共六個出發點 6
		local function ltt()
			tem_count = tem_count + 1
			if tem_count > 5 then return nil
			else
				for i=1,6 do
					--獲取物體位子
					-- local ent = ShuaGuai_entity[i]

					--DOTA_TEAM_GOODGUYS = 2
					--DOTA_TEAM_BADGUYS = 3
					--超過三的時候出兵變為聯合軍
					local team = nil
					local unit_name = nil
					if i > 3 then
						team = 3
					else
						team = 2
					end
					if tem_count > 3 then
						if team == 2 then
							unit_name = "com_archer"
						elseif team == 3 then
							unit_name = "com_archer_B"
						end
					else
						if team == 2 then
							unit_name = "com_ashigaru_spearmen"
						elseif team == 3 then
							unit_name = "com_ashigaru_spearmen_B"
						end
					end
					--if tem_count > 3 then unit_name = "npc_dota_creep_goodguys_melee" else	 unit_name = "npc_dota_creep_badguys_melee" end

					--【武士 、 弓箭手】
					--創建單位
					local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[i] , true, nil, nil, team)
					unit:AddAbility("set_level_1"):SetLevel(1)
					if string.match(unit_name, "ashigaru_spearmen") then
						local hp = unit:GetMaxHealth()
						unit:SetBaseMaxHealth(hp+A_count * 5)
						local dmgmax = unit:GetBaseDamageMax()
						local dmgmin = unit:GetBaseDamageMin()
						unit:SetBaseDamageMax(dmgmax+A_count*1)
						unit:SetBaseDamageMax(dmgmin+A_count*1)
						local armor = unit:GetPhysicalArmorBaseValue()
						unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
					else
						local hp = unit:GetMaxHealth()
						unit:SetBaseMaxHealth(hp+A_count * 3)
						local dmgmax = unit:GetBaseDamageMax()
						local dmgmin = unit:GetBaseDamageMin()
						unit:SetBaseDamageMax(dmgmax+A_count*2)
						unit:SetBaseDamageMax(dmgmin+A_count*2)
						local armor = unit:GetPhysicalArmorBaseValue()
						unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
					end
					--creep:SetContextNum("isshibing",1,0)

					--單位面向角度
					unit:SetForwardVector(ShuaGuai_entity_forvec[i])

					--禁止單位尋找最短路徑
					unit:SetMustReachEachGoalEntity(false)

					--顏色
					if team == 2 then
						unit:SetRenderColor(200,200,200)
					elseif team == 3 then
						--unit:SetRenderColor(0,200,0)
					end

					--讓單位沿著設置好的路線開始行動
					unit:SetInitialGoalEntity(ShuaGuai_entity[i])

					--碰撞面積
					--unit:SetHullRadius(40)

					--?
					--FindClearSpaceForUnit(unit,unit:GetAbsOrigin(), false)
				end
				return 0.5
			end
		end
		Timers:CreateTimer(ltt)
	end

	function ShuaGuai_Of_B( )
		local tem_count = 0
		B_count = B_count + 1
		--總共六個出發點 6
		local function ltt()
			tem_count = tem_count + 1
			if tem_count > 2 then return nil
			else
				for i=1,6 do
					--獲取物體位子
					-- local ent = ShuaGuai_entity[i]

					--DOTA_TEAM_GOODGUYS = 2
					--DOTA_TEAM_BADGUYS = 3
					--超過三的時候出兵變為聯合軍
					local team = nil
					local unit_name = nil
					if i > 3 then
						team = 3
					else
						team = 2
					end
					unit_name = "com_gunner"
					--if tem_count > 3 then unit_name = "npc_dota_creep_goodguys_melee" else	 unit_name = "npc_dota_creep_badguys_melee" end

					--【槍手】
					--創建單位
					local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[i] , true, nil, nil, team)
					unit:AddAbility("set_level_1"):SetLevel(1)
					local hp = unit:GetMaxHealth()
					unit:SetBaseMaxHealth(hp+A_count * 3)
					local dmgmax = unit:GetBaseDamageMax()
					local dmgmin = unit:GetBaseDamageMin()
					unit:SetBaseDamageMax(dmgmax+A_count*5)
					unit:SetBaseDamageMax(dmgmin+A_count*5)
					local armor = unit:GetPhysicalArmorBaseValue()
					unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
					--creep:SetContextNum("isshibing",1,0)

					--單位面向角度
					unit:SetForwardVector(ShuaGuai_entity_forvec[i])

					--禁止單位尋找最短路徑
					unit:SetMustReachEachGoalEntity(false)

					--讓單位沿著設置好的路線開始行動
					unit:SetInitialGoalEntity(ShuaGuai_entity[i])

					--碰撞面積
					--unit:SetHullRadius(40)

					--?
					--FindClearSpaceForUnit(unit,unit:GetAbsOrigin(), false)
				end
				return 0.5
			end
		end
		Timers:CreateTimer(ltt)
	end

	function ShuaGuai_Of_C( )
		local tem_count = 0
		C_count = C_count + 1
		--總共六個出發點 6
		local function ltt()
			tem_count = tem_count + 1
			if tem_count > 1 then return nil
			else
				for i=1,6 do
					--獲取物體位子
					-- local ent = ShuaGuai_entity[i]

					--DOTA_TEAM_GOODGUYS = 2
					--DOTA_TEAM_BADGUYS = 3
					--超過三的時候出兵變為聯合軍
					local team = nil
					local unit_name = nil
					if i > 3 then
						team = 3
					else
						team = 2
					end
					unit_name = "com_cavalry"
					--if tem_count > 3 then unit_name = "npc_dota_creep_goodguys_melee" else	 unit_name = "npc_dota_creep_badguys_melee" end

					--【騎兵】
					--創建單位
					local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[i] , true, nil, nil, team)
					
					local hp = unit:GetMaxHealth()
					unit:SetBaseMaxHealth(hp+A_count * 10)
					local dmgmax = unit:GetBaseDamageMax()
					local dmgmin = unit:GetBaseDamageMin()
					unit:SetBaseDamageMax(dmgmax+A_count*5)
					unit:SetBaseDamageMax(dmgmin+A_count*5)
					local armor = unit:GetPhysicalArmorBaseValue()
					unit:SetPhysicalArmorBaseValue(armor+A_count*0.2)
					--creep:SetContextNum("isshibing",1,0)

					--單位面向角度
					unit:SetForwardVector(ShuaGuai_entity_forvec[i])

					--禁止單位尋找最短路徑
					unit:SetMustReachEachGoalEntity(false)

					--讓單位沿著設置好的路線開始行動
					unit:SetInitialGoalEntity(ShuaGuai_entity[i])

					--碰撞面積
					--unit:SetHullRadius(40)

					--?
					--FindClearSpaceForUnit(unit,unit:GetAbsOrigin(), false)
				end
				return 0.5
			end
		end
		Timers:CreateTimer(ltt)
	end
end
