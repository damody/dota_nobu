print ( '[Nobu-lua] varible_of_globals' )

-- local _mt_number = { __index = function() return 0 end }
-- local _mt_boolean = { __index = function() return false end }
-- local _mt_string = { __index = function() return "" end }

-- local function ExecuteFunc(s)
--     if _G[s] and type(_G[s]) == 'function' then
--         pcall(_G[s])
--     else
-- 	    jass.ExecuteFunc(s)
--     end
-- end

--【BJ函數】
_G.bj_PI = 3.14159
_G.bj_E = 2.71828
_G.bj_CELLWIDTH = 128.0
_G.bj_CLIFFHEIGHT = 128.0
_G.bj_UNIT_FACING = 270.0
_G.bj_RADTODEG = 180.0 / _G.bj_PI
_G.bj_DEGTORAD = _G.bj_PI / 180.0
_G.bj_TEXT_DELAY_QUEST = 20
_G.bj_TEXT_DELAY_QUESTUPDATE = 20
_G.bj_TEXT_DELAY_QUESTDONE = 20
_G.bj_TEXT_DELAY_QUESTFAILED = 20
_G.bj_TEXT_DELAY_QUESTREQUIREMENT = 20
_G.bj_TEXT_DELAY_MISSIONFAILED = 20
_G.bj_TEXT_DELAY_ALWAYSHINT = 12
_G.bj_TEXT_DELAY_HINT = 12
_G.bj_TEXT_DELAY_SECRET = 10
_G.bj_TEXT_DELAY_UNITACQUIRED = 15
_G.bj_TEXT_DELAY_UNITAVAILABLE = 10
_G.bj_TEXT_DELAY_ITEMACQUIRED = 10
_G.bj_TEXT_DELAY_WARNING = 12
_G.bj_QUEUE_DELAY_QUEST = 5
_G.bj_QUEUE_DELAY_HINT = 5
_G.bj_QUEUE_DELAY_SECRET = 3
_G.bj_HANDICAP_EASY = 60
_G.bj_GAME_STARTED_THRESHOLD = 0.01
_G.bj_WAIT_FOR_COND_MIN_INTERVAL = 0.10
_G.bj_POLLED_WAIT_INTERVAL = 0.10
_G.bj_POLLED_WAIT_SKIP_THRESHOLD = 2


-- _G.bj_MAX_INVENTORY = 6
-- _G.bj_MAX_PLAYERS = 12
-- _G.bj_PLAYER_NEUTRAL_VICTIM = 13
-- _G.bj_PLAYER_NEUTRAL_EXTRA = 14
-- _G.bj_MAX_PLAYER_SLOTS = 16
-- _G.bj_MAX_SKELETONS = 25
-- _G.bj_MAX_STOCK_ITEM_SLOTS = 11
-- _G.bj_MAX_STOCK_UNIT_SLOTS = 11
-- _G.bj_MAX_ITEM_LEVEL = 10



-- _G.bj_TOD_DAWN = 6
-- _G.bj_TOD_DUSK = 18

-- _G.bj_MELEE_STARTING_TOD = 8
-- _G.bj_MELEE_STARTING_GOLD_V0 = 750
-- _G.bj_MELEE_STARTING_GOLD_V1 = 500
-- _G.bj_MELEE_STARTING_LUMBER_V0 = 200
-- _G.bj_MELEE_STARTING_LUMBER_V1 = 150
-- _G.bj_MELEE_STARTING_HERO_TOKENS = 1
-- _G.bj_MELEE_HERO_LIMIT = 3
-- _G.bj_MELEE_HERO_TYPE_LIMIT = 1
-- _G.bj_MELEE_MINE_SEARCH_RADIUS = 2000
-- _G.bj_MELEE_CLEAR_UNITS_RADIUS = 1500
-- _G.bj_MELEE_CRIPPLE_TIMEOUT = 120
-- _G.bj_MELEE_CRIPPLE_MSG_DURATION = 20
-- _G.bj_MELEE_MAX_TWINKED_HEROES_V0 = 3
-- _G.bj_MELEE_MAX_TWINKED_HEROES_V1 = 1


-- _G.bj_CREEP_ITEM_DELAY = 0.50


-- _G.bj_STOCK_RESTOCK_INITIAL_DELAY = 120
-- _G.bj_STOCK_RESTOCK_INTERVAL = 30
-- _G.bj_STOCK_MAX_ITERATIONS = 20


-- _G.bj_MAX_DEST_IN_REGION_EVENTS = 64


