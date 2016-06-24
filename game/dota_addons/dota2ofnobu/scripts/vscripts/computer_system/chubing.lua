--print ('[Nobu] chubing lua script Starting..' )

--[[
IDEA:
先把秒數用全局紀錄下來
	O可以作成動態管理出兵秒數
	O中路尋路用攻擊指令，不用自動尋路
BUG
	o問題超多
	O移動速度會莫名其妙lag
	O尋路系統效能耗超大
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
	ShuaGuai_entity={Entities:FindByName(nil,"chubinluxian_location_of_nobu_button"),
				Entities:FindByName(nil,"chubinluxian_location_of_nobu_middle"),
				Entities:FindByName(nil,"chubinluxian_location_of_nobu_top"),
				Entities:FindByName(nil,"chubinluxian_location_of_wl_button"),
				Entities:FindByName(nil,"chubinluxian_location_of_wl_middle"),
				Entities:FindByName(nil,"chubinluxian_location_of_wl_top")
	}
	ShuaGuai_entity_point={}
	ShuaGuai_entity_forvec={}
	for i=1,6 do
		ShuaGuai_entity_point[i] = ShuaGuai_entity[i]:GetAbsOrigin()
		--print(ShuaGuai_entity_point[i])
		ShuaGuai_entity_forvec[i] = ShuaGuai_entity[i]:GetForwardVector()
	end	
	return nil
end
)

function ShuaGuai( )

	--出兵觸發:武士+弓箭手
	--50秒出第一波，之後每26秒出一波
 	Timers:CreateTimer( 50, function()--50
	  	ShuaGuai_Of_A()
	    return 26 --26
	 end)

	--出兵觸發:火槍兵
 	Timers:CreateTimer( 143.0, function()
  		ShuaGuai_Of_B()
	    return 143.00
	end)

	--出兵觸發:騎兵
 	Timers:CreateTimer( 98.0, function()
  		ShuaGuai_Of_C()
	    return 98.00
	end)
end

function ShuaGuai_Of_A( )
	--print("[nobu]Run ShuaGuaiA")

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
				if i > 3 then team = 3 else team = 2 end			
				if tem_count > 3 then 
					unit_name = "com_archer" 
				else	 
					unit_name = "com_ashigaru_spearmen" 
				end
				--if tem_count > 3 then unit_name = "npc_dota_creep_goodguys_melee" else	 unit_name = "npc_dota_creep_badguys_melee" end

				--【武士 、 弓箭手】
				--創建單位
				local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[i] , true, nil, nil, team)

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

function ShuaGuai_Of_B( )
	--print("[nobu]Run ShuaGuaiB")

	for i=1,6 do --總共六個出發點
		--獲取物體位子
		local ent = ShuaGuai_entity[i]

		--DOTA_TEAM_GOODGUYS = 2
		--DOTA_TEAM_BADGUYS = 3
		--超過三的時候出兵變為聯合軍
		local s = 2	
		if i > 3 then
			s = 3			
		end

		for k=1,ShuaGuai_Of_Gunner_num do

			--創建單位
			local unit = CreateUnitByName("com_gunner", ent:GetAbsOrigin() , false, nil, nil, s)

			--禁止單位尋找最短路徑
			--unit:SetMustReachEachGoalEntity(true)

			--讓單位沿著設置好的路線開始行動
			unit:SetInitialGoalEntity(ent)

			--添加相位移動的modifier，持續時間0.2秒
			--當相位移動的modifier消失，系統會自動計算碰撞，這樣就避免了卡位
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.2})
		end	
	end	
end

function ShuaGuai_Of_C( )
	--print("[nobu]Run ShuaGuaiC")

	for i=1,6 do --總共六個出發點
		--獲取物體位子
		local ent = ShuaGuai_entity[i]

		--DOTA_TEAM_GOODGUYS = 2
		--DOTA_TEAM_BADGUYS = 3
		--超過三的時候出兵變為聯合軍
		local s = 2	
		if i > 3 then
			s = 3			
		end

		for k=1,ShuaGuai_Of_Cavalry_num do

			--創建單位
			local unit = CreateUnitByName("com_cavalry", ent:GetAbsOrigin() , false, nil, nil, s)

			--禁止單位尋找最短路徑
			--unit:SetMustReachEachGoalEntity(true)

			--讓單位沿著設置好的路線開始行動
			unit:SetInitialGoalEntity(ent)

			--添加相位移動的modifier，持續時間0.2秒
			--當相位移動的modifier消失，系統會自動計算碰撞，這樣就避免了卡位
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.2})
		end	
	end	
end
