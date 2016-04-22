
zhangfei={}
zhangfei.isbig = false
function wanfumodi_big(keys)  --张飞 模型变大
    -- body
    local caster=EntIndexToHScript(keys.caster_entindex)
    local i = 1
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("asdadad"),
        function( )
            -- body
            if i<= 25 then
               caster:SetModelScale(1+i/50)   --核心：通过设置模型大小完成
               i=i+1
               return 0.01
            else 
               return nil
            end
        end,0)
end
function wanfumodi_small(keys)   --张飞模型变小
    -- body
    local caster=EntIndexToHScript(keys.caster_entindex)
    local i = 1
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("asaaasdfasdasd"),
        function( )
            -- body
            if i<= 25 then
               caster:SetModelScale(1+(25-i)/50)    --核心：通过设置模型大小完成
               i=i+1
               return 0.02
            else 
               return nil
            end
        end,0)
end 
function zhangfei_wanfumodi_01(keys)   --张飞  万夫莫敌   
    -- body
    local caster=EntIndexToHScript(keys.caster_entindex) 
    local k=keys.ability:GetLevel()
    local maxhealth_bonus=keys.ability:GetLevelSpecialValueFor("maxhealth_bonus",k-1)
    local _duration=keys.ability:GetLevelSpecialValueFor("duration",k-1)
    caster:AddNewModifier(caster, keys.ability, "modifier_brewmaster_earth_spell_immunity", {duration=_duration})
    --当张飞用于魔法免疫效果时，模型变大，当失去魔法免疫效果时，模型变小
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("zhangfei_think"),
        function (  )
            -- body
            if caster:HasModifier("modifier_brewmaster_earth_spell_immunity") and zhangfei.isbig == false then             
                wanfumodi_big(keys)   --调用变大
                zhangfei.isbig=true
                return 0.01
            elseif not caster:HasModifier("modifier_brewmaster_earth_spell_immunity") and zhangfei.isbig == true then 
                wanfumodi_small(keys)       --调用变小         
                zhangfei.isbig = false
                return nil 
            else  
                return 0.01
            end 

        end,0)
end
function zhangfei_yinghan_01(keys)   --张飞   硬汉 
    -- body
    local caster=EntIndexToHScript(keys.caster_entindex)
    --当张飞血量小于百分之五十时添加硬汉buff
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("bonus_armor_zhangfei"),
        function (  )
            -- body
            local nowhealth=caster:GetHealth()
          if nowhealth < caster:GetMaxHealth()/2 then 
              if caster:HasModifier("zhangfei_yinghan_buff") then
                  return 0.3
              end
              keys.ability:ApplyDataDrivenModifier(caster, caster, "zhangfei_yinghan_buff", nil)
              return 0.3
          else
               if caster:HasModifier("zhangfei_yinghan_buff") then
                  caster:RemoveModifierByName("zhangfei_yinghan_buff")
               end 
               return 0.3
           end          
        end,0)
end
function zhangfei_shenji_01(keys)   --张飞  神技   移动、攻击加速，多承受50%伤害
	-- body   
    local caster=EntIndexToHScript(keys.caster_entindex)
    local i=keys.ability:GetLevel()
    local currenthealth = caster:GetHealth()
    local durationtime=keys.ability:GetLevelSpecialValueFor("ability_duration",i-1)
    local amplify_damage=keys.ability:GetLevelSpecialValueFor("amplify_damage",i-1)
    local leap_speedbonus_as_one=keys.ability:GetLevelSpecialValueFor("leap_speedbonus_as_one",i-1)
    local overtime = Time()+durationtime
    local speed=caster:GetAttackSpeed()
    local speed1=caster:GetAttacksPerSecond()
    local str= leap_speedbonus_as_one*speed
    --通过modifier按百分比修改攻击速度
    if str>=100 then 
        local x1=math.floor(str/100)*100
        keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_"..tostring(x1), {duration=durationtime})
        local x2=math.floor((str-x1)/10)*10 
        keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_"..tostring(x2), {duration=durationtime})       
        local x3=math.floor(str-x1-x2)
        keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_"..tostring(x3), {duration=durationtime})
    else 
        if str>=10 then 
           local x2=math.floor(str/10)*10 
           keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_"..tostring(x2), {duration=durationtime})
         -- keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_100", {duration=durationtime}) 
           local x3=math.floor(str-x2)
           keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed"..tostring(x3), {duration=durationtime})
        else 
           local x3=math.floor(str)
           keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_"..tostring(x3), {duration=durationtime}) 
        end
    end 
    --修改移动速度
    local speed1=caster:GetAttacksPerSecond()
    speed=caster:GetAttackSpeed()
end
function zhangfei_shenji_02(keys) 
      local _damage=keys.DamageTaken * 0.5
                   ApplyDamage(
                                                      {   
                                                          victim = keys.caster, 
                                                          attacker = keys.attacker, 
                                                          damage = _damage, 
                                                          damage_type = DAMAGE_TYPE_PHYSICAL 
                                                      }
                               )

end