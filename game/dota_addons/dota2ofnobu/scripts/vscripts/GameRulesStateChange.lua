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
    if _G.nobu_server_b then
      Nobu:OpenRoom()
    end
    GameRules:SendCustomMessage("歡迎來到 AON信長的野望 20.4HI", DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("5分鐘後可以打 -ff 投降" , DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("目前作者: Damody, Tenmurakumo, BedRock, 佐佐木小籠包", DOTA_TEAM_GOODGUYS, 0)
	elseif(newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then --遊戲開始 --7
		--刪除建築物無敵
	  local allBuildings = Entities:FindAllByClassname('npc_dota_building')
	  for i = 1, #allBuildings, 1 do
	     local building = allBuildings[i]
	     if building:HasModifier('modifier_invulnerable') then
	        building:RemoveModifierByName('modifier_invulnerable')
	     end
	  end
	  Timers:CreateTimer(1, function()
	  	--SendToConsole("sv_cheats 1")
	    --SendToConsole("r_farz 7000")
	  end)
    --出兵觸發
    if _G.nobu_chubing_b then
      ShuaGuai()
    end
    -- 增加單挑殺人得分
    Timers:CreateTimer(10, function()
    	if _G.mo then
	    	for _,hero in ipairs(HeroList:GetAllHeroes()) do
				if not hero:IsIllusion() then
					hero:AddAbility("play_1v1"):SetLevel(1)
					local nobu_id = _G.heromap[hero:GetName()]
					GameRules: SendCustomMessage("<font color='#aaaaff'>".._G.hero_name_zh[nobu_id].."得到 "..hero.score.." 分</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
				end
			end
	    end
    end)
    

    Timers:CreateTimer(120, function()
    	_G.can_bomb = true
	    GameRules:SendCustomMessage("可以開始使用爆裂彈了！",0,0)
    end)
    Timers:CreateTimer(1200, function()
    	_G.full_reward6300 = true
	    GameRules:SendCustomMessage("犒賞有攻擊加成了！",0,0)
    end)
    
    Timers:CreateTimer(2, function ()
		for i=-3,3 do
		  for j=-3,3 do
		    AddFOWViewer(6, Vector(i*5000,j*5000,0), 10000, 99999, false)
		  end
		end
		end)

    

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