-- _G.bj_CAMERA_MIN_FARZ = 100
-- _G.bj_CAMERA_DEFAULT_DISTANCE = 1650
-- _G.bj_CAMERA_DEFAULT_FARZ = 5000
-- _G.bj_CAMERA_DEFAULT_AOA = 304
-- _G.bj_CAMERA_DEFAULT_FOV = 70
-- _G.bj_CAMERA_DEFAULT_ROLL = 0
-- _G.bj_CAMERA_DEFAULT_ROTATION = 90


-- _G.bj_RESCUE_PING_TIME = 2


-- _G.bj_NOTHING_SOUND_DURATION = 5
-- _G.bj_TRANSMISSION_PING_TIME = 1
-- _G.bj_TRANSMISSION_IND_RED = 255
-- _G.bj_TRANSMISSION_IND_BLUE = 255
-- _G.bj_TRANSMISSION_IND_GREEN = 255
-- _G.bj_TRANSMISSION_IND_ALPHA = 255
-- _G.bj_TRANSMISSION_PORT_HANGTIME = 1.50


-- _G.bj_CINEMODE_INTERFACEFADE = 0.50
-- _G.bj_CINEMODE_GAMESPEED = MAP_SPEED_NORMAL


-- _G.bj_CINEMODE_VOLUME_UNITMOVEMENT = 0.40
-- _G.bj_CINEMODE_VOLUME_UNITSOUNDS = 0
-- _G.bj_CINEMODE_VOLUME_COMBAT = 0.40
-- _G.bj_CINEMODE_VOLUME_SPELLS = 0.40
-- _G.bj_CINEMODE_VOLUME_UI = 0
-- _G.bj_CINEMODE_VOLUME_MUSIC = 0.55
-- _G.bj_CINEMODE_VOLUME_AMBIENTSOUNDS = 1
-- _G.bj_CINEMODE_VOLUME_FIRE = 0.60


-- _G.bj_SPEECH_VOLUME_UNITMOVEMENT = 0.25
-- _G.bj_SPEECH_VOLUME_UNITSOUNDS = 0
-- _G.bj_SPEECH_VOLUME_COMBAT = 0.25
-- _G.bj_SPEECH_VOLUME_SPELLS = 0.25
-- _G.bj_SPEECH_VOLUME_UI = 0
-- _G.bj_SPEECH_VOLUME_MUSIC = 0.55
-- _G.bj_SPEECH_VOLUME_AMBIENTSOUNDS = 1
-- _G.bj_SPEECH_VOLUME_FIRE = 0.60


-- _G.bj_SMARTPAN_TRESHOLD_PAN = 500
-- _G.bj_SMARTPAN_TRESHOLD_SNAP = 3500


-- _G.bj_MAX_QUEUED_TRIGGERS = 100
-- _G.bj_QUEUED_TRIGGER_TIMEOUT = 180


-- _G.bj_CAMPAIGN_INDEX_T = 0
-- _G.bj_CAMPAIGN_INDEX_H = 1
-- _G.bj_CAMPAIGN_INDEX_U = 2
-- _G.bj_CAMPAIGN_INDEX_O = 3
-- _G.bj_CAMPAIGN_INDEX_N = 4
-- _G.bj_CAMPAIGN_INDEX_XN = 5
-- _G.bj_CAMPAIGN_INDEX_XH = 6
-- _G.bj_CAMPAIGN_INDEX_XU = 7
-- _G.bj_CAMPAIGN_INDEX_XO = 8


-- _G.bj_CAMPAIGN_OFFSET_T = 0
-- _G.bj_CAMPAIGN_OFFSET_H = 1
-- _G.bj_CAMPAIGN_OFFSET_U = 2
-- _G.bj_CAMPAIGN_OFFSET_O = 3
-- _G.bj_CAMPAIGN_OFFSET_N = 4
-- _G.bj_CAMPAIGN_OFFSET_XN = 0
-- _G.bj_CAMPAIGN_OFFSET_XH = 1
-- _G.bj_CAMPAIGN_OFFSET_XU = 2
-- _G.bj_CAMPAIGN_OFFSET_XO = 3



-- _G.bj_MISSION_INDEX_T00 = _G.bj_CAMPAIGN_OFFSET_T * 1000 + 0
-- _G.bj_MISSION_INDEX_T01 = _G.bj_CAMPAIGN_OFFSET_T * 1000 + 1

