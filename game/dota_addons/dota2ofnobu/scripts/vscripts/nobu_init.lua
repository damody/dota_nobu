
function _G.Nobu:InitGameMode()
  print( "[Nobu-lua] Nobu:InitGameMode is loaded." )

  --【Varible】
  _G.GameMap = GetMapName()
  local GameMode = GameRules:GetGameModeEntity()

  --【模式判斷】
  if _G.GameMap == "" then
  end

  --【Setup rules】
  -- --LimitPathingSearchDepth(0.5)
  --GameRules:SetHeroRespawnEnabled( false )
  if false then
    --設定每隊人數
    GameRules:SetCustomGameTeamMaxPlayers(6, 1)
    
    --自定血條顏色
    SetTeamCustomHealthbarColor(2,255,150,150)
    SetTeamCustomHealthbarColor(3,150,150,255)
  end

  --GameRules:SetCustomGameTeamMaxPlayers(2, 7)
  --GameRules:SetCustomGameTeamMaxPlayers(3, 7)

  GameRules:SetUseUniversalShopMode( false ) --开启/关闭全地图商店模式
  GameRules:SetSameHeroSelectionEnabled( false )
  GameRules:SetHeroSelectionTime( 30 )--設定選擇英雄時間
  if _G.nobu_debug then
    GameRules:SetPreGameTime( 0 )--設置遊戲準備時間
  else
    GameRules:SetPreGameTime( 0 )--設置遊戲準備時間
  end
  -- GameRules:SetPostGameTime( 9001 )
  GameRules:SetTreeRegrowTime( 10000.0 )--设置砍倒的树木重生时间
  GameRules:SetUseCustomHeroXPValues ( true )-- 是否使用自定義的英雄經驗
  GameRules:SetGoldPerTick(20)-- 設置金錢
  GameRules:SetGoldTickTime(2)--金錢跳錢秒數
  GameRules:SetUseBaseGoldBountyOnHeroes( true ) --设置是否对英雄使用基础金钱奖励
  GameRules:SetFirstBloodActive(true) --設置第一殺獎勵
  GameRules:SetCustomGameEndDelay(30) --遊戲結束時間 --正常30
  GameRules:SetCustomVictoryMessageDuration(3)  --遊戲結束發送訊息時間
  GameRules:SetCustomVictoryMessage("天下布武！")
  -- GameRules:SetCustomGameSetupTimeout(20)
  -- GameRules:SetHeroMinimapIconScale( 1 )
  -- GameRules:SetCreepMinimapIconScale( 1 )
  -- GameRules:SetRuneMinimapIconScale( 1 )
  -- GameRules:SetFirstBloodActive( false )
  -- GameRules:SetHideKillMessageHeaders( true )
  -- GameRules:EnableCustomGameSetupAutoLaunch( false )

  --【Set game GameMode rules】
  -- GameMode = GameRules:GetGameModeEntity()
  GameMode:SetRecommendedItemsDisabled( false )--禁止推薦
  GameMode:SetBuybackEnabled( false ) --關閉英雄買活功能
  GameMode:SetTopBarTeamValuesOverride ( false )
  --GameMode:SetTopBarTeamValuesVisible( true ) --?
  -- GameMode:SetUnseenFogOfWarEnabled( UNSEEN_FOG_ENABLED )
  GameMode:SetTowerBackdoorProtectionEnabled( false )--關閉偷塔保護
  -- GameMode:SetGoldSoundDisabled( false )
  GameMode:SetRemoveIllusionsOnDeath( true )--死亡會不會有陰影
  --GameMode:SetAnnouncerDisabled( true )
  GameMode:SetLoseGoldOnDeath( false )--死亡會不會掉錢
  GameMode:SetCameraDistanceOverride( 1150 )--攝像頭距離
  GameMode:SetUseCustomHeroLevels ( true )-- 允許自定義英雄等級
  --GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

  if _G.nobu_debug then
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)--地圖視野
  end
  GameMode:SetStashPurchasingDisabled( false )-- 是否关闭/开启储藏处购买功能
  GameMode:SetAnnouncerDisabled(false) --禁止播音員
  GameMode:SetFountainConstantManaRegen(-1) --溫泉回魔(固定值)
  GameMode:SetFountainPercentageHealthRegen(-1) --溫泉回血(百分比)
  GameMode:SetFountainPercentageManaRegen(-1) --溫泉回魔(百分比)
  GameMode:SetMaximumAttackSpeed( 600 ) --最大攻擊速度
  GameMode:SetMinimumAttackSpeed(-1000) --最小攻擊速度
  GameMode:SetGoldSoundDisabled( false )
  GameMode:SetLoseGoldOnDeath( false )  --是否死亡掉錢
  --GameMode:SetCustomGameForceHero("npc_dota_hero_dragon_knight") --強迫選擇英雄 (可以跳過選角畫面)
  
  --【HUD】
  -- GameMode:SetHUDVisible(0,  false) --Clock
  -- GameMode:SetHUDVisible(1,  false)
  -- GameMode:SetHUDVisible(2,  false)
  -- GameMode:SetHUDVisible(3,  false) --Action Panel
  -- GameMode:SetHUDVisible(4,  false) --Minimap
  -- GameMode:SetHUDVisible(5,  false) --Inventory
  -- GameMode:SetHUDVisible(6,  false)
  -- GameMode:SetHUDVisible(7,  false)
  -- GameMode:SetHUDVisible(8,  false)
  -- GameMode:SetHUDVisible(9,  false)
  -- GameMode:SetHUDVisible(11, false)
  -- GameMode:SetHUDVisible(12, false)

  --【隨機種子】Random seed for RNG
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  -- --【經驗值設定】
  MaxLevel = 30 --最大等級
  XpTable = {} --升級所需經驗
  local xp = 80
  XpTable[1]=0
  for i=2,MaxLevel do
    XpTable[i]=xp
    xp = xp + i*60
    if i > 15 then
      --xp = xp + i*20
    end
  end
  GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(MaxLevel)
  GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XpTable)--類型為table
  -- 定时清理垃圾
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("collectgarbage"), function()
		collectgarbage()
		return 300
	end, 300)
end
