
function Nobu:LevelUP( keys )
  -- DeepPrintTable(keys)
  -- [   VScript   ]:    player                            = 1 (number)
  -- [   VScript   ]:    level                             = 24 (number)
  -- [   VScript   ]:    splitscreenplayer                 = -1 (number)
  local p     = PlayerResource:GetPlayer(keys.player-1)
  local caster     = p:GetAssignedHero()
  local name = caster:GetUnitName()
  if name == "npc_dota_hero_bristleback"  then
    if keys.level == 8 then
      local ability = caster:FindAbilityByName("B15D")
      ability:SetLevel(1)
    end
  end
end

function Nobu:Learn_Ability( keys )
  -- DeepPrintTable(keys)
  -- [   VScript          ]:    player                           = 1 (number)
  -- [   VScript          ]:    abilityname                      = "A06W" (string)
  -- [   VScript          ]:    splitscreenplayer                = -1 (number)
end

function Nobu:Connect_Full( keys )
  -- DeepPrintTable(keys)
  -- [   VScript              ]:    PlayerID                         = 0 (number)
  -- [   VScript              ]:    index                            = 0 (number)
  -- [   VScript              ]:    userid                           = 1 (number)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
end

function Nobu:OnDisconnect( keys ) --代測試

  DeepPrintTable(keys)
end

function Nobu:OnItemPurchased( keys )
  -- DeepPrintTable(keys)
  -- [   VScript              ]:    itemcost                         = 50 (number)
  -- [   VScript              ]:    itemname                         = "item_tpscroll" (string)
  -- [   VScript              ]:    PlayerID                         = 0 (number)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
end

function Nobu:OnItemPickedUp( keys )
  -- DeepPrintTable(keys)
  -- O 購買物品不會觸發
  -- [   VScript              ]:    itemname                         = "item_invis_sword" (string)
  -- [   VScript              ]:    PlayerID                         = 0 (number)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
  -- [   VScript              ]:    ItemEntityIndex                  = 2529 (number)
  -- [   VScript              ]:    HeroEntityIndex                  = 2548 (number)
end

function Nobu:OnEntityHurt( keys )
  -- DeepPrintTable(keys)
  -- O為甚麼要filter外 還有這個傷害事件
  -- [   VScript              ]:    damagebits                       = 0 (number)
  -- [   VScript              ]:    entindex_killed                  = 2548 (number)
  -- [   VScript              ]:    damage                           = 41.65344619751 (number)
  -- [   VScript              ]:    entindex_attacker                = 306 (number)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
end

function Nobu:PlayerConnect( keys )
  --print("Nobu PlayerConnect")
  --DeepPrintTable(keys)
  -- [   VScript              ]:    address                          = "none" (string)
  -- [   VScript              ]:    bot                              = 1 (number)
  -- [   VScript              ]:    userid                           = 2 (number)
  -- [   VScript              ]:    index                            = 1 (number)
  -- [   VScript              ]:    xuid                             = 0 (userdata)
  -- [   VScript              ]:    networkid                        = "BOT" (string)
  -- [   VScript              ]:    name                             = "Louie Bot" (string)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
end

function Nobu:PlayerSay( keys ) --代測試

  DeepPrintTable(keys)
end

function Nobu:Item_Changed( keys ) --代測試

  DeepPrintTable(keys)
end

function Nobu:ModifyGoldFilter(filterTable)
  -- DeepPrintTable(filterTable)
  -- [   VScript              ]:    reason_const                     = 13 (number)
  -- [   VScript              ]:    reliable                         = 0 (number)
  -- [   VScript              ]:    player_id_const                  = 0 (number)
  -- [   VScript              ]:    gold                             = 61 (number)

  -- Disable gold gain from hero kills
  -- if filterTable["reason_const"] == DOTA_ModifyGold_HeroKill then
  --     filterTable["gold"] = 0
  --     return false
  -- end

  return true
end

function Nobu:AbilityTuningValueFilter(filterTable)
  --DeepPrintTable(filterTable)
  -- [   VScript              ]:    value                            = 6 (number)
  -- [   VScript              ]:    entindex_ability_const           = 799 (number)
  -- [   VScript              ]:    value_name_const                 = "A06W_Duration" (string)
  -- [   VScript              ]:    entindex_caster_const            = 798 (number)

  -- [   VScript              ]:    value                            = 5 (number)
  -- [   VScript              ]:    entindex_ability_const           = 786 (number)
  -- [   VScript              ]:    value_name_const                 = "A06R_SPEED" (string)
  -- [   VScript              ]:    entindex_caster_const            = 798 (number)
  --print("Nobu:AbilityTuningValueFilter")
  return true
end

function Nobu:SetItemAddedToInventoryFilter(filterTable)
  --DeepPrintTable(filterTable)
  -- [   VScript ]:    item_entindex_const               = 830 (number)
  -- [   VScript ]:    inventory_parent_entindex_const   = 798 (number)
  -- [   VScript ]:    suggested_slot                    = -1 (number)
  -- [   VScript ]:    item_parent_entindex_const        = -1 (number)
  --print("SetItemAddedToInventoryFilter")
  return true
end

function Nobu:SetModifyExperienceFilter(filterTable)
  -- DeepPrintTable(filterTable)
  -- [   VScript              ]:    reason_const                     = 2 (number)
  -- [   VScript              ]:    experience                       = 120 (number)
  -- [   VScript              ]:    player_id_const                  = 0 (number)

  return true
end

function Nobu:SetTrackingProjectileFilter(filterTable)
  --DeepPrintTable(filterTable)
  -- [   VScript          ]:    is_attack                        = 0 (number)
  -- [   VScript          ]:    entindex_ability_const           = 330 (number)
  -- [   VScript          ]:    max_impact_time                  = 0 (number)
  -- [   VScript          ]:    entindex_target_const            = 495 (number)
  -- [   VScript          ]:    move_speed                       = 1100 (number)
  -- [   VScript          ]:    entindex_source_const            = 328 (number)
  -- [   VScript          ]:    dodgeable                        = 1 (number)
  -- [   VScript          ]:    expire_time                      = 0 (number)

  return true
end


function Nobu:Attachment_UpdateUnit(args)
  --DebugPrint('Attachment_UpdateUnit')
  --DebugPrintTable(args)

  local unit = EntIndexToHScript(args.index)
  print("args")
  -- if not unit then
  --   --Notify(args.PlayerID, "Invalid Unit.")
  --   return
  -- end

  -- local cosmetics = {}
  -- for i,child in ipairs(unit:GetChildren()) do
  --   if child:GetClassname() == "dota_item_wearable" and child:GetModelName() ~= "" then
  --     table.insert(cosmetics, child:GetModelName())
  --   end
  -- end

  -- --DebugPrintTable(cosmetics)
  -- CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.PlayerID), "attachment_cosmetic_list", cosmetics )
end
