print ('[Nobu] main lua script Starting..' )

function SendHTTPRequestBan(method, values, callback)
	local req = CreateHTTPRequest( method, "http://218.161.33.54/dota2" )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end


function SendHTTPRequestOpenRoom(method, values, callback)
	local req = CreateHTTPRequest( method, "http://218.161.33.54/open_room" )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end

function SendHTTPRequestCloseRoom(method, values, callback)
	local req = CreateHTTPRequest( method, "http://218.161.33.54/close_room" )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end

function SendHTTPRequestAddOnlineUser(method, values, callback)
	local req = CreateHTTPRequest( method, "http://218.161.33.54/add_online_user" )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end

function Nobu:OnPlayerConnectFull(keys)
    local player = PlayerInstanceFromIndex(keys.index + 1)
	local pID = keys.index
	local steamID = PlayerResource:GetSteamAccountID(pID)
    print("steamID "..steamID)

    ShowMessage("跳狗")
	Msg("就是你")
	GameRules:SendCustomMessage("#別再跳了", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
	GameRules:SendCustomMessage("#你媽媽", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
	GameRules:SendCustomMessage("#會傷心的", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
	SendHTTPRequestAddOnlineUser("POST",
		{
			id = tostring(steamID),
		},
		function(result)
			print(result)
		end
		)
	SendHTTPRequestBan("POST",
		{
			id = tostring(steamID),
		}, 
		function(result)
			print(result)
		end
	)
end

function Nobu:Server()
	
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(Nobu, 'OnPlayerConnectFull'), self)
	-- 產生隨機數種子，主要是為了程序中的隨機數考慮
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','') 
	math.randomseed(tonumber(timeTxt))--GetSystemTime	string GetSystemTime()	獲取真實世界的時間
	SendToConsole("r_farz 60000")

    Timers:CreateTimer( 5, function()
    	local ids = {}
    	for pID = 0, 9 do
	    	local steamID = PlayerResource:GetSteamAccountID(pID)
	    	ids["id_"..(pID+1)] = tostring(steamID)
	    end
  		SendHTTPRequestOpenRoom("POST",
		ids, 
		function(result)
			print(result)
			if (result == "error") then
				player:Destroy()
			end
			-- Decode response into a lua table
			local resultTable = {}
			if not pcall(function()
				resultTable = JSON:decode(result)
			end) then
				Warning("[dota2.tools.Storage] Can't decode result: " .. result)
			end
		end )

      return nil
    end)
end