-- _G.bj_MISSION_INDEX_H00 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 0
-- _G.bj_MISSION_INDEX_H01 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 1
-- _G.bj_MISSION_INDEX_H02 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 2
-- _G.bj_MISSION_INDEX_H03 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 3
-- _G.bj_MISSION_INDEX_H04 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 4
-- _G.bj_MISSION_INDEX_H05 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 5
-- _G.bj_MISSION_INDEX_H06 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 6
-- _G.bj_MISSION_INDEX_H07 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 7
-- _G.bj_MISSION_INDEX_H08 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 8
-- _G.bj_MISSION_INDEX_H09 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 9
-- _G.bj_MISSION_INDEX_H10 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 10
-- _G.bj_MISSION_INDEX_H11 = _G.bj_CAMPAIGN_OFFSET_H * 1000 + 11

-- _G.bj_MISSION_INDEX_U00 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 0
-- _G.bj_MISSION_INDEX_U01 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 1
-- _G.bj_MISSION_INDEX_U02 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 2
-- _G.bj_MISSION_INDEX_U03 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 3
-- _G.bj_MISSION_INDEX_U05 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 4
-- _G.bj_MISSION_INDEX_U07 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 5
-- _G.bj_MISSION_INDEX_U08 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 6
-- _G.bj_MISSION_INDEX_U09 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 7
-- _G.bj_MISSION_INDEX_U10 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 8
-- _G.bj_MISSION_INDEX_U11 = _G.bj_CAMPAIGN_OFFSET_U * 1000 + 9

-- _G.bj_MISSION_INDEX_O00 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 0
-- _G.bj_MISSION_INDEX_O01 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 1
-- _G.bj_MISSION_INDEX_O02 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 2
-- _G.bj_MISSION_INDEX_O03 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 3
-- _G.bj_MISSION_INDEX_O04 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 4
-- _G.bj_MISSION_INDEX_O05 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 5
-- _G.bj_MISSION_INDEX_O06 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 6
-- _G.bj_MISSION_INDEX_O07 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 7
-- _G.bj_MISSION_INDEX_O08 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 8
-- _G.bj_MISSION_INDEX_O09 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 9
-- _G.bj_MISSION_INDEX_O10 = _G.bj_CAMPAIGN_OFFSET_O * 1000 + 10

-- _G.bj_MISSION_INDEX_N00 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 0
-- _G.bj_MISSION_INDEX_N01 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 1
-- _G.bj_MISSION_INDEX_N02 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 2
-- _G.bj_MISSION_INDEX_N03 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 3
-- _G.bj_MISSION_INDEX_N04 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 4
-- _G.bj_MISSION_INDEX_N05 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 5
-- _G.bj_MISSION_INDEX_N06 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 6
-- _G.bj_MISSION_INDEX_N07 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 7
-- _G.bj_MISSION_INDEX_N08 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 8
-- _G.bj_MISSION_INDEX_N09 = _G.bj_CAMPAIGN_OFFSET_N * 1000 + 9

-- _G.bj_MISSION_INDEX_XN00 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 0
-- _G.bj_MISSION_INDEX_XN01 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 1
-- _G.bj_MISSION_INDEX_XN02 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 2
-- _G.bj_MISSION_INDEX_XN03 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 3
-- _G.bj_MISSION_INDEX_XN04 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 4
-- _G.bj_MISSION_INDEX_XN05 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 5
-- _G.bj_MISSION_INDEX_XN06 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 6
-- _G.bj_MISSION_INDEX_XN07 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 7
-- _G.bj_MISSION_INDEX_XN08 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 8
-- _G.bj_MISSION_INDEX_XN09 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 9
-- _G.bj_MISSION_INDEX_XN10 = _G.bj_CAMPAIGN_OFFSET_XN * 1000 + 10

-- _G.bj_MISSION_INDEX_XH00 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 0
-- _G.bj_MISSION_INDEX_XH01 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 1
-- _G.bj_MISSION_INDEX_XH02 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 2
-- _G.bj_MISSION_INDEX_XH03 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 3
-- _G.bj_MISSION_INDEX_XH04 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 4
-- _G.bj_MISSION_INDEX_XH05 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 5
-- _G.bj_MISSION_INDEX_XH06 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 6
-- _G.bj_MISSION_INDEX_XH07 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 7
-- _G.bj_MISSION_INDEX_XH08 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 8
-- _G.bj_MISSION_INDEX_XH09 = _G.bj_CAMPAIGN_OFFSET_XH * 1000 + 9

