-- [[API]]
--- self[target_name]:CastedAbilityHandler(target, source, ability, keys)
--- self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
--- self[hero_name]:CastAbilityAtPositionHandler(hero, target_position, ability, keys)
--- self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
--- self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
--- self[hero_name]:GeneralCastAbilityHandler(hero, ability)
-- [[API]]



if AbilityCore == nil then
    AbilityCore = class( { })
end

require('abilities.Zhuge')
if AbilityCore.npc_dota_hero_Invoker == nil then
    print("###  1")
    AbilityCore.npc_dota_hero_Invoker = class( { })
end
function AbilityCore:Init()
    -- 监听玩家使用技能事件
    ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(AbilityCore, "OnPlayerCastAbility"), self)
    -- 监听玩家学习技能事件
    ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(AbilityCore, "OnPlayerLearnedAbility"), self)
end

-- 当玩家释放某个技能
function AbilityCore:OnPlayerCastAbility(keys)
    -- 获取玩家ID
    local player_id = keys.PlayerID

    -- 获取玩家实体
    local player = PlayerResource:GetPlayer(player_id)
    if not player then print("INVALID PLAYER") return end

    -- 获取玩家所使用的英雄
    local hero = player:GetAssignedHero()
    if not hero then print("INVALID HERO") return end

    -- 从keys获取技能名称，再获取所释放的技能
    local ability_name = keys.abilityname
    local ability = hero:FindAbilityByName(ability_name)
    if ability then
        -- print("ABILITY IS VALID", ability:GetAbilityName())
        local ability_target = ability:GetCursorTarget()
        local ability_position = ability:GetCursorPosition()
        local hero_name = hero:GetUnitName()

        -- 如果获取到了技能目标（说明这是一个单位目标技能）
        if ability_target then
            local target_name = ability_target:GetUnitName()
            if self[target_name] and self[target_name].CastedAbilityHandler then
                -- 某个英雄被释放一个指向性技能的Handler
                local source = hero
                local target = ability_target
                ------
                -- -
                self[target_name]:CastedAbilityHandler(target, source, ability, keys)
                -- -
                -----
            end
            if self[hero_name] and self[hero_name].CastAbilityOnTargetHandler then
                -- 某个英雄释放一个指向性技能的Handler
                local source = hero
                local target = ability_target
                -- -
                self[hero_name]:CastAbilityOnTargetHandler(source, target, ability_name, ability, keys)
                -- -
            end
        end
        -- 如果获取到了技能位置，但是没有目标（为了避免某些单位目标技能同时会返回技能目标位置的情况）
        if ability_position and not ability_target then
            if self[hero_name] and self[hero_name].CastAbilityAtPositionHandler then
                -- 当某个英雄对某个位置释放技能的Handler
                ----
                self[hero_name]:CastAbilityAtPositionHandler(hero, ability_position, ability, keys)
                ----
            end
        end
        -- 如果没有技能位置且没有技能目标，那应该是一个无目标技能
        if not(ability_target and ability_position) then
            if self[hero_name] and self[hero_name].CastAbilityNoTargetHandler then
                -- 当某个英雄释放某个无目标技能的Handler
                ----
                self[hero_name]:CastAbilityNoTargetHandler(hero, ability)
                ----
            end
        end
        -- 所有技能的通用接口，只要有对应的英雄文本被require，且
        -- 那个文本中有GeneralCastAbilityHandler这个函数
        -- 那么在这里就会调用那个函数
        if self[hero_name] and self[hero_name].GeneralCastAbilityHandler then
            self[hero_name]:GeneralCastAbilityHandler(hero, ability)
        end
    end
end

function AbilityCore:OnPlayerLearnedAbility(keys)

    -- 获取学习技能的玩家实体
    local player = EntIndexToHScript(keys.player)
    if not player then return end
    -- 获取英雄
    local hero = player:GetAssignedHero()
    if hero then
        local hero_name = hero:GetUnitName()
        if keys.abilityname == 'Zhuge_Wolongguangxian' then 
            self:zhuge_da(keys, hero, keys.abilityname)
        end 

        -- print("LEARNED ABILITY HANDLER", hero_name)
        --[[if self[hero_name] and self[hero_name].LearnAbilityHandler then
            print("###### 3")
            -- 调用对应的接口
            -- print("LEARNED ABILITY HANDLER CALLING HERO SCRIPT, hero:", hero:GetUnitName(), "ability:", keys.abilityname)
            self[hero_name]:LearnAbilityHandler(keys, hero, keys.abilityname)
        end]]
    end
end
function AbilityCore:zhuge_da(keys, hero, ability_name)
    -- 当玩家学习卧龙光线，就设置天变和其他天气技能的等级
    if ability_name == 'Zhuge_Wolongguangxian' then
        local ability = hero:FindAbilityByName('Zhuge_Tianbian')
        if ability:GetLevel() < 1 then
            hero:FindAbilityByName('Zhuge_Tianbian'):SetLevel(1)
            hero:FindAbilityByName('Zhuge_Tianbian_Wu'):SetLevel(1)
            hero:FindAbilityByName('Zhuge_Tianbian_Xue'):SetLevel(1)
            hero:FindAbilityByName('Zhuge_Tianbian_Yu'):SetLevel(1)
            hero:FindAbilityByName('Zhuge_Tianbian_Cancel'):SetLevel(1)
        end
    end
    local weather_abilities = { "Zhuge_Wolongguangxian", "Zhuge_Wuyin", "Zhuge_Leiting", "Zhuge_Bingxuebao" }
    for _, name in pairs(weather_abilities) do
        if name == ability_name then
            ZhugeLevelupAllWeatherAbilities(hero)
        end
    end
end