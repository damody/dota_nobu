require("utils/utils_print")
function xun_jingzhixianjin_01( keys)    --寻，静止陷阱
	-- body
    local caster=EntIndexToHScript(keys.caster_entindex)
    local target = keys.target   --获取陷阱实体
    FindClearSpaceForUnit(target,target:GetAbsOrigin(),false)    -- 返回类型: void
        -- 参数说明: 
        -- 描述: 在未被占用的地方创建单位
    local invisibility =false            --初始标记陷阱为可见
    local _ability=keys.ability     --获取技能
    local k=keys.ability:GetLevel()  --获取技能等级
	local spell = target:FindAbilityByName("xun_jingzhixianjin_invisible")  --为陷阱添加隐形技能
    if spell then  
        spell:SetLevel(k)
    end 
    target:CastAbilityImmediately(spell, target:GetPlayerOwnerID())           --隐形     
end
function xun_jingzhixianjin_02( keys)    --陷阱触发爆炸函数
    -- body
    local caster=EntIndexToHScript(keys.caster_entindex)
    local target = keys.target_entities    --陷阱实体
    local spell = caster:FindAbilityByName("xun_jingzhixianjin_stun")   --爆炸技能
    local k=keys.ability:GetLevel()
    local delay=keys.ability:GetLevelSpecialValueFor("blast_daley",k-1)  --获取爆炸延时时间
        if spell then  
            spell:SetLevel(1)
        end
    if target[1] then
        if caster:HasModifier("modifier_persistent_invisibility")  then     --触发是移除隐身modifier
            caster:RemoveModifierByName("modifier_persistent_invisibility")
        end 
        caster:CastAbilityImmediately(spell, caster:GetPlayerOwnerID())    --释放爆炸技能
        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("xun_think"),
        function()
            -- body
           caster:ForceKill(true)
           return nil
       end,1)    --爆炸延迟    
    end   
end
function xun_zhimingjiejie_01(keys)   --致命结界
    -- body
    print("xun zhiming")
    local caster=EntIndexToHScript(keys.caster_entindex)
    local target = keys.target
    FindClearSpaceForUnit(target,target:GetAbsOrigin(),false) --防止卡英雄
    local invisibility =false
    local _ability=keys.ability
    local k=keys.ability:GetLevel()
    target:SetBaseMaxHealth(target:GetMaxHealth()+(k-1)*100)           --设置每级血量
    local unit_health=keys.ability:GetLevelSpecialValueFor("unit_health",k-1)
    local spell = target:FindAbilityByName("xun_zhimingjiejie_buff")      --添加致命结界buff
    if spell then  
        spell:SetLevel(k)
        target:CastAbilityImmediately(spell, target:GetPlayerOwnerID())   --释放
    end
    
end