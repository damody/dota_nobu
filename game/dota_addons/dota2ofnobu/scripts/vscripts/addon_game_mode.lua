--[[
Bug:
  O阿市R可以打建築物
  O阿市W沒有特效
]]

print ( '[Nobu] ADDON INIT EXECUTED' )

--【全局變量】
if Nobu == nil then
  _G.Nobu = class({})
end
_G.nobu_debug =  true

-- 這個函數其實就是一個pcall，通過這個函數載入lua文件，就可以在載入的時候通過報錯發現程序哪裡錯誤了
-- 避免遊戲直接崩潰的情況
local function loadModule(name)
    local status, err = pcall(function()
        -- Load the module
        require(name)
    end)

    if not status then
        -- Tell the user about it
        print('WARNING: '..name..' failed to load!')
        print(err)
    end
end

-- 載入項目所有文件
------------------
loadModule ( 'varible_of_globals' )
loadModule ( 'util' )
loadModule ( 'amhc_library/amhc' )
loadModule ( 'library/math' )
loadModule ( 'library/timers' )
loadModule ( 'utilities' ) --6/14增加
------------------
loadModule ( 'computer_system/Game_Init' ) --6/17增加
------------------
--loadModule ( 'library/chetcodeselfmode' )
loadModule ( 'library/events/eventfordamage' )
loadModule ( 'library/events/eventfororder' )
loadModule ( 'library/events/eventforlevelup' )
loadModule ( 'library/events/eventforpichero' )
loadModule ( 'library/events/eventforspawned' )
loadModule ( 'library/events/eventforchat' )
loadModule ( 'library/events/eventforkill' )
loadModule ( 'library/common/dummy' ) --馬甲系統
loadModule ( 'library/common/word' )  --漂浮字系統
------電腦系統-----
loadModule ( 'computer_system/chubing' ) --出兵
loadModule ( 'server' ) --6/24增加
--
-- require ( "util/damage" )
-- require ( "util/stun" )
-- require ( "util/pauseunit" )
require ( "util/silence" )
require ( "util/magic_immune" )
require ( "util/Precache" )
-- require ( "util/timers" )
-- require ( "util/util" )
-- require ( "util/disarmed" )
-- require ( "util/invulnerable" )
-- require ( "util/graveunit" )
-- require ( "util/collision" )
-- require ( "util/nodamage" )
-- require ( "util/CheckItemModifies")
--
  
function Nobu:Init_Event_and_Filter_GameMode()
  --【Filter】
  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Nobu.eventfororder, self )
  GameRules:GetGameModeEntity():SetDamageFilter( Nobu.DamageFilterEvent, self )

  --【Evnet】
  ListenToGameEvent('dota_player_gained_level', Nobu.LevelUP, self)
  ListenToGameEvent("dota_player_pick_hero",Nobu.PickHero, self)
  ListenToGameEvent('npc_spawned', Nobu.OnHeroIngame, self)  
  ListenToGameEvent( "entity_killed", Nobu.OnUnitKill, self )
  ListenToGameEvent("player_chat",Nobu.Chat,self) --玩家對話事件
  --ListenToGameEvent( "dota_item_picked_up", test, self )
  --ListenToGameEvent( "item_purchased", test, self ) --false
  --ListenToGameEvent( "dota_item_purchased", test, self ) 
  --ListenToGameEvent( "dota_item_used", test, self ) --false
  --ListenToGameEvent( "dota_inventory_item_changed", test, self )
  ListenToGameEvent("game_rules_state_change", Nobu.OnGameRulesStateChange , self)  --監聽遊戲進度
end

function Nobu:OnGameRulesStateChange( keys )
  print("[Nobu] Nobu:OnGameRulesStateChange is loaded.")

  --獲取遊戲進度
  local newState = GameRules:State_Get()
  print(newState)

  --選擇英雄階段
  if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
  end

  --當英雄選擇結束
  if newState == DOTA_GAMERULES_STATE_PRE_GAME then
      GameRules:SendCustomMessage("歡迎來到 信長之野望", DOTA_TEAM_GOODGUYS, 0)
      GameRules:SendCustomMessage("作者: David Hund & Damody & 螺絲  | 美工：阿荒老師 | 顧問：FN" , DOTA_TEAM_GOODGUYS, 0)
      GameRules:SendCustomMessage("dota2信長目前還在測試階段 請多見諒", DOTA_TEAM_GOODGUYS, 0)
  end
  --遊戲開始
  if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    --出兵觸發
    ShuaGuai()
  end
