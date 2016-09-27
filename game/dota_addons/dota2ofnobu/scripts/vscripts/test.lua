function Nobu_Test:LevelUP( keys )
  -- DeepPrintTable(keys)
  -- [   VScript   ]:    player                            = 1 (number)
  -- [   VScript   ]:    level                             = 24 (number)
  -- [   VScript   ]:    splitscreenplayer                 = -1 (number)
  -- local p     = PlayerResource:GetPlayer(keys.player-1)
  -- local caster     = p:GetAssignedHero()
  -- local name = caster:GetUnitName()
  -- if name == "npc_dota_hero_bristleback"  then
  --   if keys.level == 8 then
  --     local ability = caster:FindAbilityByName("B15D")
  --     ability:SetLevel(1)
  --   end
  -- end
end

function Nobu_Test:Learn_Ability( keys )
  -- DeepPrintTable(keys)
  -- [   VScript          ]:    player                           = 1 (number)
  -- [   VScript          ]:    abilityname                      = "A06W" (string)
  -- [   VScript          ]:    splitscreenplayer                = -1 (number)
end

function Nobu_Test:Connect_Full( keys )
  -- DeepPrintTable(keys)
  -- [   VScript              ]:    PlayerID                         = 0 (number)
  -- [   VScript              ]:    index                            = 0 (number)
  -- [   VScript              ]:    userid                           = 1 (number)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
end

function Nobu_Test:OnDisconnect( keys ) --代測試

  DeepPrintTable(keys)
end

function Nobu_Test:OnItemPurchased( keys )
  -- DeepPrintTable(keys)
  -- [   VScript              ]:    itemcost                         = 50 (number)
  -- [   VScript              ]:    itemname                         = "item_tpscroll" (string)
  -- [   VScript              ]:    PlayerID                         = 0 (number)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
end

function Nobu_Test:OnItemPickedUp( keys )
  -- DeepPrintTable(keys)
  -- O 購買物品不會觸發
  -- [   VScript              ]:    itemname                         = "item_invis_sword" (string)
  -- [   VScript              ]:    PlayerID                         = 0 (number)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
  -- [   VScript              ]:    ItemEntityIndex                  = 2529 (number)
  -- [   VScript              ]:    HeroEntityIndex                  = 2548 (number)
end

function Nobu_Test:OnEntityHurt( keys )
  -- DeepPrintTable(keys)
  -- O為甚麼要filter外 還有這個傷害事件
  -- [   VScript              ]:    damagebits                       = 0 (number)
  -- [   VScript              ]:    entindex_killed                  = 2548 (number)
  -- [   VScript              ]:    damage                           = 41.65344619751 (number)
  -- [   VScript              ]:    entindex_attacker                = 306 (number)
  -- [   VScript              ]:    splitscreenplayer                = -1 (number)
end

function Nobu_Test:PlayerConnect( keys )
  --print("Nobu_Test PlayerConnect")
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

function Nobu_Test:PlayerSay( keys ) --代測試

  DeepPrintTable(keys)
end

function Nobu_Test:Item_Changed( keys ) --代測試

  DeepPrintTable(keys)
end

function Nobu_Test:ModifyGoldFilter(filterTable)
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

function Nobu_Test:AbilityTuningValueFilter(filterTable)
  --DeepPrintTable(filterTable)
  -- [   VScript              ]:    value                            = 6 (number)
  -- [   VScript              ]:    entindex_ability_const           = 799 (number)
  -- [   VScript              ]:    value_name_const                 = "A06W_Duration" (string)
  -- [   VScript              ]:    entindex_caster_const            = 798 (number)

  -- [   VScript              ]:    value                            = 5 (number)
  -- [   VScript              ]:    entindex_ability_const           = 786 (number)
  -- [   VScript              ]:    value_name_const                 = "A06R_SPEED" (string)
  -- [   VScript              ]:    entindex_caster_const            = 798 (number)
  --print("Nobu_Test:AbilityTuningValueFilter")
  return true
end

function Nobu_Test:SetItemAddedToInventoryFilter(filterTable)
  --DeepPrintTable(filterTable)
  -- [   VScript ]:    item_entindex_const               = 830 (number)
  -- [   VScript ]:    inventory_parent_entindex_const   = 798 (number)
  -- [   VScript ]:    suggested_slot                    = -1 (number)
  -- [   VScript ]:    item_parent_entindex_const        = -1 (number)
  --print("SetItemAddedToInventoryFilter")
  return true
end

