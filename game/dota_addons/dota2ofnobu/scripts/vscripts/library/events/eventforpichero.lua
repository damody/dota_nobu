
 heromap = _G.heromap 

function Nobu:PickHero( keys )
  local id       = keys.player
  local p        = PlayerResource:GetPlayer(id-1)
  local caster     = EntIndexToHScript(keys.heroindex)
  local point    = caster:GetAbsOrigin()
  local owner = caster:GetPlayerOwner()
--CustomUI:DynamicHud_Create(-1,"mainWin","file://{resources}/layout/custom_game/game_info.xml",nil)
  Timers:CreateTimer(1, function ()
    if not caster:IsIllusion() then
      if _G.CountUsedAbility_Table == nil then
        _G.CountUsedAbility_Table = {}
      end
      if _G.CountUsedAbility_Table[id] == nil then
        _G.CountUsedAbility_Table[id] = {}
      end
      --【英雄名稱判別】
      local name = caster:GetUnitName()
      caster.version = "16"
      caster.name = heromap[name]
      print("name " .. name)
      if string.match(name, "ancient_apparition")  then --竹中重治
        caster:FindAbilityByName("A04D"):SetLevel(1)
      elseif string.match(name, "jakiro") then --佐佐木小次郎
        caster:FindAbilityByName("C22D"):SetLevel(1)
      elseif string.match(name, "magnataur") then -- 淺井長政
        Timers:CreateTimer(1, function ()
          if (caster:GetLevel() >= 18) then
            caster:FindAbilityByName("B08D_old"):SetLevel(1)
            return nil
          end
          return 1
        end)
      elseif string.match(name, "templar_assassin") then --松姬
        caster:FindAbilityByName("C19D"):SetLevel(1)
      elseif string.match(name, "centaur") then --本多忠勝
        caster:FindAbilityByName("A07D"):SetLevel(1)
      elseif string.match(name, "undying") then --服部半藏
        caster:FindAbilityByName("A13D"):SetLevel(1)
      elseif string.match(name, "storm_spirit") then --大谷吉繼
        caster:FindAbilityByName("A12D"):SetLevel(1)
        caster:FindAbilityByName("A12D"):SetActivated(false)
        caster:FindAbilityByName("A12D_HIDE"):SetLevel(1)
      elseif string.match(name, "bristleback") then -- 今川義元
        Timers:CreateTimer(1, function ()
          if (caster:GetLevel() >= 8) then
            caster:FindAbilityByName("B15D"):SetLevel(1)
            return nil
          end
          return 1
        end)
      elseif string.match(name, "silencer") then --立花道雪
        -- 這隻角色天生會帶一個modifier我們需要砍掉他
        caster:RemoveModifierByName("modifier_silencer_int_steal")
        caster:FindAbilityByName("C07D"):SetLevel(1)
      elseif string.match(name, "windrunner") then -- 阿市
        caster:FindAbilityByName("C17D"):SetLevel(1)
      elseif string.match(name, "faceless_void") then --風魔小太郎
        caster:FindAbilityByName("B02D"):SetLevel(1)
      end
    end
  end)
  --【英雄名稱判別】

  --【英雄系統】
    --<<事件:任一單位施放技能>>
    --caster:AddAbility("EventForUnitSpellAbility"):SetLevel(1)
    --<<事件:命令事件>>
    --caster:AddAbility("EventForOrder"):SetLevel(1)
    --<<全能力點數>>
    --caster:AddAbility("attribute_bonusx")

  --【英雄系統】

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
