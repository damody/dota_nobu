print ( '[Nobu] ADDON INIT EXECUTED' )

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
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheResource( "particle", "particles/base_attacks/ranged_badguy.vpcf", context )
	PrecacheResource( "particle", "particles/neutral_fx/black_dragon_attack.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_crystalmaiden/maiden_base_attack.vpcf", context )
end

-- 載入項目所有文件
loadModule ( 'library/timers' )
loadModule ( 'library/chetcodeselfmode' )
loadModule ( 'computer_system/chubing' )
loadModule ( 'main' )
loadModule ( 'amhc_library/amhc' )
loadModule ( 'library/events/eventfororder' )
--

-- Create the game mode when we activate
function Activate()
	Lua_of_main()
	AMHCInit()

	--<< ↓ ↓ ↓ 05.09.16更新 ↓ ↓ ↓ >>
	Nobu:InitGameMode()
	--<< ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ >>

	--test
	--GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
end

--<< ↓ ↓ ↓ 05.09.16更新 ↓ ↓ ↓ >>   
--事件:OnOrder
Nobu = class({})

function Nobu:FilterExecuteOrder( filterTable )
	eventfororder( filterTable )
	return true --一定要true 要不然單位接收不到命令
end

function Nobu:InitGameMode()
  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap(Nobu, "FilterExecuteOrder" ), self )
end
--<<↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑>>