function Nobu_Test:SetModifyExperienceFilter(filterTable)
  -- DeepPrintTable(filterTable)
  -- [   VScript              ]:    reason_const                     = 2 (number)
  -- [   VScript              ]:    experience                       = 120 (number)
  -- [   VScript              ]:    player_id_const                  = 0 (number)

  return true
end

function Nobu_Test:SetTrackingProjectileFilter(filterTable)
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


function Nobu_Test:Attachment_UpdateUnit(args)
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



function Nobu_Test:Chat(keys)
	local s   	   = keys.text
	local id  	   = 1 --keys.userid --BUG:會1.2的調換，不知道為甚麼
	local p 	     = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家
	local caster 	   = p:GetAssignedHero() --获取该玩家的英雄
	local point    = caster:GetAbsOrigin()

	if s == "tlv" then
		--等級
		for i=1,25 do
			caster:HeroLevelUp(false)
			--caster.HeroLevelUp(caster,true)
		end
	end

	--自訂義血量
	if string.match(s,"thp") then
		local hp = tonumber(string.match(s, '%d+'))
		--caster:SetBaseMaxHealth(hp) --false
		_G.TestUnit:SetMaxHealth(hp)
		_G.TestUnit:SetHealth(hp)

		print(hp)
	end

	--自訂義防禦
	--自訂義傷害
	--自訂義魔法抗性
	--自訂義模型大小
	if string.match(s,"tml") then
		local s2 = string.sub(s,4,8)
		local num = tonumber(s2)
		--tonumber(string.match(s,'%f[0~9]'))
		--tonumber(string.match(s, '%d+'))
		print(num)
		_G.TestUnit:SetModelScale(num)
	elseif string.match(s,"ml") then
		local s2 = string.sub(s,3,7)
		local num = tonumber(s2)
		--tonumber(string.match(s,'%f[0~9]'))
		--tonumber(string.match(s, '%d+'))
		print(num)
		caster:SetModelScale(num)
	end


end

--[[ ============================================================================================================
	Author: Rook, with help from some of Pizzalol's SpellLibrary code
	Date: January 25, 2015
	Called when Blink Dagger is cast.  Blinks the caster in the targeted direction.
	Additional parameters: keys.MaxBlinkRange and keys.BlinkRangeClamp
================================================================================================================= ]]
function item_blink_datadriven_on_spell_start(keys)
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.

	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, keys.caster)
	keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")

	local origin_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local difference_vector = target_point - origin_point

	-- if difference_vector:Length2D() > keys.MaxBlinkRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
	-- 	target_point = origin_point + (target_point - origin_point):Normalized() * keys.BlinkRangeClamp
	-- end

	keys.caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(keys.caster, target_point, false)

	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, keys.caster)
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 25, 2015
	Called when a unit with Blink Dagger in their inventory takes damage.  Puts the Blink Dagger on a brief cooldown
	if the damage is nonzero (after reductions) and originated from any player or Roshan.
	Additional parameters: keys.BlinkDamageCooldown and keys.Damage
	Known Bugs: keys.Damage contains the damage before reductions, whereas we want to compare the damage to 0 after reductions.
================================================================================================================= ]]
function modifier_item_blink_datadriven_damage_cooldown_on_take_damage(keys)
	local attacker_name = keys.attacker:GetName()

	if keys.Damage > 0 and (attacker_name == "npc_dota_roshan" or keys.attacker:IsControllableByAnyPlayer()) then  --If the damage was dealt by neutrals or lane creeps, essentially.
		if keys.ability:GetCooldownTimeRemaining() < keys.BlinkDamageCooldown then
			keys.ability:StartCooldown(keys.BlinkDamageCooldown)
		end
	end
end

