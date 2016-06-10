print ( '[Nobu] ADDON INIT EXECUTED' )

--global
	GameRules.Nobu = class({})
--endglobal

--require
    -------------------------------------------------------------------------
    --

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
--endrequire

function Precache( context )
	local zr={
    "models/items/death_prophet/corset_of_the_mortal_coil/corset_of_the_mortal_coil.vmdl",
    }
     
	local t=#zr;
	for i=1,t do
      PrecacheResource( "model", zr[i], context)
    end
    print("done loading shiping")
end

-- 載入項目所有文件
loadModule ( 'library/timers' )
loadModule ( 'library/chetcodeselfmode' )
loadModule ( 'computer_system/chubing' )
loadModule ( 'main' )
loadModule ( 'util' )
loadModule ( 'amhc_library/amhc' )
loadModule ( 'library/events/eventfordamage' )
loadModule ( 'library/events/eventfororder' )
loadModule ( 'library/events/eventforlevelup' )
loadModule ( 'library/events/eventforpichero' )
loadModule ( 'library/events/eventforspawned' )
loadModule ( 'library/events/eventforkill' )
loadModule ( 'library/math' )
loadModule ( 'library/common/dummy' )
loadModule ( 'library/common/word' )
loadModule ( 'library/common/api' )
--

-- Create the game mode when we activate
function Activate()
	Lua_of_main()
	AMHCInit()

	--<< ↓ ↓ ↓ 05.09.16更新 ↓ ↓ ↓ >>
	GameRules.Nobu:InitGameMode()
	--<< ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ >>

	--test
	--GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
end
  
function GameRules.Nobu:InitGameMode()
  --<< ↓ ↓ ↓ 05.09.16更新 ↓ ↓ ↓ >> 
  GameRules:GetGameModeEntity():SetExecuteOrderFilter( GameRules.Nobu.eventfororder, self )

  --<< ↓ ↓ ↓ 05.23更新 ↓ ↓ ↓ >> 
  GameRules:GetGameModeEntity():SetDamageFilter( GameRules.Nobu.DamageFilterEvent, self )

  --<< ↓ ↓ ↓ 05.24更新 ↓ ↓ ↓ >> 
  ListenToGameEvent('dota_player_gained_level', GameRules.Nobu.LevelUP, self)

  ListenToGameEvent("dota_player_pick_hero",GameRules.Nobu.PickHero, self)

  ListenToGameEvent('npc_spawned', GameRules.Nobu.OnHeroIngame, self)  

  ListenToGameEvent( "entity_killed", GameRules.Nobu.OnUnitKill, self )
end
--<<↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑>>