-- _G.bj_MISSION_INDEX_XU00 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 0
-- _G.bj_MISSION_INDEX_XU01 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 1
-- _G.bj_MISSION_INDEX_XU02 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 2
-- _G.bj_MISSION_INDEX_XU03 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 3
-- _G.bj_MISSION_INDEX_XU04 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 4
-- _G.bj_MISSION_INDEX_XU05 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 5
-- _G.bj_MISSION_INDEX_XU06 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 6
-- _G.bj_MISSION_INDEX_XU07 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 7
-- _G.bj_MISSION_INDEX_XU08 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 8
-- _G.bj_MISSION_INDEX_XU09 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 9
-- _G.bj_MISSION_INDEX_XU10 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 10
-- _G.bj_MISSION_INDEX_XU11 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 11
-- _G.bj_MISSION_INDEX_XU12 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 12
-- _G.bj_MISSION_INDEX_XU13 = _G.bj_CAMPAIGN_OFFSET_XU * 1000 + 13


-- _G.bj_MISSION_INDEX_XO00 = _G.bj_CAMPAIGN_OFFSET_XO * 1000 + 0


-- _G.bj_CINEMATICINDEX_TOP = 0
-- _G.bj_CINEMATICINDEX_HOP = 1
-- _G.bj_CINEMATICINDEX_HED = 2
-- _G.bj_CINEMATICINDEX_OOP = 3
-- _G.bj_CINEMATICINDEX_OED = 4
-- _G.bj_CINEMATICINDEX_UOP = 5
-- _G.bj_CINEMATICINDEX_UED = 6
-- _G.bj_CINEMATICINDEX_NOP = 7
-- _G.bj_CINEMATICINDEX_NED = 8
-- _G.bj_CINEMATICINDEX_XOP = 9
-- _G.bj_CINEMATICINDEX_XED = 10


-- _G.bj_ALLIANCE_UNALLIED = 0
-- _G.bj_ALLIANCE_UNALLIED_VISION = 1
-- _G.bj_ALLIANCE_ALLIED = 2
-- _G.bj_ALLIANCE_ALLIED_VISION = 3
-- _G.bj_ALLIANCE_ALLIED_UNITS = 4
-- _G.bj_ALLIANCE_ALLIED_ADVUNITS = 5
-- _G.bj_ALLIANCE_NEUTRAL = 6
-- _G.bj_ALLIANCE_NEUTRAL_VISION = 7


-- _G.bj_KEYEVENTTYPE_DEPRESS = 0
-- _G.bj_KEYEVENTTYPE_RELEASE = 1


-- _G.bj_KEYEVENTKEY_LEFT = 0
-- _G.bj_KEYEVENTKEY_RIGHT = 1
-- _G.bj_KEYEVENTKEY_DOWN = 2
-- _G.bj_KEYEVENTKEY_UP = 3


-- _G.bj_TIMETYPE_ADD = 0
-- _G.bj_TIMETYPE_SET = 1
-- _G.bj_TIMETYPE_SUB = 2


-- _G.bj_CAMERABOUNDS_ADJUST_ADD = 0
-- _G.bj_CAMERABOUNDS_ADJUST_SUB = 1


-- _G.bj_QUESTTYPE_REQ_DISCOVERED = 0
-- _G.bj_QUESTTYPE_REQ_UNDISCOVERED = 1
-- _G.bj_QUESTTYPE_OPT_DISCOVERED = 2
-- _G.bj_QUESTTYPE_OPT_UNDISCOVERED = 3


-- _G.bj_QUESTMESSAGE_DISCOVERED = 0
-- _G.bj_QUESTMESSAGE_UPDATED = 1
-- _G.bj_QUESTMESSAGE_COMPLETED = 2
-- _G.bj_QUESTMESSAGE_FAILED = 3
-- _G.bj_QUESTMESSAGE_REQUIREMENT = 4
-- _G.bj_QUESTMESSAGE_MISSIONFAILED = 5
-- _G.bj_QUESTMESSAGE_ALWAYSHINT = 6
-- _G.bj_QUESTMESSAGE_HINT = 7
-- _G.bj_QUESTMESSAGE_SECRET = 8
-- _G.bj_QUESTMESSAGE_UNITACQUIRED = 9
-- _G.bj_QUESTMESSAGE_UNITAVAILABLE = 10
-- _G.bj_QUESTMESSAGE_ITEMACQUIRED = 11
-- _G.bj_QUESTMESSAGE_WARNING = 12


-- _G.bj_SORTTYPE_SORTBYVALUE = 0
-- _G.bj_SORTTYPE_SORTBYPLAYER = 1
-- _G.bj_SORTTYPE_SORTBYLABEL = 2


