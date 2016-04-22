--判断游戏是否暂停
function IsGamePaused()
    old = GameRules:GetGameTime()
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("GamePaused"),function( )
        local new = GameRules:GetGameTime()

        if new == old then
            GameRules.__IsGamePaused = true
        else
            GameRules.__IsGamePaused = false
        end
        old = new

        return 0.1
    end,0)
end

function GetDistance(ent1,ent2)
     local pos_1=ent_1:GetOrigin()
     local pos_2=ent_2:GetOrigin() 
     local x_=(pos_1[1]-pos_2[1])^2
     local y_=(pos_1[2]-pos_2[2])^2
     local dis=(x_+y_)^(0.5)
     return dis
end
function table.nums(table)
    if type(table) ~= "table" then return nil end
    local l = 0
    for k,v in pairs(table) do
        l = l+1
    end
    return l
end
function IsNumberInTable(Table,t)
    if Table == nil then return false end
    if type(Table) ~= "table" then return false end
    for i= 1,#Table do
        if t == Table[i] then
            return true
        end
    end
    return false
end
function  ApplyProjectile(keys,distance,File)
--  local benti = Entities:FindByModel(sven_soul,"juggernaut.vmdl")
    --local testtable = FindAllByModel("juggernaut.vmdl")
--  sven_soul:SetAnimation("ACT_DOTA_ATTACK")
    local caster = keys.caster
    local vecCaster = caster:GetOrigin() 
    local forwardVec = caster:GetForwardVector() 
    local face = (caster:GetForwardVector()):Normalized()
    local info = 
        {
            Ability = keys.ability,
            EffectName = File,
            vSpawnOrigin = caster:GetOrigin(),
            fDistance = distance,
            fStartRadius = 0,
            fEndRadius = 125,
            Source = caster,
            bHasFrontalCone = false,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            fExpireTime = GameRules:GetGameTime() + 2,
            bDeleteOnHit = false,
            vVelocity = face * 1800,
            bProvidesVision = false
        }
ProjectileManager:CreateLinearProjectile(info)
end
function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
     end
     return _copy(object)
end
--删除table中的table
function TableRemoveTable( table_1 , table_2 )
    for i,v in pairs(table_1) do
        if v == table_2 then
            table.remove(table_1,i)
            return
        end
    end
end
 GameRules.AbilityBehavior = {             
    DOTA_ABILITY_BEHAVIOR_ATTACK,            
    DOTA_ABILITY_BEHAVIOR_AURA,     
    DOTA_ABILITY_BEHAVIOR_AUTOCAST,    
    DOTA_ABILITY_BEHAVIOR_CHANNELLED,   
    DOTA_ABILITY_BEHAVIOR_DIRECTIONAL,    
    DOTA_ABILITY_BEHAVIOR_DONT_ALERT_TARGET,    
    DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT, 
    DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK,   
    DOTA_ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT,             
    DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING,    
    DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL,      
    DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE,   
    DOTA_ABILITY_BEHAVIOR_IGNORE_TURN ,        
    DOTA_ABILITY_BEHAVIOR_IMMEDIATE,         
    DOTA_ABILITY_BEHAVIOR_ITEM,              
    DOTA_ABILITY_BEHAVIOR_NOASSIST,            
    DOTA_ABILITY_BEHAVIOR_NONE,             
    DOTA_ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN, 
    DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE,       
    DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES,      
    DOTA_ABILITY_BEHAVIOR_RUNE_TARGET,         
    DOTA_ABILITY_BEHAVIOR_UNRESTRICTED ,  
}

--判断单体技能
function CDOTABaseAbility:IsUnitTarget( )
    local b = self:GetBehavior()

    if self:IsHidden() then b = b - 1 end
    for k,v in pairs(GameRules.AbilityBehavior) do
        repeat
            if v == 0 then break end
            b = b % v
        until true
    end

    if (b - DOTA_ABILITY_BEHAVIOR_AOE) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
        b = b - DOTA_ABILITY_BEHAVIOR_AOE
    end

    if b == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
        return true
    end
    return false
end

--判断点目标技能
function CDOTABaseAbility:IsPoint( )
    local b = self:GetBehavior()

    if self:IsHidden() then b = b - 1 end
    for k,v in pairs(GameRules.AbilityBehavior) do
        repeat
            if v == 0 then break end
            b = b % v
        until true
    end

    if (b - DOTA_ABILITY_BEHAVIOR_AOE) == DOTA_ABILITY_BEHAVIOR_POINT then
        b = b - DOTA_ABILITY_BEHAVIOR_AOE
    end

    if b == DOTA_ABILITY_BEHAVIOR_POINT then
        return true
    end
    return false
end

