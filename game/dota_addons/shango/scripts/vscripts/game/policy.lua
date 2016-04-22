--require("game.ZSSpawner")
----------------------------------------
-------------------策略功能系统组-------
----------------------------------------
if Policy == nil then Policy=class({}) end 
-------------------补给系统-------------
Policy.supply={}
Policy.supply.shu={}
Policy.supply.wei={}
Policy.supply.shu.baozi={LastTime=0,CD=60}
Policy.supply.shu.guojiu ={LastTime=0,CD=60}
Policy.supply.wei.baozi={LastTime=0,CD=60}
Policy.supply.wei.guojiu={LastTime=0,CD=60}

Policy.supply.shu.judian={}
Policy.supply.wei.judian={}

-----------------------------------------
----------------
function Policy:Int()
 	-- body
    ---------------------------测试码----
    Convars:RegisterCommand( "testwood",function( )
        -- body
        local cmdPlayer = Convars:GetCommandClient()   
        if cmdPlayer then
           local caster=cmdPlayer:GetAssignedHero()
           local caster_origin = caster:GetOrigin()
           local plyID=caster:GetPlayerID()
           if caster.__lumber_data == nil then caster.__lumber_data = 0 end
           caster.__lumber_data = caster.__lumber_data+1000
           UpdateLumberDataForPlayer(plyID, caster.__lumber_data)
        end
    end,"use baozi",0)
    Convars:RegisterCommand( "testgold",function( )
        -- body
        local cmdPlayer = Convars:GetCommandClient()   
        if cmdPlayer then
           local caster=cmdPlayer:GetAssignedHero()
           local caster_origin = caster:GetOrigin()
           local plyID=caster:GetPlayerID()
           caster:ModifyGold(1000,false,0)
        end
    end,"use baozi",0)
    Convars:RegisterCommand( "testhero",function( )
        -- body
        local cmdPlayer = Convars:GetCommandClient()   
        if cmdPlayer then
           local caster=cmdPlayer:GetAssignedHero()
           local caster_origin = caster:GetOrigin()
           local plyID=caster:GetPlayerID()
           
        end
    end,"use baozi",0)
    ------------------------------------------
   
    CustomGameEventManager:RegisterListener("UseBaoZi",Dynamic_Wrap(Policy, "UseBaoZi"))
    
    CustomGameEventManager:RegisterListener("YuanJun",Dynamic_Wrap(Policy, "YuanJun"))
    
    CustomGameEventManager:RegisterListener("UseGuoJiu",Dynamic_Wrap(Policy, "UseGuoJiu"))
    
    CustomGameEventManager:RegisterListener("chubing_shanglu",Dynamic_Wrap(Policy, "chubing_shanglu"))
    
    CustomGameEventManager:RegisterListener("chubing_zhonglu",Dynamic_Wrap(Policy, "chubing_zhonglu"))
    
    CustomGameEventManager:RegisterListener("chubing_xialu",Dynamic_Wrap(Policy, "chubing_xialu"))
   
    CustomGameEventManager:RegisterListener("BuyTouShiChe",Dynamic_Wrap(Policy, "BuyTouShiChe"))
    --test command
    --据点
    Policy.supply.shu.judian={jd_s=Entities:FindByName(nil, 'judian_shu_xia'),jd_x=Entities:FindByName(nil, 'judian_shu_shang')}
    Policy.supply.wei.judian={jd_s=Entities:FindByName(nil, 'judian_wei_shang'),jd_x=Entities:FindByName(nil, 'judian_wei_xia')}
    --援军出现点
    Policy.supply.shu.point_yuanjun=Entities:FindByName(nil, 'shu_bot_5')
    Policy.supply.wei.point_yuanjun=Entities:FindByName(nil, 'wei_top_4')
    --紧急征召点
    
end 
function Policy:ShiQi(keys)
    -- body
