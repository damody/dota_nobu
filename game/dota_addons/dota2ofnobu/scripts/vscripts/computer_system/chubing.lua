--print ('[Nobu-lua] chubing lua script Starting..' )
--if _G.nobu_chubing_b then --"Nobu" then
print("[Nobu-lua] _G.nobu_chubing_b")
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
prestige = nil
payprestige = nil
Timers:CreateTimer(5, function()
		prestige = _G.prestige
		payprestige = _G.payprestige
	end)

--用於記錄波數
ShuaGuai_bo=0

--紀錄出兵的兵量
ShuaGuai_Of_Archer_num=2 --弓箭手
ShuaGuai_Of_Walker_num=3 --足輕
ShuaGuai_Of_Cavalry_num=1 --騎兵
ShuaGuai_Of_Gunner_num=2 --火槍兵

_G.A_count = -1
_G.B_count = -1
_G.C_count = -1

_G.team_broken = {}
_G.team_broken[2] = {}
_G.team_broken[2]["top"] = 0
_G.team_broken[2]["mid"] = 0
_G.team_broken[2]["down"] = 0
_G.team_broken[3] = {}
_G.team_broken[3]["top"] = 0
_G.team_broken[3]["mid"] = 0
_G.team_broken[3]["down"] = 0

--紀錄出兵起始點、路徑 (必須要用計時器，初始化時物體還沒建造)
Timers:CreateTimer( 2, function()
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
end)

-- 中路模式

function ShuaGuai( )
	--ShuaGuai_Of_A( )

	--出兵觸發:足輕+弓箭手
	--50秒出第一波，之後每26秒出一波
	local speedup = 0.01
	local ShuaGuai_count = -1
 	Timers:CreateTimer(60, function()--50
 		ShuaGuai_count = ShuaGuai_count + 1
 		--強化箭塔
 		local allBuildings = Entities:FindAllByClassname('npc_dota_tower')
		for k, ent in pairs(allBuildings) do
		    if ent:IsTower() then
		    	ent:SetMaxHealth(ent:GetBaseMaxHealth()+ShuaGuai_count*10)
		    	ent:SetHealth(ent:GetHealth()+10)
		    	ent:SetBaseDamageMax(ent:GetBaseDamageMax() + 4)
		    	ent:SetBaseDamageMin(ent:GetBaseDamageMin() + 4)
		    	ent:SetPhysicalArmorBaseValue(ent:GetPhysicalArmorBaseValue() + 0.5)
			end
		end
		local AA_num = 3 -- + 0.015*ShuaGuai_count
		local AB_num = 2 -- + 0.008*ShuaGuai_count
		if (AA_num > 4) then
			AA_num = 4
		end
		if (AB_num > 4) then
			AB_num = 4
		end
	  	ShuaGuai_Of_AA(AA_num)
	  	ShuaGuai_Of_AB(AB_num)
	  	
	    local time =  26 - 0.1*ShuaGuai_count
	    if _G.hardcore then 
	    	time = 30
	    end
	    if time < 20 then
	    	return 20
	  	else
	  		return time
	  	end
	 end)

	--出兵觸發:火槍兵
 	Timers:CreateTimer( 90,function()
 		local B_num = 2 -- + 0.003*ShuaGuai_count
 		if (B_num > 3) then
			B_num = 3
		end
  		ShuaGuai_Of_B(B_num)
	    local time =  100 - 0.5*ShuaGuai_count
	    if _G.hardcore then 
	    	time = 45
	    end
	    if time < 30 then
	    	return 30
	  	else
	  		return time
	  	end
	end)

	--出兵觸發:騎兵
 	Timers:CreateTimer( 95, function()
 		local C_num = 2 -- + 0.005*ShuaGuai_count
 		if (C_num > 3) then
			C_num = 3
		end
  		ShuaGuai_Of_C(C_num)
	    local time =  70 - 0.5*ShuaGuai_count
	    if _G.hardcore then 
	    	time = 45
	    end
	    if time < 30 then
	    	return 30
	  	else
	  		return time
	  	end
	end)
end


