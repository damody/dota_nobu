-- 初始化刷怪器·真三
if ZSSpawner == nil then
    ZSSpawner = class( { })
end
ZSSpawner.shibing={}
ZSSpawner.hero={}
-- API ： 开始刷怪
function ZSSpawner:Start_wild_init( )
    -- body
    -- 监听单位击杀事件
    ListenToGameEvent("entity_killed", Dynamic_Wrap(ZSSpawner, "wild"), self)
end
function ZSSpawner:wild_maxaway(caster) --当野怪的离开距离时返回原点
    -- body
     local maxtime=0
     local lifetime=0
     local lifetime1=0
     local health=caster:GetHealth()
     local wild_origin_name = caster:GetContext("spwaner_name")
     local wild_origin = Entities:FindByName(nil, wild_origin_name)
     local goback = false
     caster:SetContextThink( "wild_maxaway", function()
          if not caster:IsAlive() then return nil end 
          local caster_vec = caster:GetAbsOrigin()
          local wild_spwaner = wild_origin:GetAbsOrigin()
          local distance = (wild_spwaner-caster_vec):Length()
          if wild_origin_name== "zs_long_1"  then 
             if distance > 1600 then 
                caster:MoveToPositionAggressive(wild_spwaner)
                goback = true
             end             
          end
          if maxtime>8 then
                caster:MoveToPositionAggressive(wild_spwaner)
                caster:AddAbility("ability_yeguai_buff")
                local abi=caster:FindAbilityByName("ability_yeguai_buff")
                abi:SetLevel(1)
                goback = true
                maxtime=0
          end
          if distance > 10 then 
             local enemies = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil,1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
             if not enemies then 
                caster:MoveToPositionAggressive(wild_spwaner)
                goback = true
             end
          end
          if distance < 50 then
            if caster:HasAbility("ability_yeguai_buff") then
               caster:RemoveAbility("ability_yeguai_buff")
               goback = false
            end
            if caster:HasModifier("yeguai_buff_001") then 
                 caster:RemoveModifierByName("yeguai_buff_001")
                 goback = false
            end
            
          end
          if wild_origin_name== "zs_long_1"  then
               if health == caster:GetHealth() then                                    
                        if caster:GetHealth() ~= caster:GetMaxHealth() then lifetime=lifetime+1 end
                        if lifetime > 20 then 
                          if caster:GetHealth() ~= caster:GetMaxHealth() then
                            caster:SetHealth(caster:GetMaxHealth())  
                            lifetime=0
                          end                             
                        end
                else
                   lifetime=0
                end             
          end
          if goback == true then 
            caster:MoveToPositionAggressive(wild_spwaner)
          end
            if wild_origin_name== "zs_long_1"  then
                if health ~= caster:GetHealth() then
                   health = caster:GetHealth()
                   lifitime=0
                end             
            end 

          if distance > 10 then
              maxtime=maxtime+1 
              return 1
          else 
              return 1
          end
     end,0)         
end
function table.removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
      if list[i - rmCount] == item then
          table.remove(list, i - rmCount)
          if removeAll then
              rmCount = rmCount + 1
          else
              break
          end
      end
   end
end
function ZSSpawner:wild(keys)
    -- body
    local entity_killed = EntIndexToHScript(keys.entindex_killed)
    local entity_attacker = EntIndexToHScript(keys.entindex_attacker)
    if not(entity_killed and entity_attacker) then return end
    if entity_killed:GetContext("isshibing")==1 then
        table.removeItem(self.shibing,entity_killed,nil)
    end 
    if entity_killed:GetContext("iswild")==1 then 
        local _wild_name=entity_killed:GetContext("wild_name")
        local _spwaner_name = entity_killed:GetContext("spwaner_name")
        if _wild_name == "npc_zs_qiangdao" then 
            GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("ZSSpawnerTimer_11"),function()        
                self:DoSpawn_wild(self._spawner_wild[_spwaner_name]:GetOrigin(),_wild_name,_spwaner_name)
                return nil
            end,75)
        elseif _wild_name=="npc_dota_long" then
            GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("ZSSpawnerTimer_12"),function()        
                self:DoSpawn_wild(self._spawner_wild[_spwaner_name]:GetOrigin(),_wild_name,_spwaner_name)
                return nil
            end,360)
        else 
            GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("ZSSpawnerTimer_22"),function()                
                self:DoSpawn_wild(self._spawner_wild[_spwaner_name]:GetOrigin(),_wild_name,_spwaner_name)
                return nil
            end,85)
        end
    end