end
function Policy:YuanJun(keys)
    local playerid=keys.PlayerID
     local team = PlayerResource:GetTeam( playerid )        
     local player = PlayerResource:GetPlayer(playerid)  
     local hero = player:GetAssignedHero()

    local player = Convars:GetCommandClient()   
    if player then
        local caster=player:GetAssignedHero()
        local caster_origin = caster:GetOrigin()
        local plyID=caster:GetPlayerID()
        if caster.__lumber_data ~=nil and caster.__lumber_data >= 60 then 
             --判断玩家是否有足够的金币
            if caster:GetGold() < 800 then 
                FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "金币不足！！！" } )                   
                return nil 
            else 
                caster:SpendGold(800,0)
            end  
            caster.__lumber_data = caster.__lumber_data-60
            UpdateLumberDataForPlayer(plyID, caster.__lumber_data)                                   
        else 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "木材不足！！！" } )                   
            return nil
        end   
       
         
        local team =caster:GetTeam()
        local boss
        if team == DOTA_TEAM_GOODGUYS then
            boss = CreateUnitByName("npc_dota_creature_boss_pudge", Policy.supply.shu.point_yuanjun:GetOrigin(), true, nil, nil, team)
            boss:SetTeam(team)
            boss:SetMustReachEachGoalEntity(false)
            boss:SetInitialGoalEntity(Policy.supply.shu.point_yuanjun)
        elseif team == DOTA_TEAM_BADGUYS then
            boss = CreateUnitByName("npc_dota_creature_boss_pudge", Policy.supply.wei.point_yuanjun:GetOrigin(), true, nil, nil, team)
            boss:SetTeam(team)
            boss:SetMustReachEachGoalEntity(false)
            boss:SetInitialGoalEntity(Policy.supply.wei.point_yuanjun)
        end

    end 

end 
function Policy:UseBaoZi(keys)  --使用包子时调用，当英雄在据点800范围内时，使用有效。
	-- body
    print("baozi success!")
    local playerid=keys.PlayerID
     local team = PlayerResource:GetTeam( playerid )        
     local player = PlayerResource:GetPlayer(playerid)  
     local hero = player:GetAssignedHero()


      
    if hero:GetGold() < 50 then 
         FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "金币不足！" } )
         return nil 
    end
    if player then
         if hero:IsAlive() then  --如果英雄存活
            local hero_origin = hero:GetOrigin()  --获取英雄位置
            local distance =nil  --英雄到据点的距离
            local team =hero:GetTeam() 
            if team == DOTA_TEAM_GOODGUYS then
                if Policy.supply.shu.baozi.LastTime ~= 0 and GameRules:GetGameTime()-Policy.supply.shu.baozi.LastTime<Policy.supply.shu.baozi.CD then
                    FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "离补给时间还有："..tostring(math.ceil((Policy.supply.shu.baozi.CD-(GameRules:GetGameTime()-Policy.supply.shu.baozi.LastTime)))).." 秒！" } )
                    return nil
                end 
                if (Policy.supply.shu.judian.jd_s:GetOrigin() - hero_origin):Length() <= 800 or (Policy.supply.shu.judian.jd_x:GetOrigin() - hero_origin):Length() <= 800 then
                    if hero:GetHealth() == hero:GetMaxHealth() then 
                        FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "生命值已满！" } )
                         return nil
                    else 
                        hero:Heal(400, hero) 
                        hero:SpendGold(50,0)
                        Policy.supply.shu.baozi.LastTime = GameRules:GetGameTime()
                    end
                else
                    FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "不在据点附近，无法补给！" } )                  
                     return nil
                end
            elseif team == DOTA_TEAM_BADGUYS then 
                if Policy.supply.wei.baozi.LastTime ~= 0 and GameRules:GetGameTime()-Policy.supply.wei.baozi.LastTime<Policy.supply.wei.baozi.CD then
                    FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "离补给时间还有："..tostring(math.ceil((Policy.supply.wei.baozi.CD-(GameRules:GetGameTime()-Policy.supply.wei.baozi.LastTime)))).." 秒！" } )
                     return nil
                end 
                if (Policy.supply.wei.judian.jd_s:GetOrigin() - hero_origin):Length() <= 800 or (Policy.supply.wei.judian.jd_x:GetOrigin() - hero_origin):Length() <= 800 then
                    if hero:GetHealth() == hero:GetMaxHealth() then 
                        FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "生命值已满！" } )
                         return nil
                    
                    else
                        hero:Heal(400, hero) 
                        hero:SpendGold(50,0)
                        Policy.supply.wei.baozi.LastTime = GameRules:GetGameTime()
                    end
                else
                    FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "不在据点附近，无法补给！" } )                  
                     return nil
                end
            end 

        end        
    end
