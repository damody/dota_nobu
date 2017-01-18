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

function SurrenderSystem:OnPlayerChat( keys )
	-- [   VScript ]:    playerid                        	= 0 (number)
	-- [   VScript ]:    text                            	= "3" (string)
	-- [   VScript ]:    teamonly                        	= 1 (number)
	-- [   VScript ]:    userid                          	= 1 (number)
	-- [   VScript ]:    splitscreenplayer               	= -1 (number)
	local text = keys.text

	-- 排除其他指令
	if text ~= "-ff" then 
		return 
	end

	-- 確認是否可以投降
	if not self.canSurrender then
		local remainTime = math.ceil(self.TIME_DELAY - GameRules:GetGameTime())
		local min = math.floor(remainTime/60)
		local sec = math.fmod(remainTime,60)
		if min > 0 then
			self:SendMsgToAll(min.."分"..sec.."秒後才能投降")
		else
			self:SendMsgToAll(sec.."秒後才能投降")
		end
		return
	end

	-- 計算結果
	self:CheckVoteResults(keys.playerid)
end

function SurrenderSystem:CheckVoteResults(playerid)
	local iTeam = PlayerResource:GetTeam(playerid)
	local votes = self.votes
	local res = 0

	-- 投票
	local votes = self.votes
	if votes[playerid] == nil then
		votes[playerid] = true
	else
		votes[playerid] = not votes[playerid]
	end

	-- 統計特定隊伍，同意投降的玩家數量
	for playerid, agree in pairs(votes) do
		local team = PlayerResource:GetTeam(playerid)
		local state = PlayerResource:GetConnectionState(playerid)
		if team == iTeam and agree and state == 2 then -- 2 = connected
			res = res + 1
		end
	end

	-- 計算投降的門檻
	local threshold = math.ceil(PlayerResource:GetPlayerCountForTeam(iTeam)*0.5 + 0.1)

	-- 顯示投票結果
	local msg = string.format("同意:%d 門檻:%d", res, threshold)

	if iTeam == DOTA_TEAM_GOODGUYS then
		if res < threshold then
			self:SendMsgToAll("織田軍有意投降: "..msg)
		else
			self:SendMsgToAll("織田軍已經投降")
			_G.Oda_home:ForceKill(false)
		end
	end

	if iTeam == DOTA_TEAM_BADGUYS then
		if res > threshold then
			self:SendMsgToAll("聯合軍有意投降: "..msg)
		else
			self:SendMsgToAll("聯合軍已經投降")
			_G.Unified_home:ForceKill(false)
		end
	end

	-- 避免在次投票
	if res > threshold then
		self.canSurrender = false 
	end
end

function SurrenderSystem:Init()
	if self.initOnce == nil then
		self.initOnce = true
		self.TIME_DELAY = 20*60 -- 秒 可投降時間
		self:Print("Online")
		ListenToGameEvent( "player_chat", Dynamic_Wrap( SurrenderSystem, "OnPlayerChat" ), self )
	end

	self:Print("Init")
	local remainTime = self.TIME_DELAY - GameRules:GetGameTime()
	if remainTime > 0 then
		self.votes = {}
		self.canSurrender = false
		Timers:CreateTimer(remainTime, function()
			self.canSurrender = true
			self:SendMsgToAll("聊天室窗輸入 -ff 可以投降")
		end)
	end
end

SurrenderSystem:Init()