--【足輕】
function ShuaGuai_Of_AA(num)
	A_count = _G.A_count
	A_count = A_count + 1
	--print("A_count "..A_count)
	local tem_count = 0
	--總共六個出發點 6
	local randomkey = RandomInt(1,8)
	local function ltt()
		tem_count = tem_count + 1
		if tem_count > num then return nil
		else
			for i=1,6 do
				local go = false
				if _G.mo == nil then
					go = true
				elseif i==2 or i==5 then
					go = true
				end
				if go then
					--超過三的時候出兵變為聯合軍
					local team = nil
					local unit_name = nil
					if i > 3 then
						team = 3
					else
						team = 2
					end
					if team == 2 then
						unit_name = "com_infantry_oda_" .. randomkey
					elseif team == 3 then
						unit_name = "com_infantry_unified_" .. randomkey
					end
					--創建單位
					local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[i] , true, nil, nil, team)
					unit:AddAbility("set_level_1"):SetLevel(1)
					local hp = unit:GetMaxHealth()
					unit:SetBaseMaxHealth(hp+A_count * 8)
					local dmgmax = unit:GetBaseDamageMax()
					local dmgmin = unit:GetBaseDamageMin()
					unit:SetBaseDamageMax(dmgmax+A_count*1.5)
					unit:SetBaseDamageMax(dmgmin+A_count*1.5)
					local armor = unit:GetPhysicalArmorBaseValue()
					unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
					--creep:SetContextNum("isshibing",1,0)

					--單位面向角度
					unit:SetForwardVector(ShuaGuai_entity_forvec[i])

					--禁止單位尋找最短路徑
					unit:SetMustReachEachGoalEntity(false)

					--顏色
					if team == 2 then
						----unit:SetRenderColor(255,100,100)
					elseif team == 3 then
						----unit:SetRenderColor(100,255,100)
					end

					--讓單位沿著設置好的路線開始行動
					unit:SetInitialGoalEntity(ShuaGuai_entity[i])
				end
			end
			return 0.5
		end
	end
	Timers:CreateTimer(ltt)
end
--【弓箭手】
function ShuaGuai_Of_AB(num)
	A_count = _G.A_count
	local tem_count = 0
	--總共六個出發點 6
	local randomkey = RandomInt(1,8)
	local function ltt()
		tem_count = tem_count + 1
		if tem_count > num then return nil
		else
			for i=1,6 do
				local go = false
				if _G.mo == nil then
					go = true
				elseif i==2 or i==5 then
					go = true
				end
				if go then
					--超過三的時候出兵變為聯合軍
					local team = nil
					local unit_name = nil
					if i > 3 then
						team = 3
					else
						team = 2
					end
					if team == 2 then
						unit_name = "com_archer_oda_" .. randomkey
					elseif team == 3 then
						unit_name = "com_archer_unified_" .. randomkey
					end

					
					--創建單位
					local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[i] , true, nil, nil, team)
					unit:AddAbility("set_level_1"):SetLevel(1)
					
					local hp = unit:GetMaxHealth()
					unit:SetBaseMaxHealth(hp+A_count * 5)
					local dmgmax = unit:GetBaseDamageMax()
					local dmgmin = unit:GetBaseDamageMin()
					unit:SetBaseDamageMax(dmgmax+A_count*5)
					unit:SetBaseDamageMax(dmgmin+A_count*5)
					local armor = unit:GetPhysicalArmorBaseValue()
					unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
					--creep:SetContextNum("isshibing",1,0)

					--單位面向角度
					unit:SetForwardVector(ShuaGuai_entity_forvec[i])

					--禁止單位尋找最短路徑
					unit:SetMustReachEachGoalEntity(false)

					--顏色
					if team == 2 then
						----unit:SetRenderColor(255,100,100)
					elseif team == 3 then
						----unit:SetRenderColor(100,255,100)
					end

					--讓單位沿著設置好的路線開始行動
					unit:SetInitialGoalEntity(ShuaGuai_entity[i])
				end
			end
			return 0.5
		end
	end
	Timers:CreateTimer(ltt)
end

