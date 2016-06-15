                            --【6/14】 
                            -- require('internal/util')
                            -- require('gamemode')







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
                          --【6/14】 
                          --[[
                            This function is used to precache resources/units/items/abilities that will be needed
                            for sure in your game and that will not be precached by hero selection.  When a hero
                            is selected from the hero selection screen, the game will precache that hero's assets,
                            any equipped cosmetics, and perform the data-driven precaching defined in that hero's
                            precache{} block, as well as the precache{} block for any equipped abilities.

                            See GameMode:PostLoadPrecache() in gamemode.lua for more information
                            ]]

                            -- DebugPrint("[BAREBONES] Performing pre-load precache")

                            -- -- Particles can be precached individually or by folder
                            -- -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
                            -- PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
                            -- PrecacheResource("particle_folder", "particles/test_particle", context)

                            -- -- Models can also be precached by folder or individually
                            -- -- PrecacheModel should generally used over PrecacheResource for individual models
                            -- PrecacheResource("model_folder", "particles/heroes/antimage", context)
                            -- PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
                            -- PrecacheModel("models/heroes/viper/viper.vmdl", context)
                            -- --PrecacheModel("models/props_gameplay/treasure_chest001.vmdl", context)
                            -- --PrecacheModel("models/props_debris/merchant_debris_chest001.vmdl", context)
                            -- --PrecacheModel("models/props_debris/merchant_debris_chest002.vmdl", context)

                            -- -- Sounds can precached here like anything else
                            -- PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)

                            -- -- Entire items can be precached by name
                            -- -- Abilities can also be precached in this way despite the name
                            -- PrecacheItemByNameSync("example_ability", context)
                            -- PrecacheItemByNameSync("item_example_item", context)

                            -- -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
                            -- -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
                            -- PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
                            -- PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
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
loadModule ( 'utilities' ) --6/14增加
--

-- Create the game mode when we activate
function Activate()
                          --【6/14】 
                          -- GameRules.GameMode = GameMode()
                          -- GameRules.GameMode:_InitGameMode()
                          
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