-- _G.bj_CINEFADETYPE_FADEIN = 0
-- _G.bj_CINEFADETYPE_FADEOUT = 1
-- _G.bj_CINEFADETYPE_FADEOUTIN = 2


-- _G.bj_REMOVEBUFFS_POSITIVE = 0
-- _G.bj_REMOVEBUFFS_NEGATIVE = 1
-- _G.bj_REMOVEBUFFS_ALL = 2
-- _G.bj_REMOVEBUFFS_NONTLIFE = 3


-- _G.bj_BUFF_POLARITY_POSITIVE = 0
-- _G.bj_BUFF_POLARITY_NEGATIVE = 1
-- _G.bj_BUFF_POLARITY_EITHER = 2


-- _G.bj_BUFF_RESIST_MAGIC = 0
-- _G.bj_BUFF_RESIST_PHYSICAL = 1
-- _G.bj_BUFF_RESIST_EITHER = 2
-- _G.bj_BUFF_RESIST_BOTH = 3


-- _G.bj_HEROSTAT_STR = 0
-- _G.bj_HEROSTAT_AGI = 1
-- _G.bj_HEROSTAT_INT = 2


-- _G.bj_MODIFYMETHOD_ADD = 0
-- _G.bj_MODIFYMETHOD_SUB = 1
-- _G.bj_MODIFYMETHOD_SET = 2


-- _G.bj_UNIT_STATE_METHOD_ABSOLUTE = 0
-- _G.bj_UNIT_STATE_METHOD_RELATIVE = 1
-- _G.bj_UNIT_STATE_METHOD_DEFAULTS = 2
-- _G.bj_UNIT_STATE_METHOD_MAXIMUM = 3


-- _G.bj_GATEOPERATION_CLOSE = 0
-- _G.bj_GATEOPERATION_OPEN = 1
-- _G.bj_GATEOPERATION_DESTROY = 2


-- _G.bj_GAMECACHE_BOOLEAN = 0
-- _G.bj_GAMECACHE_INTEGER = 1
-- _G.bj_GAMECACHE_REAL = 2
-- _G.bj_GAMECACHE_UNIT = 3
-- _G.bj_GAMECACHE_STRING = 4


-- _G.bj_HASHTABLE_BOOLEAN = 0
-- _G.bj_HASHTABLE_INTEGER = 1
-- _G.bj_HASHTABLE_REAL = 2
-- _G.bj_HASHTABLE_STRING = 3
-- _G.bj_HASHTABLE_HANDLE = 4


-- _G.bj_ITEM_STATUS_HIDDEN = 0
-- _G.bj_ITEM_STATUS_OWNED = 1
-- _G.bj_ITEM_STATUS_INVULNERABLE = 2
-- _G.bj_ITEM_STATUS_POWERUP = 3
-- _G.bj_ITEM_STATUS_SELLABLE = 4
-- _G.bj_ITEM_STATUS_PAWNABLE = 5


-- _G.bj_ITEMCODE_STATUS_POWERUP = 0
-- _G.bj_ITEMCODE_STATUS_SELLABLE = 1
-- _G.bj_ITEMCODE_STATUS_PAWNABLE = 2


-- _G.bj_MINIMAPPINGSTYLE_SIMPLE = 0
-- _G.bj_MINIMAPPINGSTYLE_FLASHY = 1
-- _G.bj_MINIMAPPINGSTYLE_ATTACK = 2


-- _G.bj_CORPSE_MAX_DEATH_TIME = 8


-- _G.bj_CORPSETYPE_FLESH = 0
-- _G.bj_CORPSETYPE_BONE = 1


-- _G.bj_ELEVATOR_BLOCKER_CODE = 1146381680
-- _G.bj_ELEVATOR_CODE01 = 1146384998
-- _G.bj_ELEVATOR_CODE02 = 1146385016


-- _G.bj_ELEVATOR_WALL_TYPE_ALL = 0
-- _G.bj_ELEVATOR_WALL_TYPE_EAST = 1
-- _G.bj_ELEVATOR_WALL_TYPE_NORTH = 2
-- _G.bj_ELEVATOR_WALL_TYPE_SOUTH = 3
-- _G.bj_ELEVATOR_WALL_TYPE_WEST = 4






-- _G.bj_FORCE_ALL_PLAYERS = nil
-- _G.bj_FORCE_PLAYER = {}

-- _G.bj_MELEE_MAX_TWINKED_HEROES = 0


-- _G.bj_mapInitialPlayableArea = nil
-- _G.bj_mapInitialCameraBounds = nil


