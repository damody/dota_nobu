gamestates =
{
	[0] = "DOTA_GAMERULES_STATE_INIT",
	[1] = "DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD",
	[2] = "DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP",
	[3] = "DOTA_GAMERULES_STATE_HERO_SELECTION",
	[4] = "DOTA_GAMERULES_STATE_STRATEGY_TIME",
	[5] = "DOTA_GAMERULES_STATE_TEAM_SHOWCASE",
	[6] = "DOTA_GAMERULES_STATE_PRE_GAME",
	[7] = "DOTA_GAMERULES_STATE_GAME_IN_PROGRESS",
	[8] = "DOTA_GAMERULES_STATE_POST_GAME",
	[9] = "DOTA_GAMERULES_STATE_DISCONNECT"
}


function SendHTTPRequest(path, method, values, callback)
	local req = CreateHTTPRequestScriptVM( method, "http://172.104.107.13/"..path )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end

-- 測試模式送裝
function for_test_equiment()
  Timers:CreateTimer ( 1, function ()
		for ii=0,9 do
			local test_ent = PlayerResource:GetPlayer(ii):GetAssignedHero()
			if (test_ent == nil) then
			  return 1
			end
			local item_point = test_ent:GetAbsOrigin()
			Test_ITEM ={
			  "item_flash_ring"
			}
			for i,v in ipairs(Test_ITEM) do
			  local item = CreateItem(v,nil, nil)
			  print(v)
			  CreateItemOnPositionSync(item_point+Vector(i*100,0), item)
			end
			return nil
		end
      end)
end

