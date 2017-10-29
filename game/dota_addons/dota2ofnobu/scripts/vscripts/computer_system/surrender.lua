-- 投降機制

if SurrenderSystem == nil then
	SurrenderSystem = class({})
end

function SurrenderSystem:Print( msg )
	print("[SurrenderSystem] "..msg)
end

function SurrenderSystem:SendMsgToAll( msg )
	GameRules:SendCustomMessage("[SurrenderSystem] "..msg,DOTA_TEAM_GOODGUYS+DOTA_TEAM_BADGUYS,0)
end

function SurrenderSystem:SendMsg( msg, iTeam )
	GameRules:SendCustomMessage("[SurrenderSystem] "..msg,iTeam,0)
end

-- 當使用者在聊天視窗輸入訊息時會觸發，只在遊戲中才生效
function SurrenderSystem:OnPlayerChat( keys )
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return end
	-- [   VScript ]:    playerid                        	= 0 (number)
	-- [   VScript ]:    text                            	= "3" (string)
	-- [   VScript ]:    teamonly                        	= 1 (number)
	-- [   VScript ]:    userid                          	= 1 (number)
	-- [   VScript ]:    splitscreenplayer               	= -1 (number)
	local playerid = keys.playerid
	local text = keys.text:lower()

	-- 排除其他指令
	if text ~= "-ff" then 
		return 
	end

	-- 確認是否可以投降
	local progressTime = GameRules:GetGameTime() - self.startTime
	local remainTime = math.ceil(self.TIME_DELAY - progressTime)
	if self.canSurrender then
		-- 紀錄投票狀態，重複投票可以反悔
		local votes = self.votes
		if votes[playerid] == nil then
			votes[playerid] = true
		else
			votes[playerid] = not votes[playerid]
		end
		-- 計算結果
		self:CheckVoteResults(keys.playerid)
	elseif remainTime > 0 then
		-- 提示還有多久才能投降
		local min = math.floor(remainTime/60)
		local sec = math.fmod(remainTime,60)
		if min > 0 then
			self:SendMsgToAll(min.."分"..sec.."秒後才能投降")
		else
			self:SendMsgToAll(sec.."秒後才能投降")
		end
	end
end


function getMVP_value(hero)
	if hero.building_count == nil then
		hero.building_count = 0
	end
	local kda = hero:GetKills()*1.5-hero:GetDeaths()+hero:GetAssists()+hero.building_count
	return kda
end

-- playerid 是輸入指令的使用者
function SurrenderSystem:CheckVoteResults(playerid)
	local iTeam = PlayerResource:GetTeam(playerid)
	local votes = self.votes

	-- 統計同隊在線玩家數量，與同意人數
	local connected_players = 0
	local agree_players = 0
	for _,hero in ipairs(HeroList:GetAllHeroes()) do
		if not hero:IsIllusion() then
			local id = hero:GetPlayerID()
			local team = PlayerResource:GetTeam(id)
			local state = PlayerResource:GetConnectionState(id)
			if team == iTeam and state == 2 then -- 2 = connected
				connected_players = connected_players + 1
				if votes[id] then agree_players  = agree_players + 1 end
			end
		end
	end

	-- 計算通過門檻
	local threshold = math.ceil(connected_players*0.5 + 0.1)

	-- 顯示投票結果
	local msg = string.format("同意:%d 門檻:%d", agree_players, threshold)

	if iTeam == DOTA_TEAM_GOODGUYS then
		self:SendMsgToAll("織田軍有意投降: "..msg)
		if agree_players >= threshold then
			OnOdaGiveUp()
		end
	end

	if iTeam == DOTA_TEAM_BADGUYS then
		self:SendMsgToAll("聯合軍有意投降: "..msg)
		if agree_players >= threshold then
			OnUnifiedGiveUp()
		end
	end

	-- 避免在次投票
	if agree_players >= threshold then
		self.canSurrender = false 
	end
end