_G.bj_forLoopAIndex = 0
_G.bj_forLoopBIndex = 0
_G.bj_forLoopAIndexEnd = 0
_G.bj_forLoopBIndexEnd = 0

-- _G.bj_slotControlReady = false
-- _G.bj_slotControlUsed = setmetatable({}, _mt_boolean)
-- _G.bj_slotControl = {}


-- _G.bj_gameStartedTimer = nil
-- _G.bj_gameStarted = false
-- _G.bj_volumeGroupsTimer = CreateTimer ( )


-- _G.bj_isSinglePlayer = false


-- _G.bj_dncSoundsDay = nil
-- _G.bj_dncSoundsNight = nil
-- _G.bj_dayAmbientSound = nil
-- _G.bj_nightAmbientSound = nil
-- _G.bj_dncSoundsDawn = nil
-- _G.bj_dncSoundsDusk = nil
-- _G.bj_dawnSound = nil
-- _G.bj_duskSound = nil
-- _G.bj_useDawnDuskSounds = true
-- _G.bj_dncIsDaytime = false



-- _G.bj_rescueSound = nil
-- _G.bj_questDiscoveredSound = nil
-- _G.bj_questUpdatedSound = nil
-- _G.bj_questCompletedSound = nil
-- _G.bj_questFailedSound = nil
-- _G.bj_questHintSound = nil
-- _G.bj_questSecretSound = nil
-- _G.bj_questItemAcquiredSound = nil
-- _G.bj_questWarningSound = nil
-- _G.bj_victoryDialogSound = nil
-- _G.bj_defeatDialogSound = nil


-- _G.bj_stockItemPurchased = nil
-- _G.bj_stockUpdateTimer = nil
-- _G.bj_stockAllowedPermanent = setmetatable({}, _mt_boolean)
-- _G.bj_stockAllowedCharged = setmetatable({}, _mt_boolean)
-- _G.bj_stockAllowedArtifact = setmetatable({}, _mt_boolean)
-- _G.bj_stockPickedItemLevel = 0


-- _G.bj_meleeVisibilityTrained = nil
-- _G.bj_meleeVisibilityIsDay = true
-- _G.bj_meleeGrantHeroItems = false
-- _G.bj_meleeNearestMineToLoc = nil
-- _G.bj_meleeNearestMine = nil
-- _G.bj_meleeNearestMineDist = 0
-- _G.bj_meleeGameOver = false
-- _G.bj_meleeDefeated = setmetatable({}, _mt_boolean)
-- _G.bj_meleeVictoried = setmetatable({}, _mt_boolean)
-- _G.bj_ghoul = {}
-- _G.bj_crippledTimer = {}
-- _G.bj_crippledTimerWindows = {}
-- _G.bj_playerIsCrippled = setmetatable({}, _mt_boolean)
-- _G.bj_playerIsExposed = setmetatable({}, _mt_boolean)
-- _G.bj_finishSoonAllExposed = false
-- _G.bj_finishSoonTimerDialog = nil
-- _G.bj_meleeTwinkedHeroes = setmetatable({}, _mt_number)


-- _G.bj_rescueUnitBehavior = nil
-- _G.bj_rescueChangeColorUnit = true
-- _G.bj_rescueChangeColorBldg = true


-- _G.bj_cineSceneEndingTimer = nil
-- _G.bj_cineSceneLastSound = nil
-- _G.bj_cineSceneBeingSkipped = nil


-- _G.bj_cineModePriorSpeed = MAP_SPEED_NORMAL
-- _G.bj_cineModePriorFogSetting = false
-- _G.bj_cineModePriorMaskSetting = false
-- _G.bj_cineModeAlreadyIn = false
-- _G.bj_cineModePriorDawnDusk = false
-- _G.bj_cineModeSavedSeed = 0


-- _G.bj_cineFadeFinishTimer = nil
-- _G.bj_cineFadeContinueTimer = nil
-- _G.bj_cineFadeContinueRed = 0
-- _G.bj_cineFadeContinueGreen = 0
-- _G.bj_cineFadeContinueBlue = 0
-- _G.bj_cineFadeContinueTrans = 0
-- _G.bj_cineFadeContinueDuration = 0
-- _G.bj_cineFadeContinueTex = ""


-- _G.bj_queuedExecTotal = 0
-- _G.bj_queuedExecTriggers = {}
-- _G.bj_queuedExecUseConds = setmetatable({}, _mt_boolean)
-- _G.bj_queuedExecTimeoutTimer = CreateTimer ( )
-- _G.bj_queuedExecTimeout = nil


