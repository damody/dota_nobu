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

function Nobu:OnPlayerConnectFull(keys)
    local player = PlayerInstanceFromIndex(keys.index + 1)
	local pID = keys.index
	local steamID = PlayerResource:GetSteamAccountID(pID)
    print("steamID "..steamID)
	
	SendHTTPRequestBan("POST",
		{
			id = tostring(steamID),
		}, 
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
		end
	)
end

function Nobu:Server()
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(Nobu, 'OnPlayerConnectFull'), self)
	-- 產生隨機數種子，主要是為了程序中的隨機數考慮
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','') 
	math.randomseed(tonumber(timeTxt))--GetSystemTime	string GetSystemTime()	獲取真實世界的時間
	SendToConsole("r_farz 60000")
    Timers:CreateTimer( 1, function()
  		SendToConsole("r_farz 60000")
      return 1
    end)
end
