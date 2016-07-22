--[[
Bug:
  O阿市R可以打建築物
  O阿市W沒有特效
]]

print ( '[Nobu] ADDON INIT EXECUTED' )

--【全局變量】
_G.nobu_debug =  true--IsInToolsMode() --是否在測試模式
_G.nobu_server_b = false

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
loadModule ( 'util_of_nobu') --自訂義的api
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
------test-------
loadModule ( 'test' ) --6/24增加
loadModule ( 'events' ) --6/24增加
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

--require('internal/util')
require('gamemode')
--


function Nobu:Init_Event_and_Filter_GameMode()
  --【測試模式】
  if nobu_debug then
    Test_main(self)
  end

  --【Filter】
  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Nobu.eventfororder, self )
  GameRules:GetGameModeEntity():SetDamageFilter( Nobu.DamageFilterEvent, self )
  GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(Nobu, "ModifyGoldFilter"), Nobu)
  GameRules:GetGameModeEntity():SetAbilityTuningValueFilter(Dynamic_Wrap(Nobu, "AbilityTuningValueFilter"), Nobu)
  GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(Nobu, "SetItemAddedToInventoryFilter"), Nobu)  --用来控制物品被放入物品栏时的行为
  GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(Nobu, "SetModifyExperienceFilter"), Nobu)  --經驗值
  GameRules:GetGameModeEntity():SetTrackingProjectileFilter(Dynamic_Wrap(Nobu, "SetTrackingProjectileFilter"), Nobu)  --投射物

  --【Evnet】
  Nobu.Event ={
  ListenToGameEvent('dota_player_gained_level', Nobu.LevelUP, self),
  ListenToGameEvent("dota_player_pick_hero",Nobu.PickHero, self),
  ListenToGameEvent('npc_spawned', Nobu.OnHeroIngame, self)  ,
  ListenToGameEvent("entity_killed", Nobu.OnUnitKill, self ),
  ListenToGameEvent("player_chat",Nobu.Chat,self), --玩家對話事件
  --ListenToGameEvent( "item_purchased", test, self ) --false
  --ListenToGameEvent( "dota_item_used", test, self ) --false
  --ListenToGameEvent("dota_inventory_item_changed", Nobu.Item_Changed, self ), --false
  ListenToGameEvent("game_rules_state_change", Nobu.OnGameRulesStateChange , self),  --監聽遊戲進度
  ListenToGameEvent("dota_player_gained_level", Nobu.LevelUP, self),   --升等事件
  ListenToGameEvent('dota_player_learned_ability', Nobu.Learn_Ability, self),  --學習技能
  ListenToGameEvent('player_connect_full', Nobu.Connect_Full, self) , --連結完成(遊戲內大廳)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(Nobu, 'OnDisconnect'), self)  ,
  ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(Nobu, 'OnItemPurchased'), self) , --購買物品事件
  ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(Nobu, 'OnItemPickedUp'), self) ,
  ListenToGameEvent('player_changename', Dynamic_Wrap(Nobu, 'OnPlayerChangedName'), self), --?
  ListenToGameEvent('player_connect', Dynamic_Wrap(Nobu, 'PlayerConnect'), self), --?
  --ListenToGameEvent('player_say', Dynamic_Wrap(Nobu, 'PlayerSay'), self), --?
  --ListenToGameEvent('dota_pause_event', Dynamic_Wrap(Nobu, 'Pause'), self), --無效

  ListenToGameEvent('entity_hurt', Dynamic_Wrap(Nobu, 'OnEntityHurt'), self) --傷害事件
  }

  --【Js Evnet】
  -- CustomGameEventManager:RegisterListener("Attachment_UpdateUnit", Dynamic_Wrap(Nobu, "Attachment_UpdateUnit"))

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
      GameRules:SendCustomMessage("作者: David & Damody & 螺絲  | 美術：阿荒老師 | 顧問：FN" , DOTA_TEAM_GOODGUYS, 0)
      GameRules:SendCustomMessage("dota2信長目前還在測試階段 請多見諒", DOTA_TEAM_GOODGUYS, 0)
  end

  --遊戲開始
  if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    --出兵觸發
    if _G.GameMap == "Nobu" then
      ShuaGuai()
    end
  end
end

function Nobu:InitGameMode()
  print( "[Nobu] Nobu:InitGameMode is loaded." )

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
  GameRules:SetCustomGameEndDelay(30) --遊戲結束時間
  GameRules:SetCustomVictoryMessageDuration(30)  --遊戲結束發送訊息時間
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
    print("[Nobu] Activate")
    -- Script_reload_B = true
    -- StopListeningToAllGameEvents(Nobu:GetEntityHandle())

    AMHCInit()
    if _G.nobu_server_b then
      Nobu:OpenRoom() --Server Init
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
