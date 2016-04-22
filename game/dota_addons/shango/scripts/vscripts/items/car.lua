require("utils/utils_print")
--初始化车子系统  
function che_point(keys)  --当车子被购买的时候调用
    -- body
    local caster=EntIndexToHScript(keys.caster_entindex)
    local caster_fv = caster:GetForwardVector()
    local caster_origin = caster:GetOrigin()
    local plyID=caster:GetPlayerID()
    point=GetGroundPosition(caster_origin,caster)
    --判断玩家是否有足够的木材购买投石车，不足则退还220元，且提示木材不足
    local result = { }
       if caster.__lumber_data ~=nil and caster.__lumber_data >= 12 then 
        caster.__lumber_data = caster.__lumber_data-12
            UpdateLumberDataForPlayer(plyID, caster.__lumber_data)
            -- Lumber:UpdateLumberToHUD(plyID, caster.__lumber_data) 
            table.insert(result, point)      
        else 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "木材不足！！！" } )
           caster:ModifyGold(220,false,0)   
        end   
    
    return result
end
function test_001(keys)  --测试
    -- body
end
function on_dummy_spawn(keys)   --投石车普通攻击时调用
    -- body 
    local caster =keys.caster
	local point = keys.target:GetAbsOrigin()  --获取马甲
    local team = keys.caster:GetTeam()       
    local result = { }
    local unit_name = "npc_dummy_1"
    EmitSoundOn("Hero_Bane.Attack", creep)
    --创建马甲
    local creep = CreateUnitByName(unit_name,point, false,caster:GetOwner(),caster:GetOwner(), team)
    creep:SetOwner(caster:GetOwner())
    --投石车与马甲间的角力
    local distance = (keys.caster:GetAbsOrigin()-creep:GetAbsOrigin()):Length()
    --特效飞行时间
    local _time=distance/900
    --为马甲添加范围伤害技能
    local spell = creep:FindAbilityByName("toushiche_dummy_01")
            if spell then  
                spell:SetLevel(1)
            end
    local _target = creep
    local ability=keys.caster:FindAbilityByName("toushiche_toushi_1")
    --投掷物信息
    local info = {
                Target = _target,
                Source = keys.caster,
                Ability =ability,
                EffectName = "particles/base_attacks/ranged_siege_good.vpcf",
                bDodgeable = true,
                bProvidesVision = true,
                iMoveSpeed = 900,
                iVisionRadius = 1,
                iVisionTeamNumber = keys.caster:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
        }
    --发出投掷物
    ProjectileManager:CreateTrackingProjectile( info )    
    creep:SetContextThink(DoUniqueString("chezi_01"),
        function()
            --当特效到达马甲时，释放马甲范围伤害技能
          creep:CastAbilityImmediately(spell, creep:GetOwner():GetPlayerOwnerID())
          EmitSoundOn("Hero_Bane.ProjectileImpact", creep)
        end,_time)
    --定时移除马甲单位
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("chezi_01"),
        function()
            -- body
            creep:RemoveSelf()
        end,3)
end
function on_chezi_spwan(keys)   --当购买车子时电泳
local target=keys.target
local caster = keys.caster
local spell = target:FindAbilityByName("toushiche_toushi_1")  --添加普通攻击技能
           if spell then  
                spell:SetLevel(1)
           end 
           target:AddAbility("toushiche_toushi_2")
local spell2 = target:FindAbilityByName("toushiche_toushi_2")  --添加攻击地面技能
if spell2 then  
             spell2:SetLevel(1)
 end
end
function on_dummy_spawn_2(keys)  --当攻击地面技能使用时调用，与普通攻击原理体育一致，只是马甲单位伤害范围不一样
    -- body  
    local caster =keys.caster
    local point = keys.target_points[1]
    local team = keys.caster:GetTeam()
    local result = { }
    local unit_name = "npc_dummy_2"

    local creep = CreateUnitByName(unit_name,point, false, caster:GetOwner(), caster:GetOwner(), team)
          creep:SetOwner(caster:GetOwner())   
          EmitSoundOn("Hero_Bane.Attack", creep) 
    local distance = (keys.caster:GetAbsOrigin()-creep:GetAbsOrigin()):Length()
    local _time=distance/800
    local spell = creep:FindAbilityByName("toushiche_dummy_02")
            if spell then  
                spell:SetLevel(1)
            end
    local _target = creep
    local ability=keys.caster:FindAbilityByName("toushiche_toushi_2")
    local info = {
                Target = _target,
                Source = keys.caster,
                Ability =ability,
                EffectName = "particles/base_attacks/ranged_siege_good.vpcf",
                bDodgeable = true,
                bProvidesVision = true,
                iMoveSpeed = 800,
                iVisionRadius = 1,
                iVisionTeamNumber = keys.caster:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
        }
    ProjectileManager:CreateTrackingProjectile( info )
    
    creep:SetContextThink(DoUniqueString("chezi_01"),
        function()
            -- body 释放技能
             
            creep:CastAbilityImmediately(spell, creep:GetPlayerOwnerID())
            EmitSoundOn("Hero_Bane.ProjectileImpact", creep)
        end,_time)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("chezi_01"),
        function()
            -- body
            creep:RemoveSelf()
        end,3)
end