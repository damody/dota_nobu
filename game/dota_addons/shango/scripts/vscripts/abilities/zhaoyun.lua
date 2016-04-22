require("utils/utils_print")
function zhaoyun_wushuang_01(keys)   --赵云  无双
  -- body
  local caster=EntIndexToHScript(keys.caster_entindex)
  local i=keys.ability:GetLevel()
  local durationtime=keys.ability:GetLevelSpecialValueFor("ability_duration",i-1)
  local leap_speedbonus_as_one=keys.ability:GetLevelSpecialValueFor("leap_speedbonus_as_one",i-1)
  local speed=caster:GetAttackSpeed()
    local speed1=caster:GetAttacksPerSecond()
  local str= leap_speedbonus_as_one*speed
 --按比例修改攻击速度  
  if str>=100 then 
        local x1=math.floor(str/100)*100
        keys.ability:ApplyDataDrivenModifier(caster, caster, "zhaoyun_attackspeed_"..tostring(x1), {duration=durationtime})
        local x2=math.floor((str-x1)/10)*10 
        keys.ability:ApplyDataDrivenModifier(caster, caster, "zhaoyun_attackspeed_"..tostring(x2), {duration=durationtime})       
        local x3=math.floor(str-x1-x2)
        keys.ability:ApplyDataDrivenModifier(caster, caster, "zhaoyun_attackspeed_"..tostring(x3), {duration=durationtime})
    else 
        if str>=10 then 
           local x2=math.floor(str/10)*10 
           keys.ability:ApplyDataDrivenModifier(caster, caster, "zhaoyun_attackspeed_"..tostring(x2), {duration=durationtime})
         -- keys.ability:ApplyDataDrivenModifier(caster, caster, "attackspeed_100", {duration=durationtime}) 
           local x3=math.floor(str-x2)
           keys.ability:ApplyDataDrivenModifier(caster, caster, "zhaoyun_attackspeed_"..tostring(x3), {duration=durationtime})
        else 
           local x3=math.floor(str)
           keys.ability:ApplyDataDrivenModifier(caster, caster, "zhaoyun_attackspeed_"..tostring(x3), {duration=durationtime}) 
        end
    end 
end
function zhaoyun_changqiangtuci(keys)  --赵云长枪突刺，无需修改
  -- body
  local caster=EntIndexToHScript(keys.caster_entindex)
  local i=keys.ability:GetLevel()
  local knockback_distance=keys.ability:GetLevelSpecialValueFor("knockback_distance",i-1)
  local knockback_duration=keys.ability:GetLevelSpecialValueFor("knockback_duration",i-1)
  local target=keys.target
  --local target_point=keys.target_points[1]
  local veccaster=caster:GetAbsOrigin()
  --local vectarget=target:GetAbsOrigin()
  local vectarget=keys.target_points[1]
  local directionvec=(vectarget-veccaster):Normalized()  --方向向量
  local perseconddistance=knockback_distance/(knockback_duration/0.05) --没单位时间移动距离
  local perdeltavec=directionvec*perseconddistance --每单位时间移动向量
  local movecount = knockback_duration/0.05
  local nowcount = 0
  local nowtarget=vectarget
     GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("zhaoyun"),
        function ()
          if not target:IsAlive() then return nil end
          if nowcount<=movecount then
            if isnearunit(target,nowtarget,perdeltavec) then return nil end 
            if not GridNav:IsNearbyTree(nowtarget+perdeltavec,45,true) then 
              if GridNav:IsBlocked(nowtarget+perdeltavec) or not GridNav:IsTraversable(nowtarget+perdeltavec) then 
                 return nil                 
              end 
              else                
                return 0.01
            end 
            target:SetAbsOrigin(GetGroundPosition(nowtarget+perdeltavec,target) + Vector(0,0,GetMinHeight(target)))
               
            nowtarget=nowtarget+perdeltavec
            nowcount=nowcount+1       
            return 0.05
          else
            return nil 
          end         
      end , 0)
end
function GetMinHeight(unit)
      return unit.fMinHeight or 0
end
function isnearunit(target,nowtarget,perdeltavec)
  -- body
  local teams = DOTA_UNIT_TARGET_TEAM_BOTH
  local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_MECHANICAL
  local flags = DOTA_UNIT_TARGET_FLAG_NONE
  local rad   = 45 
     local group = FindUnitsInRadius(target:GetTeam(),nowtarget+perdeltavec,nil, rad, teams, types, flags, FIND_CLOSEST, true)
     if group == nil then 
        return false
     else 
       for i,unit in pairs(group) do
        if unit ~= nil then 
          return true 
        else
          return false
        end  
       end
     end 
end
function zhaoyun_changqiangtuci_01(keys)
  -- body
  print("start")
  local caster=EntIndexToHScript(keys.caster_entindex)
  local i=keys.ability:GetLevel()
  local knockback_distance=keys.ability:GetLevelSpecialValueFor("knockback_distance",i-1)
  local knockback_duration=keys.ability:GetLevelSpecialValueFor("knockback_duration",i-1)
  local target=keys.target
  local veccaster=caster:GetAbsOrigin()
  local vectarget=target:GetAbsOrigin()
  local vectarget=keys.target_points[1]
  local directionvec=(vectarget-veccaster):Normalized()  --方向向量
  local perseconddistance=knockback_distance/(knockback_duration/0.01) --没单位时间移动距离
  local perdeltavec=directionvec*perseconddistance --每单位时间移动向量
  local movecount = knockback_duration/0.01
  local nowcount = 0
  local nowtarget=vectarget
     GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("zhaoyun"),
        function ()
          if nowcount<=movecount then
            if isnearunit(target,nowtarget,perdeltavec) then return nil end 
            if not GridNav:IsNearbyTree(nowtarget+perdeltavec,30,true) then 
              if GridNav:IsBlocked(nowtarget+perdeltavec) or not GridNav:IsTraversable(nowtarget+perdeltavec) then 
                 return nil                 
              end 
          --  else                
               --  return 0.01
            end 
            target:SetAbsOrigin(nowtarget+perdeltavec)
            nowtarget=nowtarget+perdeltavec
            nowcount=nowcount+0.01       
            return 0.01
          else
            return nil 
          end 
      end , 0)
end

