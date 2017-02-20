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
--loadModule ( 'computer_system/Game_Init' ) --6/17增加
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
--loadModule ( 'libraries/selection')
--loadModule ( 'libraries/gatherer')
------電腦系統-----
loadModule ( 'computer_system/chubing' ) --出兵
loadModule ( 'computer_system/surrender' ) -- 投降機制
loadModule ( 'server' ) --6/24增加
------test-------
--loadModule ( 'test' ) --6/24增加
loadModule ( 'physics')



loadModule ( 'events' ) --6/24增加
loadModule ( 'nobu_init' ) --6/24增加
loadModule ( 'GameRulesStateChange' ) --6/24增加
--
-- require ( "util/damage" )
-- require ( "util/stun" )
-- require ( "util/pauseunit" )
--require ( "util/silence" )
--require ( "util/magic_immune" )
--require ( "util/Precache" )
-- require ( "util/timers" )
-- require ( "util/util" )
-- require ( "util/disarmed" )
-- require ( "util/invulnerable" )
-- require ( "util/graveunit" )
-- require ( "util/collision" )
-- require ( "util/nodamage" )
-- require ( "util/CheckItemModifies")

--require('internal/util')
-- require('gamemode')
--

-- nobu
loadModule ( 'nobu_modifiers/nobu_modifier_spell_hint' ) -- 可以顯示施法範圍