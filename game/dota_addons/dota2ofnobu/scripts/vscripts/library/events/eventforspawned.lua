require("equilibrium_constant")
LinkLuaModifier( "modifier_record", "items/Addon_Items/record.lua",LUA_MODIFIER_MOTION_NONE )
--單位創建也會運行

_G.CountUsedAbility_Table = {}

heromap = {
  npc_dota_hero_bristleback = "B15",
  npc_dota_hero_earthshaker = "B24",
  npc_dota_hero_brewmaster = "B26",
  npc_dota_hero_silencer = "C07",
  npc_dota_hero_sniper = "A17",
  npc_dota_hero_beastmaster = "B34",
  npc_dota_hero_huskar = "A16",

  npc_dota_hero_mirana = "C15",
  npc_dota_hero_antimage = "C10",
  npc_dota_hero_crystal_maiden = "A34",
  npc_dota_hero_storm_spirit = "A12",
  
  npc_dota_hero_troll_warlord = "A06",
  npc_dota_hero_faceless_void = "B02",
  npc_dota_hero_undying = "A13",

  npc_dota_hero_invoker = "A28",
  npc_dota_hero_omniknight = "A27",
  npc_dota_hero_oracle = "A29",
  npc_dota_hero_ancient_apparition = "A04",
  npc_dota_hero_dragon_knight = "B32",
  npc_dota_hero_drow_ranger = "B33",
  
  npc_dota_hero_nevermore = "B01",
  npc_dota_hero_pugna = "B25",
  npc_dota_hero_axe = "B06",
  npc_dota_hero_viper = "C01",
  npc_dota_hero_windrunner = "C17",
  npc_dota_hero_keeper_of_the_light = "B05",
  npc_dota_hero_jakiro = "C22",
  npc_dota_hero_alchemist = "C21",
  npc_dota_hero_treant = "A25",
  npc_dota_hero_templar_assassin = "C19",
  npc_dota_hero_medusa = "A31",
  npc_dota_hero_magnataur = "B08",
  npc_dota_hero_centaur = "A07",
  npc_dota_hero_naga_siren = "B16",
}

function Nobu:OnHeroIngame( keys )
  --PrintTable(keys)
  local hero = EntIndexToHScript( keys.entindex )
    
  if hero:IsHero() then
    local caster = hero
    if caster:HasModifier("modifier_record") then
      caster:RemoveModifierByName("modifier_record")
    end
    caster.name = heromap[caster:GetUnitName()]
    caster.version = "16"
    caster:AddNewModifier(caster,ability,"modifier_record",{})
    caster:FindModifierByName("modifier_record").caster = caster

    local name = caster:GetUnitName()
    if string.match(name, "ancient_apparition")  then --竹中重治
      if caster:FindAbilityByName("A04D") ~= nil then
        caster:FindAbilityByName("A04D"):SetLevel(1)
      end
    elseif string.match(name, "jakiro") then --佐佐木小次郎
      if caster:FindAbilityByName("C22D") ~= nil then
        caster:FindAbilityByName("C22D"):SetLevel(1)
      end
    elseif string.match(name, "magnataur") then -- 淺井長政
      if caster:FindAbilityByName("B08T") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "templar_assassin") then --松姬
      if caster:FindAbilityByName("C19D") ~= nil then
        caster:FindAbilityByName("C19D"):SetLevel(1)
      else
        caster.version = "11"
      end
    elseif string.match(name, "pugna") then --本願寺顯如
      if caster:FindAbilityByName("B25R") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "keeper_of_the_light") then -- 毛利元就
      if caster:FindAbilityByName("B05R") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "nevermore") then --雜賀孫市
      if caster:FindAbilityByName("B01W") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "beastmaster") then --武田勝賴
      if caster:FindAbilityByName("B34E") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "dragon_knight") then --上杉謙信
      if caster:FindAbilityByName("B32W") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "slardar") then -- 真田幸村
      if caster:FindAbilityByName("B06W") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "troll_warlord") then -- 井伊直政
      if caster:FindAbilityByName("A06W") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "centaur") then --本多忠勝
      if caster:FindAbilityByName("A07D") ~= nil and caster:FindAbilityByName("A07D"):GetLevel() == 0 then
        caster:FindAbilityByName("A07D"):SetLevel(1)
      end
      if caster:FindAbilityByName("A07D") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "broodmother") then --服部半藏
      if caster:FindAbilityByName("A13D") ~= nil and caster:FindAbilityByName("A13D"):GetLevel() == 0 then
        caster:FindAbilityByName("A13D"):SetLevel(1)
      end
      if caster:FindAbilityByName("A13D") == nil then
        caster.version = "11"
      end
    elseif string.match(name, "storm_spirit") then --大谷吉繼
      caster:FindAbilityByName("A12D"):SetLevel(1)
      caster:FindAbilityByName("A12D"):SetActivated(false)
      caster:FindAbilityByName("A12D_HIDE"):SetLevel(1)
    elseif string.match(name, "silencer") then -- 立花道雪
      if caster:FindAbilityByName("C07D") ~= nil then
        caster:FindAbilityByName("C07D"):SetLevel(1)
      end
      -- 這隻角色天生會帶一個modifier我們需要砍掉他
      caster:RemoveModifierByName("modifier_silencer_int_steal")
    elseif string.match(name, "windrunner") then -- 阿市
      if caster:FindAbilityByName("C17D") ~= nil then
        caster:FindAbilityByName("C17D"):SetLevel(1)
      end
    elseif string.match(name, "faceless_void") then --風魔小太郎
      if caster:FindAbilityByName("B02D") ~= nil and caster:FindAbilityByName("B02D"):GetLevel() == 0 then
        caster:FindAbilityByName("B02D"):SetLevel(1)
      end
    elseif string.match(name, "naga_siren") then -- 望月千代女
      local B16D = caster:FindAbilityByName("B16D")
      if B16D ~= nil and B16D:GetLevel() == 0 then
        B16D:SetLevel(1)
      end
      local B16W = caster:FindAbilityByName("B16W")
      if B16W ~= nil then
        B16W:SetActivated(false)
      end
    end
	Timers:CreateTimer ( 1, function ()
		if not hero:IsIllusion() then
      if hero.init1 == nil then
        hero.init1 = true
        hero.kill_count = 0
        hero.damage = 0
        hero.takedamage = 0
        hero.herodamage = 0
        hero:AddNewModifier(caster,ability,"modifier_record",{})
        hero:FindModifierByName("modifier_record").caster = caster
        --hero:AddItem(CreateItem("item_flash_ring", hero, hero))
    		--hero:AddItem(CreateItem("item_pleated_skirt", hero, hero))
    		
    		local donkey = CreateUnitByName("npc_dota_courier", hero:GetAbsOrigin()+Vector(100, 100, 0), true, hero, hero, hero:GetTeam())
    		donkey:SetOwner(hero)
    		donkey:SetControllableByPlayer(hero:GetPlayerID(), true)

        --[[
        for abilitySlot=0,15 do
          local ability = donkey:GetAbilityByIndex(abilitySlot)
            if ability ~= nil then 
              local abilityLevel = ability:GetLevel()
              local abilityName = ability:GetAbilityName()
              donkey:RemoveAbility(abilityName)
            end
        end
        ]]
      end
      Timers:CreateTimer(1, function ()
          for itemSlot=0,5 do
            local item = hero:GetItemInSlot(itemSlot)
            if item ~= nil then
              item:SetPurchaseTime(100000)
            end
          end
          return 5
        end)
		end
	end)
    --等級
    for i=1,5 do
      --hero:HeroLevelUp(false)
    end
  end

  if _G.nobu_server_b then
    if hero:IsHero() then
      --AddAFKTimer(hero)
      --hero.start_afk()
    end
  end
