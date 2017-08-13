json = require ("game.dkjson")

local special = {
  128732954, -- damody
  292642709, -- 蘿絲
  334794913, -- 蘿絲2
  160191755, -- 揚智
  235963145, -- Madrid
  340558013, -- jackylee
  86765515,  -- Roxas_K
}

print ('[Nobu-lua] main lua script Starting..' )

localplayerID = 0
_G.afkcount = {}
winmsg = ""

function SendHTTPRequest(path, method, values, callback)
	local req = CreateHTTPRequestScriptVM( method, "http://172.104.107.13/"..path )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end

function PlayerCanPlay(callback)
	local pID = localplayerID
	local steamID = PlayerResource:GetSteamAccountID(pID)
	if (steamID ~= 0) then
		steamID = tostring(steamID)
		SendHTTPRequest("check_can_play", "POST",
			{id = steamID}, function(res)
				if (string.match(res, "error")) then
					callback()
				end
			end)
	end
    return true
end

function GameCanPlay(callback)
	for pID = 0, 13 do
    	local steamID = PlayerResource:GetSteamAccountID(pID)
    	if (steamID ~= 0) then
	    	steamID = tostring(steamID)
	    	SendHTTPRequest("check_can_play", "POST",
				{id = steamID}, function(res)
					if (string.match(res, "error")) then
						callback(steamID)
					end
				end)
	    end
    end
    return true
end

_G.blacklist = {
	"338693950", --玩遊戲玩死你
	
}