--【鐵炮兵】
function ShuaGuai_Of_B(num)
	local tem_count = 0
	B_count = _G.B_count
	B_count = B_count + 1
	A_count = _G.A_count
	--總共六個出發點 6
	local randomkey = RandomInt(1,8)
	local function ltt()
		tem_count = tem_count + 1
		if tem_count > num then return nil
		else
			for i=1,6 do
				local go = false
				if _G.mo == nil then
					go = true
				elseif i==2 or i==5 then
					go = true
				end
				if go then
					--超過三的時候出兵變為聯合軍

					local ok = false
					if _G.team_broken[2]["top"] < 2 and i == 3 then
						ok = true
					end
					if _G.team_broken[2]["mid"] < 2 and i == 2 then
						ok = true
					end
					if _G.team_broken[2]["down"] < 2 and i == 1 then
						ok = true
					end
					if _G.team_broken[3]["top"] < 2 and i == 4 then
						ok = true
					end
					if _G.team_broken[3]["mid"] < 2 and i == 5 then
						ok = true
					end
					if _G.team_broken[3]["down"] < 2 and i == 6 then
						ok = true
					end
					if ok then
						local team = nil
						local unit_name = nil
						if i > 3 then
							team = 3
						else
							team = 2
						end
						if team == 2 then
							unit_name = "com_gunner_oda_" .. randomkey
						elseif team == 3 then
							unit_name = "com_gunner_unified_" .. randomkey
						end
						
						--創建單位
						local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[i] , true, nil, nil, team)
						unit:AddAbility("set_level_1"):SetLevel(1)
						local hp = unit:GetMaxHealth()
						unit:SetBaseMaxHealth(hp+A_count * 8)
						local dmgmax = unit:GetBaseDamageMax()
						local dmgmin = unit:GetBaseDamageMin()
						unit:SetBaseDamageMax(dmgmax+A_count*8)
						unit:SetBaseDamageMax(dmgmin+A_count*8)
						local armor = unit:GetPhysicalArmorBaseValue()
						unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
						--creep:SetContextNum("isshibing",1,0)

						--單位面向角度
						unit:SetForwardVector(ShuaGuai_entity_forvec[i])

						--禁止單位尋找最短路徑
						unit:SetMustReachEachGoalEntity(false)

						--讓單位沿著設置好的路線開始行動
						unit:SetInitialGoalEntity(ShuaGuai_entity[i])

						--顏色
						if team == 2 then
							--unit:SetRenderColor(255,100,100)
						elseif team == 3 then
							--unit:SetRenderColor(100,255,100)
						end
					end
				end
			end
			return 0.5
		end
	end
	Timers:CreateTimer(ltt)
end

--【騎兵】
function ShuaGuai_Of_C(num)
	local tem_count = 0
	C_count = _G.C_count
	C_count = C_count + 1
	A_count = _G.A_count
	--總共六個出發點 6
	local randomkey = RandomInt(1,8)
	local function ltt()
		tem_count = tem_count + 1
		if tem_count > num then return nil
		else
			for i=1,6 do
				local go = false
				if _G.mo == nil then
					go = true
				elseif i==2 or i==5 then
					go = true
				end
				if go then
					--超過三的時候出兵變為聯合軍
					local ok = false
					if _G.team_broken[2]["top"] == 0 and i == 3 then
						ok = true
					end
					if _G.team_broken[2]["mid"] == 0 and i == 2 then
						ok = true
					end
					if _G.team_broken[2]["down"] == 0 and i == 1 then
						ok = true
					end
					if _G.team_broken[3]["top"] == 0 and i == 4 then
						ok = true
					end
					if _G.team_broken[3]["mid"] == 0 and i == 5 then
						ok = true
					end
					if _G.team_broken[3]["down"] == 0 and i == 6 then
						ok = true
					end
					if ok then
						local team = nil
						local unit_name = nil
						if i > 3 then
							team = 3
						else
							team = 2
						end
						if team == 2 then
							unit_name = "com_cavalry_oda_" .. randomkey
						elseif team == 3 then
							unit_name = "com_cavalry_unified_" .. randomkey
						end

						--【騎兵】
						--創建單位
						local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[i] , true, nil, nil, team)
						
						local hp = unit:GetMaxHealth()
						unit:SetBaseMaxHealth(hp+A_count * 20)
						local dmgmax = unit:GetBaseDamageMax()
						local dmgmin = unit:GetBaseDamageMin()
						unit:SetBaseDamageMax(dmgmax+A_count*10)
						unit:SetBaseDamageMax(dmgmin+A_count*10)
						local armor = unit:GetPhysicalArmorBaseValue()
						unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
						--creep:SetContextNum("isshibing",1,0)

						--單位面向角度
						unit:SetForwardVector(ShuaGuai_entity_forvec[i])

						--禁止單位尋找最短路徑
						unit:SetMustReachEachGoalEntity(false)

						--讓單位沿著設置好的路線開始行動
						unit:SetInitialGoalEntity(ShuaGuai_entity[i])

						--顏色
						if team == 2 then
							--unit:SetRenderColor(255,100,100)
						elseif team == 3 then
							--unit:SetRenderColor(100,255,100)
						end
					end
				end
				--碰撞面積
				--unit:SetHullRadius(40)
			end
			return 0.5
		end
	end
	Timers:CreateTimer(ltt)
