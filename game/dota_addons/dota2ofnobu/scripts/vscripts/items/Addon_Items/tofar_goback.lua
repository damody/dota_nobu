LinkLuaModifier("modifier_ninja2", "heroes/modifier_ninja2.lua", LUA_MODIFIER_MOTION_NONE)
		
function choose_16( keys )
	local caster = keys.caster
	local ability = keys.ability
	local nobu_id = _G.heromap[caster:GetName()]
	-- 通知所有玩家該英雄已經變成新版
	GameRules:SendCustomMessage("<font color='#33ff88'>16版 ".._G.hero_name_zh[nobu_id].." 參戰</font>",0,0)
	caster.isnew = true
	caster:SetAbilityPoints(caster:GetLevel())
	caster.version = "16"

	for i = 0, caster:GetAbilityCount() - 1 do
      local ability = caster:GetAbilityByIndex( i )
      if ability  then
        caster:RemoveAbility(ability:GetName())
      end
    end
    local skill = _G.heromap_skill[nobu_id]["16"]
    for si=1,#skill do
      if si == #skill and #skill < 6 then
        caster:AddAbility("attribute_bonusx")
      end
      caster:AddAbility(nobu_id..skill:sub(si,si))
    end
    if #skill >= 6 then
      caster:AddAbility("attribute_bonusx")
    end
    -- 要自動學習的技能
    local askill = _G.heromap_autoskill[nobu_id]["16"]
    for si=1,#askill do
      caster:FindAbilityByName(nobu_id..askill:sub(si,si)):SetLevel(1)
    end
    -- 直江兼續新版要砍普攻距離
    if nobu_id == "B36" and caster:HasModifier("modifier_B36D_old") then
    	caster:RemoveModifierByName("modifier_B36D_old")
    end
    -- 加藤段藏天生技要拿掉
    if nobu_id == "C08" and caster:HasModifier("modifier_C08D_old_duge") then
    	caster:RemoveModifierByName("modifier_C08D_old_duge")
    end
    caster:AddAbility(nobu_id.."_precache"):SetLevel(1)
    for i=1,4 do
    	if caster:HasModifier("modifier_buff_"..i) then
    		caster:AddAbility("buff_"..i):SetLevel(1)
    	end
    end
end

function choose_11( keys )
	local caster = keys.caster
	local ability = keys.ability
	local nobu_id = _G.heromap[caster:GetName()]
	-- 通知所有玩家該英雄已經變成舊版
	GameRules:SendCustomMessage("<font color='#ff3388'>11版 ".._G.hero_name_zh[nobu_id].." 參戰</font>",0,0)

	caster.isold = true
	caster:SetAbilityPoints(caster:GetLevel())
	caster.version = "11"

	-- 拔掉英雄的技能
	for i = 0, caster:GetAbilityCount() - 1 do
		local ability = caster:GetAbilityByIndex( i )
		if ability  then
			caster:RemoveAbility(ability:GetName())
		end
	end
	for i = 0, caster:GetAbilityCount() - 1 do
      local ability = caster:GetAbilityByIndex( i )
      if ability  then
        caster:RemoveAbility(ability:GetName())
      end
    end
    local skill = _G.heromap_skill[nobu_id]["11"]
    for si=1,#skill do
      if si == #skill and #skill < 6 then
        caster:AddAbility("attribute_bonusx")
      end
      caster:AddAbility(nobu_id..skill:sub(si,si).."_old")
    end
    if #skill >= 6 then
      caster:AddAbility("attribute_bonusx")
    end
    -- 要自動學習的技能
    local askill = _G.heromap_autoskill[nobu_id]["11"]
    for si=1,#askill do
      caster:FindAbilityByName(nobu_id..askill:sub(si,si).."_old"):SetLevel(1)
    end
    caster:AddAbility(nobu_id.."_precache"):SetLevel(1)
    for i=1,4 do
    	if caster:HasModifier("modifier_buff_"..i) then
    		caster:AddAbility("buff_"..i):SetLevel(1)
    	end
    end