end

function Nobu:InitGameMode()
  print( "[Nobu] Nobu:InitGameMode is loaded." )
  --【Varible】
  local GameMode = GameRules:GetGameModeEntity()

  --【Setup rules】
  -- --LimitPathingSearchDepth(0.5)
  -- --GameRules:SetHeroRespawnEnabled( false )
  GameRules:SetUseUniversalShopMode( false ) --开启/关闭全地图商店模式
  -- GameRules:SetSameHeroSelectionEnabled( true )
  GameRules:SetHeroSelectionTime( 15 )--設定選擇英雄時間
  GameRules:SetPreGameTime( 1 )--設置遊戲準備時間
  -- GameRules:SetPostGameTime( 9001 )
  GameRules:SetTreeRegrowTime( 10000.0 )--设置砍倒的树木重生时间
  GameRules:SetUseCustomHeroXPValues ( true )-- 是否使用自定義的英雄經驗
  GameRules:SetGoldPerTick(6)-- 設置金錢
  GameRules:SetGoldTickTime(1)--金錢跳錢秒數
  GameRules:SetUseBaseGoldBountyOnHeroes( true ) --设置是否对英雄使用基础金钱奖励
  -- GameRules:SetHeroMinimapIconScale( 1 )
  -- GameRules:SetCreepMinimapIconScale( 1 )
  -- GameRules:SetRuneMinimapIconScale( 1 )
  -- GameRules:SetFirstBloodActive( false )
  -- GameRules:SetHideKillMessageHeaders( true )
  -- GameRules:EnableCustomGameSetupAutoLaunch( false )

  --【Set game mode rules】
  -- GameMode = GameRules:GetGameModeEntity()        
  GameMode:SetRecommendedItemsDisabled( true )--禁止推薦
  GameMode:SetBuybackEnabled( false ) --關閉英雄買活功能
  -- GameMode:SetTopBarTeamValuesOverride ( true )
  -- GameMode:SetTopBarTeamValuesVisible( true )
  -- GameMode:SetUnseenFogOfWarEnabled( UNSEEN_FOG_ENABLED ) 
  GameMode:SetTowerBackdoorProtectionEnabled( false )--關閉偷塔保護
  -- GameMode:SetGoldSoundDisabled( false )
  GameMode:SetRemoveIllusionsOnDeath( true )--死亡會不會有陰影
  --GameMode:SetAnnouncerDisabled( true )
  GameMode:SetLoseGoldOnDeath( false )--死亡會不會掉錢
  GameMode:SetCameraDistanceOverride( 1234 )--攝像頭距離
  GameMode:SetUseCustomHeroLevels ( true )-- 允許自定義英雄等級
  --GameMode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
  GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)--地圖視野
  GameMode:SetStashPurchasingDisabled( true )-- 是否关闭/开启储藏处购买功能
  GameMode:SetMaximumAttackSpeed( 500 ) --最大攻擊速度
  --GameMode:SetCustomGameForceHero("npc_dota_hero_dragon_knight") --強迫選擇英雄 (可以跳過選角畫面)

  --【經驗值設定】
    MaxLevel = 25 --最大等級
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
    print("[Nobu] Activate")
    -- Script_reload_B = true
    -- StopListeningToAllGameEvents(Nobu:GetEntityHandle())

    AMHCInit()
    Nobu:Server() --Server Init
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
    --阿市
    "particles/c17w/c17w.vpcf",
    --秋山
    "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf",
    "particles/b24t/b01t.vpcf",
    "particles/b24w/b24w.vpcf" ,
    "particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",
    "particles/b24t3/b24t3.vpcf"

    }
    for i,v in ipairs(particle_Precache_Table) do
      PrecacheResource("particle", v, context)
    end

  -- 【聲音預載】
    local sound_Precache_Table = {
    "soundevents/ITEMS/D09.vsndevts",
    "soundevents/ITEMS/D03.vsndevts",
    "soundevents/custom_sounds.vsndevts",
    }
    for i,v in ipairs(sound_Precache_Table) do
      PrecacheResource("soundfile", v, context)
    end  
end 

--【特別】
-- Script_reload_B = true --專門做給Script_reload用
-- Activate()

--【Timer】
-- Script_reload_B = false
-- Timers:CreateTimer(1,function() 
--   Activate()
-- end)    