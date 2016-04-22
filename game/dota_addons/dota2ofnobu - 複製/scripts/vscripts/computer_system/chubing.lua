print ('[Nobu] chubing lua script Starting..' )

--用於記錄波數
ShuaGuai_bo=0

--紀錄出兵的兵量
GameRules.ShuaGuai_Of_Archer_num=2 --弓箭手
GameRules.ShuaGuai_Of_Walker_num=3 --武士
GameRules.ShuaGuai_Of_Cavalry_num=1 --騎兵
GameRules.ShuaGuai_Of_Gunner_num=2 --火槍兵

--紀錄出兵起始點、路徑 (必須要用計時器，初始化時物體還沒建造)
Timers:CreateTimer( 2.00, function()

	ShuaGuai_entity={Entities:FindByName(nil,"chubinluxian_location_of_nobu_button"),
				Entities:FindByName(nil,"chubinluxian_location_of_nobu_middle"),
				Entities:FindByName(nil,"chubinluxian_location_of_nobu_top"),
				Entities:FindByName(nil,"chubinluxian_location_of_wl_button"),
				Entities:FindByName(nil,"chubinluxian_location_of_wl_middle"),
				Entities:FindByName(nil,"chubinluxian_location_of_wl_top")
	}

		return nil
    end
)

function ShuaGuai( )

	--出兵觸發:武士+弓箭手
	--50秒出第一波，之後每26秒出一波
 	Timers:CreateTimer( 50.0, function()

	  		ShuaGuai_Of_A()

	      return 26.00
	    end
	)

	--出兵觸發:火槍兵
 	Timers:CreateTimer( 143.0, function()

  		ShuaGuai_Of_B()

	      return 143.00
	    end
	)

	--出兵觸發:騎兵
 	Timers:CreateTimer( 98.0, function()

  		ShuaGuai_Of_C()

	      return 98.00
	    end
	)


end

function ShuaGuai_Of_A( )
	print("[nobu]Run ShuaGuaiA")

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

		--武士	
		for k=1,GameRules.ShuaGuai_Of_Walker_num do

			--創建單位
			local unit = CreateUnitByName("com_ashigaru_spearmen", ent:GetAbsOrigin() , false, nil, nil, s)

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(true)

			--讓單位沿著設置好的路線開始行動
			unit:SetInitialGoalEntity(ent)

			--添加相位移動的modifier，持續時間0.2秒
			--當相位移動的modifier消失，系統會自動計算碰撞，這樣就避免了卡位
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.2})
		end	

		--弓箭手
		for k=1,GameRules.ShuaGuai_Of_Archer_num do
			--創建單位
			local unit = CreateUnitByName("com_archer", ent:GetAbsOrigin() , false, nil, nil, s)

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(true)

			--讓單位沿著設置好的路線開始行動
			unit:SetInitialGoalEntity(ent)

			--添加相位移動的modifier，持續時間0.2秒
			--當相位移動的modifier消失，系統會自動計算碰撞，這樣就避免了卡位
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.2})
		end	
	end	




end

function ShuaGuai_Of_B( )
	print("[nobu]Run ShuaGuaiB")

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

		for k=1,GameRules.ShuaGuai_Of_Gunner_num do

			--創建單位
			local unit = CreateUnitByName("com_gunner", ent:GetAbsOrigin() , false, nil, nil, s)

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(true)

			--讓單位沿著設置好的路線開始行動
			unit:SetInitialGoalEntity(ent)

			--添加相位移動的modifier，持續時間0.2秒
			--當相位移動的modifier消失，系統會自動計算碰撞，這樣就避免了卡位
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.2})
		end	
	end	
end

function ShuaGuai_Of_C( )
	print("[nobu]Run ShuaGuaiC")

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

		for k=1,GameRules.ShuaGuai_Of_Cavalry_num do

			--創建單位
			local unit = CreateUnitByName("com_cavalry", ent:GetAbsOrigin() , false, nil, nil, s)

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(true)

			--讓單位沿著設置好的路線開始行動
			unit:SetInitialGoalEntity(ent)

			--添加相位移動的modifier，持續時間0.2秒
			--當相位移動的modifier消失，系統會自動計算碰撞，這樣就避免了卡位
			unit:AddNewModifier(nil, nil, "modifier_phased", {duration=0.2})
		end	
	end	
end
