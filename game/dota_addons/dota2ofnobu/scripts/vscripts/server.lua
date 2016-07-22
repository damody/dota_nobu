print ('[Nobu] main lua script Starting..' )

localplayerID = 0

function SendHTTPRequest(path, method, values, callback)
	local req = CreateHTTPRequest( method, "http://140.114.235.19/"..path )
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
	for pID = 0, 9 do
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

local cannotplay = {}
function Nobu:OnPlayerConnectFull(keys)
    local player = PlayerInstanceFromIndex(keys.index + 1)
	local pID = keys.index
	localplayerID = pID
	local steamID = PlayerResource:GetSteamAccountID(pID)
    print("keys.index"..keys.index.." steamID "..steamID)
    PlayerCanPlay(function()
	    	player:Destroy()
	    end)

	local canplay = GameCanPlay(function(sid)
			table.insert(cannotplay, sid)
		end)
	Timers:CreateTimer( 5, function()
		if (#cannotplay > 0) then
		    GameRules:SetCustomGameEndDelay(1)
		    GameRules:SetCustomVictoryMessage("贏三小啦幹")
		    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		end
		end)
end

function Nobu:CloseRoom()
	local steamID = PlayerResource:GetSteamAccountID(0)
	steamID = tostring(steamID)
	local indata = {id = steamID, winteam = "15"}
	for i = 1, 10 do
		local player = PlayerInstanceFromIndex(i)
		if (player ~= nil) then
			local hero = player:GetAssignedHero()
			DeepPrintTable(hero)
			print("DeepPrintTable(hero)")
			indata["id_"..i.."_k"] = tostring(hero:GetKills())
			indata["id_"..i.."_d"] = tostring(hero:GetDeaths())
			indata["id_"..i.."_a"] = tostring(hero:GetAssists())
		end
	end

	SendHTTPRequest("close_room", "POST",
		indata, function(res)
			print(res)
		end)
end

function Nobu:OpenRoom()

	ListenToGameEvent('player_connect_full', Dynamic_Wrap(Nobu, 'OnPlayerConnectFull'), self)
	-- 產生隨機數種子，主要是為了程序中的隨機數考慮
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(timeTxt))--GetSystemTime	string GetSystemTime()	獲取真實世界的時間
	SendToConsole("r_farz 60000")

    Timers:CreateTimer( 10, function()
    	if (#cannotplay == 0) then
	    	local ids = {}
	    	for pID = 0, 9 do
		    	local steamID = PlayerResource:GetSteamAccountID(pID)
		    	ids["id_"..(pID+1)] = tostring(steamID)
		    end
	  		SendHTTPRequest("open_room", "POST",
			ids,
			function(result)
				-- Decode response into a lua table
				local resultTable = {}
				if not pcall(function()
					resultTable = JSON:decode(result)
				end) then
					Warning("[dota2.tools.Storage] Can't decode result: " .. result)
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
		end
      return nil
    end)
end