function SurrenderSystem:OnGameStateChange( keys )
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		-- 開啟投票系統，並在聊天室窗提示指令
		self.startTime = GameRules:GetGameTime()
		Timers:CreateTimer(300, function ()
			self.canSurrender = true
			self:SendMsgToAll("聊天視窗輸入 -ff 可以投降")
	  	end)
	end
end

function SurrenderSystem:Init()
	-- 用來避免reload script的時候重複執行
	if self.initOnce == nil then
		self.initOnce = true
		self.TIME_DELAY = 0 -- 投降機制啟動時間(秒)
		self.startTime = 0
		self.votes = {}
		self.canSurrender = false
		self:Print("Online")

		-- 取得使用者輸入事件
		ListenToGameEvent( "player_chat", Dynamic_Wrap( SurrenderSystem, "OnPlayerChat" ), self )

		-- 取得遊戲狀態改變事件
		ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap(SurrenderSystem, "OnGameStateChange"), self)
	end
end

SurrenderSystem:Init()

function OnOdaGiveUp()
	SurrenderSystem:SendMsgToAll("織田軍已經投降")
	local mvp = nil
	local mvp_value = -100
	for _,hero in ipairs(HeroList:GetAllHeroes()) do
		if not hero:IsIllusion() then
			if not hero:IsAlive() then
				hero:SetTimeUntilRespawn(0)
			end
			if getMVP_value(hero)>mvp_value then
				mvp_value = getMVP_value(hero)
				mvp = hero
			end
		end
	end
	_G.Unified_home:AddNewModifier(_G.Unified_home, nil, "modifier_invulnerable", nil )
	Timers:CreateTimer(0.1, function()
		local pos = _G.Oda_home:GetAbsOrigin()
		if mvp then
			_G.Oda_home:ForceKill(false)
			for i=0,9 do
				AMHC:SetCamera(i, mvp)
			end
			mvp:SetAbsOrigin(pos+Vector(0,0,250))
			local nobu_id = _G.heromap[mvp:GetName()]
			local mesg = "本場MVP為 ".._G.hero_name_zh[nobu_id]
			mesg = mesg.."\n聯合軍獲勝"
			GameRules:SetCustomVictoryMessage(mesg)
			Timers:CreateTimer(0.1, function()
				mvp:SetAbsOrigin(pos+Vector(0,0,250))
				mvp:AddNewModifier(mvp, nil, "modifier_invulnerable", nil )
				return 0.1
			end)
		end
		end)
end

function OnUnifiedGiveUp()
	SurrenderSystem:SendMsgToAll("聯合軍已經投降")
	local mvp = nil
	local mvp_value = -100
	for _,hero in ipairs(HeroList:GetAllHeroes()) do
		if not hero:IsIllusion() then
			if not hero:IsAlive() then
				hero:SetTimeUntilRespawn(0)
			end
			if getMVP_value(hero)>mvp_value then
				mvp_value = getMVP_value(hero)
				mvp = hero
				
			end
		end
	end
	_G.Oda_home:AddNewModifier(_G.Oda_home, nil, "modifier_invulnerable", nil )
	Timers:CreateTimer(0.1, function()
		local pos = _G.Unified_home:GetAbsOrigin()
		if mvp then
			_G.Unified_home:ForceKill(false)
			for i=0,9 do
				AMHC:SetCamera(i, mvp)
			end
			mvp:SetAbsOrigin(pos+Vector(0,0,250))
			local nobu_id = _G.heromap[mvp:GetName()]
			local mesg = "本場MVP為 ".._G.hero_name_zh[nobu_id]
			mesg = mesg.."\n織田軍獲勝"
			GameRules:SetCustomVictoryMessage(mesg)
			Timers:CreateTimer(0.1, function()
				mvp:SetAbsOrigin(pos+Vector(0,0,250))
				mvp:AddNewModifier(mvp, nil, "modifier_invulnerable", nil )
				return 0.1
			end)
		end
		end)
end