end
function Policy:UseGuoJiu(keys)  --使用果酒时调用
	-- body
    print("guojiu success!")
      local playerid=keys.PlayerID       
     local player = PlayerResource:GetPlayer(playerid)  
     local hero = player:GetAssignedHero()     
      if hero:GetGold() < 50 then 
         FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "金币不足！" } )
         return nil 
      end
    if player then
         if hero:IsAlive() then  --如果英雄存活
            local hero_origin = hero:GetOrigin()  --获取英雄位置
            local distance =nil  --英雄到据点的距离
            local team =hero:GetTeam() 
            if team == DOTA_TEAM_GOODGUYS then
                if Policy.supply.shu.guojiu.LastTime ~= 0 and GameRules:GetGameTime()-Policy.supply.shu.guojiu.LastTime<Policy.supply.shu.guojiu.CD then
                    FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "离补给时间还有："..tostring(math.ceil((Policy.supply.shu.guojiu.CD-(GameRules:GetGameTime()-Policy.supply.shu.guojiu.LastTime)))).." 秒！" } )
                     return nil
                end
                if (Policy.supply.shu.judian.jd_s:GetOrigin() - hero_origin):Length() <= 800 or (Policy.supply.shu.judian.jd_x:GetOrigin() - hero_origin):Length() <= 800 then
                    if hero:GetMana() == hero:GetMaxMana() then 
                        FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "魔法值已满！" } )
                         return nil
                    elseif hero:GetMana() + 100 >= hero:GetMaxMana() then
                        hero:SetMana(hero:GetMaxMana())
                        hero:SpendGold(50,0)
                        Policy.supply.shu.guojiu.LastTime = GameRules:GetGameTime()
                    else
                        hero:SetMana(hero:GetMana()+100)
                        hero:SpendGold(50,0)
                        Policy.supply.shu.guojiu.LastTime = GameRules:GetGameTime()
                    end
                else
                    FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "不在据点附近，无法补给！" } )                  
                     return nil
                end
            elseif team == DOTA_TEAM_BADGUYS then 
                if Policy.supply.wei.guojiu.LastTime ~= 0 and GameRules:GetGameTime()-Policy.supply.wei.guojiu.LastTime<Policy.supply.wei.guojiu.CD then
                    FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "离补给时间还有："..tostring(math.ceil((Policy.supply.wei.guojiu.LastTime-(GameRules:GetGameTime()-Policy.supply.wei.guojiu.LastTime)))).." 秒！" } )
                    return nil
                end 
                if (Policy.supply.wei.judian.jd_s:GetOrigin() - hero_origin):Length() <= 800 or (Policy.supply.wei.judian.jd_x:GetOrigin() - hero_origin):Length()  <= 800 then
                    if hero:GetMana() == hero:GetMaxMana() then 
                        FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "魔法值已满！" } )
                         return nil
                    elseif hero:GetMana() + 100 >= hero:GetMaxMana() then
                        hero:SetMana(hero:GetMaxMana())
                        hero:SpendGold(50,0)
                         Policy.supply.wei.guojiu.LastTime = GameRules:GetGameTime()
                    else
                        hero:SetMana(hero:GetMana()+100)
                        hero:SpendGold(50,0)
                         Policy.supply.wei.guojiu.LastTime = GameRules:GetGameTime()
                    end
                else
                    FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "不在据点附近，无法补给！" } )                  
                     return nil
                end
            end 

        end        
    end
