--[[诸葛亮 技能脚本 XavierCHN @ 2012.11.30]]
require('abilities/ability_generic')

-- 当玩家释放暴雷雨
function OnBaoleiyuStart(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    -- 创建马甲并释放拉席克的暴风雨
    CreateDummyAndCastAbilityOnTarget(caster, "leshrac_lightning_storm", ability:GetLevel(), target, 5, false)
end

-- 当玩家释放飓风·[飓风的马甲单位创建完成之后]
function OnJufeng(keys)

    local caster = keys.caster
    local ability = keys.ability
    -- 这个target获取的是飓风的马甲单位
    local jufeng = keys.target

    -- 设置马甲的伤害技能等级为飓风技能等级
    local ability_effect = jufeng:FindAbilityByName("Zhuge_Jufeng_Dummy")
    ability_effect:SetLevel(ability:GetLevel())

    -- 随机获取一个位置
    local random_angle = QAngle(0, RandomInt(-60, 60), 0)
    local caster_fv = caster:GetForwardVector()
    local target_pos = jufeng:GetOrigin() + caster_fv * 1000
    local random_pos = RotatePosition(jufeng:GetOrigin(), random_angle, target_pos)
    -- 让飓风往随机位置移动
    jufeng:SetContextThink(DoUniqueString('move'), function() jufeng:MoveToPosition(random_pos) end, 0)

    -- 创建一个粒子特效也往那个方向移动
    local info =
    {
        Ability = keys.ability,
        EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf",
        vSpawnOrigin = jufeng:GetAbsOrigin(),
        fDistance = 1000,
        fStartRadius = 64,
        fEndRadius = 64,
        Source = jufeng,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = false,
        vVelocity = (random_pos - jufeng:GetOrigin()):Normalized() * 100,
        bProvidesVision = false,
        iVisionRadius = 0,
        iVisionTeamNumber = jufeng:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)

end

-- 从AbilityCore过来的，诸葛学习技能的监听
if AbilityCore.npc_dota_hero_Invoker == nil then
    AbilityCore.npc_dota_hero_Invoker = class( { })
end

-- 当玩家学习某个天气技能，就同时升级所有其他天气技能
function ZhugeLevelupAllWeatherAbilities(hero)
    local weather_abilities = { "Zhuge_Wolongguangxian", "Zhuge_Wuyin", "Zhuge_Leiting", "Zhuge_Bingxuebao" }
    local max_level = 0
    for _, ability_name in pairs(weather_abilities) do
        local ability = hero:FindAbilityByName(ability_name)
        if ability:GetLevel() > max_level then
            max_level = ability:GetLevel()
        end
    end
    for _, ability_name in pairs(weather_abilities) do
        local ability = hero:FindAbilityByName(ability_name)
        ability:SetLevel(max_level)
    end
end

-- 当玩家学习技能的事件监听
function AbilityCore.npc_dota_hero_Invoker:LearnAbilityHandler(keys, hero, ability_name)
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

-- 技能切换
-- 当玩家使用天变的时候，切换技能为 雾 雨 雪和取消
function ZhugeSwapAbilityToTianbian(caster)
    caster:SwapAbilities("Zhuge_Baoleiyu", "Zhuge_Tianbian_Wu", false, true)
    caster:SwapAbilities("Zhuge_Jidongningjie", "Zhuge_Tianbian_Yu", false, true)
    caster:SwapAbilities("Zhuge_Jufeng", "Zhuge_Tianbian_Xue", false, true)
    caster:SwapAbilities("Zhuge_Tianbian", "Zhuge_Tianbian_Cancel", false, true)
end
-- 当玩家使用取消，或者某个天气，就把技能切换为雷暴雨 急冻凝结 飓风 和天变
function ZhugeTianbianSwapBack(caster)
    caster:SwapAbilities("Zhuge_Baoleiyu", "Zhuge_Tianbian_Wu", true, false)
    caster:SwapAbilities("Zhuge_Jidongningjie", "Zhuge_Tianbian_Yu", true, false)
    caster:SwapAbilities("Zhuge_Jufeng", "Zhuge_Tianbian_Xue", true, false)
    caster:SwapAbilities("Zhuge_Tianbian", "Zhuge_Tianbian_Cancel", true, false)
end
-- 根据选择的天气，把大招切换为对应的天气大招
function SwapAbilityToCurrentWeather(caster, weather_ability_name)
    local weather_abilities = { "Zhuge_Wolongguangxian", "Zhuge_Wuyin", "Zhuge_Leiting", "Zhuge_Bingxuebao" }
    for _, ability_name in pairs(weather_abilities) do
        if ability_name ~= weather_ability_name then
            caster:SwapAbilities(ability_name, weather_ability_name, false, true)
        end
    end
end

-- 当玩家使用天变
function OnTianBian(keys)
    local caster = keys.caster
    ZhugeSwapAbilityToTianbian(caster)
end

-- 当玩家使用天变·雾
function OnTianBianWu(keys)
    local caster = keys.caster
    ZhugeTianbianSwapBack(caster)
    SwapAbilityToCurrentWeather(caster, "Zhuge_Wuyin")
    GameRules:SendCustomMessage("#tianbian_wu", caster:GetTeam(), 0)
end

-- 当玩家使用天变·雨
function OnTianBianYu(keys)
    local caster = keys.caster
    ZhugeTianbianSwapBack(caster)
    -- caster:SwapAbilities("Zhuge_Wolongguangxian","Zhuge_Leiting",false,true)
    SwapAbilityToCurrentWeather(caster, "Zhuge_Leiting")
    GameRules:SendCustomMessage("#tianbian_yu", caster:GetTeam(), 0)
end

-- 当玩家使用天变·雪
function OnTianBianXue(keys)
    local caster = keys.caster
    ZhugeTianbianSwapBack(caster)
    SwapAbilityToCurrentWeather(caster, "Zhuge_Bingxuebao")
    GameRules:SendCustomMessage("#tianbian_xue", caster:GetTeam(), 0)
end

-- 当玩家使用天变·取消
function OnTianBianCancel(keys)
    local caster = keys.caster
    ZhugeTianbianSwapBack(caster)
    local ability_tianbian = caster:FindAbilityByName("Zhuge_Tianbian")
    ability_tianbian:EndCooldown()
end

-- 当玩家使用天变·天变的效果结束
function OnTianbianEnd(keys)
    local caster = keys.caster
    SwapAbilityToCurrentWeather(caster, "Zhuge_Wolongguangxian")
end

-- 获取卧龙光线的目标位置
function GetWolongGuangxianPoint(keys)
    local caster = keys.caster
    local caster_fv = caster:GetForwardVector()
    local caster_origin = caster:GetOrigin()
    
    -- 计算正负30度的两个点，还有中间那个点
    ang_right = QAngle(0, -30, 0)
    ang_left = QAngle(0, 30, 0)
    point_mid = caster_origin + caster_fv * 1200
    point_left = RotatePosition(caster_origin, ang_left, point_mid)
    point_right = RotatePosition(caster_origin, ang_right, point_mid)

    local result = { }
    table.insert(result, point_mid)
    table.insert(result, point_left)
    table.insert(result, point_right)

    return result
end

-- 下面这三个获取的是第三次的，正负五度的位置
function GetWolongGuangxianPointMid3(keys)
    local caster = keys.caster
    local result = { }
    local caster_fv = caster:GetForwardVector()
    local caster_origin = caster:GetOrigin()
    point_mid = caster_origin + caster_fv * 1200
    --table.insert(result, caster.__point_left)
    table.insert(result, point_mid)
    return result
end
function GetWolongGuangxianPointMid2(keys)
    local caster = keys.caster
    local result = { }
    local caster_fv = caster:GetForwardVector()
    local caster_origin = caster:GetOrigin()
    point_mid = caster_origin + caster_fv * 1200
   -- table.insert(result, caster.__point_right)
   table.insert(result, point_mid)
    return result
end
function GetWolongGuangxianPointMid1(keys)
    local caster = keys.caster
    local caster_fv = caster:GetForwardVector()
    local caster_origin = caster:GetOrigin()
    ang_left = QAngle(0, 3, 0)
    ang_right = QAngle(0, -3, 0)
    point_mid = caster_origin + caster_fv * 1200
    point_right = RotatePosition(caster_origin, ang_right, point_mid)
    point_left = RotatePosition(caster_origin, ang_left, point_mid)

    caster.__point_left = point_left
    caster.__point_right = point_right

    local result = { }
    table.insert(result, point_mid)
    return result
end

-- 雾隐和雷霆，使用马甲释放技能
function OnWuyin(keys)
    local caster = keys.caster
    local ability = keys.ability
    CreateDummyAtPositionAndCastAbilityNoTarget(caster, "mirana_invis", ability:GetLevel(), caster:GetOrigin(), 25, false)
end
function OnLeiting(keys)
    local caster = keys.caster
    local ability = keys.ability
    CreateDummyAtPositionAndCastAbilityNoTarget(caster, "zuus_thundergods_wrath", ability:GetLevel(), caster:GetOrigin(), 3, false)
end

-- 急冻凝结的特效
function OnJidongningjieDummy(keys)
    local caster = keys.caster
    local ningjie = keys.target

    local point = ningjie:GetOrigin()

    local p = ParticleManager:CreateParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_CUSTOMORIGIN, ningjie)
    ParticleManager:SetParticleControl(p, 0, point)
    ParticleManager:ReleaseParticleIndex(p)
end