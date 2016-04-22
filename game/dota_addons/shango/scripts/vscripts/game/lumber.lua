require("utils/utils_print")

LUMBER_GAIN_HERO_KILL = 5
LUMBER_GAIN_CREEP_KILL = 1

-- 初始化木材系统
if Lumber == nil then Lumber = class( { }) end
function Lumber:Init()
    -- 监听单位击杀事件
    ListenToGameEvent("entity_killed", Dynamic_Wrap(Lumber, "AddLumber"), self)
end
function Lumber:AddLumber(keys)
    local entity_killed = EntIndexToHScript(keys.entindex_killed)
    local entity_attacker = EntIndexToHScript(keys.entindex_attacker)
    if not(entity_killed and entity_attacker) then return end
    local team_attacker = entity_attacker:GetTeam()
    if not(team_attacker == DOTA_TEAM_GOODGUYS or team_attacker == DOTA_TEAM_BADGUYS) then return end -- 确保攻击者是蜀国或者魏国的单位，中立单位击杀的不计算木头

    if not entity_attacker:GetOwner() then
        if not entity_attacker:IsControllableByAnyPlayer() then return end -- 确保击杀的单位是玩家控制的单位，被小兵击杀的也不计算木头
    end

    if entity_attacker:GetPlayerOwnerID() then 
        player_id = entity_attacker:GetPlayerOwnerID() -- 如果是玩家控制的英雄的其他单位，那么获取单位的所有者
    else
        player_id = entity_attacker:GetPlayerID() -- 如果是英雄直接获取玩家ID
    end

    local player = PlayerResource:GetPlayer(player_id) -- 通过玩家ID获取玩家实体
    if not player then return end -- 确保玩家实体获取正确
    
    local hero = player:GetAssignedHero()
    if not hero then return end -- 确保英雄实体获取正确

    -- 一直到这里，所有的判定都是为了确认击杀者是一个玩家的单位

    if hero.__lumber_data == nil then hero.__lumber_data = 0 end -- 如果英雄还未获得任何，那么设置为0

    -- 如果击杀的是英雄，增加5木材
    if entity_killed:IsRealHero() then
       hero.__lumber_data =hero.__lumber_data + LUMBER_GAIN_HERO_KILL
       -- PopupNumbers(entity_killed, "gold", Vector(0, 255, 0), 2.0, LUMBER_GAIN_HERO_KILL, POPUP_SYMBOL_PRE_PLUS, nil)
       PopupImageForPlayer(entity_killed, "images/popup/5lumber.png", player_id) -- image for test purpose, todo
    else
    -- 如果击杀的是普通单位，且是敌人，增加1木材
        if entity_killed:GetTeam() ~= entity_attacker:GetTeam() then
           hero.__lumber_data = hero.__lumber_data + LUMBER_GAIN_CREEP_KILL
           -- PopupNumbers(entity_killed, "gold", Vector(0, 255, 0), 2.0, LUMBER_GAIN_CREEP_KILL, POPUP_SYMBOL_PRE_PLUS, nil)
           PopupImageForPlayer(entity_killed, "images/popup/1lumber.png", player_id)
        end
    end

    -- 刷新界面的木材信息.
    UpdateLumberDataForPlayer(player_id, hero.__lumber_data)
end