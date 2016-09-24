
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
	

    ------------------------------------------------------------------
    local killedUnit = EntIndexToHScript( keys.entindex_killed )
  	local name = killedUnit:GetUnitName()
  	if name == "npc_dota_hero_silencer" then
  		-- 這隻角色天生會帶一個modifier我們需要砍掉他
      -- 一般是立花道雪在用他
      local count = 0
  		Timers:CreateTimer(0.01, function ()
  		  if (killedUnit:GetModifierNameByIndex(0) ~= nil) then
    			killedUnit:RemoveModifierByName(killedUnit:GetModifierNameByIndex(0))
  		  end
        count = count + 1
        if count > 3 then
          return nil
        end
  		  return 0.01
  		end)
  		print("npc_dota_hero_silencer_dead")
  	end

    if killedUnit:IsRealHero() then
      --killedUnit:RespawnUnit()
	    killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*1)
      group = FindUnitsInRadius(
          killedUnit:GetTeamNumber(), 
          killedUnit:GetAbsOrigin(), 
          nil, 
          1500,
          DOTA_UNIT_TARGET_TEAM_ENEMY, 
          DOTA_UNIT_TARGET_HERO, 
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
          FIND_ANY_ORDER, 
          false)
      if (#group > 0) then
        local xp = killedUnit:GetLevel() * 50 / #group
        for _,v in ipairs(group) do
          v:AddExperience(xp, DOTA_ModifyGold_HeroKill, false, false)
        end
      end

      -- for i=1,10 do
      --   GameRules: SendCustomMessage("   ",DOTA_TEAM_GOODGUYS,0)
      -- end
      --Tutorial: AddQuest("quest_1",1,"破塔成功","ssssssssss")
    end

    print(killedUnit:GetUnitName() )
    if killedUnit  == _G.TestUnit then
      killedUnit:RespawnUnit()
    end
    --print("dead")
end