end

function play_1v1( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster.score == nil then caster.score = 0 end
	caster.score = caster.score + 1
end

function warrior_souls_OnDeath( keys )
	local caster = keys.caster
	local ability = keys.ability
	if (keys.attacker:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
		GameRules: SendCustomMessage("<font color='#ffff00'>織田軍擊殺了武士亡靈並得到黃金</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
	else
		GameRules: SendCustomMessage("<font color='#ffff00'>聯合軍擊殺了武士亡靈並得到黃金</font>", DOTA_TEAM_BADGUYS + DOTA_TEAM_GOODGUYS, 0)
	end
	for playerID=0,9 do
		local player = PlayerResource:GetPlayer(playerID)
        if player then
          local hero = player:GetAssignedHero()
          if hero:GetTeamNumber() == keys.attacker:GetTeamNumber() then
          	AMHC:GivePlayerGold_UnReliable(playerID, 1000)
          end
      	end
	end
end

function robbers_checkfly( keys )
	local caster = keys.caster
	local ability = keys.ability
	if (caster:GetAbsOrigin()-caster.origin_pos):Length2D() > 200 then
		ability:ApplyDataDrivenModifier( caster , caster , "modifier_fly" , { duration = 1 } )
	else
		if caster:GetHealth() == caster:GetMaxHealth() then
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_stunned",{ duration = 1 })
		end
	end
	
end


function robbers_skill( keys )
	local caster = keys.caster
	local ability = keys.ability
	if (keys.attacker:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
		GameRules: SendCustomMessage("<font color='#ffff00'>織田軍得到了強盜王的黃金</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
	else
		GameRules: SendCustomMessage("<font color='#ffff00'>聯合軍得到了強盜王的黃金</font>", DOTA_TEAM_BADGUYS + DOTA_TEAM_GOODGUYS, 0)
	end
	for playerID=0,9 do
		local player = PlayerResource:GetPlayer(playerID)
        if player then
          local hero = player:GetAssignedHero()
          if hero:GetTeamNumber() == keys.attacker:GetTeamNumber() then
          	AMHC:GivePlayerGold_UnReliable(playerID, 600)
          end
      	end
	end
end

function play_on_die( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:StartGestureWithPlaybackRate(ACT_DOTA_DIE,1)
	
	Timers:CreateTimer(2, function ()
		caster:Destroy()
	end)
end

function gold_to_prestige( keys )
	local caster = keys.caster
	local ability = keys.ability
	local add_prestige = 100
	if caster:IsHero() then
		_G.goldprestige[caster:GetTeamNumber()] = _G.goldprestige[caster:GetTeamNumber()] + add_prestige
	end
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

function reward6300(keys)
	local caster = keys.caster
	local ability = keys.ability
	local pos = caster:GetAbsOrigin()
	if caster:IsHero() then
		local dummy = CreateUnitByName("npc_dummy_unit_Ver2",caster.donkey.oripos ,false,caster,caster,caster:GetTeamNumber())	
		ability:ApplyDataDrivenModifier(caster,dummy,"modifier_invulnerable",{duration=60})
		ability:ApplyDataDrivenModifier(caster,dummy,"modifier_kill",{duration=60})
		dummy:AddAbility("reward6300"):SetLevel(1)
		dummy:FindAbilityByName("reward6300"):ApplyDataDrivenModifier(dummy,dummy,"modifier_reward6300_hero_aura",nil)
		dummy:FindAbilityByName("reward6300"):ApplyDataDrivenModifier(dummy,dummy,"modifier_reward6300_aura",nil)
	end
end

function tofar_goback(keys)
	local caster = keys.caster
	Timers:CreateTimer(1, function()
		if caster.pos == nil then
			caster.pos = caster:GetAbsOrigin()
		end
		if IsValidEntity(caster) then
			if (VectorDistance(caster:GetAbsOrigin(), caster.pos) > 1000) then
				local order = {
			 		UnitIndex = caster:entindex(), 
			 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			 		Position = caster.pos, --Optional.  Only used when targeting the ground
			 		Queue = 0 --Optional.  Used for queueing up abilities
			 	}
				ExecuteOrderFromTable(order)
			end
			return 1
		end
		end)
end

Timers:CreateTimer( 3, function()
_G.Unified_pos1 = Entities:FindByName(nil,"chubinluxian_location_of_wl_button"):GetAbsOrigin()
_G.Unified_pos2 = Entities:FindByName(nil,"chubinluxian_location_of_wl_top"):GetAbsOrigin()
_G.Nobu_pos1 = Entities:FindByName(nil,"chubinluxian_location_of_nobu_button"):GetAbsOrigin()
_G.Nobu_pos2 = Entities:FindByName(nil,"chubinluxian_location_of_nobu_top"):GetAbsOrigin()
end)

function patrol_Unified(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()

	if caster.isgo then
		caster.isgo = nil
		ExecuteOrderFromTable( { UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = _G.Unified_pos1 })
	else
		caster.isgo = 1
		ExecuteOrderFromTable( { UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = _G.Unified_pos2 })
	end
end

function patrol_Nobu(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()

	if caster.isgo then
		caster.isgo = nil
		ExecuteOrderFromTable( { UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = _G.Nobu_pos1 })
	else
		caster.isgo = 1
		ExecuteOrderFromTable( { UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = _G.Nobu_pos2 })
	end
end

function attack_building(keys)
	if IsServer() then
		local caster = keys.caster
		local pos = caster:GetAbsOrigin()

		Timers:CreateTimer(3, function()
			if IsValidEntity(caster) then
				local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
					nil,  700 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC,
					DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
				local com_general = nil
				for _,it in pairs(group) do
			    	if it:GetUnitName() == "com_general" then
			    		com_general = it
			    	end
			    end
			    if com_general then
			    	caster:SetForceAttackTarget(group[1])
			    else
					local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
						nil,  700 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING,
						DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
					if #group > 0 then
						caster:SetForceAttackTarget(group[1])
					else
						caster:SetForceAttackTarget(nil)
					end
				end
				return 3
			end
			end)
	end
end


function dead_destroy(keys)
	local caster = keys.caster
	caster:Destroy()
end

function dead_give_item(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	print("keys.item "..keys.item)
	local item = CreateItem(keys.item,nil, nil)
	CreateItemOnPositionSync(pos+RandomVector(100), item)
end

function near_hero_then_can_use_ability(keys)
	local caster = keys.caster
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  500 , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

	for abilitySlot=0,15 do
        local ability = caster:GetAbilityByIndex(abilitySlot)
        if ability ~= nil then
          local abilityLevel = ability:GetLevel()
          local abilityName = ability:GetAbilityName()
          if abilityName ~= "near_hero_then_can_use_ability" then
          	if #group > 0 then
          		ability:SetActivated(true)
          	else
          		ability:SetActivated(false)
          	end
          end
        end
    end

    for _,it in pairs(group) do
    	caster.buyer = it
    	caster:SetOwner(caster.buyer)
    	--print("caster.buyer "..it:GetUnitName())
    	break
    end

end

function update_buy_ninja3(keys)
	local caster = keys.caster.owner
	if caster.buy_ninja3 then
		caster.buy_ninja3 = caster.buy_ninja3 - 1
	end
end

function call_ninja3_OnAbilityPhaseStart(keys)
	local caster = keys.caster
	if caster.buyer.buy_ninja3 == nil then caster.buyer.buy_ninja3 = 0 end
	if caster.buyer.buy_ninja3 >= 15 then
		caster:Interrupt()
	else
		caster.buyer.buy_ninja3 = caster.buyer.buy_ninja3 + 1
	end
end

function update_buy_ninja1(keys)
	local caster = keys.caster.owner
	if caster.buy_ninja1 then
		caster.buy_ninja1 = caster.buy_ninja1 - 1
	end
end

function call_ninja1_OnAbilityPhaseStart(keys)
	local caster = keys.caster
	if caster.buyer.buy_ninja1 == nil then caster.buyer.buy_ninja1 = 0 end
	if caster.buyer.buy_ninja1 >= 4 then
		caster:Interrupt()
	else
		caster.buyer.buy_ninja1 = caster.buyer.buy_ninja1 + 1
	end
end

function call_ninja1(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	local donkey = CreateUnitByName("ninja_unit1", caster:GetAbsOrigin() + Vector(50, 100, 0), true, caster, caster, caster:GetTeamNumber())
    donkey:SetOwner(caster.buyer)
    donkey.owner = caster.buyer
    donkey:SetControllableByPlayer(caster.buyer:GetPlayerOwnerID(), true)
    donkey:AddNewModifier(donkey,ability,"modifier_phased",{duration=0.1})
end

function call_ninja2(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	local donkey = CreateUnitByName("ninja_unit2", caster:GetAbsOrigin() + Vector(50, 100, 0), true, caster, caster, caster:GetTeamNumber())
    donkey:SetOwner(caster.buyer)
    donkey.owner = caster.buyer
    donkey:SetControllableByPlayer(caster.buyer:GetPlayerOwnerID(), true)
    donkey:AddNewModifier(donkey,ability,"modifier_phased",{duration=0.1})
    donkey:FindAbilityByName("ninja_hole"):SetLevel(1)
end

function call_ninja3(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	local donkey = CreateUnitByName("ninja_unit3", caster:GetAbsOrigin() + Vector(50, 100, 0), true, caster, caster, caster:GetTeamNumber())
    donkey:SetOwner(caster.buyer)
    donkey.owner = caster.buyer
    donkey:SetControllableByPlayer(caster.buyer:GetPlayerOwnerID(), true)
    donkey:AddNewModifier(donkey,ability,"modifier_phased",{duration=0.1})
end

function ninja_hole_start(keys)
	local caster = keys.caster
    caster:AddNewModifier(donkey,ability,"modifier_ninja2",{})
end

function ninja_hole_end(keys)
	local caster = keys.caster
    caster:RemoveModifierByName("modifier_ninja2")
end

function warrior_souls_OnAttackLanded(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	target:SetMana(0)
end

function afk_gogo(keys)
	for _,hero in ipairs(HeroList:GetAllHeroes()) do
		local id = hero:GetPlayerID()
		local team = PlayerResource:GetTeam(id)
		local state = PlayerResource:GetConnectionState(id)
		if state == 3 then -- 2 = connected
			if hero.donkey ~= nil then
				hero.donkey:SetAbsOrigin(Vector(99999,99999,0))
   				if hero.stop == nil then
   					hero.stop = 1
   				else
   					hero.stop = hero.stop + 1
   					if hero.stop > 3 then
		   				hero:SetAbsOrigin(Vector(99999,99999,0))
		   			end
		   			hero:Stop()
   				end
   			end
   			hero:AddNewModifier(nil, nil, 'modifier_stunned', {duration=1.5})
   		elseif state == 2 then
   			if hero.stop ~= nil then
   				hero.stop = nil
   				hero.donkey:SetAbsOrigin(hero.donkey.oripos)
   				hero:RemoveModifierByName("modifier_stunned")
   				FindClearSpaceForUnit(hero,hero.donkey.oripos+Vector(100,100,0),true)
   			end
   			if hero:GetAbsOrigin().x > 90000 then
   				FindClearSpaceForUnit(hero,hero.donkey.oripos+Vector(100,100,0),true)
   			end
   			if hero.donkey ~= nil and hero.donkey:GetAbsOrigin().x > 90000 then
   				FindClearSpaceForUnit(hero.donkey,hero.donkey.oripos,true)
   			end
		end
	end
end

