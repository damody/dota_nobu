
function Nobu:PickHero( keys )
  local id       = keys.player
  local p        = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家
  local caster     = p: GetAssignedHero()
  local point    = caster:GetAbsOrigin()
  local owner = caster:GetPlayerOwner()


  --【統計系統】
    --【技能】
    caster.skillw = 0
    caster.skille = 0
    caster.skillr = 0
    caster.skilld = 0
    caster.skillt = 0

    --【傷害】
    caster.damage_num = 0
    caster.damaged_num = 0

    --【金錢】



  --【英雄名稱判別】
  local name = caster:GetUnitName()
  if string.match(name, "ancient_apparition")  then
    caster:FindAbilityByName("A04D"):SetLevel(1)
  elseif string.match(name, "jakiro") then
    caster:FindAbilityByName("C22D"):SetLevel(1)
  elseif string.match(name, "templar_assassin") then
    caster:FindAbilityByName("C19D"):SetLevel(1)
  elseif string.match(name, "centaur") then --本多忠勝
    caster:FindAbilityByName("A07D"):SetLevel(1)
    GameRules: SendCustomMessage("",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    GameRules: SendCustomMessage("本多忠勝玩家可以打 -old 使用舊版角色",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
  elseif string.match(name, "pugna") then --本願寺顯如
    GameRules: SendCustomMessage("",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    GameRules: SendCustomMessage("本願寺顯如玩家可以打 -old 使用舊版角色",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
  elseif string.match(name, "keeper_of_the_light") then -- 毛利元就
    GameRules: SendCustomMessage("",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    GameRules: SendCustomMessage("毛利元就玩家可以打 -old 使用舊版角色",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
  elseif string.match(name, "broodmother") then
    caster:FindAbilityByName("A13D"):SetLevel(1)
  elseif string.match(name, "storm_spirit") then
    caster:FindAbilityByName("A12D_HIDE"):SetLevel(1)
  elseif string.match(name, "bristleback") then -- 今川義元
    Timers:CreateTimer(1, function ()
      if (caster:GetLevel() >= 8) then
        hero:FindAbilityByName("B15D"):SetLevel(1)
        return nil
      end
      return 1
    end)
  elseif string.match(name, "silencer") then --立花道雪
    -- 這隻角色天生會帶一個modifier我們需要砍掉他
    Timers:CreateTimer(0.1, function ()
      if (caster:GetModifierNameByIndex(0) ~= nil) then
        caster:RemoveModifierByName(caster:GetModifierNameByIndex(0))
      end
      return nil
    end)
    caster:FindAbilityByName("C07D"):SetLevel(1)
  elseif string.match(name, "windrunner") then
    caster:FindAbilityByName("C17D"):SetLevel(1)
  elseif string.match(name, "faceless_void") then --風魔
    caster:FindAbilityByName("B02D"):SetLevel(1)
  end
  --【英雄名稱判別】

  --【英雄系統】
    --<<事件:任一單位施放技能>>
    --caster:AddAbility("EventForUnitSpellAbility"):SetLevel(1)
    --<<事件:命令事件>>
    --caster:AddAbility("EventForOrder"):SetLevel(1)
    --<<全能力點數>>
    --caster:AddAbility("attribute_bonus")

  --【英雄系統】

  --【御守系統】
  caster.yushou = false

  --【test】
    --物品
  -- item = CreateItem("item_blink_datadriven",nil,nil)
  -- CreateItemOnPositionSync(point, item)
  --
  -- item = CreateItem("item_invis_sword",nil,nil)
  -- CreateItemOnPositionSync(point, item)
  --
  -- CreateItemOnPositionSync(point, CreateItem("item_D09",nil,nil))
  -- CreateItemOnPositionSync(point, CreateItem("item_D0"..2,nil,nil))
  -- CreateItemOnPositionSync(point, CreateItem("item_S01",nil,nil))


  --print(bj_CELLWIDTH)



 -- CreateItemOnPositionSync(point, CreateItem("item_test",nil,nil))
  -- item = CreateItem("item_sphere",nil,nil)
  -- CreateItemOnPositionSync(point, item)

  -- item = CreateItem("item_manta_datadriven",nil,nil)
  -- CreateItemOnPositionSync(point, item)

  --debug
  --GameRules: SendCustomMessage("Hello World",DOTA_TEAM_GOODGUYS,0)

end
