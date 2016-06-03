--單位創建也會運行

model_lookup = {}
model_lookup["npc_dota_hero_storm_spirit"] = true
model_lookup["npc_dota_hero_drow_ranger"] = true
model_lookup["npc_dota_hero_windrunner"] = true
model_lookup["npc_dota_hero_earthshaker"] = true
model_lookup["npc_dota_hero_sniper"] = true
model_lookup["npc_dota_hero_huskar"] = true
model_lookup["npc_dota_hero_beastmaster"] = true
model_lookup["npc_dota_hero_antimage"] = true
model_lookup["npc_dota_hero_silencer"] = true
model_lookup["npc_dota_hero_pugna"] = true
model_change_wearable = {}
model_change_wearable["npc_dota_hero_antimage"]= true


function GameRules.Nobu:OnHeroIngame( keys )
  local hero = EntIndexToHScript( keys.entindex )
  if hero:IsHero() then  
    RemoveWearables( hero )
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
        print("Wearable"..child:GetClassname())
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