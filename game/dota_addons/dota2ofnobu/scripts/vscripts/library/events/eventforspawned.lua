require("equilibrium_constant")

--單位創建也會運行

model_lookup = {}
model_lookup["npc_dota_hero_storm_spirit"] = true
model_lookup["npc_dota_hero_drow_ranger"] = true
--model_lookup["npc_dota_hero_windrunner"] = true
model_lookup["npc_dota_hero_earthshaker"] = true
model_lookup["npc_dota_hero_sniper"] = true
model_lookup["npc_dota_hero_huskar"] = true
model_lookup["npc_dota_hero_beastmaster"] = true
model_lookup["npc_dota_hero_antimage"] = true
model_lookup["npc_dota_hero_silencer"] = true
model_lookup["npc_dota_hero_brewmaster"] = true
model_lookup["npc_dota_hero_crystal_maiden"] = true
model_lookup["npc_dota_hero_mirana"] = true
model_lookup["npc_dota_hero_dragon_knight"] = true
model_change_wearable = {}
model_change_wearable["npc_dota_hero_antimage"]= true

_G.CountUsedAbility_Table = {}


function Nobu:OnHeroIngame( keys )
  --PrintTable(keys)
  -- local hero = EntIndexToHScript( keys.entindex )
  -- if hero:IsHero() then
  --   RemoveWearables( hero )
  -- end

  local hero = EntIndexToHScript( keys.entindex )
  
  if hero:IsHero() then
    local caster = hero
    local name = caster:GetUnitName()
    if string.match(name, "ancient_apparition")  then
      caster:FindAbilityByName("A04D"):SetLevel(1)
    elseif string.match(name, "jakiro") then
      caster:FindAbilityByName("C22D"):SetLevel(1)
    elseif string.match(name, "templar_assassin") then
      caster:FindAbilityByName("C19D"):SetLevel(1)
    elseif string.match(name, "centaur") then
      if (caster:FindAbilityByName("A07D") ~= nil and caster:FindAbilityByName("A07D"):GetLevel() == 0) then
        caster:FindAbilityByName("A07D"):SetLevel(1)
      end
    elseif string.match(name, "broodmother") then
      if (caster:FindAbilityByName("A13D"):GetLevel() == 0) then
        caster:FindAbilityByName("A13D"):SetLevel(1)
      end
    elseif string.match(name, "storm_spirit") then
      caster:FindAbilityByName("A12D_HIDE"):SetLevel(1)
    elseif string.match(name, "silencer") then
      -- 這隻角色天生會帶一個modifier我們需要砍掉他
      Timers:CreateTimer(0.01, function ()
        if (caster:GetModifierNameByIndex(0) ~= nil) then
          caster:RemoveModifierByName(caster:GetModifierNameByIndex(0))
        end
        return nil
      end)
      caster:FindAbilityByName("C07D"):SetLevel(1)
    elseif string.match(name, "windrunner") then
      caster:FindAbilityByName("C17D"):SetLevel(1)
    elseif string.match(name, "faceless_void") then--風魔
      if (caster:FindAbilityByName("B02D"):GetLevel() == 0) then
        caster:FindAbilityByName("B02D"):SetLevel(1)
      end
    end
	Timers:CreateTimer ( 1, function ()
		if not hero:IsIllusion() then
      if hero.init1 == nil then
        hero.init1 = true
        --hero:AddItem(CreateItem("item_flash_ring", hero, hero))
		--hero:AddItem(CreateItem("item_pleated_skirt", hero, hero))
		
		local donkey = CreateUnitByName("npc_dota_courier", hero:GetAbsOrigin()+Vector(100, 100, 0), true, hero, hero, hero:GetTeam())
		donkey:SetOwner(hero)
		donkey:SetControllableByPlayer(hero:GetPlayerID(), true)
		donkey:SetBaseMaxHealth(2000)
		donkey:SetHealth(donkey:GetMaxHealth())
		donkey:SetPhysicalArmorBaseValue(10)
		donkey:SetBaseMoveSpeed(2000)
		donkey:AddAbility("for_magic_immune")
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
      AddAFKTimer(hero)
      hero.start_afk()
    end
  end
end

-- 統計英雄使用情況
function Nobu:CountUsedAbility( keys )
  if (_G.CountUsedAbility_Table[keys.PlayerID] == nil) then
    _G.CountUsedAbility_Table[keys.PlayerID]  = {}
  end
  if (_G.CountUsedAbility_Table[keys.PlayerID][keys.abilityname] == nil) then
    _G.CountUsedAbility_Table[keys.PlayerID][keys.abilityname] = 1
  else
    _G.CountUsedAbility_Table[keys.PlayerID][keys.abilityname] =
      _G.CountUsedAbility_Table[keys.PlayerID][keys.abilityname] + 1
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

function RemoveWearables( hero )
  local children = hero:GetChildren()
  local name = hero:GetUnitName()

  if model_lookup[name]  == true then
    if model_change_wearable[name] == true then
    end
  else
    for k,child in pairs(children) do
       --print("Wearable"..child:GetClassname())
       if child:GetClassname() == "dota_item_wearable" then
          child:RemoveSelf()
       end
    end
  end
end

-- [   VScript   ]: Wearableelder_titan_echo_stomp
-- [   VScript   ]: Wearableelder_titan_ancestral_spirit
-- [   VScript   ]: Wearableelder_titan_natural_order
-- [   VScript   ]: Wearableelder_titan_return_spirit
-- [   VScript   ]: Wearableelder_titan_earth_splitter
-- [   VScript   ]: Wearableability_datadriven
-- [   VScript   ]: Wearabledota_item_wearable
-- [   VScript   ]: Wearabledota_item_wearable
-- [   VScript   ]: Wearabledota_item_wearable
-- [   VScript   ]: Wearabledota_item_wearable
-- [   VScript   ]: Wearabledota_item_wearable
-- [   VScript   ]: Wearabledota_item_wearable
