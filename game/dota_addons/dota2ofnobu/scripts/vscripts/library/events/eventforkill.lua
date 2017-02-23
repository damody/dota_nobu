
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
    if (AttackerUnit:IsRealHero()) then
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
      print("AttackerUnit.kill_count "..AttackerUnit.kill_count)
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
      if killedUnit.death_count == nil then
        killedUnit.death_count = 1
      else
        killedUnit.death_count = killedUnit.death_count + 1
      end
      if killedUnit:GetLevel() >= 20 then
        killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2.5)
      elseif killedUnit:GetLevel() >= 10 then
        killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2)
      else
        killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*1.5)
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
          if v:IsHero() and killedUnit:GetLevel() > 10 then
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

      -- for i=1,10 do
      --   GameRules: SendCustomMessage("   ",DOTA_TEAM_GOODGUYS,0)
      -- end
      --Tutorial: AddQuest("quest_1",1,"破塔成功","ssssssssss")
    elseif string.match(name, "neutral_130") then
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


    print(killedUnit:GetUnitName() )
    if killedUnit:GetUnitName() == "npc_dota_courier2" then
      killedUnit:RespawnUnit()
      killedUnit:SetOrigin(killedUnit.oripos)
    end
    --print("dead")
end
