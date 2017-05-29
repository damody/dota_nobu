require('libraries/containers')
--idea test


--已知BUG:沒辦法捕捉非英雄單位order事件
function EventForSpellTarget( filterTable )
	local f = filterTable
	local caster = EntIndexToHScript(f.units["0"])
	local ability = EntIndexToHScript(f.entindex_ability) --技能在dota2也是ent
	local target = EntIndexToHScript(f.entindex_target)
	local unitname = caster:GetUnitName()
	local targetname = target:GetUnitName()


end

--已知BUG:沒辦法捕捉非英雄單位order事件
function EventForAttackTarget( filterTable )
	local f = filterTable
	local caster = EntIndexToHScript(f.units["0"])
	local ability = EntIndexToHScript(f.entindex_ability)
	local target = EntIndexToHScript( f.entindex_target )
	if not IsValidEntity(caster) or not IsValidEntity(target) then return false end
	if caster:GetTeamNumber() == target:GetTeamNumber() then
		return false
	end
	return true

	 --    DeepPrintTable(filterTable)
	 --    [   VScript                ]: {
	-- [   VScript                ]:    entindex_ability                	= 0 (number)
	-- [   VScript                ]:    sequence_number_const           	= 13 (number)
	-- [   VScript                ]:    queue                           	= 0 (number)
	-- [   VScript                ]:    units                           	= table: 0x039c9948 (table)
	-- [   VScript                ]:    {
	-- [   VScript                ]:       0                               	= 331 (number)
	-- [   VScript                ]:    }
	-- [   VScript                ]:    entindex_target                 	= 444 (number)
	-- [   VScript                ]:    position_z                      	= 0 (number)
	-- [   VScript                ]:    position_x                      	= 0 (number)
	-- [   VScript                ]:    order_type                      	= 4 (number)
	-- [   VScript                ]:    position_y                      	= 0 (number)
	-- [   VScript                ]:    issuer_player_id_const          	= 0 (number)
	-- [   VScript                ]: }
end






function test_of_spell( filterTable )
	local f = filterTable
	local keys = f
	local caster = EntIndexToHScript(f.units["0"])

	-- Reset cooldown for abilities that is not rearm
	for i = 0, caster:GetAbilityCount() - 1 do
		local ability = caster:GetAbilityByIndex( i )
		if ability and ability ~= EntIndexToHScript(f.units["0"]) then
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

	caster:SetMana(caster:GetMaxMana())
end
function DumpTable( tTable )
	local inspect = require('inspect')
	local iDepth = 2
 	print(inspect(tTable,
 		{depth=iDepth} 
 	))
end