end

-- 統計英雄使用情況
function Nobu:CountUsedAbility( keys )
  local keyid = keys.PlayerID + 1
  if (_G.CountUsedAbility_Table[keyid] == nil) then
    _G.CountUsedAbility_Table[keyid]  = {}
  end
  if (_G.CountUsedAbility_Table[keyid][keys.abilityname] == nil) then
    _G.CountUsedAbility_Table[keyid][keys.abilityname] = 1
  else
    _G.CountUsedAbility_Table[keyid][keys.abilityname] =
      _G.CountUsedAbility_Table[keyid][keys.abilityname] + 1
  end
  --DeepPrintTable(_G.CountUsedAbility_Table)
end


function SendHTTPRequest(path, method, values, callback)
	local req = CreateHTTPRequest( method, "http://140.114.235.19/"..path )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end

function AddAFKTimer( hero )
  hero.afkcount = 0
  hero.start_afk = function()
	  local hasafk = false
      local pos = hero:GetAbsOrigin()
      Timers:CreateTimer( 1, function()
        if (hero:IsAlive() and pos == hero:GetAbsOrigin()) then
          hero.afkcount = hero.afkcount + 1
        else
          pos = hero:GetAbsOrigin()
          hero.afkcount = 0
        end
        if (hero.afkcount > 180 and not hasafk) then
    		  hero.afkcount = 0
    		  hasafk = true
          local pID = hero:GetPlayerOwner():GetPlayerID()
          local steamID = PlayerResource:GetSteamAccountID(pID)
          print("steamID "..steamID)
          GameRules:SendCustomMessage("玩家"..pID.."中離", DOTA_TEAM_GOODGUYS, 0)
          SendHTTPRequest("afk", "POST",
            {
              id = tostring(steamID),
            },
            function(result)
              print(result)
              if (result == "error") then
                player:Destroy()
              end
              -- Decode response into a lua table
              local resultTable = {}
              if not pcall(function()
                resultTable = JSON:decode(result)
              end) then
                Warning("[dota2.tools.Storage] Can't decode result: " .. result)
              end

              -- If we get an error response, successBool should be false
              if resultTable ~= nil and resultTable["errors"] ~= nil then
                callback(resultTable["errors"], false)
                return
              end

              -- If we get a success response, successBool should be true
              if resultTable ~= nil and resultTable["data"] ~= nil  then
                callback(resultTable["data"], true)
                return
              end
            end
          )
        end
        return 1
      end)
    end
end
