
die_time = {1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 47, 49, 52, 56, 61, 67, 74, 80}

function Nobu:OnUnitKill( keys )
--每当单位死亡，检查其是否符合条件，如果符合就刷新任务
  ------------------------------------------------------------------
   --  local killedUnit = EntIndexToHScript( keys.entindex_killed )

   --  if killedUnit and string.find(killedUnit:GetUnitName(), "kobold") then
   --      -- 填充进度条并修改标题
   --      GameRules.Quest.UnitsKilled = GameRules.Quest.UnitsKilled + 1
   --      GameRules.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, GameRules.Quest.UnitsKilled)
   --      GameRules.subQuest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, GameRules.Quest.UnitsKilled )

   --      -- 检查任务是否完成
   --      if GameRules.Quest.UnitsKilled >= GameRules.Quest.KillLimit then
   --          GameRules.Quest:CompleteQuest()
   --      end
   -- end
   ------------------------------------------------------------------

  --[解决] 请问怎么修改英雄复活时间呢？
    -- local killedUnit = EntIndexToHScript( keys.entindex_killed )
    -- --print(keys.entindex_killed, " killed")
    -- if killedUnit:IsRealHero() then
    --         --print("Hero has been killed")
    --         if killedUnit:IsReincarnating() == false then
    --                 --print("Setting time for respawn")
    --                 killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*200)
    --         end
    -- end

    -- DeepPrintTable(keys)
    -- [   VScript              ]: {
    -- [   VScript              ]:    entindex_killed                 	= 259 (number)
    -- [   VScript              ]:    damagebits                      	= 0 (number)
    -- [   VScript              ]:    splitscreenplayer               	= -1 (number)
    -- [   VScript              ]: }
	
    local AttackerUnit = EntIndexToHScript( keys.entindex_attacker )
    local killedUnit = EntIndexToHScript( keys.entindex_killed )
    if killedUnit:IsBuilding() then
      local group = FindUnitsInRadius(AttackerUnit:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
      for _,hero in ipairs(group) do
        hero.kill_tower = 1
        if not hero:IsIllusion() then
          print("hero "..hero:GetUnitName())
        end
      end
      
      Timers:CreateTimer(1, function ()
        for _,hero in ipairs(group) do
          if IsValidEntity(hero) then
            hero.kill_tower = nil
          end
        end
        end)
      if _G.mo and killedUnit:GetUnitName() == "com_towera" or (string.match(killedUnit:GetUnitName(), "com_soldiercamp") and killedUnit:GetUnitName()~="com_soldiercamp") then
        if AttackerUnit.score == nil then AttackerUnit.score = 0 end
        AttackerUnit.score = AttackerUnit.score + 1
      end
    end
    local neutral = false
    if string.match(killedUnit:GetUnitName(), "neutral") then
      neutral = true
    end
    if (AttackerUnit:IsRealHero()) and not neutral then
      if AttackerUnit.kill_hero_count == nil then
        AttackerUnit.kill_hero_count = 0
      end
      if AttackerUnit.kill_count == nil then
        AttackerUnit.kill_count = 0
      end
      if AttackerUnit.building_count == nil then
        AttackerUnit.building_count = 0
      end
      if killedUnit:IsBuilding() then
        AttackerUnit.building_count = AttackerUnit.building_count + 1
      else
        AttackerUnit.kill_count = AttackerUnit.kill_count + 1
      end
      if killedUnit:IsHero() and not killedUnit:IsIllusion() then
        AttackerUnit.kill_hero_count = AttackerUnit.kill_hero_count + 1
      end
    end
    ------------------------------------------------------------------
  	local name = killedUnit:GetUnitName()
  	if string.match(name,"silencer") then
  		-- 這隻角色天生會帶一個modifier我們需要砍掉他
      -- 一般是立花道雪在用他
      
    elseif string.match(name,"axe") then --幸村開大
      killedUnit:RemoveModifierByName("modifier_B06T")
  	end

    if killedUnit:IsRealHero() then
      if _G.CN then
        AMHC:GivePlayerGold_UnReliable(killedUnit:GetPlayerOwnerID(), -300)
      end
      if killedUnit.death_count == nil then
        killedUnit.death_count = 1
      else
        killedUnit.death_count = killedUnit.death_count + 1
      end
      if _G.CN then
        if die_time[killedUnit:GetLevel()] ~= nil then
          killedUnit:SetTimeUntilRespawn(die_time[killedUnit:GetLevel()])
        end
      else
        if killedUnit:GetLevel() >= 18 then
          killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2+9)
        elseif killedUnit:GetLevel() >= 12 then
          killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2+6)
        elseif killedUnit:GetLevel() >= 6 then
          killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2+3)
        else
          killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2)
        end
      end
      group = FindUnitsInRadius(
          killedUnit:GetTeamNumber(), 
          killedUnit:GetAbsOrigin(), 
          nil, 
          2000,
          DOTA_UNIT_TARGET_TEAM_ENEMY, 
          DOTA_UNIT_TARGET_HERO, 
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
          FIND_ANY_ORDER, 
          false)
      if (#group > 0) then
        local xp = killedUnit:GetLevel() * 35 / #group
        for _,v in ipairs(group) do
          v:AddExperience(xp, DOTA_ModifyGold_HeroKill, false, false)
          if v:IsHero() and killedUnit:GetLevel() > 7 then
            if killedUnit:GetLevel() > v:GetLevel()+4 then
              v:AddExperience(xp*3, DOTA_ModifyGold_HeroKill, false, false)
            elseif killedUnit:GetLevel() > v:GetLevel()+3 then
              v:AddExperience(xp*2, DOTA_ModifyGold_HeroKill, false, false)
            elseif killedUnit:GetLevel() > v:GetLevel()+2 then
              v:AddExperience(xp*1, DOTA_ModifyGold_HeroKill, false, false)
            elseif killedUnit:GetLevel() > v:GetLevel()+1 then
              v:AddExperience(xp*0.5, DOTA_ModifyGold_HeroKill, false, false)
            end
          end
        end
      end
    end
      -- for i=1,10 do
      --   GameRules: SendCustomMessage("   ",DOTA_TEAM_GOODGUYS,0)
      -- end
      --Tutorial: AddQuest("quest_1",1,"破塔成功","ssssssssss")
    if _G.mo == nil then
      if string.match(name, "neutral_130") then
        local unitname = name
        local pos = killedUnit:GetAbsOrigin()
        local team = killedUnit:GetTeamNumber()
        Timers:CreateTimer(90, function()
          if (killedUnit.origin_pos) then
            pos = killedUnit.origin_pos
            local unit = CreateUnitByName(unitname,pos,false,nil,nil,team)
            unit.origin_pos = pos
            local CP_Monster = _G.CP_Monster
            local hp = unit:GetMaxHealth()
            unit:SetBaseMaxHealth(hp+CP_Monster * 50)
            local dmgmax = unit:GetBaseDamageMax()
            local dmgmin = unit:GetBaseDamageMin()
            unit:SetBaseDamageMax(dmgmax+CP_Monster*12)
            unit:SetBaseDamageMax(dmgmin+CP_Monster*12)
          end
          end)
      elseif string.match(name, "npc_dota_cursed_warrior_souls") then
        local unitname = name
        local pos = killedUnit:GetAbsOrigin()
        local team = killedUnit:GetTeamNumber()
        Timers:CreateTimer(300, function()
          if (killedUnit.origin_pos) then
            pos = killedUnit.origin_pos
            local unit = CreateUnitByName(unitname,pos,false,nil,nil,team)
            unit.origin_pos = pos
            local CP_Monster = _G.CP_Monster
            local hp = unit:GetMaxHealth()
            unit:SetBaseMaxHealth(hp+CP_Monster * 50)
            local dmgmax = unit:GetBaseDamageMax()
            local dmgmin = unit:GetBaseDamageMin()
            unit:SetBaseDamageMax(dmgmax+CP_Monster*12)
            unit:SetBaseDamageMax(dmgmin+CP_Monster*12)
          end
          end)
      elseif string.match(name, "neutral_160") then
        local unitname = name
        local pos = killedUnit:GetAbsOrigin()
        local team = killedUnit:GetTeamNumber()
        Timers:CreateTimer(120, function()
          if (killedUnit.origin_pos) then
            pos = killedUnit.origin_pos
            local unit = CreateUnitByName(unitname,pos,false,nil,nil,team)
            unit.origin_pos = pos
            local CP_Monster = _G.CP_Monster
            local hp = unit:GetMaxHealth()
            unit:SetBaseMaxHealth(hp+CP_Monster * 50)
            local dmgmax = unit:GetBaseDamageMax()
            local dmgmin = unit:GetBaseDamageMin()
            unit:SetBaseDamageMax(dmgmax+CP_Monster*12)
            unit:SetBaseDamageMax(dmgmin+CP_Monster*12)
          end
          end)
      end
    end


    print(killedUnit:GetUnitName() )
    if killedUnit:GetUnitName() == "npc_dota_courier2" then
      killedUnit:RespawnUnit()
      killedUnit:FindAbilityByName("for_magic_immune"):
        ApplyDataDrivenModifier(caster,target,"modifier_for_magic_immune",nil)
      killedUnit:SetOrigin(killedUnit.oripos)
    end
    --print("dead")
end