end
function ZSSpawner:Start_wild()
    -- body
     -- 寻找刷怪点
    self:CollectSpawners()

    self:DoSpawn_wild(self._spawner_wild["zs_bailangwang"]:GetOrigin(),"npc_zs_beifangzhilang_b","zs_bailangwang")
    self:DoSpawn_wild(self._spawner_wild["zs_bailang_1"]:GetOrigin(),"npc_zs_beifangzhilang_s","zs_bailang_1")
    self:DoSpawn_wild(self._spawner_wild["zs_bailang_2"]:GetOrigin(),"npc_zs_beifangzhilang_s","zs_bailang_2")
    self:DoSpawn_wild(self._spawner_wild["zs_beijixiong"]:GetOrigin(),"npc_zs_beijixiong","zs_beijixiong")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_1"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_1")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_2"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_2")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_3"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_3")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_4"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_4")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_5"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_5")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_6"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_6")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_7"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_7")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_8"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_8")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_9"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_9")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_10"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_10")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_11"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_11")
    self:DoSpawn_wild(self._spawner_wild["zs_qiangdao_12"]:GetOrigin(),"npc_zs_qiangdao","zs_qiangdao_12")
    self:DoSpawn_wild(self._spawner_wild["zs_laohu_da"]:GetOrigin(),"npc_zs_laohu_b","zs_laohu_da")  --target
    self:DoSpawn_wild(self._spawner_wild["zs_laohu_xiao_1"]:GetOrigin(),"npc_zs_laohu_s","zs_laohu_xiao_1")  --target
    self:DoSpawn_wild(self._spawner_wild["zs_laohu_xiao_2"]:GetOrigin(),"npc_zs_laohu_s","zs_laohu_xiao_2")   --target
    self:DoSpawn_wild(self._spawner_wild["zs_pangxie_2"]:GetOrigin(),"npc_zs_pangxie","zs_pangxie_2")
    self:DoSpawn_wild(self._spawner_wild["zs_pangxie_1"]:GetOrigin(),"npc_zs_pangxie","zs_pangxie_1")
    self:DoSpawn_wild(self._spawner_wild["zs_aoxia"]:GetOrigin(),"npc_zs_aoxiao","zs_aoxia")
    self:DoSpawn_wild(self._spawner_wild["zs_long_1"]:GetOrigin(),"npc_dota_long","zs_long_1")
end
function ZSSpawner:bingying_alive_init()
    -- body
    -- 监听单位击杀事件
    self.bingying_alive={}
    self.bingying_alive["bingying_wei_shang"]=true
    self.bingying_alive["bingying_wei_mid"]=true
    self.bingying_alive["bingying_wei_xia"]=true
    self.bingying_alive["bingying_shu_shang"]=true
    self.bingying_alive["bingying_shu_mid"]=true
    self.bingying_alive["bingying_shu_xia"]=true
    ListenToGameEvent("entity_killed", Dynamic_Wrap(ZSSpawner, "spwaner_stop"), self)
end
function ZSSpawner:spwaner_stop(keys)
    -- body
local entity_killed = EntIndexToHScript(keys.entindex_killed)
local killed_name = entity_killed:GetName()
   for k,v in pairs(self.bingying_alive) do
        if killed_name == k then 
           self.bingying_alive[k] = false
        end
   end

