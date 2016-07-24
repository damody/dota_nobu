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

-- 測試模式送裝
function for_test_equiment()
  Timers:CreateTimer ( 1, function ()
        local test_ent = PlayerResource:GetPlayer(0):GetAssignedHero()
        if (test_ent == nil) then
          return 1
        end
        local item_point = test_ent:GetAbsOrigin()
        Test_ITEM ={
          "item_c05",
          "item_D01",
          "item_D02",
          "item_D03",
          "item_D09"
        }
        for i,v in ipairs(Test_ITEM) do
          local item = CreateItem(v,nil, nil)
          print(v)
          CreateItemOnPositionSync(item_point+Vector(i*100,0), item)
        end
        return nil
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
	elseif(newState == DOTA_GAMERULES_STATE_STRATEGY_TIME) then

	elseif(newState == DOTA_GAMERULES_STATE_TEAM_SHOWCASE) then --選擇英雄階段

	elseif(newState == DOTA_GAMERULES_STATE_PRE_GAME) then --當英雄選擇結束 --6
    if (_G.nobu_debug) then -- 測試模式給裝
      for_test_equiment()
    end
    if _G.nobu_server_b then
      Nobu:OpenRoom()
    end
    GameRules:SendCustomMessage("歡迎來到 信長之野望", DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("作者: David & Damody & 螺絲  | 美術：阿荒老師 | 顧問：FN" , DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("dota2信長目前還在測試階段 請多見諒", DOTA_TEAM_GOODGUYS, 0)
	elseif(newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then --遊戲開始 --7
    --出兵觸發
    if _G.nobu_chubing_b then
      ShuaGuai()
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