-- _G.bj_destInRegionDiesCount = 0
-- _G.bj_destInRegionDiesTrig = nil
-- _G.bj_groupCountUnits = 0
-- _G.bj_forceCountPlayers = 0
-- _G.bj_groupEnumTypeId = 0
-- _G.bj_groupEnumOwningPlayer = nil
-- _G.bj_groupAddGroupDest = nil
-- _G.bj_groupRemoveGroupDest = nil
-- _G.bj_groupRandomConsidered = 0
-- _G.bj_groupRandomCurrentPick = nil
-- _G.bj_groupLastCreatedDest = nil
-- _G.bj_randomSubGroupGroup = nil
-- _G.bj_randomSubGroupWant = 0
-- _G.bj_randomSubGroupTotal = 0
-- _G.bj_randomSubGroupChance = 0
-- _G.bj_destRandomConsidered = 0
-- _G.bj_destRandomCurrentPick = nil
-- _G.bj_elevatorWallBlocker = nil
-- _G.bj_elevatorNeighbor = nil
-- _G.bj_itemRandomConsidered = 0
-- _G.bj_itemRandomCurrentPick = nil
-- _G.bj_forceRandomConsidered = 0
-- _G.bj_forceRandomCurrentPick = nil
-- _G.bj_makeUnitRescuableUnit = nil
-- _G.bj_makeUnitRescuableFlag = true
-- _G.bj_pauseAllUnitsFlag = true
-- _G.bj_enumDestructableCenter = nil
-- _G.bj_enumDestructableRadius = 0
-- _G.bj_setPlayerTargetColor = nil
-- _G.bj_isUnitGroupDeadResult = true
-- _G.bj_isUnitGroupEmptyResult = true
-- _G.bj_isUnitGroupInRectResult = true
-- _G.bj_isUnitGroupInRectRect = nil
-- _G.bj_changeLevelShowScores = false
-- _G.bj_changeLevelMapName = nil
-- _G.bj_suspendDecayFleshGroup = CreateGroup ( )
-- _G.bj_suspendDecayBoneGroup = CreateGroup ( )
-- _G.bj_delayedSuspendDecayTimer = CreateTimer ( )
-- _G.bj_delayedSuspendDecayTrig = nil
-- _G.bj_livingPlayerUnitsTypeId = 0
-- _G.bj_lastDyingWidget = nil


-- _G.bj_randDistCount = 0
-- _G.bj_randDistID = setmetatable({}, _mt_number)
-- _G.bj_randDistChance = setmetatable({}, _mt_number)


-- _G.bj_lastCreatedUnit = nil
-- _G.bj_lastCreatedItem = nil
-- _G.bj_lastRemovedItem = nil
-- _G.bj_lastHauntedGoldMine = nil
-- _G.bj_lastCreatedDestructable = nil
-- _G.bj_lastCreatedGroup = CreateGroup ( )
-- _G.bj_lastCreatedFogModifier = nil
-- _G.bj_lastCreatedEffect = nil
-- _G.bj_lastCreatedWeatherEffect = nil
-- _G.bj_lastCreatedTerrainDeformation = nil
-- _G.bj_lastCreatedQuest = nil
-- _G.bj_lastCreatedQuestItem = nil
-- _G.bj_lastCreatedDefeatCondition = nil
-- _G.bj_lastStartedTimer = CreateTimer ( )
-- _G.bj_lastCreatedTimerDialog = nil
-- _G.bj_lastCreatedLeaderboard = nil
-- _G.bj_lastCreatedMultiboard = nil
-- _G.bj_lastPlayedSound = nil
-- _G.bj_lastPlayedMusic = ""
-- _G.bj_lastTransmissionDuration = 0
-- _G.bj_lastCreatedGameCache = nil
-- _G.bj_lastCreatedHashtable = nil
-- _G.bj_lastLoadedUnit = nil
-- _G.bj_lastCreatedButton = nil
-- _G.bj_lastReplacedUnit = nil
-- _G.bj_lastCreatedTextTag = nil
-- _G.bj_lastCreatedLightning = nil
-- _G.bj_lastCreatedImage = nil
-- _G.bj_lastCreatedUbersplat = nil


-- filterIssueHauntOrderAtLocBJ = nil
-- filterEnumDestructablesInCircleBJ = nil
-- filterGetUnitsInRectOfPlayer = nil
-- filterGetUnitsOfTypeIdAll = nil
-- filterGetUnitsOfPlayerAndTypeId = nil
-- filterMeleeTrainedUnitIsHeroBJ = nil
-- filterLivingPlayerUnitsOfTypeId = nil