end
function ZSSpawner:Start()

    -- 初始刷近战3个，远程1个
    self.__melee_count = 3
    self.__range_count = 1

    -- 记录开始刷兵时间
    self.__spawn_start_time = GameRules:GetGameTime()
    self.__last_spawn_time = GameRules:GetGameTime()

    -- 记录小兵升级
    self.__creature_levelup = 0

    -- 刷第一波怪
    self:Spawn()
    
    -- TODO，尝试改用SetContextThink()
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("ZSSpawnerTimer"),function()
        local now = GameRules:GetGameTime()
        -- 如果当前时间距离上一次刷怪时间超过30秒，那么刷新下一波怪
        if now - self.__last_spawn_time >= 30 then
            self.__last_spawn_time = now -- 记录上次刷怪时间
            -- 当游戏时间逝去1000秒，近战兵为4个
            if now - self.__spawn_start_time >= 1000 and self.__melee_count <= 3 then
                self.__melee_count = 4
            end

            -- 当游戏时间逝去1300秒，远程兵为2个
            if now - self.__spawn_start_time >= 1300 and self.__range_count <= 1 then
                self.__range_count = 2
            end

            -- 每550秒小兵等级增加1级，增加40血量和7攻击，550秒要加上英雄选择的12秒和出兵的48秒。
            local upgrade_level = math.floor((now - self.__spawn_start_time + 60) / 550)
            if upgrade_level > self.__creature_levelup then self.__creature_levelup = upgrade_level end

            -- 循环刷近战和远程兵
            -- print("DO SPAWN")
            for i = 1, self.__melee_count do
                if self.bingying_alive["bingying_wei_shang"]==true then
                    self:DoSpawn(self.__spawners["wei_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", self.__target["wei_top"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_wei_mid"]==true then
                    self:DoSpawn(self.__spawners["wei_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", self.__target["wei_mid"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_wei_xia"]==true then
                    self:DoSpawn(self.__spawners["wei_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", self.__target["wei_bot"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_shu_shang"]==true then
                    self:DoSpawn(self.__spawners["shu_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", self.__target["shu_top"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_shu_mid"]==true then
                    self:DoSpawn(self.__spawners["shu_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", self.__target["shu_mid"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_shu_xia"]==true then
                    self:DoSpawn(self.__spawners["shu_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", self.__target["shu_bot"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
                end
            end
            for i = 1, self.__range_count do
                -- 确保远程兵刷在最后一个。-- 或者说是尽量刷在最后一个吧
                
                if self.bingying_alive["bingying_wei_shang"]==true then
                    self:DoSpawn(self.__spawners["wei_top"]:GetOrigin() + Vector(50, 0, 0), "npc_zs_creep_wei_range", self.__target["wei_top"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_wei_mid"]==true then
                    self:DoSpawn(self.__spawners["wei_mid"]:GetOrigin() + Vector(30, 30, 0), "npc_zs_creep_wei_range", self.__target["wei_mid"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_wei_xia"]==true then
                    self:DoSpawn(self.__spawners["wei_bot"]:GetOrigin() + Vector(0, 50, 0), "npc_zs_creep_wei_range", self.__target["wei_bot"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_shu_shang"]==true then
                    self:DoSpawn(self.__spawners["shu_top"]:GetOrigin() + Vector(0, -50, 0), "npc_zs_creep_shu_range", self.__target["shu_top"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_shu_mid"]==true then
                    self:DoSpawn(self.__spawners["shu_mid"]:GetOrigin() + Vector(-30, -30, 0), "npc_zs_creep_shu_range", self.__target["shu_mid"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
                end
                if self.bingying_alive["bingying_shu_xia"]==true then
                    self:DoSpawn(self.__spawners["shu_bot"]:GetOrigin() + Vector(-50, 0, 0), "npc_zs_creep_shu_range", self.__target["shu_bot"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
                end
            end
        end
             return 0.5
    end,0)
end

-- 刷怪函数
function ZSSpawner:Spawn()
    -- 循环近战小兵个数和远程小兵个数次，分别在六个刷怪点刷对应个数的怪。
    for i = 1, self.__melee_count do
        self:DoSpawn(self.__spawners["wei_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", self.__target["wei_top"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["wei_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", self.__target["wei_mid"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["wei_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_wei_melee", self.__target["wei_bot"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["shu_top"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", self.__target["shu_top"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["shu_mid"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", self.__target["shu_mid"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["shu_bot"]:GetOrigin() + RandomVector(30), "npc_zs_creep_shu_melee", self.__target["shu_bot"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
    end
    for i = 1, self.__range_count do
        self:DoSpawn(self.__spawners["wei_top"]:GetOrigin() + Vector(80, 0, 0), "npc_zs_creep_wei_range", self.__target["wei_top"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["wei_mid"]:GetOrigin() + Vector(50, 50, 0), "npc_zs_creep_wei_range", self.__target["wei_mid"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["wei_bot"]:GetOrigin() + Vector(0, 80, 0), "npc_zs_creep_wei_range", self.__target["wei_bot"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["shu_top"]:GetOrigin() + Vector(0, -80, 0), "npc_zs_creep_shu_range", self.__target["shu_top"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["shu_mid"]:GetOrigin() + Vector(-50, -50, 0), "npc_zs_creep_shu_range", self.__target["shu_mid"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
        self:DoSpawn(self.__spawners["shu_bot"]:GetOrigin() + Vector(-80, 0, 0), "npc_zs_creep_shu_range", self.__target["shu_bot"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
    end
end

-- 在某个刷怪点刷怪，并让他向敌方开始进军的API
function ZSSpawner:SpawnUnitAtShuTop(unit_name)
    self:DoSpawn(self.__spawners["shu_top"]:GetOrigin() + RandomVector(30), unit_name, self.__target["shu_top"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
end
function ZSSpawner:SpawnUnitAtShuMid(unit_name)
    self:DoSpawn(self.__spawners["shu_mid"]:GetOrigin() + RandomVector(30), unit_name, self.__target["shu_mid"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
end
function ZSSpawner:SpawnUnitAtShuBot(unit_name)
    self:DoSpawn(self.__spawners["shu_bot"]:GetOrigin() + RandomVector(30), unit_name, self.__target["shu_bot"], DOTA_TEAM_GOODGUYS, self.__creature_levelup)
end
function ZSSpawner:SpawnUnitAtWeiTop(unit_name)
    self:DoSpawn(self.__spawners["wei_top"]:GetOrigin() + RandomVector(30), unit_name, self.__target["wei_top"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
end
function ZSSpawner:SpawnUnitAtWeiMid(unit_name)
    self:DoSpawn(self.__spawners["wei_mid"]:GetOrigin() + RandomVector(30), unit_name, self.__target["wei_mid"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
end
function ZSSpawner:SpawnUnitAtWeiBot(unit_name)
    self:DoSpawn(self.__spawners["wei_bot"]:GetOrigin() + RandomVector(30), unit_name, self.__target["wei_bot"], DOTA_TEAM_BADGUYS, self.__creature_levelup)
end

-- [Comment]
-- 刷一个小兵的函数，在其他地方也可以调用
-- spawn_location: 刷怪地点
-- unit_name: 刷怪名称
-- initial_target: 初始目标
-- team: 队伍
-- level: 等级，要升级为几级，就设置为几级
function ZSSpawner:DoSpawn(spawn_location, unit_name, initial_target, team, level)
    local creep = CreateUnitByName(unit_name, spawn_location, true, nil, nil, team)
    creep:SetContextNum("isshibing",1,0)
    table.insert(self.shibing,creep)
    -- 如果是兵线上的小兵，为其设置等级
    if creep:GetClassname() == 'npc_dota_creep_lane' then
        self:CreepLevelUp(creep, level)
    end
    -- 如果可以应用CreatureLevelUp，则为其升级
    if creep.CreatureLevelUp and level > 1 then
        print('creature level up enabled, leveling')
        creep:CreatureLevelUp(level - 1)
    end
    MSys:shibing_morale_set(creep)
    creep:SetHullRadius(40)
    FindClearSpaceForUnit(creep,creep:GetAbsOrigin(), false)
   
    creep:SetMustReachEachGoalEntity(false)
    creep:SetInitialGoalEntity(initial_target)
end
function ZSSpawner:DoSpawn_wild(spawn_location, unit_name,spwaner_name)
    -- body
    local creep = CreateUnitByName(unit_name, spawn_location, true, nil, nil,DOTA_TEAM_NEUTRALS)
    creep:SetContextNum("iswild",1,0)
    creep:SetContext("wild_name",unit_name,0)
    creep:SetContext("spwaner_name",spwaner_name,0)
    FindClearSpaceForUnit(creep,creep:GetAbsOrigin(), false) 
    creep:SetHullRadius(42)
    self:wild_maxaway(creep)
end

-- 为小兵升级的特殊函数，血量+40，攻击力+7
function ZSSpawner:CreepLevelUp(creep, level,team)
    local health = creep:GetHealth() + 40 * level
    creep:SetMaxHealth(health)
    creep:SetHealth(health)
    creep:SetBaseDamageMin(creep:GetBaseDamageMin() + 7 * level)
    creep:SetBaseDamageMax(creep:GetBaseDamageMax() + 7 * level)
end

-- 循环在地图上查找刷怪位置实体
function ZSSpawner:CollectSpawners()
    self.__spawners = { }
    self.__target = { }
    self._spawner_wild={ }
-------------野怪
    local zs_bailang_2 = Entities:FindByName(nil, 'zs_bailang_2')
    local zs_bailang_1 = Entities:FindByName(nil, 'zs_bailang_1')
    local zs_bailangwang = Entities:FindByName(nil, 'zs_bailangwang')
    local zs_beijixiong = Entities:FindByName(nil, 'zs_beijixiong')
    local zs_qiangdao_1 = Entities:FindByName(nil, 'zs_qiangdao_1')
    local zs_qiangdao_2 = Entities:FindByName(nil, 'zs_qiangdao_2')
    local zs_qiangdao_3 = Entities:FindByName(nil, 'zs_qiangdao_3')
    local zs_qiangdao_4 = Entities:FindByName(nil, 'zs_qiangdao_4')
    local zs_qiangdao_5 = Entities:FindByName(nil, 'zs_qiangdao_5')
    local zs_qiangdao_6 = Entities:FindByName(nil, 'zs_qiangdao_6')
    local zs_qiangdao_7 = Entities:FindByName(nil, 'zs_qiangdao_7')
    local zs_qiangdao_8 = Entities:FindByName(nil, 'zs_qiangdao_8')
    local zs_qiangdao_9 = Entities:FindByName(nil, 'zs_qiangdao_9')
    local zs_qiangdao_10 = Entities:FindByName(nil, 'zs_qiangdao_10')
    local zs_qiangdao_11 = Entities:FindByName(nil, 'zs_qiangdao_11')
    local zs_qiangdao_12 = Entities:FindByName(nil, 'zs_qiangdao_12')
    local zs_laohu_da = Entities:FindByName(nil, 'zs_laohu_da')
    local zs_laohu_xiao_2 = Entities:FindByName(nil, 'zs_laohu_xiao_2')
    local zs_laohu_xiao_1 = Entities:FindByName(nil, 'zs_laohu_xiao_1')
    local zs_pangxie_2 = Entities:FindByName(nil, 'zs_pangxie_2')
    local zs_pangxie_1 = Entities:FindByName(nil, 'zs_pangxie_1')
    local zs_aoxia = Entities:FindByName(nil, 'zs_aoxia')
    local zs_long_1 =Entities:FindByName(nil, 'zs_long_1')
    if zs_long_1 then
        self._spawner_wild["zs_long_1"] = zs_long_1
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_bailang_1 then
        self._spawner_wild["zs_bailang_1"] = zs_bailang_1
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_bailang_2 then
        self._spawner_wild["zs_bailang_2"] = zs_bailang_2
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_bailangwang then
        self._spawner_wild["zs_bailangwang"] = zs_bailangwang
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_beijixiong then
        self._spawner_wild["zs_beijixiong"] = zs_beijixiong
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_1 then
        self._spawner_wild["zs_qiangdao_1"] = zs_qiangdao_1
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_2 then
        self._spawner_wild["zs_qiangdao_2"] = zs_qiangdao_2
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_3 then
        self._spawner_wild["zs_qiangdao_3"] = zs_qiangdao_3
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_4 then
        self._spawner_wild["zs_qiangdao_4"] = zs_qiangdao_4
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_5 then
        self._spawner_wild["zs_qiangdao_5"] = zs_qiangdao_5
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_6 then
        self._spawner_wild["zs_qiangdao_6"] = zs_qiangdao_6
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_7 then
        self._spawner_wild["zs_qiangdao_7"] = zs_qiangdao_7
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_8 then
        self._spawner_wild["zs_qiangdao_8"] = zs_qiangdao_8
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_9 then
        self._spawner_wild["zs_qiangdao_9"] = zs_qiangdao_9
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_10 then
        self._spawner_wild["zs_qiangdao_10"] = zs_qiangdao_10
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_11 then
        self._spawner_wild["zs_qiangdao_11"] = zs_qiangdao_11
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_qiangdao_12 then
        self._spawner_wild["zs_qiangdao_12"] = zs_qiangdao_12
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_laohu_da then
        self._spawner_wild["zs_laohu_da"] = zs_laohu_da
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_laohu_xiao_1 then
        self._spawner_wild["zs_laohu_xiao_1"] = zs_laohu_xiao_1
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_laohu_xiao_2 then
        self._spawner_wild["zs_laohu_xiao_2"] = zs_laohu_xiao_2
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_pangxie_1 then
        self._spawner_wild["zs_pangxie_1"] = zs_pangxie_1
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_pangxie_2 then
        self._spawner_wild["zs_pangxie_2"] = zs_pangxie_2
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if zs_aoxia then
        self._spawner_wild["zs_aoxia"] = zs_aoxia
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end

--------------------
    local spawner_wei_top = Entities:FindByName(nil, 'wei_spawner_top')
    local spawner_wei_mid = Entities:FindByName(nil, 'wei_spawner_mid')
    local spawner_wei_bot = Entities:FindByName(nil, 'wei_spawner_bot')

    local target_wei_top = Entities:FindByName(nil, "wei_top_1")
    local target_wei_mid = Entities:FindByName(nil, "wei_mid_01")
    local target_wei_bot = Entities:FindByName(nil, "wei_bot_1")

    if spawner_wei_top then
        self.__spawners["wei_top"] = spawner_wei_top
    else
        print("SPAWNER WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if spawner_wei_mid then
        self.__spawners["wei_mid"] = spawner_wei_mid
    else
        print("SPAWNER WEI MID NOT FOUND!!!!!!!!!!!!!")
    end
    if spawner_wei_bot then
        self.__spawners["wei_bot"] = spawner_wei_bot
    else
        print("SPAWNER WEI BOT NOT FOUND!!!!!!!!!!!!!")
    end

    if target_wei_top then
        self.__target["wei_top"] = target_wei_top
    else
        print("target WEI TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if target_wei_mid then
        self.__target["wei_mid"] = target_wei_mid
    else
        print("target WEI MID NOT FOUND!!!!!!!!!!!!!")
    end
    if target_wei_bot then
        self.__target["wei_bot"] = target_wei_bot
    else
        print("target WEI BOT NOT FOUND!!!!!!!!!!!!!")
    end

    local spawner_shu_top = Entities:FindByName(nil, 'shu_spawner_top')
    local spawner_shu_mid = Entities:FindByName(nil, 'shu_spawner_mid')
    local spawner_shu_bot = Entities:FindByName(nil, 'shu_spawner_bot')

    local target_shu_top = Entities:FindByName(nil, "shu_top_1")
    local target_shu_mid = Entities:FindByName(nil, "shu_mid_1")
    local target_shu_bot = Entities:FindByName(nil, "shu_bot_1")

    if spawner_shu_top then
        self.__spawners["shu_top"] = spawner_shu_top
    else
        print("SPAWNER shu TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if spawner_shu_mid then
        self.__spawners["shu_mid"] = spawner_shu_mid
    else
        print("SPAWNER shu MID NOT FOUND!!!!!!!!!!!!!")
    end
    if spawner_shu_bot then
        self.__spawners["shu_bot"] = spawner_shu_bot
    else
        print("SPAWNER shu BOT NOT FOUND!!!!!!!!!!!!!")
    end

    if target_shu_top then
        self.__target["shu_top"] = target_shu_top
    else
        print("target shu TOP NOT FOUND!!!!!!!!!!!!!")
    end
    if target_shu_mid then
        self.__target["shu_mid"] = target_shu_mid
    else
        print("target shu MID NOT FOUND!!!!!!!!!!!!!")
    end
    if target_shu_bot then
        self.__target["shu_bot"] = target_shu_bot
    else
        print("target shu BOT NOT FOUND!!!!!!!!!!!!!")
    end
end
--------------------------------------------------------------------------------------------------
-------------野怪刷怪系统--------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
