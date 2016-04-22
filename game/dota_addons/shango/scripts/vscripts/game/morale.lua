-- 真三·士气系统
-- 每次某一方提升士气，那么降低另一方的士气，双方的士气总额始终为20
-- 1、只要有英雄阵亡该队伍的士气下降，每个队伍的起始值为10，小兵都带有士气buff，
-- 士气在13、16、19时小兵士气buff分别为1、2、3级，（士气buff：加攻速和移动速度）
-- 2、士气buff：移动速度和攻击速度：5% 10% 15%
-- 当某一方的谷仓被击杀
-- 那么降低那一方的士气，同时停发系统工资
-- 兵营，据点，都降士气
-- 谷仓降士气同时停工资

-- Author:XavierCHN @ 2015.3.17

-- 会影响士气的建筑列表
local MORALE_BUILDINGS = {
    "npc_zs_gucang", -- 谷仓
    "npc_zs_bingying", -- 兵营
    "npc_zs_judian", -- 据点
}

-- 会停发工资的建筑
local MORALE_BUILDING_GOLD = "npc_zs_gucang"

-- 初始化
if MSys == nil then MSys = class({}) end

-- 士气系统：初始化
-- 注册事件监听，初始化双方的士气数值
-- 
function MSys:Init()
    -- 注册事件监听
    ListenToGameEvent("dota_player_killed", Dynamic_Wrap(MSys, "OnPlayerKilled"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(MSys, "OnEntityKilled"), self)

    -- 设置双方的初始士气为10
    self.__morale = {}
    self.__morale[DOTA_TEAM_GOODGUYS] = 10
    self.__morale[DOTA_TEAM_BADGUYS] = 10
    self.__moraleLevel = {}
    self.__moraleLevel[DOTA_TEAM_GOODGUYS] = 0
    self.__moraleLevel[DOTA_TEAM_BADGUYS] = 0


    -- 设置双方的金钱
    self.__goldTicking = {}
    self.__goldTicking[DOTA_TEAM_BADGUYS] = true
    self.__goldTicking[DOTA_TEAM_GOODGUYS] = true

    self.__goldTickTimerStarted = false

    -- 注册小兵
    self.__allCreeps = {}

end
--士兵士气技能入口
--------------------------------------------
function MSys:shibing_morale()
   local shibing=ZSSpawner.shibing
   if shibing[1] then 
      self:shibing_morales_set(shibing)
   end 

end
function MSys:shibing_morale_set(target)
     local team = target:GetTeam()
     local ability=target:FindAbilityByName("morale_ability")
     if ability then 
        if self.__morale[team]>10  then 
            ability:SetLevel(self.__morale[team]-9)
        elseif self.__morale[team]<= 10 then 
            ability:SetLevel(1)
        end
     end 
end 
function MSys:shibing_morales_set(target)
    for _,target in pairs(target) do
        local team = target:GetTeam()
        local ability=target:FindAbilityByName("morale_ability")
        if ability then 
            if self.__morale[team]>10  then 
                ability:SetLevel(self.__morale[team]-9)
            elseif self.__morale[team]<= 10 then 
                ability:SetLevel(1)
            end
        end 
    end
     
end 
-- 士气系统：英雄被击杀的响应
-- 当有英雄被击杀的事件响应
-- 
function MSys:OnPlayerKilled(keys)
    local playerId = keys.PlayerID
    local playerKilled = PlayerResource:GetPlayer(playerId)
    if not playerKilled then return end -- 确保成功
    local heroKilled = playerKilled:GetAssignedHero()
    if not heroKilled then return end -- 确保成功

    -- print("[DOTA2ZS] a hero was killed, deal with morale system")

    local heroKilledTeam = heroKilled:GetTeam()
    -- print("player from", heroKilledTeam,"was killed")

    -- 提升被击杀队伍的士气，同时提升击杀方士气
    self:MoraleDown(playerKilled, heroKilledTeam)

       self:shibing_morale()
end

-- 士气系统：单位被击杀的响应
-- 
function MSys:OnEntityKilled(keys)
    local entityKilled = EntIndexToHScript(keys.entindex_killed)
    --打龙奖金
        if entityKilled:GetUnitName() == "npc_dota_long" then
                    local entity_attacker = EntIndexToHScript(keys.entindex_attacker)
                    local _Team = entity_attacker:GetTeam()
                    for i = -1,DOTA_MAX_PLAYERS do
                            local player = PlayerResource:GetPlayer(i)                                       
                            if player then
                                local hero = player:GetAssignedHero() 
                               if hero:GetTeam() == _Team then
                                   PlayerResource:ModifyGold(hero:GetPlayerID(), 1000, false, 0)
                                end
                            end
                    end
        end 

    -- 如果有士气建筑被击杀，那么降低被击杀那方的士气
    for _, name in pairs(MORALE_BUILDINGS) do
        if entityKilled:GetUnitName() == name then
            -- print("a morale building was killed, fixing morale data")
            local team = entityKilled:GetTeam()
            self:MoraleDown(entityKilled, team)

            if entityKilled:GetUnitName() == MORALE_BUILDING_GOLD then
                -- 禁止双方发工资
                GameRules:SetGoldPerTick(0)
                -- GameRules:SetGoldTickTime(0)
                self.__goldTicking[team] = false
                -- 启动一个计时器为另一方发工资
                if not self.__goldTickTimerStarted then
                    self.__goldTickTimerStarted = true
                    local enemyTeam = self:__GetEnemyTeam(team)
                    for i = -1,DOTA_MAX_PLAYERS do
                            local player = PlayerResource:GetPlayer(i)                                       
                            if player then
                                local hero = player:GetAssignedHero() 
                               if hero:GetTeam() == enemyTeam then
                                   PlayerResource:ModifyGold(hero:GetPlayerID(), 800, false, 0)
                                end
                            end
                    end
                    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("moraleTimer_1"),function()
                        if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then return GameRules:GetGoldTickTime() end
                        for i = -1,DOTA_MAX_PLAYERS do
                            local player = PlayerResource:GetPlayer(i)                                       
                            if player then
                                local hero = player:GetAssignedHero() 
                               if hero:GetTeam() == enemyTeam then
                                   PlayerResource:ModifyGold(hero:GetPlayerID(), GameRules:GetGoldPerTick(), false, 0)
                                   -- 如果双方都不发工资，那么停止计时器
                                   if self.__goldTicking[team] == false and self.__goldTicking[self:__GetEnemyTeam(team)] == false then
                                      return nil
                                   else
                                      return GameRules:GetGoldTickTime()
                                   end
                                end
                            end
                        end
                    end,GameRules:GetGoldTickTime())
               
                end
            end
        end
    end

    -- 处理小兵被击杀的问题
    if string.find(entityKilled:GetUnitName(), "npc_zs_creep_" ) then
        for k,v in pairs(self.__allCreeps) do
            if v == entityKilled then
                self.__allCreeps[k] = nil
            end
        end
    end