function spell_ability ( filterTable )
	local f = filterTable
	local ordertype = filterTable.order_type
	local caster = EntIndexToHScript(f.units["0"])
	local ability = EntIndexToHScript(f.entindex_ability)
	if (caster:GetUnitName() == "npc_dota_courier2") 
		and not string.match(ability:GetName(), "courier") then
		return false
	end
	if ability and ability:GetName() == "item_napalm_bomb" and _G.can_bomb == nil then
		return false
	end
	if ability then
		caster.abilityName = ability:GetAbilityName() --用來標記技能名稱
	end
	if ordertype == DOTA_UNIT_ORDER_CAST_POSITION then --5
		-- [   VScript             ]: {
		-- [   VScript             ]:    entindex_ability                	= 461 (number)
		-- [   VScript             ]:    sequence_number_const           	= 25 (number)
		-- [   VScript             ]:    queue                           	= 0 (number)
		-- [   VScript             ]:    units                           	= table: 0x0399cdb8 (table)
		-- [   VScript             ]:    {
		-- [   VScript             ]:       0                               	= 451 (number)
		-- [   VScript             ]:    }
		-- [   VScript             ]:    entindex_target                 	= 0 (number)
		-- [   VScript             ]:    position_z                      	= 128 (number)
		-- [   VScript             ]:    position_x                      	= 6182.5732421875 (number)
		-- [   VScript             ]:    order_type                      	= 5 (number)
		-- [   VScript             ]:    position_y                      	= -6421.2026367188 (number)
		-- [   VScript             ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript             ]: }
		if filterTable.units and filterTable.units["0"] then
			local unit = EntIndexToHScript(filterTable.units["0"])
			if IsValidEntity(unit) then
				local itemID = filterTable.entindex_ability
    			local itemName = Containers.itemIDs[itemID]
				if unit:GetUnitName() == "B07E_UNIT" and itemName == "item_napalm_bomb" then
					return false
				end
			end
		end
	elseif ordertype == DOTA_UNIT_ORDER_CAST_TARGET then --6
		-- [   VScript             ]: {
		-- [   VScript             ]:    entindex_ability                	= 453 (number)
		-- [   VScript             ]:    sequence_number_const           	= 34 (number)
		-- [   VScript             ]:    queue                           	= 0 (number)
		-- [   VScript             ]:    units                           	= table: 0x03966540 (table)
		-- [   VScript             ]:    {
		-- [   VScript             ]:       0                               	= 451 (number)
		-- [   VScript             ]:    }
		-- [   VScript             ]:    entindex_target                 	= 429 (number)
		-- [   VScript             ]:    position_z                      	= 0 (number)
		-- [   VScript             ]:    position_x                      	= 0 (number)
		-- [   VScript             ]:    order_type                      	= 6 (number)
		-- [   VScript             ]:    position_y                      	= 0 (number)
		-- [   VScript             ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript             ]: }
	elseif ordertype == DOTA_UNIT_ORDER_CAST_TARGET_TREE then -- 7
	elseif ordertype == DOTA_UNIT_ORDER_CAST_NO_TARGET then -- 8
		-- [   VScript              ]: {
		-- [   VScript              ]:    entindex_ability                	= 333 (number)
		-- [   VScript              ]:    sequence_number_const           	= 8 (number)
		-- [   VScript              ]:    queue                           	= 0 (number)
		-- [   VScript              ]:    units                           	= table: 0x03e04d18 (table)
		-- [   VScript              ]:    {
		-- [   VScript              ]:       0                               	= 332 (number)
		-- [   VScript              ]:    }
		-- [   VScript              ]:    entindex_target                 	= 0 (number)
		-- [   VScript              ]:    position_z                      	= 0 (number)
		-- [   VScript              ]:    position_x                      	= 0 (number)
		-- [   VScript              ]:    order_type                      	= 8 (number)
		-- [   VScript              ]:    position_y                      	= 0 (number)
		-- [   VScript              ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript              ]: }
		-- [   VScript              ]: Spell hahahhaa   :8

	elseif ordertype == DOTA_UNIT_ORDER_CAST_TOGGLE then -- 9
	end
	return true
end

