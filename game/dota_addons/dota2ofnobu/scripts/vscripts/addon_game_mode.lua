print ( '[Nobu-lua] ADDON INIT EXECUTED' )

--【全局變量】
_G.nobu_debug =  true--IsInToolsMode() --是否在測試模式
_G.nobu_server_b = true

if Nobu == nil then
  _G.Nobu = class({})
else
  --先Stop事件，為了reload script用
  for i,v in ipairs(Nobu.Event) do
    StopListeningToGameEvent(v)
  end
  -- print(#Nobu.Event)

  --停止filter

  --GameRules:GetGameModeEntity():ClearDamageFilter()
  GameRules:GetGameModeEntity():ClearExecuteOrderFilter()
  GameRules:GetGameModeEntity():ClearModifyGoldFilter()
  GameRules:GetGameModeEntity():ClearDamageFilter()
  --GameRules:GetGameModeEntity():ClearAbilityTuningValueFilter()

  --重新註冊
  Nobu = nil
  _G.Nobu = class({})

  --重新註冊用
  Script_reload_B = true
end

require('require')

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
    if _G.nobu_server_b then
      Nobu:OpenRoom()
    end
    GameRules:SendCustomMessage("歡迎來到 信長之野望", DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("作者: David & Damody & 螺絲  | 美術：阿荒老師 | 顧問：FN" , DOTA_TEAM_GOODGUYS, 0)
    GameRules:SendCustomMessage("dota2信長目前還在測試階段 請多見諒", DOTA_TEAM_GOODGUYS, 0)
	elseif(newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS) then --遊戲開始 --7
    --出兵觸發
    if _G.GameMap == "Nobu" then
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

function Nobu:InitGameMode()
  print( "[Nobu-lua] Nobu:InitGameMode is loaded." )

  --【Varible】
  _G.GameMap = GetMapName()
  local GameMode = GameRules:GetGameModeEntity()

  --【模式判斷】
  if _G.GameMap == "" then
  end

  --【Setup rules】
  -- --LimitPathingSearchDepth(0.5)
  -- --GameRules:SetHeroRespawnEnabled( false )
  GameRules:SetUseUniversalShopMode( false ) --开启/关闭全地图商店模式
  GameRules:SetSameHeroSelectionEnabled( true )
  GameRules:SetHeroSelectionTime( 0 )--設定選擇英雄時間
  GameRules:SetPreGameTime( 50 )--設置遊戲準備時間
  -- GameRules:SetPostGameTime( 9001 )
  GameRules:SetTreeRegrowTime( 10000.0 )--设置砍倒的树木重生时间
  GameRules:SetUseCustomHeroXPValues ( true )-- 是否使用自定義的英雄經驗
  GameRules:SetGoldPerTick(6)-- 設置金錢
  GameRules:SetGoldTickTime(1)--金錢跳錢秒數
  GameRules:SetUseBaseGoldBountyOnHeroes( true ) --设置是否对英雄使用基础金钱奖励
  GameRules:SetFirstBloodActive(true) --設置第一殺獎勵
  GameRules:SetCustomGameEndDelay(1) --遊戲結束時間 --正常30
  GameRules:SetCustomVictoryMessageDuration(1)  --遊戲結束發送訊息時間
  -- GameRules:SetCustomGameSetupTimeout(20)
  -- GameRules:SetHeroMinimapIconScale( 1 )
  -- GameRules:SetCreepMinimapIconScale( 1 )
  -- GameRules:SetRuneMinimapIconScale( 1 )
  -- GameRules:SetFirstBloodActive( false )
  -- GameRules:SetHideKillMessageHeaders( true )
  -- GameRules:EnableCustomGameSetupAutoLaunch( false )

  --【Set game GameMode rules】
  -- GameMode = GameRules:GetGameModeEntity()
  GameMode:SetRecommendedItemsDisabled( true )--禁止推薦
  GameMode:SetBuybackEnabled( false ) --關閉英雄買活功能
  GameMode:SetTopBarTeamValuesOverride ( true )
  --GameMode:SetTopBarTeamValuesVisible( true ) --?
  -- GameMode:SetUnseenFogOfWarEnabled( UNSEEN_FOG_ENABLED )
  GameMode:SetTowerBackdoorProtectionEnabled( false )--關閉偷塔保護
  -- GameMode:SetGoldSoundDisabled( false )
  GameMode:SetRemoveIllusionsOnDeath( true )--死亡會不會有陰影
  --GameMode:SetAnnouncerDisabled( true )
  GameMode:SetLoseGoldOnDeath( false )--死亡會不會掉錢
  --GameMode:SetCameraDistanceOverride( 1234 )--攝像頭距離
  GameMode:SetUseCustomHeroLevels ( true )-- 允許自定義英雄等級
  --GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

  if _G.nobu_debug then
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)--地圖視野
  end
  GameMode:SetStashPurchasingDisabled( true )-- 是否关闭/开启储藏处购买功能
  GameMode:SetMaximumAttackSpeed( 500 ) --最大攻擊速度
  GameMode:SetAnnouncerDisabled(false) --禁止播音員
  GameMode:SetFountainConstantManaRegen(-1) --溫泉回魔(固定值)
  GameMode:SetFountainPercentageHealthRegen(-1) --溫泉回血(百分比)
  GameMode:SetFountainPercentageManaRegen(-1) --溫泉回魔(百分比)
  GameMode:SetMaximumAttackSpeed(400) --最大攻擊速度
  GameMode:SetMinimumAttackSpeed(0) --最小攻擊速度
  GameMode:SetGoldSoundDisabled( false )
  GameMode:SetStashPurchasingDisabled ( false ) --倉庫
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
  MaxLevel = 20 --最大等級
  XpTable = {} --升級所需經驗
  local xp = 50
  for i=1,MaxLevel do
    XpTable[i]=xp
    xp = xp + i*50
  end
  GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(MaxLevel)
  GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XpTable)--類型為table
