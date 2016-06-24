--[[
BUG
	O大廳裡面也可以捕捉到，這時候hero值為nil
]]

local function chat_of_test(keys)
	print("[Nobu] Test")
	--local id    = keys.player --BUG:在講話事件裡，讀取不到玩家，是整數。
	local s   	   = keys.text	
	local id  	   = 1 --keys.userid --BUG:會1.2的調換，不知道為甚麼
	local p 	     = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家
	local hero 	   = p: GetAssignedHero() --获取该玩家的英雄
	local point    = hero:GetAbsOrigin()	

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
end

function Nobu:Chat( keys )
	print("[Nobu] Chat Init")
	--DeepPrintTable(keys)    --详细打印传递进来的表
	--local id    = keys.player --BUG:在講話事件裡，讀取不到玩家，是整數。
	local s   	   = keys.text	
	local id  	   = 1 --keys.userid --BUG:會1.2的調換，不知道為甚麼
	local p 	     = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家
	local hero 	   = p: GetAssignedHero() --获取该玩家的英雄
	local point    = hero:GetAbsOrigin()

	if nobu_debug then
		chat_of_test(keys)
	end
end