--[[
	發現:
	O命令取第一時間
]]
function Nobu:eventfororder( filterTable )
	--DeepPrintTable(filterTable)
	--print("ordertype = "..tostring(ordertype))
	--瑞龍院日秀 偽情報
	if filterTable.units and filterTable.units["0"] then
		local unit = EntIndexToHScript(filterTable.units["0"])
		if IsValidEntity(unit) and unit.A21T then
			return false
		end
	end

	local ordertype = filterTable.order_type
	if ordertype == DOTA_UNIT_ORDER_MOVE_TO_POSITION then --1

	elseif ordertype == DOTA_UNIT_ORDER_MOVE_TO_TARGET then --2
		-- [   VScript       ]: {
		-- [   VScript       ]:    entindex_ability                	= 0 (number)
		-- [   VScript       ]:    sequence_number_const           	= 12 (number)
		-- [   VScript       ]:    queue                           	= 0 (number)
		-- [   VScript       ]:    units                           	= table: 0x03940710 (table)
		-- [   VScript       ]:    {
		-- [   VScript       ]:       0                               	= 336 (number)
		-- [   VScript       ]:    }
		-- [   VScript       ]:    entindex_target                 	= 154 (number)
		-- [   VScript       ]:    position_z                      	= 0 (number)
		-- [   VScript       ]:    position_x                      	= 0 (number)
		-- [   VScript       ]:    order_type                      	= 2 (number)
		-- [   VScript       ]:    position_y                      	= 0 (number)
		-- [   VScript       ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript       ]: }
	elseif ordertype == DOTA_UNIT_ORDER_ATTACK_MOVE then --3
		-- [   VScript       ]: ordertype = 3
		-- [   VScript       ]: {
		-- [   VScript       ]:    entindex_ability                	= 0 (number)
		-- [   VScript       ]:    sequence_number_const           	= 15 (number)
		-- [   VScript       ]:    queue                           	= 0 (number)
		-- [   VScript       ]:    units                           	= table: 0x039c5f00 (table)
		-- [   VScript       ]:    {
		-- [   VScript       ]:       0                               	= 336 (number)
		-- [   VScript       ]:    }
		-- [   VScript       ]:    entindex_target                 	= 0 (number)
		-- [   VScript       ]:    position_z                      	= 128 (number)
		-- [   VScript       ]:    position_x                      	= 2176 (number)
		-- [   VScript       ]:    order_type                      	= 3 (number)
		-- [   VScript       ]:    position_y                      	= -5990.3994140625 (number)
		-- [   VScript       ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript       ]: }
	elseif ordertype == DOTA_UNIT_ORDER_ATTACK_TARGET then --4
		return EventForAttackTarget(filterTable)
		-- [   VScript       ]: ordertype = 4
		-- [   VScript       ]: {
		-- [   VScript       ]:    entindex_ability                	= 0 (number)
		-- [   VScript       ]:    sequence_number_const           	= 13 (number)
		-- [   VScript       ]:    queue                           	= 0 (number)
		-- [   VScript       ]:    units                           	= table: 0x03998c90 (table)
		-- [   VScript       ]:    {
		-- [   VScript       ]:       0                               	= 336 (number)
		-- [   VScript       ]:    }
		-- [   VScript       ]:    entindex_target                 	= 85 (number)
		-- [   VScript       ]:    position_z                      	= 0 (number)
		-- [   VScript       ]:    position_x                      	= 0 (number)
		-- [   VScript       ]:    order_type                      	= 4 (number)
		-- [   VScript       ]:    position_y                      	= 0 (number)
		-- [   VScript       ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript       ]: }
	elseif ordertype >= 5 and ordertype <= 9 then --技能類
		return spell_ability(filterTable)
	elseif ordertype == DOTA_UNIT_ORDER_HOLD_POSITION then --10
		if _G.nobu_debug then
			test_of_spell( filterTable )
		end
		-- DeepPrintTable(filterTable)
		-- [   VScript              ]: {
		-- [   VScript              ]:    entindex_ability                	= 0 (number)
		-- [   VScript              ]:    sequence_number_const           	= 1 (number)
		-- [   VScript              ]:    queue                           	= 0 (number)
		-- [   VScript              ]:    units                           	= table: 0x03e04118 (table)
		-- [   VScript              ]:    {
		-- [   VScript              ]:       0                               	= 144 (number)
		-- [   VScript              ]:    }
		-- [   VScript              ]:    entindex_target                 	= 0 (number)
		-- [   VScript              ]:    position_z                      	= 0 (number)
		-- [   VScript              ]:    position_x                      	= 0 (number)
		-- [   VScript              ]:    order_type                      	= 10 (number)
		-- [   VScript              ]:    position_y                      	= 0 (number)
		-- [   VScript              ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript              ]: }
	elseif ordertype == DOTA_UNIT_ORDER_TRAIN_ABILITY then --11 --學習技能
		-- DeepPrintTable(filterTable)
		-- [   VScript              ]: {
		-- [   VScript              ]:    entindex_ability                	= 415 (number)
		-- [   VScript              ]:    sequence_number_const           	= 1 (number)
		-- [   VScript              ]:    queue                           	= 0 (number)
		-- [   VScript              ]:    units                           	= table: 0x03f03520 (table)
		-- [   VScript              ]:    {
		-- [   VScript              ]:       0                               	= 414 (number)
		-- [   VScript              ]:    }
		-- [   VScript              ]:    entindex_target                 	= 0 (number)
		-- [   VScript              ]:    position_z                      	= 0 (number)
		-- [   VScript              ]:    position_x                      	= 0 (number)
		-- [   VScript              ]:    order_type                      	= 11 (number)
		-- [   VScript              ]:    position_y                      	= 0 (number)
		-- [   VScript              ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript              ]: }
	elseif ordertype == DOTA_UNIT_ORDER_DROP_ITEM then --12
		if filterTable.units and filterTable.units["0"] then
			local unit = EntIndexToHScript(filterTable.units["0"])
			if IsValidEntity(unit) then
				if unit.B23T_old then
					return false
				end
				if unit:GetUnitName() == "B07E_UNIT" then
					return false
				end
			end
		end
		-- DeepPrintTable(filterTable)
		-- [   VScript              ]: {
		-- [   VScript              ]:    entindex_ability                	= 212 (number)
		-- [   VScript              ]:    sequence_number_const           	= 7 (number)
		-- [   VScript              ]:    queue                           	= 0 (number)
		-- [   VScript              ]:    units                           	= table: 0x039caa50 (table)
		-- [   VScript              ]:    {
		-- [   VScript              ]:       0                               	= 286 (number)
		-- [   VScript              ]:    }
		-- [   VScript              ]:    entindex_target                 	= 0 (number)
		-- [   VScript              ]:    position_z                      	= 128 (number)
		-- [   VScript              ]:    position_x                      	= 6905.3413085938 (number)
		-- [   VScript              ]:    order_type                      	= 12 (number)
		-- [   VScript              ]:    position_y                      	= -7083.51171875 (number)
		-- [   VScript              ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript              ]: }
	elseif ordertype == DOTA_UNIT_ORDER_GIVE_ITEM then --13
		if filterTable.units and filterTable.units["0"] then
			local unit = EntIndexToHScript(filterTable.units["0"])
			if IsValidEntity(unit) then
				if unit.B23T_old then
					return false
				end
				if unit:GetUnitName() == "B07E_UNIT" then
					return false
				end
			end
		end
	elseif ordertype == DOTA_UNIT_ORDER_PICKUP_ITEM then --14
		if filterTable.units and filterTable.units["0"] then
			local unit = EntIndexToHScript(filterTable.units["0"])
			if IsValidEntity(unit) then
				if unit.B23T_old then
					return false
				end
				if unit:GetUnitName() == "B07E_UNIT" then
					return false
				end
			end
		end
		--[[DeepPrintTable(filterTable)
		local f = filterTable
		local caster = EntIndexToHScript(f.units["0"])
		local target = EntIndexToHScript(f.entindex_target)
		local itemID = filterTable.entindex_target
    	local itemName = Containers.itemIDs[itemID]
		--local unitname = caster:GetUnitName()
		--print(unitname)
		--print(target:GetUnitName())
		--print(target:GetAbilityName())
		--print(itemName:GetAbilityName())
		--local ability = EntIndexToHScript(filterTable.entindex_ability)
		--print(ability:GetAbilityName())
		]]--AMHC:Damage(caster,caster,400,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		
	elseif ordertype == DOTA_UNIT_ORDER_PICKUP_RUNE then --15
	elseif ordertype == DOTA_UNIT_ORDER_PURCHASE_ITEM then --16
		local itemID = filterTable.entindex_ability
    	local itemName = Containers.itemIDs[itemID]
    	if filterTable.units and filterTable.units["0"] then
			local unit = EntIndexToHScript(filterTable.units["0"])
			if IsValidEntity(unit) then
				if unit.B23T_old then
					return false
				end
				if unit:GetUnitName() == "B07E_UNIT" then
					return false
				end
			end
		end
    	if filterTable.units ~= nil and filterTable.units["0"] ~= nil then
	    	local unit = EntIndexToHScript(filterTable.units["0"])
	    	if itemName == "item_c06e" or itemName == "item_the_soul_of_power" or string.match(itemName, "_new") then
	    		return false
	    	end
	    	itemName = itemName.."_buy"
	    	if _G.CountUsedAbility_Table == nil then
	    		_G.CountUsedAbility_Table = {}
	    	end
	    	if _G.CountUsedAbility_Table[unit:GetPlayerOwnerID()+1] == nil then
	    		_G.CountUsedAbility_Table[unit:GetPlayerOwnerID()+1] = {}
	    	end
	    	if _G.CountUsedAbility_Table[unit:GetPlayerOwnerID()+1][itemName] == nil then
	    		_G.CountUsedAbility_Table[unit:GetPlayerOwnerID()+1][itemName] = 1
	    	else
	    		_G.CountUsedAbility_Table[unit:GetPlayerOwnerID()+1][itemName] = _G.CountUsedAbility_Table[unit:GetPlayerOwnerID()+1][itemName] + 1
			end
		end
		--print(DeepPrintTable(_G.CountUsedAbility_Table))
	elseif ordertype == DOTA_UNIT_ORDER_SELL_ITEM then --17
		if filterTable.units and filterTable.units["0"] then
			local item = EntIndexToHScript(filterTable.entindex_ability)
			local unit = EntIndexToHScript(filterTable.units["0"])
			local itemcost = item:GetCost()
			Timers:CreateTimer(0.1, function()
				if _G.hardcore then 
					AMHC:GivePlayerGold_UnReliable(unit:GetPlayerOwnerID(), -0.2*itemcost)
				else
					AMHC:GivePlayerGold_UnReliable(unit:GetPlayerOwnerID(), -0.1*itemcost)
				end
			end)
			if IsValidEntity(unit) then
				if unit.B23T_old then
					return false
				end
				if unit:GetUnitName() == "B07E_UNIT" then
					return false
				end
			end
		end
		
	elseif ordertype == DOTA_UNIT_ORDER_DISASSEMBLE_ITEM then --18
	elseif ordertype == DOTA_UNIT_ORDER_MOVE_ITEM	 then --19
		if filterTable.units and filterTable.units["0"] then
			local unit = EntIndexToHScript(filterTable.units["0"])
			if IsValidEntity(unit)  then
				if unit.B23T_old then
					return false
				end
				if unit:GetUnitName() == "B07E_UNIT" then
					return false
				end
			end
		end
	elseif ordertype == DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO	 then --20
	elseif ordertype == DOTA_UNIT_ORDER_STOP	 then --21 --出生時會有三次

	elseif ordertype == DOTA_UNIT_ORDER_TAUNT	 then --22
	elseif ordertype == DOTA_UNIT_ORDER_BUYBACK	 then --23
	elseif ordertype == DOTA_UNIT_ORDER_GLYPH	 then --24
		return false
	elseif ordertype == DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH	 then --25
	elseif ordertype == DOTA_UNIT_ORDER_CAST_RUNE	 then --26
	elseif ordertype == 31	 then --24
		return false
	elseif ordertype ==	33	 then --案s一開始
		-- DeepPrintTable(filterTable)
		-- [   VScript              ]: {
		-- [   VScript              ]:    entindex_ability                	= 0 (number)
		-- [   VScript              ]:    sequence_number_const           	= 2 (number)
		-- [   VScript              ]:    queue                           	= 0 (number)
		-- [   VScript              ]:    units                           	= table: 0x039c7768 (table)
		-- [   VScript              ]:    {
		-- [   VScript              ]:       0                               	= 1283 (number)
		-- [   VScript              ]:    }
		-- [   VScript              ]:    entindex_target                 	= 0 (number)
		-- [   VScript              ]:    position_z                      	= 0 (number)
		-- [   VScript              ]:    position_x                      	= 0 (number)
		-- [   VScript              ]:    order_type                      	= 33 (number)
		-- [   VScript              ]:    position_y                      	= 0 (number)
		-- [   VScript              ]:    issuer_player_id_const          	= 0 (number)
		-- [   VScript              ]: }
	end

	-- DOTA_UNIT_ORDER_NONE	0
	-- DOTA_UNIT_ORDER_MOVE_TO_POSITION	1
	-- DOTA_UNIT_ORDER_MOVE_TO_TARGET	2
	-- DOTA_UNIT_ORDER_ATTACK_MOVE	3
	-- DOTA_UNIT_ORDER_ATTACK_TARGET	4
	-- DOTA_UNIT_ORDER_CAST_POSITION	5
	-- DOTA_UNIT_ORDER_CAST_TARGET	6
	-- DOTA_UNIT_ORDER_CAST_TARGET_TREE	7
	-- DOTA_UNIT_ORDER_CAST_NO_TARGET	8
	-- DOTA_UNIT_ORDER_CAST_TOGGLE	9
	-- DOTA_UNIT_ORDER_HOLD_POSITION	10
	-- DOTA_UNIT_ORDER_TRAIN_ABILITY	11
	-- DOTA_UNIT_ORDER_DROP_ITEM	12
	-- DOTA_UNIT_ORDER_GIVE_ITEM	13
	-- DOTA_UNIT_ORDER_PICKUP_ITEM	14
	-- DOTA_UNIT_ORDER_PICKUP_RUNE	15
	-- DOTA_UNIT_ORDER_PURCHASE_ITEM	16
	-- DOTA_UNIT_ORDER_SELL_ITEM	17
	-- DOTA_UNIT_ORDER_DISASSEMBLE_ITEM	18
	-- DOTA_UNIT_ORDER_MOVE_ITEM	19
	-- DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO	20
	-- DOTA_UNIT_ORDER_STOP	21
	-- DOTA_UNIT_ORDER_TAUNT	22
	-- DOTA_UNIT_ORDER_BUYBACK	23
	-- DOTA_UNIT_ORDER_GLYPH	24
	-- DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH	25
	-- DOTA_UNIT_ORDER_CAST_RUNE	26
	return true
end


-- DOTA_UNIT_ORDERS
-- Name	Value	Description
-- DOTA_UNIT_ORDER_NONE	0
-- DOTA_UNIT_ORDER_MOVE_TO_POSITION	1
-- DOTA_UNIT_ORDER_MOVE_TO_TARGET	2
-- DOTA_UNIT_ORDER_ATTACK_MOVE	3
-- DOTA_UNIT_ORDER_ATTACK_TARGET	4
-- DOTA_UNIT_ORDER_CAST_POSITION	5
-- DOTA_UNIT_ORDER_CAST_TARGET	6
-- DOTA_UNIT_ORDER_CAST_TARGET_TREE	7
-- DOTA_UNIT_ORDER_CAST_NO_TARGET	8
-- DOTA_UNIT_ORDER_CAST_TOGGLE	9
-- DOTA_UNIT_ORDER_HOLD_POSITION	10
-- DOTA_UNIT_ORDER_TRAIN_ABILITY	11
-- DOTA_UNIT_ORDER_DROP_ITEM	12
-- DOTA_UNIT_ORDER_GIVE_ITEM	13
-- DOTA_UNIT_ORDER_PICKUP_ITEM	14
-- DOTA_UNIT_ORDER_PICKUP_RUNE	15
-- DOTA_UNIT_ORDER_PURCHASE_ITEM	16
-- DOTA_UNIT_ORDER_SELL_ITEM	17
-- DOTA_UNIT_ORDER_DISASSEMBLE_ITEM	18
-- DOTA_UNIT_ORDER_MOVE_ITEM	19
-- DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO	20
-- DOTA_UNIT_ORDER_STOP	21
-- DOTA_UNIT_ORDER_TAUNT	22
-- DOTA_UNIT_ORDER_BUYBACK	23
-- DOTA_UNIT_ORDER_GLYPH	24
-- DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH	25
-- DOTA_UNIT_ORDER_CAST_RUNE	26