function test_1()
	--print("lua"..tostring(DOTA_MAX_PLAYERS))
	
	if _G.nobu_debug then
		Timers:CreateTimer(2,function()
			--【測試單位】
			_G.TestUnit = CreateUnitByName("TestUnit_nomagicresist", Vector(0,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
		end)
		Timers:CreateTimer(2,function()

			--【HP/MP滿血】
			for playerID = 0, 10 do
				local id       = playerID
			  local p        = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家

				--print("lua"..tostring(p))

				if p ~= nil and (p: GetAssignedHero()) ~= nil then
				  local caster     = p: GetAssignedHero()
				  local point    = caster:GetAbsOrigin()
				  local owner = caster:GetPlayerOwner()

					GameRules: SendCustomMessage("每20秒 全場狀態回復",DOTA_TEAM_GOODGUYS,0)

					caster:SetMana(caster:GetMaxMana() )
					caster:SetHealth(caster:GetMaxHealth())

					-- Reset cooldown for abilities that is not rearm
					for i = 0, caster:GetAbilityCount() - 1 do
						local ability = caster:GetAbilityByIndex( i )
						if ability  then
							ability:EndCooldown()
						end
					end

					-- Put item exemption in here
					local exempt_table = {}

					-- Reset cooldown for items
					for i = 0, 5 do
						local item = caster:GetItemInSlot( i )
						if item then--if item and not exempt_table( item:GetAbilityName() ) then
							item:EndCooldown()
						end
					end
				end
			end

			return 20
		end)
	end
end


function Nobu_Test:PickHero(keys)
  local id       = keys.player
  local p        = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家
  local caster     = p: GetAssignedHero()
  local point    = caster:GetAbsOrigin()
  local owner = caster:GetPlayerOwner()
  --金錢
  for i=0,9 do
	PlayerResource:SetGold(i,99999,false)--玩家ID需要減一
  end
end

function Test_main(self)

	--【自動系統】
	test_1() --

	-- ListenToGameEvent("player_chat",Nobu.test_chat,self)
	-- print("Lua test main")
	-- print(self)
	-- DeepPrintTable(self)

	--【Filter】
  -- GameRules:GetGameModeEntity():SetExecuteOrderFilter( Nobu_Test.eventfororder, self )
  -- GameRules:GetGameModeEntity():SetDamageFilter( Nobu_Test.DamageFilterEvent, self )
  -- GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(Nobu_Test, "ModifyGoldFilter"), Nobu_Test)
  -- GameRules:GetGameModeEntity():SetAbilityTuningValueFilter(Dynamic_Wrap(Nobu_Test, "AbilityTuningValueFilter"), Nobu_Test)
  -- GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(Nobu_Test, "SetItemAddedToInventoryFilter"), Nobu_Test)  --用来控制物品被放入物品栏时的行为
  -- GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(Nobu_Test, "SetModifyExperienceFilter"), Nobu_Test)  --經驗值
  -- GameRules:GetGameModeEntity():SetTrackingProjectileFilter(Dynamic_Wrap(Nobu_Test, "SetTrackingProjectileFilter"), Nobu_Test)  --投射物

  --【Evnet】
  Nobu_Test.Event ={






  -- ListenToGameEvent('dota_player_gained_level', Nobu_Test.LevelUP, self),
  ListenToGameEvent("dota_player_pick_hero",Nobu_Test.PickHero, self),
  -- ListenToGameEvent('npc_spawned', Nobu_Test.OnHeroIngame, self)  ,
  -- ListenToGameEvent('dota_player_used_ability', Nobu_Test.CountUsedAbility, self)  ,
  -- ListenToGameEvent("entity_killed", Nobu_Test.OnUnitKill, self ),
  ListenToGameEvent("player_chat",Nobu_Test.Chat,self), --玩家對話事件
  -- --ListenToGameEvent( "item_purchased", test, self ) --false
  -- --ListenToGameEvent( "dota_item_used", test, self ) --false
  -- --ListenToGameEvent("dota_inventory_item_changed", Nobu_Test.Item_Changed, self ), --false
  -- ListenToGameEvent("game_rules_state_change", Nobu_Test.OnGameRulesStateChange , self),  --監聽遊戲進度
  -- ListenToGameEvent("dota_player_gained_level", Nobu_Test.LevelUP, self),   --升等事件
  -- ListenToGameEvent('dota_player_learned_ability', Nobu_Test.Learn_Ability, self),  --學習技能
  -- ListenToGameEvent('player_connect_full', Nobu_Test.Connect_Full, self) , --連結完成(遊戲內大廳)
  -- ListenToGameEvent('player_disconnect', Dynamic_Wrap(Nobu_Test, 'OnDisconnect'), self)  ,
  -- ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(Nobu_Test, 'OnItemPurchased'), self) , --購買物品事件
  -- ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(Nobu_Test, 'OnItemPickedUp'), self) ,
  -- ListenToGameEvent('player_changename', Dynamic_Wrap(Nobu_Test, 'OnPlayerChangedName'), self), --?
  -- ListenToGameEvent('player_connect', Dynamic_Wrap(Nobu_Test, 'PlayerConnect'), self), --?
  -- --ListenToGameEvent('player_say', Dynamic_Wrap(Nobu_Test, 'PlayerSay'), self), --?
  -- --ListenToGameEvent('dota_pause_event', Dynamic_Wrap(Nobu_Test, 'Pause'), self), --無效
	--
  -- ListenToGameEvent('entity_hurt', Dynamic_Wrap(Nobu_Test, 'OnEntityHurt'), self) --傷害事件
  }







end
