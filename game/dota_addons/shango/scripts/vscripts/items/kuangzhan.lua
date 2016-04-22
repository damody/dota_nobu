function item_kuangzhan_01(keys)   --张飞  神技   移动、攻击加速，多承受50%伤害
	-- body   
    local caster=EntIndexToHScript(keys.caster_entindex)
    local currenthealth = caster:GetHealth()
    local durationtime=keys.ability:GetLevelSpecialValueFor("ability_duration",0)
    print("durationtime:"..durationtime)
    local amplify_damage=keys.ability:GetLevelSpecialValueFor("amplify_damage",0)
    local leap_speedbonus_as_one=keys.ability:GetLevelSpecialValueFor("leap_speedbonus_as_one",0)
    local overtime = Time()+durationtime
    local speed=caster:GetAttackSpeed()
    local speed1=caster:GetAttacksPerSecond()
    local str= leap_speedbonus_as_one*speed
    --通过modifier按百分比修改攻击速度
    if str>=100 then 
        local x1=math.floor(str/100)*100
        keys.ability:ApplyDataDrivenModifier(caster, caster, "kyuexia_attackspeed_"..tostring(x1), {duration=durationtime})
        local x2=math.floor((str-x1)/10)*10 
        keys.ability:ApplyDataDrivenModifier(caster, caster, "kyuexia_attackspeed_"..tostring(x2), {duration=durationtime})       
        local x3=math.floor(str-x1-x2)
        keys.ability:ApplyDataDrivenModifier(caster, caster, "kyuexia_attackspeed_"..tostring(x3), {duration=durationtime})
    else 
        if str>=10 then 
           local x2=math.floor(str/10)*10 
           keys.ability:ApplyDataDrivenModifier(caster, caster, "kyuexia_attackspeed_"..tostring(x2), {duration=durationtime})
         -- keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_100", {duration=durationtime}) 
           local x3=math.floor(str-x2)
           keys.ability:ApplyDataDrivenModifier(caster, caster, "kyuexia_attackspeed"..tostring(x3), {duration=durationtime})
        else 
           local x3=math.floor(str)
           keys.ability:ApplyDataDrivenModifier(caster, caster, "kyuexia_attackspeed_"..tostring(x3), {duration=durationtime}) 
        end
    end 
    --修改移动速度
    local speed1=caster:GetAttacksPerSecond()
    speed=caster:GetAttackSpeed()
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("bonus_damage_zhangfei"), 
		   function( )
			if caster:IsAlive() and Time() < overtime then
				local nowhealth=caster:GetHealth()
				if caster:IsAlive() and nowhealth<currenthealth then 
					if nowhealth >0 then
						if nowhealth >= (amplify_damage*(currenthealth-nowhealth))/100 then
					       caster:SetHealth(nowhealth-(amplify_damage*(currenthealth-nowhealth))/100)
					       currenthealth=nowhealth-(currenthealth-nowhealth)
					       nowhealth=caster:GetHealth()	
					    else 					       
					       return nil
					    end
					end		
				end				
        return 0.01
      else
        return nil 
			end	

		end,0)
end