end

--【初始化】
function Activate()
  -- if Script_reload_B == false then
    print("[Nobu-lua] Activate")
    -- Script_reload_B = true
    -- StopListeningToAllGameEvents(Nobu:GetEntityHandle())

    AMHCInit()
    if _G.nobu_server_b then
      Nobu:CheckAFK() --Server Init
    end
    Nobu:InitGameMode()
    Nobu:Init_Event_and_Filter_GameMode() --管理事件、Filter
  -- end
end

--【資源預載】
function Precache( context )
  -- 【KV資源預載】
  --PrecacheEveryThingFromKV(context)   --有問題:會超lag

  -- 【特效預載】
    local particle_Precache_Table = {
    --武田勝賴
    "particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf",
    "particles/b34e/b34e.vpcf",
    "particles/b34e/b34e2.vpcf",

    --道雪
    "particles/c07w/c07w.vpcf",
    "particles/c07e3/c07e3.vpcf",
    "particles/econ/items/razor/razor_punctured_crest/razor_static_link_blade.vpcf",
    "particles/c07e3/c07e3.vpcf",
    "particles/07t/c07t.vpcf",
    "particles/07t/c07t_zc.vpcf",
    "particles/b05e/b05e.vpcf",

    --阿市
    "particles/c17w/c17w.vpcf",
    --秋山
    "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf",
    "particles/b24t/b01t.vpcf",
    "particles/b24w/b24w.vpcf" ,
    "particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",
    "particles/b24t3/b24t3.vpcf",
    "particles/b13e/b13e.vpcf",
    --鳥居
    "particles/generic_gameplay/generic_hit_blood.vpcf",
    "particles/a16r3/a16r3.vpcf"



    --注意要加,
    }
    for i,v in ipairs(particle_Precache_Table) do
      PrecacheResource("particle", v, context)
    end

  -- 【聲音預載】
    local sound_Precache_Table = {
      --武田勝賴
      -- "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts"


    "soundevents/ITEMS/D09.vsndevts",
    "soundevents/ITEMS/D03.vsndevts",
    "soundevents/custom_sounds.vsndevts",
    }
    for i,v in ipairs(sound_Precache_Table) do
      PrecacheResource("soundfile", v, context)
    end
end

--特別做來script reload
if Script_reload_B then
  print("Script_reload_B")
  Timers:CreateTimer(1,function()
    Activate()
  end)
end
