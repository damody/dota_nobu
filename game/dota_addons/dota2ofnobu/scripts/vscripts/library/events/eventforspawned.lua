
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


function Nobu:OnHeroIngame( keys )
  --PrintTable(keys)
  -- local hero = EntIndexToHScript( keys.entindex )
  -- if hero:IsHero() then
  --   RemoveWearables( hero )
  -- end

  if _G.nobu_server_b then
    local hero = EntIndexToHScript( keys.entindex )
    if hero:IsHero() then
      AddAFKTimer(hero)
      hero.start_afk()
    end
  end
end


function SendHTTPRequestAFK(method, values, callback)
  local req = CreateHTTPRequest( method, "http://140.114.235.19/afk" )
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
      local pos = hero:GetAbsOrigin()
      Timers:CreateTimer( 1, function()
        if (hero:IsAlive() and pos == hero:GetAbsOrigin()) then
          hero.afkcount = hero.afkcount + 1
        else
          pos = hero:GetAbsOrigin()
          hero.afkcount = 0
        end
        if (hero.afkcount > 180) then
          hero.afkcount = 0
          local pID = hero:GetPlayerOwner():GetPlayerID()
          local steamID = PlayerResource:GetSteamAccountID(pID)
          print("steamID "..steamID)

          SendHTTPRequestAFK("POST",
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
