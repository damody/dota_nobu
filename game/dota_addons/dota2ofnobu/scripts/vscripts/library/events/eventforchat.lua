--[[
BUG
	O大廳裡面也可以捕捉到，這時候caster值為nil
]]

local function chat_of_test(keys)
	print("[Nobu-lua] Test")
	--DeepPrintTable(keys)
	-- [   VScript ]:    playerid                        	= 0 (number)
	-- [   VScript ]:    text                            	= "3" (string)
	-- [   VScript ]:    teamonly                        	= 1 (number)
	-- [   VScript ]:    userid                          	= 1 (number)
	-- [   VScript ]:    splitscreenplayer               	= -1 (number)

	--local id    = keys.player --BUG:在講話事件裡，讀取不到玩家，是整數。
	local s   	   = keys.text
	local id  	   = 1 --keys.userid --BUG:會1.2的調換，不知道為甚麼
	local p 	     = PlayerResource:GetPlayer(keys.playerid)--可以用索引轉換玩家方式，來捕捉玩家
	local caster 	   = p:GetAssignedHero() --获取该玩家的英雄
	local point    = caster:GetAbsOrigin()
	-- if string.match(s,"test") then
	-- 	local pID = tonumber(string.match(s, '%d+'))
	-- 	local steamID = PlayerResource:GetSteamAccountID(pID)
	-- 	GameRules: SendCustomMessage(tostring(steamID),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
	-- end

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

	if s == "gg" then
		GameRules:SetCustomGameEndDelay(1)
		GameRules:SetCustomVictoryMessage("贏三小啦幹")
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	end
	
	if s == "-old" then
		if (caster:GetUnitName() == "npc_dota_hero_centaur") then
			caster:RemoveAbility("A07W")
			caster:RemoveAbility("A07E")
			caster:RemoveAbility("A07R")
			caster:RemoveAbility("A07D")
			caster:RemoveAbility("A07T")

			caster:AddAbility("A07W_old")
			caster:AddAbility("A07E_old")
			caster:AddAbility("A07R_old")
			caster:AddAbility("A07T_old")
		elseif (caster:GetUnitName() == "npc_dota_hero_pugna") then
			caster:RemoveAbility("B25W")
			caster:RemoveAbility("B25E")
			caster:RemoveAbility("B25R")
			caster:RemoveAbility("B25T")

			caster:AddAbility("B25W")
			caster:AddAbility("B25E_old")
			caster:AddAbility("B25R_old")
			caster:AddAbility("B25T_old")
		end
	end
	
	if s == "Create1" then
		local  u = CreateUnitByName("npc_dota_hero_magnataur",caster:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
		--u:SetOwner(p)                                         --設置u的擁有者
		u:SetControllableByPlayer(keys.playerid,true)               --設置u可以被玩家0操控
		--u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
		for i=1,30 do
		u:HeroLevelUp(true)
		end 
	end
	
	if s == "Create2" then
		local  u = CreateUnitByName("npc_dota_hero_crystal_maiden",caster:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
		--u:SetOwner(p)                                         --設置u的擁有者
		u:SetControllableByPlayer(keys.playerid,true)               --設置u可以被玩家0操控
		--u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
		for i=1,30 do
		u:HeroLevelUp(true)
		end 
	end
	
	--【測試指令】
	if s == "ShuaGuai" then
		print("ShuaGuai")
		ShuaGuai_Of_A( )
		ShuaGuai_Of_B( )
		ShuaGuai_Of_C( )
	elseif s == "hp" then
		print("nobu"..id)
		Timers:CreateTimer(function()
			caster:SetHealth(caster:GetMaxHealth())
			return 0.1
		end)
	elseif s == "mp" then
		print("nobu"..id)
		Timers:CreateTimer(function()
			caster:SetMana(caster:GetMaxMana())
			return 0.1
		end)
	elseif s == "cd" then
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
end

function Nobu:Chat( keys )
	print("[Nobu-lua] Chat Init")

	--【測試模式】
	--if nobu_debug then
		chat_of_test(keys)
	--end
end