end

function MSys:MoraleDown(player, team)
    -- 获取敌方士气
    local enemyTeam = self:__GetEnemyTeam(team)
    local enemyMorale = self.__morale[enemyTeam]

    -- 如果敌方士气达到20，不再增加
    if enemyMorale >= 20 then
        return
    end

    -- 提升该队伍的士气
    self.__morale[team] = self.__morale[team] - 1
    self.__morale[enemyTeam] = self.__morale[enemyTeam] + 1
    
    -- 更新士气显示
    UpdateMoraleData(self.__morale[DOTA_TEAM_GOODGUYS], self.__morale[DOTA_TEAM_BADGUYS])

end

-- 当队伍的士气发生变更的时候
-- 
function MSys:DealWithCreepsMorale()
    -- 获取士气较高的队伍的士气，和队伍名称
    local largerMorale = self.__morale[DOTA_TEAM_GOODGUYS]
    local largerMoraleTeam = DOTA_TEAM_GOODGUYS
    if self.__morale[DOTA_TEAM_GOODGUYS] < self.__morale[DOTA_TEAM_BADGUYS] then
        largerMorale = self.__morale[DOTA_TEAM_BADGUYS]
        largerMoraleTeam = DOTA_TEAM_BADGUYS
    end
    local moraleLevel = math.floor((largerMorale - 10) / 3)
    -- print("DEALING WITH MORALE. TEAM IN ADVANTAGE", largerMoraleTeam, "MORALE", largerMorale, "MORALE LEVEL", moraleLevel)

    -- 如果士气较高的那个队伍的士气等级不等于上次的士气等级，那么才需要刷新小兵的士气BUFF
    local creepsUpdateRequired = moraleLevel ~= self.__moraleLevel[largerMoraleTeam]

    -- 将他们的士气数值存入表
    self.__moraleLevel[largerMoraleTeam] = moraleLevel
    self.__moraleLevel[self:__GetEnemyTeam(largerMoraleTeam)] = 0
end

function MSys:__GetEnemyTeam(team)
    if team == DOTA_TEAM_GOODGUYS then return DOTA_TEAM_BADGUYS end
    if team == DOTA_TEAM_BADGUYS then return DOTA_TEAM_GOODGUYS end
end
