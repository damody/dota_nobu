print ('[Nobu] main lua script Starting..' )

--global
	----------------------------------------
	--game
	--

	--game
	STARTING_GOLD = 500--650

	DEBUG = true
	GameMode = nil

	TRUE = 1
	FALSE = 0
	ADD_HERO_WEARABLES_LOCK = 0
	ADD_HERO_WEARABLES_ILLUSION_LOCK = 0
--endglobal

if CEasyGameMode == nil then
	CEasyGameMode = class({})
end

function CEasyGameMode:InitGameMode()
	print( "[Nobu] CEasyGameMode:InitGameMode is loaded." )

	--設置遊戲準備時間
	GameRules:SetPreGameTime( 0.00 )

	-- 設定選擇英雄時間
	GameRules:SetHeroSelectionTime(15)

	-- 設定是否可以選擇相同英雄
	GameRules:SetSameHeroSelectionEnabled( true )

	-- 是否使用自定義的英雄經驗
  	GameRules:SetUseCustomHeroXPValues ( true )
  	
  	-- 設定每秒工資數
  	GameRules:SetGoldPerTick(6)

  	-- 允許自定義英雄等級
  	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)

  	--最大等級
  	MaxLevel = 50

  	--升級所需經驗
	XpTable = {}
	local xp = 50
	for i=1,MaxLevel do
		XpTable[i]=xp
		xp = xp + i*50
	end
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(MaxLevel)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XpTable)
	
	--監聽遊戲進度
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CEasyGameMode,"OnGameRulesStateChange"), self)

	--監聽單位被擊殺的事件,用於刷怪
	ListenToGameEvent("entity_killed", Dynamic_Wrap(CEasyGameMode, "OnEntityKilled"), self)
end

function CEasyGameMode:OnGameRulesStateChange( keys )
	print("[Nobu] CEasyGameMode:OnGameRulesStateChange is loaded.")

	--獲取遊戲進度
	local newState = GameRules:State_Get()

	--選擇英雄階段
	if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		for playerID=0,(DOTA_MAX_TEAM_PLAYERS - 1) do
			local player = PlayerResource:GetPlayer(playerID)
			if player then
				if player:GetTeam() == DOTA_TEAM_BADGUYS then
					player:SetTeam(DOTA_TEAM_GOODGUYS)
				end
			end
		end
	end

	--遊戲在準備階段
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then

		--[[獲取刷怪點實體
		for i=2,5 do
			local str = string.format("ShuaGuai_".."%d",i)
			ShuaGuai_entity[i-1]=Entities:FindByName(nil,str)
		end]]
	end

	--遊戲開始
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--出兵觸發
		ShuaGuai()
	end
end


--CP
function CEasyGameMode:OnEntityKilled( keys )
	print("OnEntityKilled")
	DeepPrintTable(keys)

	-- --獲取被殺單位
	-- local unit = EntIndexToHScript(keys.entindex_killed)

	-- --循環判斷是否是刷出的怪
	-- for i,name in pairs(ShuaGuai_unit) do
	-- 	if unit:GetUnitName() == name then
	-- 		--如果是就-1
	-- 		GameRules.ShuaGuai_num = GameRules.ShuaGuai_num - 1

	-- 		--當剩餘的怪物數量小於等於0就代表怪物被清空
	-- 		--這時刷出新的一波怪物
	-- 		if GameRules.ShuaGuai_num <= 0 then
	-- 			ShuaGuai()
	-- 		end
	-- 	end
	-- end
end

function Lua_of_main()
	CEasyGameMode:InitGameMode()
end