end
function Policy:chubing_shanglu(keys)  --上路出兵调用
	-- body
     local playerid=keys.PlayerID       
     local player = PlayerResource:GetPlayer(playerid)  
     local hero = player:GetAssignedHero() 

	   
    if player then
        local caster=player:GetAssignedHero()
        local caster_origin = caster:GetOrigin()
        local plyID=caster:GetPlayerID()
        --判断玩家是否有足够的木材购买投石车，不足则退还220元，且提示木材不足
        if caster.__lumber_data ~=nil and caster.__lumber_data >= 20 then 
            caster.__lumber_data = caster.__lumber_data-20
            UpdateLumberDataForPlayer(plyID, caster.__lumber_data)                                   
        else 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "木材不足！！！" } )                   
            return nil
        end   
        --判断玩家是否有足够的金币
        if caster:GetGold() < 240 then 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "金币不足！！！" } )                   
            return nil 
        else 
            caster:SpendGold(240,0)
        end  
         
        local team =caster:GetTeam()

        for i = 1, 6 do
            if team == DOTA_TEAM_BADGUYS then
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_top"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_mid"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_bot"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
            else   
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_top"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_mid"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_bot"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
            end
        end
        for i = 1, 2 do
            if team == DOTA_TEAM_BADGUYS then
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_top"]:GetOrigin() + Vector(80, 0, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_top"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_mid"]:GetOrigin() + Vector(50, 50, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_mid"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_bot"]:GetOrigin() + Vector(0, 80, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_bot"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
            else  
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_top"]:GetOrigin() + Vector(0, -80, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_top"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_mid"]:GetOrigin() + Vector(-50, -50, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_mid"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_bot"]:GetOrigin() + Vector(-80, 0, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_bot"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
            end
        end
    end
end
function Policy:chubing_zhonglu(keys)  --中路出兵调用
	-- body
    local playerid=keys.PlayerID       
     local player = PlayerResource:GetPlayer(playerid)  
     local hero = player:GetAssignedHero() 
   
    if player then
        local caster=player:GetAssignedHero()
        local caster_origin = caster:GetOrigin()
        local plyID=caster:GetPlayerID()
        --判断玩家是否有足够的木材购买投石车，不足则退还220元，且提示木材不足
        if caster.__lumber_data ~=nil and caster.__lumber_data >= 20 then 
            caster.__lumber_data = caster.__lumber_data-20
            UpdateLumberDataForPlayer(plyID, caster.__lumber_data)                                   
        else 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "木材不足！！！" } )                   
            return nil
        end   
        --判断玩家是否有足够的金币
        if caster:GetGold() < 240 then 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "金币不足！！！" } )                   
            return nil 
        else 
            caster:SpendGold(240,0)
        end  
         
        local team =caster:GetTeam()

        for i = 1, 6 do
            if team == DOTA_TEAM_BADGUYS then
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_top"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_mid"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_bot"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
            else   
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_top"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_mid"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_bot"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
            end
        end
        for i = 1, 2 do
            if team == DOTA_TEAM_BADGUYS then
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_top"]:GetOrigin() + Vector(80, 0, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_top"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_mid"]:GetOrigin() + Vector(50, 50, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_mid"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_bot"]:GetOrigin() + Vector(0, 80, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_bot"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
            else  
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_top"]:GetOrigin() + Vector(0, -80, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_top"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_mid"]:GetOrigin() + Vector(-50, -50, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_mid"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_bot"]:GetOrigin() + Vector(-80, 0, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_bot"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
            end
        end
    end
