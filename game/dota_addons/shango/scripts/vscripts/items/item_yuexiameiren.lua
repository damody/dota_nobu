local yuexiameiren={}
function item_yuexiameiren_01(keys)
	-- body   
    local caster=EntIndexToHScript(keys.caster_entindex)
    local leap_speedbonus_as_one=30
    local speed=caster:GetAttackSpeed()
    local speed1=caster:GetAttacksPerSecond()
    local str= leap_speedbonus_as_one*speed
    --通过modifier按百分比修改攻击速度
   if str>=100 then 
        local x1=math.floor(str/100)*100
        keys.ability:ApplyDataDrivenModifier(caster, caster, "yuexia_attackspeed_"..tostring(x1), {duration=durationtime})
        yuexiameiren.bai="yuexia_attackspeed_"..tostring(x1)
        local x2=math.floor((str-x1)/10)*10                 
        keys.ability:ApplyDataDrivenModifier(caster, caster, "yuexia_attackspeed_"..tostring(x2), {duration=durationtime})       
        yuexiameiren.shi="yuexia_attackspeed_"..tostring(x2)
        local x3=math.floor(str-x1-x2)
        keys.ability:ApplyDataDrivenModifier(caster, caster, "yuexia_attackspeed_"..tostring(x3), {duration=durationtime})
        yuexiameiren.ge="yuexia_attackspeed_"..tostring(x3)
    else 
        if str>=10 then 
           local x2=math.floor(str/10)*10 
           keys.ability:ApplyDataDrivenModifier(caster, caster, "yuexia_attackspeed_"..tostring(x2), {duration=durationtime})
         -- keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_100", {duration=durationtime}) 
           yuexiameiren.shi="yuexia_attackspeed_"..tostring(x2)
           local x3=math.floor(str-x2)
           keys.ability:ApplyDataDrivenModifier(caster, caster, "yuexia_attackspeed"..tostring(x3), {duration=durationtime})
        else 
           local x3=math.floor(str)
           keys.ability:ApplyDataDrivenModifier(caster, caster, "yuexia_attackspeed_"..tostring(x3), {duration=durationtime}) 
           yuexiameiren.shi="yuexia_attackspeed_"..tostring(x2)
        end
    end 
    local speed=caster:GetAttackSpeed()
    print("spend:"..speed)
end
function item_yuexiameiren_02(keys)
  -- body
  local caster=EntIndexToHScript(keys.caster_entindex)
  for k,v in pairs(yuexiameiren) do
       if caster:HasModifier(v) then 
              caster:RemoveModifierByName(v) 
       end
  end
end