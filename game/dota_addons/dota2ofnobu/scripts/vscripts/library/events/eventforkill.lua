
die_time = {1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 47, 49, 52, 56, 61, 67, 74, 80, 87, 95, 104, 114, 120}
die_tim2 = {2, 4, 7, 10, 14, 20, 22, 25, 28, 32, 36, 42, 45, 48, 52, 56, 60, 66, 70, 74, 78, 85}

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
    if killedUnit:IsBuilding() and not string.match(killedUnit:GetUnitName(),"_hero")  then
      local group = FindUnitsInRadius(AttackerUnit:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
      local count = 0
      for _,hero in ipairs(group) do
        if not hero:IsIllusion() then
          count = count + 1
        end
      end
      
      if AttackerUnit:IsHero() then
        for _,hero in ipairs(group) do
          if not hero:IsIllusion() then
            hero.kill_tower = 1
          end
        end
      else
        local earn = killedUnit:GetGoldBounty() / count
        for _,hero in ipairs(group) do
          if not hero:IsIllusion() then
            AMHC:GivePlayerGold_UnReliable(hero:GetPlayerOwnerID(), earn)
          end
        end
      end
      
      Timers:CreateTimer(1, function ()
        for _,hero in ipairs(group) do
          if IsValidEntity(hero) then
            hero.kill_tower = nil
          end
        end
        end)
      if _G.mo and killedUnit:GetUnitName() == "com_tower_1_mid" or (killedUnit:GetUnitName()== "com_soldiercamp_unified_mid_1") or (killedUnit:GetUnitName()== "com_soldiercamp_oda_mid_1") then
        for _,hero in ipairs(HeroList:GetAllHeroes()) do
          if not hero:IsIllusion() then
            local id = hero:GetPlayerID()
            local team = PlayerResource:GetTeam(id)
            if team == AttackerUnit:GetTeamNumber() then
              if hero.score == nil then hero.score = 0 end
              if killedUnit:GetUnitName()=="com_soldiercamp_unified_mid_1" or killedUnit:GetUnitName()=="com_soldiercamp_oda_mid_1" then
                hero.score = hero.score + 1
              else
                hero.score = hero.score + 0.5
              end
            end
          end
        end
      end
    end
    if IsValidEntity(AttackerUnit:GetOwner()) then
      local hero = AttackerUnit:GetOwner()
      if hero.IsRealHero and hero:IsRealHero() and AttackerUnit:GetTeamNumber() ~= killedUnit:GetTeamNumber() then
        AttackerUnit = hero
      end
    end
    if (AttackerUnit:IsHero()) then
      if AttackerUnit:IsIllusion() then
        for _,hero in ipairs(HeroList:GetAllHeroes()) do
          if not hero:IsIllusion() and hero:GetPlayerOwnerID() == AttackerUnit:GetPlayerOwnerID() then
            AttackerUnit = hero
          end
        end
      end

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
      if math.mod(AttackerUnit.kill_count, 100) == 0 then
        local nobu_id = _G.heromap[AttackerUnit:GetName()]
        GameRules:SendCustomMessage("<font color='#ff8888'>".._G.hero_name_zh[nobu_id].."擊破了"..AttackerUnit.kill_count.."的敵軍</font>",0,0)
      end
      if killedUnit:IsHero() and not killedUnit:IsIllusion() then
        AttackerUnit.kill_hero_count = AttackerUnit.kill_hero_count + 1

        --連殺獎勵
        local sk_kill = 1
        if AttackerUnit.sk_kill then
          AttackerUnit.sk_kill = AttackerUnit.sk_kill + 1
          sk_kill = AttackerUnit.sk_kill
        else
          AttackerUnit.sk_kill = 1
        end

        if AttackerUnit.sk_kill > 1 then
          AMHC:GivePlayerGold_UnReliable(AttackerUnit:GetPlayerOwnerID(), AttackerUnit.sk_kill*50)
          local nobu_id = _G.heromap[AttackerUnit:GetName()]
          GameRules:SendCustomMessage("<font color='#ffff00'>".._G.hero_name_zh[nobu_id].."達成了"..AttackerUnit.sk_kill.."連殺，得到"..(AttackerUnit.sk_kill*50).."獎勵</font>",0,0)
        end
        if killedUnit.sk_kill and killedUnit.sk_kill > 1 then
          AMHC:GivePlayerGold_UnReliable(AttackerUnit:GetPlayerOwnerID(), killedUnit.sk_kill*50)
          local nobu_id = _G.heromap[AttackerUnit:GetName()]
          local nobu_id2 = _G.heromap[killedUnit:GetName()]
          GameRules:SendCustomMessage("<font color='#ffff00'>".._G.hero_name_zh[nobu_id].."中止了".._G.hero_name_zh[nobu_id2].."的連殺，得到"..(killedUnit.sk_kill*50).."獎勵</font>",0,0)
        end
        Timers:CreateTimer(15, function()
          if AttackerUnit.sk_kill == sk_kill then
            AttackerUnit.sk_kill = nil
          end
        end)
      end
    end
    ------------------------------------------------------------------
  	local name = killedUnit:GetUnitName()
  	if string.match(name,"silencer") then
  		-- 這隻角色天生會帶一個modifier我們需要砍掉他
      -- 一般是立花道雪在用他
    elseif string.match(name,"_123D") then --叫兵仔
      if killedUnit.die_count == nil then killedUnit.die_count = 0 end
      killedUnit.die_count = killedUnit.die_count + 1
      if killedUnit.die_count < 2 then
        killedUnit:RespawnUnit()
        local archer_attack = killedUnit:FindAbilityByName("archer_attack")
        if archer_attack then
          Timers:CreateTimer( 0.1, function()
          archer_attack:ApplyDataDrivenModifier(killedUnit,killedUnit,"modifier_archer_attack",nil)
          end)
        end
        local attack_building = killedUnit:FindAbilityByName("attack_building")
        if attack_building then
          Timers:CreateTimer( 0.1, function()
          attack_building:ApplyDataDrivenModifier(killedUnit,killedUnit,"modifier_attack_building",nil)
          end)
        end
        local gunner_attack = killedUnit:FindAbilityByName("gunner_attack")
        if gunner_attack then
          Timers:CreateTimer( 0.1, function()
          gunner_attack:ApplyDataDrivenModifier(killedUnit,killedUnit,"modifier_gunner_attack",nil)
          end)
        end
        local for_no_collision = killedUnit:FindAbilityByName("for_no_collision")
        if for_no_collision then
          Timers:CreateTimer( 0.1, function()
          for_no_collision:ApplyDataDrivenModifier(killedUnit,killedUnit,"modifier_for_no_collision",nil)
          end)
        end
      end
  	end

    if killedUnit:IsRealHero() then
      if _G.hardcore then
        --AMHC:GivePlayerGold_UnReliable(killedUnit:GetPlayerOwnerID(), -300)
      end
      if killedUnit.death_count == nil then
        killedUnit.death_count = 1
      else
        killedUnit.death_count = killedUnit.death_count + 1
      end

      --[[
      if killedUnit:GetLevel() >= 18 then
        killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2+20)
      elseif killedUnit:GetLevel() >= 12 then
        killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2+11)
      elseif killedUnit:GetLevel() >= 6 then
        killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2+3)
      else
        killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*2)
      end
      ]]
      
      if die_tim2[killedUnit:GetLevel()] then
        killedUnit:SetTimeUntilRespawn(die_tim2[killedUnit:GetLevel()])
        killedUnit.death = true
        Timers:CreateTimer(die_tim2[killedUnit:GetLevel()], function()
          killedUnit.death = nil
          end)
      else
        killedUnit:SetTimeUntilRespawn(85)
        Timers:CreateTimer(85, function()
          killedUnit.death = nil
          end)
      end
      
      if not _G.hardcore then 
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
          local xp = killedUnit:GetLevel() * 30 / #group
          for _,v in ipairs(group) do
            if v:IsHero() then
              if killedUnit:GetLevel() > v:GetLevel()+3 then
                v:AddExperience(xp*4, DOTA_ModifyGold_HeroKill, false, false)
              elseif killedUnit:GetLevel() == v:GetLevel()+3 then
                v:AddExperience(xp*3, DOTA_ModifyGold_HeroKill, false, false)
              elseif killedUnit:GetLevel() == v:GetLevel()+2 then
                v:AddExperience(xp*2, DOTA_ModifyGold_HeroKill, false, false)
              elseif killedUnit:GetLevel() == v:GetLevel()+1 then
                v:AddExperience(xp*1, DOTA_ModifyGold_HeroKill, false, false)
              elseif killedUnit:GetLevel() == v:GetLevel() then
                v:AddExperience(xp*0.5, DOTA_ModifyGold_HeroKill, false, false)
              end
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

    if killedUnit:GetUnitName() == "npc_dota_courier2" then
      local sump = 0
      for playerID = 0, 9 do
        local id       = playerID
          local p        = PlayerResource:GetPlayer(id)
          if p ~= nil then
          sump = sump + 1
        end
      end
      if sump > 1 then
        killedUnit:RespawnUnit()
        Timers:CreateTimer(0.1, function()
          killedUnit:FindAbilityByName("for_magic_immune"):
          ApplyDataDrivenModifier(killedUnit,killedUnit,"modifier_for_magic_immune",nil)
          local for_no_collision = killedUnit:FindAbilityByName("for_no_collision")
          if for_no_collision then
            for_no_collision:ApplyDataDrivenModifier(killedUnit,killedUnit,"modifier_for_no_collision",nil)
          end
        end)
        killedUnit:SetOrigin(killedUnit.oripos)
      end
    end
    --print("dead")
  -- 統計威望
  prestige = _G.prestige
  goldprestige = _G.goldprestige
  if prestige == nil then prestige = {} end
  if goldprestige == nil then goldprestige = {} end
  prestige[2] = goldprestige[2] or 0
  prestige[3] = goldprestige[3] or 0
  local sumkill = 0
  local allHeroes = HeroList:GetAllHeroes()
  for k, v in pairs( allHeroes ) do
    if not v:IsIllusion() then
      local hero     = v
      if (hero.kill_count ~= nil)  then
        prestige[hero:GetTeamNumber()] = prestige[hero:GetTeamNumber()] + hero.kill_count
      end
      if (hero.kill_hero_count ~= nil)  then
        prestige[hero:GetTeamNumber()] = prestige[hero:GetTeamNumber()] + hero.kill_hero_count*5
      end
    end
  end
end