end

--織田足輕上
function soldier_Oda_top( )
	if _G.mo then return end
	payprestige[2] = payprestige[2] + 50
	local tem_count = 0
	--總共六個出發點 6
	A_count = _G.A_count
	local pos = 3
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_infantry_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 24)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*1)
			unit:SetBaseDamageMax(dmgmin+A_count*1)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
			--creep:SetContextNum("isshibing",1,0)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--織田足輕中
function soldier_Oda_mid( )
	payprestige[2] = payprestige[2] + 50
	local tem_count = 0
	local pos = 2
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_infantry_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 24)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*1)
			unit:SetBaseDamageMax(dmgmin+A_count*1)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
			--creep:SetContextNum("isshibing",1,0)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--織田足輕下
function soldier_Oda_bottom()
	if _G.mo then return end
	payprestige[2] = payprestige[2] + 50
	local tem_count = 0
	local pos = 1
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_infantry_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 24)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*1)
			unit:SetBaseDamageMax(dmgmin+A_count*1)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--聯合足輕上
function soldier_Unified_top( )
	if _G.mo then return end
	payprestige[3] = payprestige[3] + 50
	local tem_count = 0
	--總共六個出發點 6
	A_count = _G.A_count
	local pos = 6
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_infantry_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 24)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*1)
			unit:SetBaseDamageMax(dmgmin+A_count*1)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
			--creep:SetContextNum("isshibing",1,0)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--聯合足輕中
function soldier_Unified_mid( )
	payprestige[3] = payprestige[3] + 50
	local tem_count = 0
	local pos = 5
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_infantry_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 24)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*1)
			unit:SetBaseDamageMax(dmgmin+A_count*1)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)
			--creep:SetContextNum("isshibing",1,0)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--聯合足輕下
function soldier_Unified_bottom()
	if _G.mo then return end
	payprestige[3] = payprestige[3] + 50
	local tem_count = 0
	local pos = 4
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_infantry_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 24)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*1)
			unit:SetBaseDamageMax(dmgmin+A_count*1)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.1)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--織田弓箭手上
function archer_Oda_top( )
	if _G.mo then return end
	payprestige[2] = payprestige[2] + 70
	local tem_count = 0
	--總共六個出發點 6
	A_count = _G.A_count
	local pos = 3
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_archer_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*7)
			unit:SetBaseDamageMax(dmgmin+A_count*7)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--織田弓箭手中
function archer_Oda_mid( )
	payprestige[2] = payprestige[2] + 70
	local tem_count = 0
	local pos = 2
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_archer_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*7)
			unit:SetBaseDamageMax(dmgmin+A_count*7)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--織田弓箭手下
function archer_Oda_bottom()
	if _G.mo then return end
	payprestige[2] = payprestige[2] + 70
	local tem_count = 0
	local pos = 1
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_archer_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*7)
			unit:SetBaseDamageMax(dmgmin+A_count*7)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--聯合弓箭手上
function archer_Unified_top( )
	if _G.mo then return end
	payprestige[3] = payprestige[3] + 70
	local tem_count = 0
	--總共六個出發點 6
	A_count = _G.A_count
	local pos = 6
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_archer_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*7)
			unit:SetBaseDamageMax(dmgmin+A_count*7)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--聯合弓箭手中
function archer_Unified_mid( )
	payprestige[3] = payprestige[3] + 70
	local tem_count = 0
	local pos = 5
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_archer_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*7)
			unit:SetBaseDamageMax(dmgmin+A_count*7)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				------unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				------unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--聯合弓箭手下
function archer_Unified_bottom()
	if _G.mo then return end
	payprestige[3] = payprestige[3] + 70
	local tem_count = 0
	local pos = 4
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_archer_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*7)
			unit:SetBaseDamageMax(dmgmin+A_count*7)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				----unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				----unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--織田鐵炮兵上