-- _G.bj_wantDestroyGroup = false










-- BJDebugMsg  = function ( msg )
-- local i = 0
-- for _i = 1, 10000 do
-- DisplayTimedTextToPlayer ( Player ( i ) , 0 , 0 , 60 , msg )
-- i = i + 1
-- if i == _G.bj_MAX_PLAYERS then break end
-- end
-- end










-- RMinBJ  = function ( a , b )
-- if ( a < b ) then
-- do return a end
-- else
-- do return b end
-- end
-- end


-- RMaxBJ  = function ( a , b )
-- if ( a < b ) then
-- do return b end
-- else
-- do return a end
-- end
-- end


-- RAbsBJ  = function ( a )
-- if ( a >= 0 ) then
-- do return a end
-- else
-- do return - a end
-- end
-- end


-- RSignBJ  = function ( a )
-- if ( a >= 0.0 ) then
-- do return 1.0 end
-- else
-- do return - 1.0 end
-- end
-- end


-- IMinBJ  = function ( a , b )
-- if ( a < b ) then
-- do return a end
-- else
-- do return b end
-- end
-- end


-- IMaxBJ  = function ( a , b )
-- if ( a < b ) then
-- do return b end
-- else
-- do return a end
-- end
-- end


-- IAbsBJ  = function ( a )
-- if ( a >= 0 ) then
-- do return a end
-- else
-- do return - a end
-- end
-- end


-- ISignBJ  = function ( a )
-- if ( a >= 0 ) then
-- do return 1 end
-- else
-- do return - 1 end
-- end
-- end


-- SinBJ  = function ( degrees )
-- do return Sin ( degrees * _G.bj_DEGTORAD ) end
-- end


-- CosBJ  = function ( degrees )
-- do return Cos ( degrees * _G.bj_DEGTORAD ) end
-- end


-- TanBJ  = function ( degrees )
-- do return Tan ( degrees * _G.bj_DEGTORAD ) end
-- end


-- AsinBJ  = function ( degrees )
-- do return Asin ( degrees ) * _G.bj_RADTODEG end
-- end


-- AcosBJ  = function ( degrees )
-- do return Acos ( degrees ) * _G.bj_RADTODEG end
-- end


-- AtanBJ  = function ( degrees )
-- do return Atan ( degrees ) * _G.bj_RADTODEG end
-- end


-- Atan2BJ  = function ( y , x )
-- do return Atan2 ( y , x ) * _G.bj_RADTODEG end
-- end


-- AngleBetweenPoints  = function ( locA , locB )
-- do return _G.bj_RADTODEG * Atan2 ( GetLocationY ( locB ) - GetLocationY ( locA ) , GetLocationX ( locB ) - GetLocationX ( locA ) ) end
-- end


-- DistanceBetweenPoints  = function ( locA , locB )
-- local dx = GetLocationX ( locB ) - GetLocationX ( locA )
-- local dy = GetLocationY ( locB ) - GetLocationY ( locA )
-- do return SquareRoot ( dx * dx + dy * dy ) end
-- end


-- PolarProjectionBJ  = function ( source , dist , angle )
-- local x = GetLocationX ( source ) + dist * Cos ( angle * _G.bj_DEGTORAD )
-- local y = GetLocationY ( source ) + dist * Sin ( angle * _G.bj_DEGTORAD )
-- do return Location ( x , y ) end
-- end


-- GetRandomDirectionDeg  = function ( )
-- do return GetRandomReal ( 0 , 360 ) end
-- end


-- GetRandomPercentageBJ  = function ( )
-- do return GetRandomReal ( 0 , 100 ) end
-- end


-- GetRandomLocInRect  = function ( whichRect )
-- do return Location ( GetRandomReal ( GetRectMinX ( whichRect ) , GetRectMaxX ( whichRect ) ) , GetRandomReal ( GetRectMinY ( whichRect ) , GetRectMaxY ( whichRect ) ) ) end
-- end





-- ModuloInteger  = function ( dividend , divisor )
-- local modulus = dividend - ( math.floor ( dividend / divisor ) ) * divisor




-- if ( modulus < 0 ) then
-- modulus = modulus + divisor
-- end

-- do return modulus end
-- end





-- ModuloReal  = function ( dividend , divisor )
-- local modulus = dividend - I2R ( R2I ( dividend / divisor ) ) * divisor




-- if ( modulus < 0 ) then
-- modulus = modulus + divisor
-- end

-- do return modulus end
-- end