local cannotplay = {}
function Nobu:OnPlayerConnectFull(keys)
    local player = PlayerInstanceFromIndex(keys.index + 1)
	local pID = keys.index
	localplayerID = pID
	local steamID = PlayerResource:GetSteamAccountID(pID)
	if (steamID == PlayerResource:GetSteamAccountID(0)) then
		_G.homeisme = true
	end
    print("keys.index"..keys.index.." steamID "..steamID)
    for _,v in ipairs(_G.blacklist) do
    	if v == tostring(steamID) then
    		player:Destroy()
    	end
    end
    -- 中離檢查
    --[[
    PlayerCanPlay(function()
    		--讓該玩斷線
	    	player:Destroy()
	    end)

	local canplay = GameCanPlay(function(sid)
			table.insert(cannotplay, sid)
		end)
	Timers:CreateTimer( 5, function()
		--測到有跳狗結束遊戲
		if (#cannotplay > 0) then
		    GameRules:SetCustomGameEndDelay(1)
		    GameRules:SetCustomVictoryMessage("有跳狗啦幹")
		    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		end
		end)
	

	for pID = 0, 9 do
		_G.afkcount[pID] = 0
	end
	Timers:CreateTimer(20, function()
		if (_G.homeisme) then
			for pID = 0, 13 do
				local steamID = PlayerResource:GetSteamAccountID(pID)
				if steamID ~= 0 then
					local res = PlayerResource:GetConnectionState(pID)
					if (res == 3) then
						_G.afkcount[pID] = _G.afkcount[pID] + 1
					end
					if (_G.afkcount[pID] > 10) then
						_G.afkcount[pID] = -10000
						GameRules:SendCustomMessage("玩家"..pID.."中離", DOTA_TEAM_GOODGUYS, 0)

						SendHTTPRequest("afk", "POST",
						{
						  id = tostring(steamID),
						},
						function(result)
						  --print(result)
						end)
					end
				end
			end
			return 1
		else
			return nil
		end
	end)
	]]
end

function Nobu:CloseRoom()
	local steamID = PlayerResource:GetSteamAccountID(0)
	steamID = tostring(steamID)
	local indata = {id = steamID, winteam = "15"}
	for i = 1, 10 do
		local player = PlayerInstanceFromIndex(i)
		if (player ~= nil) then
			local hero = player:GetAssignedHero()
			if hero then
				indata["id_"..i.."_k"] = tostring(hero:GetKills())
				indata["id_"..i.."_d"] = tostring(hero:GetDeaths())
				indata["id_"..i.."_a"] = tostring(hero:GetAssists())
				indata["id_"..i.."_sk"] = tostring(hero.kill_count)
			end
		end
	end

end

function Nobu:OpenRoom()
	if GetMapName() == "nobu" then
		_G.game_level = -99
	end
	if GetMapName() == "nobu_pk" then
		_G.game_level = 99
	end
	if GetMapName() == "lv1_bronze" then
		_G.game_level = 1
	end
	if GetMapName() == "lv2_silver" then
		_G.game_level = 2
	end
	if GetMapName() == "lv3_gold" then
		_G.game_level = 3
	end
	if GetMapName() == "nobu_rank" then
		_G.game_level = 4
	end
	Timers:CreateTimer( 5, function()
		local ids = {}
		local idcount = 0
		for pID = 0, 9 do
			local steamID = PlayerResource:GetSteamAccountID(pID)
			ids["id_"..(pID+1)] = tostring(steamID)
			if steamID ~= 0 then
				idcount = idcount + 1
			end
		end
		SendHTTPRequest("open_room", "POST",
		ids,
		function(result)
			-- Decode response into a lua table
			local resultTable = {}
			if not pcall(function()
				resultTable = json.decode(result)
				DumpTable(resultTable)
			end) then
				Warning("[dota2.tools.Storage] Can't decode result: " .. result)
			end
			_G.rankTable = resultTable
			for pID = 0, 9 do
				local steamID = PlayerResource:GetSteamAccountID(pID)
				local player = PlayerResource:GetPlayer(pID)
		        if player then
		          local hero = player:GetAssignedHero()
		          if hero then
			        local nobu_id = _G.heromap[hero:GetName()]
			        local heroname = _G.hero_name_zh[nobu_id]
					steamID = tostring(steamID)
					if resultTable[steamID] ~= nil then
						local playcount = 100
						if resultTable[steamID.."count"] then
							playcount = resultTable[steamID.."count"]
						end
						if idcount < 2 then
							GameRules: SendCustomMessage("<font color='#fcac4b'>".."你的勝率為 "..(resultTable[steamID]*100).." </font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
							if resultTable[steamID.."count"] then
								GameRules: SendCustomMessage("<font color='#fcac4b'>".."你的信長總場數為 "..(playcount).." 場</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
							end
						end
						
						if resultTable[steamID] <=0.35 or playcount < 10 or (playcount < 50 and resultTable[steamID] < 0.6) then
							hero.level = -1
							if _G.game_level < 0 then
								if idcount < 2 then
									GameRules: SendCustomMessage("<font color='#fcac4b'>"..heroname.."是新銅學大家不要欺負他喔".."</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
								end
							else
								GameRules: SendCustomMessage("<font color='#bb6c00'>"..heroname.."為木牌".."</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
							end
						elseif resultTable[steamID] <=0.50 then
							if idcount < 2 then
								GameRules: SendCustomMessage("<font color='#bb6c00'>"..heroname.."為銅牌".."</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
							end
							hero.level = 0
						elseif resultTable[steamID] <=0.55 then
							if idcount < 2 then
								GameRules: SendCustomMessage("<font color='#ff8c00'>"..heroname.."為銅牌".."</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
							end
							hero.level = 1
						elseif resultTable[steamID] <=0.65 then
							if idcount < 2 then
								GameRules: SendCustomMessage("<font color='#b5b4b3'>"..heroname.."為銀牌".."</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
							end
							hero.level = 2
						else
							if idcount < 2 then
								GameRules: SendCustomMessage("<font color='#ffe01c'>"..heroname.."為金牌".."</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
							end
							hero.level = 3
						end
					end
				  end
				end
			end
			-- If we get an error response, successBool should be false
			if resultTable ~= nil and resultTable["errors"] ~= nil then
				callback(resultTable["errors"], false)
				return
			end
			-- If we get a success response, successBool should be true
			if resultTable ~= nil and resultTable["data"] ~= nil  then
				callback(resultTable["data"], true)
				return
			end
		end )
	end)
end

function Nobu:CheckAFK()
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(Nobu, 'OnPlayerConnectFull'), self)
end

function DumpTable( tTable )
	local inspect = require('inspect')
	local iDepth = 3
 	print(inspect(tTable,
 		{depth=iDepth} 
 	))
end