function gunner_Oda_top( )
	if _G.mo then return end
	payprestige[2] = payprestige[2] + 100
	local tem_count = 0
	--總共六個出發點 6
	A_count = _G.A_count
	local pos = 3
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_gunner_oda_"..RandomInt(1,8).."_D"
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*15)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--織田鐵炮兵中
function gunner_Oda_mid( )
	payprestige[2] = payprestige[2] + 100
	local tem_count = 0
	local pos = 2
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_gunner_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*15)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--織田鐵炮兵下
function gunner_Oda_bottom()
	if _G.mo then return end
	payprestige[2] = payprestige[2] + 100
	local tem_count = 0
	local pos = 1
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_gunner_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*15)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--聯合鐵炮兵上
function gunner_Unified_top( )
	if _G.mo then return end
	payprestige[3] = payprestige[3] + 100
	local tem_count = 0
	--總共六個出發點 6
	A_count = _G.A_count
	local pos = 6
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_gunner_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*15)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--聯合鐵炮兵中
function gunner_Unified_mid( )
	payprestige[3] = payprestige[3] + 100
	local tem_count = 0
	local pos = 5
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_gunner_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*15)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--聯合鐵炮兵下
function gunner_Unified_bottom()
	if _G.mo then return end
	payprestige[3] = payprestige[3] + 100
	local tem_count = 0
	local pos = 4
	--總共六個出發點 6
	A_count = _G.A_count
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_gunner_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 3)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*15)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--織田騎兵上
function cavalry_Oda_top( )
	if _G.mo then return end
	payprestige[2] = payprestige[2] + 100
	local tem_count = 0
	--總共六個出發點 6
	A_count = _G.A_count
	print("A_count "..A_count)
	local pos = 3
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_cavalry_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 20)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*5)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--織田騎兵中
function cavalry_Oda_mid( )
	payprestige[2] = payprestige[2] + 100
	local tem_count = 0
	local pos = 2
	--總共六個出發點 6
	A_count = _G.A_count
	print("A_count "..A_count)
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_cavalry_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 20)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*5)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--織田騎兵下
function cavalry_Oda_bottom()
	if _G.mo then return end
	payprestige[2] = payprestige[2] + 100
	local tem_count = 0
	local pos = 1
	--總共六個出發點 6
	A_count = _G.A_count
	print("A_count "..A_count)
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 2
			unit_name = "com_cavalry_oda_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 20)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*5)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--聯合騎兵上
function cavalry_Unified_top( )
	if _G.mo then return end
	payprestige[3] = payprestige[3] + 100
	local tem_count = 0
	--總共六個出發點 6
	A_count = _G.A_count
	print("A_count "..A_count)
	local pos = 6
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_cavalry_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 20)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*5)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--聯合騎兵中
function cavalry_Unified_mid( )
	payprestige[3] = payprestige[3] + 100
	local tem_count = 0
	local pos = 5
	A_count = _G.A_count
	--總共六個出發點 6
	print("A_count "..A_count)
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_cavalry_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)
			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 20)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*5)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)

			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end


--聯合騎兵下
function cavalry_Unified_bottom()
	if _G.mo then return end
	payprestige[3] = payprestige[3] + 100
	local tem_count = 0
	local pos = 4
	A_count = _G.A_count
	print("A_count "..A_count)
	--總共六個出發點 6
	Timers:CreateTimer(function()
		tem_count = tem_count + 1
		if tem_count > 3 then return nil
		else
			--DOTA_TEAM_GOODGUYS = 2
			--DOTA_TEAM_BADGUYS = 3
			local team = nil
			local unit_name = nil
			team = 3
			unit_name = "com_cavalry_unified_"..RandomInt(1,8).."_D"
			
			--創建單位
			local unit = CreateUnitByName(unit_name, ShuaGuai_entity_point[pos] , true, nil, nil, team)
			unit:AddAbility("set_level_1"):SetLevel(1)

			local hp = unit:GetMaxHealth()
			unit:SetBaseMaxHealth(hp+A_count * 20)
			local dmgmax = unit:GetBaseDamageMax()
			local dmgmin = unit:GetBaseDamageMin()
			unit:SetBaseDamageMax(dmgmax+A_count*15)
			unit:SetBaseDamageMax(dmgmin+A_count*5)
			local armor = unit:GetPhysicalArmorBaseValue()
			unit:SetPhysicalArmorBaseValue(armor+A_count*0.05)
			--單位面向角度
			unit:SetForwardVector(ShuaGuai_entity_forvec[pos])

			--禁止單位尋找最短路徑
			unit:SetMustReachEachGoalEntity(false)

			--顏色
			if team == 2 then
				--unit:SetRenderColor(255,100,100)
			elseif team == 3 then
				--unit:SetRenderColor(100,255,100)
			end
			unit:SetInitialGoalEntity(ShuaGuai_entity[pos])
			return 0.5
		end
	end)
end

--end