--判断无目标技能
function CDOTABaseAbility:IsNoTarget( )
    local b = self:GetBehavior()
    
    if self:IsHidden() then b = b - 1 end
    for k,v in pairs(GameRules.AbilityBehavior) do
        repeat
            if v == 0 then break end
            b = b % v
        until true
    end

    if (b - DOTA_ABILITY_BEHAVIOR_AOE) == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
        b = b % DOTA_ABILITY_BEHAVIOR_AOE
    end

    if b == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
        return true
    end
    return false
end

--弹射函数 
--用于检测是否被此次弹射命中过
function CatapultFindImpact( unit,str )
    for i,v in pairs(unit.CatapultImpact) do
        if v == str then
            return true
        end
    end
    return false
end
 
--caster是施法者或者主要来源
--target是第一个目标
--ability是技能来源
--effectName是弹射的投射物
--move_speed是投射物的速率
--doge是表示能否被躲掉
--radius是每次弹射的范围
--count是弹射次数
--teams,types,flags获取单位的三剑客
--find_tpye是单位组按远近或者随机排列
--      FIND_CLOSEST
--      FIND_FARTHEST
--      FIND_UNITS_EVERYWHERE
function Catapult( caster,target,ability,effectName,move_speed,radius,count,teams,types,flags,find_tpye )
    print("Run Catapult")
 
    local old_target = caster
 
    --生成独立的字符串
    local str = DoUniqueString(ability:GetAbilityName())
    print("Catapult:"..str)
 
    --假设一个马甲
    local unit = {}
 
    --绑定信息
    --是否发射下一个投射物
    unit.CatapultNext = false
    unit.count_num = 0
    --本次弹射标识的字符串
    unit.CatapultThisProjectile = str
    unit.old_target = old_target
    --本次弹射的目标
    unit.CatapultThisTarget     = target
 
    --CatapultUnit用来存储unit
    if caster.CatapultUnit == nil then
        caster.CatapultUnit = {}
    end
 
    --把unit插入CatapultUnit
    table.insert(caster.CatapultUnit,unit)
 
    --用于决定是否发射投射物
    local fire = true
 
    --弹射最大次数
    local count_num = 0
     
    GameRules:GetGameModeEntity():SetContextThink(str,
        function( )
 
            --满足达到最大弹射次数删除计时器
            if count_num>=count then
                print("Catapult impact :"..count_num)
                print("Catapult:"..str.." is over")
                return nil
            end
 
 
            if unit.CatapultNext then
 
                --获取单位组
                local group = FindUnitsInRadius(caster:GetTeamNumber(),target:GetOrigin(),nil,radius,teams,types,flags,FIND_CLOSEST,true)
                 
                --用于计算循环次数
                local num = 0
                for i=1,#group do
                    if group[i].CatapultImpact == nil then
                        group[i].CatapultImpact = {}
                    end
 
                    --判断是否命中
                    local impact = CatapultFindImpact(group[i],str)
 
                    if  impact == false then
 
                        --替换old_target
                        old_target = target
 
                        --新target
                        target = group[i]
 
                        --可以发射新投射物
                        fire = true
                        unit.count_num = count_num
                        --等待下一个目标
                        unit.old_target = old_target
                        unit.CatapultNext =false
 
                        --锁定当前目标
                        unit.CatapultThisTarget = target
                        break
                    end
                    num = num + 1
                end
 
                --如果大于等于单位组的数量那么就删除计时器
                if num >= #group then
                    --从CatapultUnit中删除unit
                    TableRemoveTable(caster.CatapultUnit,unit)
 
                    print("Catapult impact :"..count_num)
                    print("Catapult:"..str.." is over")
                    return nil
                end
            end
 
            --发射投射物
            if fire then
                fire = false
                count_num = count_num + 1
                local info = 
                {
                    Target = target,
                    Source = old_target,
                    Ability = ability,  
                    EffectName = effectName,
                    bDodgeable = false,
                    iMoveSpeed = move_speed,
                    bProvidesVision = true,
                    iVisionRadius = 300,
                    iVisionTeamNumber = caster:GetTeamNumber(),
                    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
                }
                projectile = ProjectileManager:CreateTrackingProjectile(info)               
            end
 
            return 0.05
        end,0)
end
 
--此函数在KV里面用OnProjectileHitUnit调用
function CatapultImpact( keys )
    local caster = keys.caster
    local target = keys.target
 
    --防止意外
    if caster.CatapultUnit == nil then
        caster.CatapultUnit = {}
    end
    if target.CatapultImpact == nil then
        target.CatapultImpact = {}
    end
 
    --挨个检测是否是弹射的目标
    for i,v in pairs(caster.CatapultUnit) do
         
        if v.CatapultThisProjectile ~= nil and v.CatapultThisTarget ~= nil then
 
            if v.CatapultThisTarget == target then
 
                --标记target被CatapultThisProjectile命中
                table.insert(target.CatapultImpact,v.CatapultThisProjectile)
 
                --允许发射下一次投射物
                v.CatapultNext = true
                return
            end
 
        end
    end
end

function PrintTable(t, indent, done)
    --print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end