--[[
[Nobu-lua] GameRules State Changed: 	DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP
think:
Q1.測試模式不會有state_init & DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD
Q2.每一個玩家進入事件異步，還是同步呢?
]]
function Nobu:OnGameRulesStateChange( keys )
  --獲取遊戲進度
  local newState = GameRules:State_Get()
  print("[Nobu-lua] GameRules State Changed: ",gamestates[newState])

  if(newState == DOTA_GAMERULES_STATE_INIT) then

	elseif(newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD) then
		--self.bSeenWaitForPlayers = true
	elseif(newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP) then

	elseif(newState == DOTA_GAMERULES_STATE_HERO_SELECTION) then --選擇英雄階段
		-- self:PostLoadPrecache()
		-- self:OnAllPlayersLoaded()
		for i=0,20 do
			PlayerResource:SetGold(i,2000,false)--玩家ID需要減一
		end
	elseif(newState == DOTA_GAMERULES_STATE_STRATEGY_TIME) then

	elseif(newState == DOTA_GAMERULES_STATE_TEAM_SHOWCASE) then --選擇英雄階段
		for playerID = 0, 9 do
			local id       = playerID
			local p        = PlayerResource:GetPlayer(id)
			if p ~= nil then
			  p:MakeRandomHeroSelection()
			end
		end
	elseif(newState == DOTA_GAMERULES_STATE_PRE_GAME) then --當英雄選擇結束 --6
    if (_G.nobu_debug) then -- 測試模式給裝
      for_test_equiment()
    end
    
    GameRules:SendCustomMessage("歡迎來到 AON信長的野望 20.7B", DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("5分鐘後可以打 -ff 投降" , DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("目前作者: Damody, 佐佐木小籠包, DowDow", DOTA_TEAM_GOODGUYS, 0)
	elseif(newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then --遊戲開始 --7
	if _G.nobu_server_b then
      Nobu:OpenRoom()
    end
		--刪除建築物無敵
	  local allBuildings = Entities:FindAllByClassname('npc_dota_building')
	  for i = 1, #allBuildings, 1 do
	     local building = allBuildings[i]
	     if building:HasModifier('modifier_invulnerable') then
	        building:RemoveModifierByName('modifier_invulnerable')
	     end
	  end
    --出兵觸發
    if _G.nobu_chubing_b then
      ShuaGuai()
    end
    -- 增加單挑殺人得分
    Timers:CreateTimer(10, function()
    	if _G.mo then
	    	for _,hero in ipairs(HeroList:GetAllHeroes()) do
				if not hero:IsIllusion() and not hero:HasModifier("modifier_play_1v1") and hero:IsAlive() then
					hero:AddAbility("play_1v1"):SetLevel(1)
				end
			end
	    end
	    return 5
    end)
    Timers:CreateTimer(1200, function()
    	if _G.mo then
	    	local c1 = HeroList:GetAllHeroes()[1]
	    	local c2 = HeroList:GetAllHeroes()[2]
	    	if c1 and c2 then
	    		if c1.score == nil then c1.score = 0 end
	    		if c2.score == nil then c2.score = 0 end
	    		if c1.score > c2.score then
	    			c1.score = 3
	    		end
	    		if c2.score > c1.score then
	    			c2.score = 3
	    		end
	    	end
	    end
	    return 1
    end)
    local ccpres = 0
	Timers:CreateTimer( 0, function()
		ccpres = ccpres + 1
		for n=2,3 do
			local pres = (ccpres/3)*100
			if GetMapName() == "nobu_rank" then
				pres = prestige[n] - goldprestige[n]
			end
			if pres > 100 then
				local money = math.floor(pres/100)*50
				if money > 300 then
					money = 300
				end
				if n == 3 then
					GameRules: SendCustomMessage("<font color='#ffff00'>聯合將領得到了"..(money).."金錢支援</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
				elseif n == 2 then
					GameRules: SendCustomMessage("<font color='#ffff00'>織田將領得到了"..(money).."金錢支援</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
				end
				for playerID = 0, 9 do
					local player = PlayerResource:GetPlayer(playerID)
					if player then
						local hero = player:GetAssignedHero()
						if hero and hero:GetTeamNumber()==n then
							AMHC:GivePlayerGold_UnReliable(playerID, money)
						end
					end
				end
			end
		end
		return 60
		end)

    Timers:CreateTimer(60, function()
    	_G.can_bomb = true
	    GameRules:SendCustomMessage("可以開始使用爆裂彈了！",0,0)
    end)
    
    Timers:CreateTimer(2, function ()
			_G.war_magic_mana = 0
		end)
    local start = 0
    for playerID = 0, 9 do
		local id       = playerID
  		local p        = PlayerResource:GetPlayer(id)
  		local steamid = PlayerResource:GetSteamAccountID(id)
  		if tostring(steamid) == "19350721" then
  			Timers:CreateTimer(start, function()
	  			CustomUI:DynamicHud_Create(-1,"mainWin1","file://{resources}/layout/custom_game/game_info_dowdow.xml",nil)
				Timers:CreateTimer(6, function()
					CustomUI:DynamicHud_Destroy(-1,"mainWin1")
			        end)
				end)
  			start = start + 7
  		elseif tostring(steamid) == "55017646" then
  			Timers:CreateTimer(start, function()
	  			CustomUI:DynamicHud_Create(-1,"mainWin2","file://{resources}/layout/custom_game/game_info_night.xml",nil)
				Timers:CreateTimer(6, function()
					CustomUI:DynamicHud_Destroy(-1,"mainWin2")
			        end)
				end)
  			start = start + 7
  		elseif tostring(steamid) == "423877076" then
  			Timers:CreateTimer(start, function()
	  			CustomUI:DynamicHud_Create(-1,"mainWin3","file://{resources}/layout/custom_game/game_info_father.xml",nil)
				Timers:CreateTimer(6, function()
					CustomUI:DynamicHud_Destroy(-1,"mainWin3")
			        end)
				end)
  			start = start + 7
  		elseif tostring(steamid) == "128732954" then
  			Timers:CreateTimer(start, function()
	  			CustomUI:DynamicHud_Create(-1,"mainWin4","file://{resources}/layout/custom_game/game_info.xml",nil)
				Timers:CreateTimer(6, function()
					CustomUI:DynamicHud_Destroy(-1,"mainWin4")
			        end)
				end)
  			start = start + 7
  		
  		end
  	end

	elseif(newState == DOTA_GAMERULES_STATE_POST_GAME) then
    if _G.nobu_server_b then
        Nobu:CloseRoom()
    end
	elseif(newState == DOTA_GAMERULES_STATE_DISCONNECT) then

	end

  -- DOTA_GAMERULES_STATE_INIT	0
  -- DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD	1
  -- DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP	2
  -- DOTA_GAMERULES_STATE_HERO_SELECTION	3
  -- DOTA_GAMERULES_STATE_STRATEGY_TIME	4
  -- DOTA_GAMERULES_STATE_TEAM_SHOWCASE	5
  -- DOTA_GAMERULES_STATE_PRE_GAME	6
  -- DOTA_GAMERULES_STATE_GAME_IN_PROGRESS	7
  -- DOTA_GAMERULES_STATE_POST_GAME	8
  -- DOTA_GAMERULES_STATE_DISCONNECT	9
end
