--[[
BUG
	O大廳裡面也可以捕捉到，這時候caster值為nil
]]
local inspect = require("inspect")

function SendHTTPRequest(path, method, values, callback)
	local req = CreateHTTPRequest( method, "http://140.114.235.19/"..path )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end

local function chat_of_test(keys)
	print("[Nobu-lua] Test")
	--DeepPrintTable(keys)
	-- [   VScript ]:    playerid                        	= 0 (number)
	-- [   VScript ]:    text                            	= "3" (string)
	-- [   VScript ]:    teamonly                        	= 1 (number)
	-- [   VScript ]:    userid                          	= 1 (number)
	-- [   VScript ]:    splitscreenplayer               	= -1 (number)

	--local id    = keys.player --BUG:在講話事件裡，讀取不到玩家，是整數。
	local s   	   = keys.text:lower()
	local p 	     = PlayerResource:GetPlayer(keys.playerid)--可以用索引轉換玩家方式，來捕捉玩家
	local caster 	   = p:GetAssignedHero() --获取该玩家的英雄
	if caster == nil then return end
	local point    = caster:GetAbsOrigin()
	-- if string.match(s,"test") then
	-- 	local pID = tonumber(string.match(s, '%d+'))
	-- 	local steamID = PlayerResource:GetSteamAccountID(pID)
	-- 	GameRules: SendCustomMessage(tostring(steamID),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
	-- end
	if _G.CountUsedAbility_Table == nil then
		_G.CountUsedAbility_Table = {}
	end
	if _G.CountUsedAbility_Table[keys.playerid + 1] == nil then
		_G.CountUsedAbility_Table[keys.playerid + 1] = {}
	end
	if s == "-se" then
		_G.CountUsedAbility_Table["winteam"] = DOTA_TEAM_GOODGUYS
		for playerID = 0, 14 do
			local id       = playerID
	  		local p        = PlayerResource:GetPlayer(id)
	  		local steamid = PlayerResource:GetSteamAccountID(id)
	    	if p ~= nil and (p:GetAssignedHero()) ~= nil then
			  local hero = p:GetAssignedHero()

			  if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			  	_G.CountUsedAbility_Table[id+1]["res"] = "W"
			  else
			  	_G.CountUsedAbility_Table[id+1]["res"] = "L"
			  end
			  _G.CountUsedAbility_Table[id+1]["name"] = hero.name
			  _G.CountUsedAbility_Table[id+1]["version"] = hero.version
			  _G.CountUsedAbility_Table[id+1]["damage"] = hero.damage
			  _G.CountUsedAbility_Table[id+1]["takedamage"] = hero.takedamage
			  _G.CountUsedAbility_Table[id+1]["herodamage"] = hero.herodamage
			  _G.CountUsedAbility_Table[id+1]["building_count"] = hero.building_count
			  _G.CountUsedAbility_Table[id+1]["team"] = hero:GetTeamNumber()
			  _G.CountUsedAbility_Table[id+1]["kda"] = {}
			  _G.CountUsedAbility_Table[id+1]["kda"]["k"] = tostring(hero:GetKills())
			  _G.CountUsedAbility_Table[id+1]["kda"]["d"] = tostring(hero:GetDeaths())
			  _G.CountUsedAbility_Table[id+1]["kda"]["a"] = tostring(hero:GetAssists())
			  _G.CountUsedAbility_Table[id+1]["kda"]["kcount"] = tostring(hero.kill_count)
			  _G.CountUsedAbility_Table[id+1]["kda"]["steamid"] = steamid
			end
		end
		DeepPrintTable(_G.CountUsedAbility_Table)
		--[[
		SendHTTPRequest("save_ability_data", "POST",
			{
			  data = tostring(inspect(_G.CountUsedAbility_Table)),
			},
			function(result)
			  print(result)
			end)
		]]
	end
	--DebugDrawText(caster:GetAbsOrigin(), "殺爆全場就是現在", false, 10)
	--舊版模式
	local nobu_id = _G.heromap[caster:GetName()]
	if (s == "-new" or s == "-16") and caster:GetLevel() == 1 and caster.isnew == nil 
		and _G.heromap_version[nobu_id]["11"] == true then -- 檢查有沒有11版
		-- 通知所有玩家該英雄已經變成新版
		GameRules:SendCustomMessage("-new ".._G.hero_name_zh[nobu_id],0,0)
		caster.isnew = true
		caster:SetAbilityPoints(1)
		caster.version = "16"

		for i = 0, caster:GetAbilityCount() - 1 do
          local ability = caster:GetAbilityByIndex( i )
          if ability  then
            caster:RemoveAbility(ability:GetName())
          end
        end
        local skill = _G.heromap_skill[nobu_id]["16"]
        for si=1,#skill do
          if si == #skill and #skill < 6 then
            caster:AddAbility("attribute_bonusx")
          end
          caster:AddAbility(nobu_id..skill:sub(si,si))
        end
        if #skill >= 6 then
          caster:AddAbility("attribute_bonusx")
        end
        -- 要自動學習的技能
        local askill = _G.heromap_autoskill[nobu_id]["16"]
        for si=1,#askill do
          caster:FindAbilityByName(nobu_id..askill:sub(si,si)):SetLevel(1)
        end
	end
	if (s == "-long" and nobu_id == "A31") then
		LinkLuaModifier("modifier_long_a31", "heroes/modifier_long_a31.lua", LUA_MODIFIER_MOTION_NONE)
		caster:AddNewModifier(caster, nil, "modifier_long_a31", nil)
		caster:RemoveModifierByName("modifier_short_a31")
	end
	if (s == "-short" and nobu_id == "A31") then
		LinkLuaModifier("modifier_short_a31", "heroes/modifier_short_a31.lua", LUA_MODIFIER_MOTION_NONE)
		caster:AddNewModifier(caster, nil, "modifier_short_a31", nil)
		caster:RemoveModifierByName("modifier_long_a31")
	end
	if (s == "-donkey" and caster.has_dota_donkey == nil) then
		caster.has_dota_donkey = 1
		local donkey = CreateUnitByName("npc_dota_courier", caster:GetAbsOrigin()+Vector(100, 100, 0), true, caster, caster, caster:GetTeam())
		donkey:SetOwner(caster)
		donkey:SetControllableByPlayer(caster:GetPlayerID(), true)
        donkey:FindAbilityByName("courier_return_to_base"):SetLevel(1)
        donkey:FindAbilityByName("courier_go_to_secretshop"):SetLevel(1)
        donkey:FindAbilityByName("courier_return_stash_items"):SetLevel(1)
        donkey:FindAbilityByName("courier_take_stash_items"):SetLevel(1)
        donkey:FindAbilityByName("courier_transfer_items"):SetLevel(1)
        donkey:FindAbilityByName("courier_burst"):SetLevel(1)
        donkey:FindAbilityByName("courier_morph"):SetLevel(1)
        donkey:FindAbilityByName("courier_take_stash_and_transfer_items"):SetLevel(1)
        donkey:FindAbilityByName("for_magic_immune"):SetLevel(1)
	end
	if (s == "-old" or s == "-11") and caster:GetLevel() == 1 and caster.isold == nil 
		and _G.heromap_version[nobu_id]["11"] == true then -- 檢查有沒有11版
		
		-- 通知所有玩家該英雄已經變成舊版
		GameRules:SendCustomMessage("-old ".._G.hero_name_zh[nobu_id],0,0)

		caster.isold = true
		caster:SetAbilityPoints(1)
		caster.version = "11"

		-- 拔掉英雄的修改器
		--[[
		local am = caster:FindAllModifiers()
		for _,v in pairs(am) do
			if v:GetName() ~= "equilibrium_constant" and v:GetName() ~= "modifier_for_record" then
				caster:RemoveModifierByName(v:GetName())
			end
		end
		]]

		-- 拔掉英雄的技能
		for i = 0, caster:GetAbilityCount() - 1 do
			local ability = caster:GetAbilityByIndex( i )
			if ability  then
				caster:RemoveAbility(ability:GetName())
			end
		end
		for i = 0, caster:GetAbilityCount() - 1 do
          local ability = caster:GetAbilityByIndex( i )
          if ability  then
            caster:RemoveAbility(ability:GetName())
          end
        end
        local skill = _G.heromap_skill[nobu_id]["11"]
        for si=1,#skill do
          if si == #skill and #skill < 6 then
            caster:AddAbility("attribute_bonusx")
          end
          caster:AddAbility(nobu_id..skill:sub(si,si).."_old")
        end
        if #skill >= 6 then
          caster:AddAbility("attribute_bonusx")
        end
        -- 要自動學習的技能
        local askill = _G.heromap_autoskill[nobu_id]["11"]
        for si=1,#askill do
          caster:FindAbilityByName(nobu_id..askill:sub(si,si).."_old"):SetLevel(1)
        end
	end
		
	sump = 0
	for playerID = 0, 14 do
		local id       = playerID
  		local p        = PlayerResource:GetPlayer(id)
    	if p ~= nil then
		  sump = sump + 1
		end
	end
	if string.match(s,"damody:") then
		sump = 1
	end
	if sump <= 2 then
		if string.match(s,"uion") then
		local GameMode = GameRules:GetGameModeEntity()
		GameMode:SetHUDVisible(0,  true) --Clock
		GameMode:SetHUDVisible(1,  true)
		GameMode:SetHUDVisible(2,  true)
		GameMode:SetHUDVisible(3,  true) --Action Panel
		GameMode:SetHUDVisible(4,  true) --Minimap
		GameMode:SetHUDVisible(5,  true) --Inventory
		GameMode:SetHUDVisible(6,  true)
		GameMode:SetHUDVisible(7,  true)
		GameMode:SetHUDVisible(8,  true)
		GameMode:SetHUDVisible(9,  true)
		GameMode:SetHUDVisible(11, true)
		GameMode:SetHUDVisible(12, true)
		end
		if string.match(s,"uioff") then
			local GameMode = GameRules:GetGameModeEntity()
			GameMode:SetHUDVisible(0,  false) --Clock
			GameMode:SetHUDVisible(1,  false)
			GameMode:SetHUDVisible(2,  false)
			GameMode:SetHUDVisible(3,  false) --Action Panel
			GameMode:SetHUDVisible(4,  false) --Minimap
			GameMode:SetHUDVisible(5,  false) --Inventory
			GameMode:SetHUDVisible(6,  false)
			GameMode:SetHUDVisible(7,  false)
			GameMode:SetHUDVisible(8,  false)
			GameMode:SetHUDVisible(9,  false)
			GameMode:SetHUDVisible(11, false)
			GameMode:SetHUDVisible(12, false)
		end
		if string.match(s,"cam") then
		local dis = tonumber(string.match(s, '%d+'))
			GameRules: GetGameModeEntity() :SetCameraDistanceOverride(dis)
		end
		if string.match(s,"-gg") then
			GameRules:SetCustomGameEndDelay(1)
			GameRules:SetCustomVictoryMessage("遊戲時間到了喔~")
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		end
		if string.match(s,"ss") then
			caster:AddAbility("for_move1500"):SetLevel(1)
		end
		if string.match(s,"xx") then
			caster:RemoveAbility("for_move1500")
			caster:RemoveModifierByName("modifier_for_move1500")
		end
		if string.match(s,"re") then
			caster:SetTimeUntilRespawn(0)
		end
		if string.match(s,"gold") then
			for i=0,9 do
			PlayerResource:SetGold(i,99999,false)--玩家ID需要減一
			end
		end
		if string.match(s,"nogo") then
			for i=0,9 do
			PlayerResource:SetGold(i,0,false)--玩家ID需要減一
			end
		end
		if string.match(s,"cd") then
			--【Timer】
			Timers:CreateTimer(function()
				caster:SetMana(caster:GetMaxMana() )
				--caster:SetHealth(caster:GetMaxHealth())

				-- Reset cooldown for abilities that is not rearm
				for i = 0, caster:GetAbilityCount() - 1 do
					local ability = caster:GetAbilityByIndex( i )
					if ability  then
						ability:EndCooldown()
					end
				end

				-- Put item exemption in here
				local exempt_table = {}

				-- Reset cooldown for items
				for i = 0, 5 do
					local item = caster:GetItemInSlot( i )
					if item then--if item and not exempt_table( item:GetAbilityName() ) then
						item:EndCooldown()
					end
				end
				return nil
			end)
		end

		if string.match(s,"supercd") or string.match(s,"scd") then
			--【Timer】
			Timers:CreateTimer(0.1, function()
				caster:SetMana(caster:GetMaxMana() )
				--caster:SetHealth(caster:GetMaxHealth())

				-- Reset cooldown for abilities that is not rearm
				for i = 0, caster:GetAbilityCount() - 1 do
					local ability = caster:GetAbilityByIndex( i )
					if ability  then
						ability:EndCooldown()
					end
				end

				-- Put item exemption in here
				local exempt_table = {}

				-- Reset cooldown for items
				for i = 0, 5 do
					local item = caster:GetItemInSlot( i )
					if item then--if item and not exempt_table( item:GetAbilityName() ) then
						item:EndCooldown()
					end
				end
				return 0.1
			end)
		end

		if string.match(s,"test") then
			local pID = tonumber(string.match(s, '%d+'))
			local steamID = PlayerResource:GetSteamAccountID(pID)
			GameRules: SendCustomMessage(tostring(steamID),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			local res = PlayerResource:GetConnectionState(pID)
			if (res == 0) then
				GameRules: SendCustomMessage("no connection",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			elseif (res == 1) then
				GameRules: SendCustomMessage("bot connected",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			elseif (res == 2) then
				GameRules: SendCustomMessage("player connected",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			elseif (res == 3) then
				GameRules: SendCustomMessage("bot/player disconnected",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			end
		end
		
		if string.match(s,"item") then
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					print(item:GetName())
				end
			end
		end
		
		if string.match(s,"lv") then
			local lvmax = tonumber(string.match(s, '%d+'))
			for i=1,lvmax do
		      caster:HeroLevelUp(true)
		    end
		end
		

		if s == "a1" then
			local  u = CreateUnitByName("com_ashigaru_spearmen",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_GOODGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "b1" then
			local  u = CreateUnitByName("com_ashigaru_spearmen",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "a2" then
			local  u = CreateUnitByName("com_archer",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_GOODGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "b2" then
			local  u = CreateUnitByName("com_archer",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "a3" then
			local  u = CreateUnitByName("com_cavalry",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_GOODGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "b3" then
			local  u = CreateUnitByName("com_cavalry",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "a4" then
			local  u = CreateUnitByName("Test_com_gunner_clone",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_GOODGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "b4" then
			local  u = CreateUnitByName("Test_com_gunner_clone",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "h" then
			GameRules: SendCustomMessage("` = 快速測試，內容不一定",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("r1 = 產生一個被綁住的淺井",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("sa = show ability",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("sm = show modifier",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("cu_es = CreateUnit_EarthShaker",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("team + nobu_id = 可以產生該英雄team=0(織田軍), team=1(聯合軍), e.g. 0C01=織田軍-明智光秀 ",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
		end

		if s == "`" then
			local mds = {}
			for _,m in ipairs(mds) do
				GameRules: SendCustomMessage("[Act-Trans:Modifier] "..m:GetName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			end
		end

		if s == "r1" then
			local  u = CreateUnitByName("npc_dota_hero_magnataur",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			u:AddNewModifier(keys.caster,nil,"modifier_rooted",nil)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "sa" then
			for i = 0, caster:GetAbilityCount() - 1 do
				local ability = caster:GetAbilityByIndex( i )
				if ability  then
					GameRules: SendCustomMessage("[Ability] "..ability:GetName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
				end
			end
		end

		if s == "sm" then
			for _,m in ipairs(caster:FindAllModifiers()) do
				GameRules: SendCustomMessage("[Modifier] "..m:GetName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			end
		end

		if s == "smsm" then
			for _,m in ipairs(caster.donkey:FindAllModifiers()) do
				GameRules: SendCustomMessage("[Modifier] "..m:GetName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			end
		end

		if s == "cu_es" then
			local  u = CreateUnitByName("npc_dota_hero_earthshaker",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		local upper = s:upper()
		local team = upper:sub(1,1)
		local nobu_id = upper:sub(2)
		local dota_hero_name = _G.nobu2dota[nobu_id]
		if dota_hero_name ~= nil then
			if team == "0" then
				-- 織田軍
				local u = CreateUnitByName(dota_hero_name,caster:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_GOODGUYS)
				u:SetControllableByPlayer(keys.playerid,true)
				for i=1,30 do
				u:HeroLevelUp(true)
				end
			elseif team == "1" then
				-- 聯合軍
				local u = CreateUnitByName(dota_hero_name,caster:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_BADGUYS)
				u:SetControllableByPlayer(keys.playerid,true)
				for i=1,30 do
				u:HeroLevelUp(true)
				end
			end
		end

		--【測試指令】
		if s == "ShuaGuai" then
			print("ShuaGuai")
			ShuaGuai_Of_AA( 10 )
			ShuaGuai_Of_AB( 10 )
			ShuaGuai_Of_B( 10 )
			ShuaGuai_Of_C( 10 )
		elseif s == "hp" then
			caster:SetHealth(caster:GetMaxHealth())
		elseif s == "mp" then
			Timers:CreateTimer(function()
				caster:SetMana(caster:GetMaxMana())
				return 0.1
			end)
		end
	end
end

function Nobu:Chat( keys )
	print("[Nobu-lua] Chat Init")

	--【測試模式】
	--if nobu_debug then
		chat_of_test(keys)
	--end
end