end
function Policy:chubing_xialu(keys) --下路出兵调用
	-- body
    local playerid=keys.PlayerID       
     local player = PlayerResource:GetPlayer(playerid)  
     local hero = player:GetAssignedHero()
	   
    if player then
        local caster=player:GetAssignedHero()
        local caster_origin = caster:GetOrigin()
        local plyID=caster:GetPlayerID()
        --判断玩家是否有足够的木材购买投石车，不足则退还220元，且提示木材不足
        if caster.__lumber_data ~=nil and caster.__lumber_data >= 20 then 
            caster.__lumber_data = caster.__lumber_data-20
            UpdateLumberDataForPlayer(plyID, caster.__lumber_data)                                   
        else 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "木材不足！！！" } )                   
            return nil
        end   
        --判断玩家是否有足够的金币
        if caster:GetGold() < 240 then 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "金币不足！！！" } )                   
            return nil 
        else 
            caster:SpendGold(240,0)
        end  
         
        local team =caster:GetTeam()

        for i = 1, 6 do
            if team == DOTA_TEAM_BADGUYS then
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_top"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_mid"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", ZSSpawner.__target["wei_bot"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
            else   
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_top"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_mid"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", ZSSpawner.__target["shu_bot"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
            end
        end
        for i = 1, 2 do
            if team == DOTA_TEAM_BADGUYS then
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_top"]:GetOrigin() + Vector(80, 0, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_top"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_mid"]:GetOrigin() + Vector(50, 50, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_mid"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["wei_bot"]:GetOrigin() + Vector(0, 80, 0), "npc_zs_creep_wei_range", ZSSpawner.__target["wei_bot"], DOTA_TEAM_BADGUYS, ZSSpawner.__creature_levelup)
            else  
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_top"]:GetOrigin() + Vector(0, -80, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_top"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                --ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_mid"]:GetOrigin() + Vector(-50, -50, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_mid"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
                ZSSpawner:DoSpawn(ZSSpawner.__spawners["shu_bot"]:GetOrigin() + Vector(-80, 0, 0), "npc_zs_creep_shu_range", ZSSpawner.__target["shu_bot"], DOTA_TEAM_GOODGUYS, ZSSpawner.__creature_levelup)
            end
        end
    end
end
function Policy:BuyTouShiChe(keys) --购买投石车时调用
	-- body
      local playerid=keys.PlayerID       
     local player = PlayerResource:GetPlayer(playerid)  
     local hero = player:GetAssignedHero()
     
	  
    if player then
        local caster=player:GetAssignedHero()
        local caster_origin = caster:GetOrigin()
        local plyID=caster:GetPlayerID()
        --判断玩家是否有足够的木材购买投石车，不足则退还220元，且提示木材不足
        if caster.__lumber_data ~=nil and caster.__lumber_data >= 12 then 
            caster.__lumber_data = caster.__lumber_data-12
            UpdateLumberDataForPlayer(plyID, caster.__lumber_data)                                   
        else 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "木材不足！！！" } )                   
            return nil
        end   
        --判断玩家是否有足够的金币
        if caster:GetGold() < 220 then 
            FireGameEvent( 'custom_error_show', { player_ID = caster:GetPlayerID(), _error = "金币不足！！！" } )                   
            return nil 
        else 
            caster:SpendGold(220,0)
        end
        --获取离英雄最近的据点
            local near_jd = nil
            local caster_origin = caster:GetOrigin()  --获取英雄位置
            local team =caster:GetTeam() 
            if team == DOTA_TEAM_GOODGUYS then
                near_jd =Policy.supply.shu.judian.jd_s:GetOrigin()
                if (Policy.supply.shu.judian.jd_s:GetOrigin() - caster_origin):Length() > (Policy.supply.shu.judian.jd_x:GetOrigin() - caster_origin):Length() then
                    near_jd=Policy.supply.shu.judian.jd_x:GetOrigin()
                end 
            elseif team == DOTA_TEAM_BADGUYS then  
                near_jd =Policy.supply.wei.judian.jd_s:GetOrigin() 
                if (Policy.supply.wei.judian.jd_s:GetOrigin()  - caster_origin):Length() > (Policy.supply.wei.judian.jd_x:GetOrigin() - caster_origin):Length() then
                    near_jd=Policy.supply.wei.judian.jd_x:GetOrigin()
                end 
            end  
        --创建投石车
        local car =CreateUnitByName("npc_che",near_jd, false,caster,caster, team)
        FindClearSpaceForUnit(car, near_jd, false)
        car:SetOwner(caster)
        car:SetControllableByPlayer(plyID,true)
        local spell = car:FindAbilityByName("toushiche_toushi_1")  --添加普通攻击技能
        if spell then  
              spell:SetLevel(1)
        end 
        car:AddAbility("toushiche_toushi_2")
        local spell2 = car:FindAbilityByName("toushiche_toushi_2")  --添加攻击地面技能
        if spell2 then  
              spell2:SetLevel(1)
        end
    end
end