--require("equilibrium_constant")
print ( '[Nobu-lua] ADDON INIT EXECUTED' )

--【全局變量】
_G.nobu_debug = false--IsInToolsMode() --是否在測試模式
_G.nobu_server_b = false
_G.nobu_chubing_b = true
_G.Nobu_Test = class({})

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

--【require】
require('require')


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

    --立花道雪
    "particles/c07w/c07w.vpcf",
    "particles/c07e3/c07e3.vpcf",
    "particles/econ/items/razor/razor_punctured_crest/razor_static_link_blade.vpcf",
    "particles/c07e3/c07e3.vpcf",
    "particles/07t/c07t.vpcf",
    "particles/07t/c07t_zc.vpcf",
    "particles/b05e/b05e.vpcf",

    --阿市
    "particles/c17w/c17w.vpcf",

    --秋山信友
    "particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf",
    "particles/b24t/b01t.vpcf",
    "particles/b24w/b24w.vpcf" ,
    "particles/units/heroes/hero_tiny/tiny_avalanche.vpcf",
    "particles/b24t3/b24t3.vpcf",
    "particles/b13e/b13e.vpcf",

    --羽柴秀吉
    "particles/econ/items/phoenix/phoenix_solar_forge/phoenix_sunray_solar_forge.vpcf",
    --鳥居元宗
    "particles/generic_gameplay/generic_hit_blood.vpcf",
    "particles/a16r3/a16r3.vpcf",
    -- 巨龍
    "particles/item/dragon.vpcf",
    -- 星杵
    "particles/item/item_club_of_nebula.vpcf",
    "particles/a07w5/a07w5.vpcf",
    "particles/a07w4/a07w4_c.vpcf",
    "particles/a34e2/a34e2.vpcf",
    "particles/a04r3/a04r3.vpcf"
    --注意要加,
    }
    for i,v in ipairs(particle_Precache_Table) do
      PrecacheResource("particle", v, context)
    end

    -- 【聲音預載】
    local sound_Precache_Table = {
      --武田勝賴
      -- "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts"
    "soundevents/items/item_the_overflame_art_of_war.vsndevts",
    "soundevents/items/D09.vsndevts",
    "soundevents/items/D03.vsndevts",
    "soundevents/custom_sounds.vsndevts",
    "soundevents/game_sounds_heroes/game_sounds_lich.vsndevts"
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
--[[
if true and not debug.bHookIsSet then
debug.sethook(function( ... )
  local info = debug.getinfo(2)
  local src = tostring(info.short_src)
  local name = tostring(info.name)
  if name ~= "__index" then
    print(debug.traceback("Crash "..src.." "..name))
  end
  -- body
end, "c")
debug.bHookIsSet = true
end
]]
