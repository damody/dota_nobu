print ('[Nobu-lua] main lua script Starting..' )

localplayerID = 0
_G.afkcount = {}
winmsg = ""

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
	if (steamID == PlayerResource:GetSteamAccountID(0)) then
		_G.homeisme = true
	end
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
		    GameRules:SetCustomVictoryMessage("有跳狗啦幹")
		    GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		end
		end)
for pID = 0, 9 do
		_G.afkcount[pID] = 0
	end
	Timers:CreateTimer(20, function()
		if (_G.homeisme) then
			for pID = 0, 9 do
				local steamID = PlayerResource:GetSteamAccountID(pID)
				if steamID ~= 0 then
					local res = PlayerResource:GetConnectionState(pID)
					if (res == 3) then
						_G.afkcount[pID] = _G.afkcount[pID] + 1
					end
					if (_G.afkcount[pID] > 10) then
						_G.afkcount[pID] = -10000
						GameRules:SendCustomMessage("玩家"..pID.."中離", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
						SendHTTPRequest("afk", "POST",
				            {
				              id = tostring(steamID),
				            },
				            function(result)
				              --print(result)
				            end
				          )
					end
				end
			end
			SendHTTPRequest("keep_alive", "POST",
				{
					id = tostring(steamID),
				},
					function(result)
						--print(result)
					end
				)
			return 1
		else
			return nil
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
	Timers:CreateTimer( 5, function()
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

function Nobu:CheckAFK()

	ListenToGameEvent('player_connect_full', Dynamic_Wrap(Nobu, 'OnPlayerConnectFull'), self)

end