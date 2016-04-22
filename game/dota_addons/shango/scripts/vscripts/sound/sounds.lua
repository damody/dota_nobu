local BGM_STRACKS = {
	"Zhensan.Shu_Pre",
	"Zhensan.Wei_Pre",
	-- "Zhensan.Shu_Sad",
	-- "Zhensan.Wei_Sad",
	"Zhensan.Shu_Bravely",
	"Zhensan.Wei_Bravely"
	-- "Zhensan.Shu_Silent",
	-- "Zhensan.Wei_Silent"
}

local SOUND_LENGTH = {
	["Zhensan.Shu_Pre"] = 181,
	["Zhensan.Wei_Pre"] = 118,
	["Zhensan.Shu_Sad"] = 156,
	["Zhensan.Wei_Sad"] = 122,
	["Zhensan.Shu_Bravely"] = 166,
	["Zhensan.Wei_Bravely"] = 132,
	["Zhensan.Shu_Silent"] = 83,
	["Zhensan.Wei_Silent"] = 84
}


function SoundControllerStart()
	local currentSound = BGM_STRACKS[RandomInt(1, #BGM_STRACKS)]
	local soundLength = SOUND_LENGTH[currentSound]
	
	-- 游戏开始10秒之后开始播放BGM，同样的，每个BGM之间间隔5秒
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("123_1321"),
		function()
			-- print("Attemp to start sound :", currentSound, "Sound Length: " , soundLength)
			EmitGlobalSound(currentSound)
			GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("123_1322"), function()
				-- 如果游戏已经结束，那么不播放下一首
				if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
					SoundControllerStart()
				end
			end,soundLength)
		end,5)
end