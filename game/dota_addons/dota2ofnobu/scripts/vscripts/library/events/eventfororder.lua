


require('heroes/B_Unified/B06_Sanada_Yukimura')

--idea test


--已知BUG:沒辦法捕捉非英雄單位order事件
function EventForSpellTarget( filterTable )
	local f = filterTable
	local caster = EntIndexToHScript(f.units["0"]) 
	local ability = EntIndexToHScript(f.entindex_ability) --技能在dota2也是ent
	local target = EntIndexToHScript(f.entindex_target)
	local unitname = caster:GetUnitName()
	local targetname = target:GetUnitName()

	--信村R技能
	if targetname == "npc_dota_hero_elder_titan" then
		local casterplayerNum = caster:GetTeamNumber() --print
		local targetplayerNum = target:GetTeamNumber()
		if casterplayerNum ~= targetplayerNum then --概念:不是一樣ID就是敵方
			if target.B06R_Buff ~=nil and target.B06R_Buff then
				B06R_BeSpelled(target,ability)
			end	
		end
	end 

end

--已知BUG:沒辦法捕捉非英雄單位order事件
function EventForAttackTarget( filterTable )
	local f = filterTable
	local caster = EntIndexToHScript(f.units["0"]) 
	local ability = EntIndexToHScript(f.entindex_ability)
	-- local rate = caster:GetAttackSpeed()
	--print(tostring(rate))

	--播放動畫
    --caster:StartGesture( ACT_SLAM_TRIPMINE_ATTACH )
    -- if rate < 1.00 then
    -- 	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK1,1.00)
    -- else
    -- 	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK1,rate)
    -- end
    -- print("@@ Attack")

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





function Nobu:eventfororder( filterTable )
	local ordertype = filterTable.order_type 
	--print("@@@"..tostring(ordertype))

	if ordertype >= 5 and ordertype <= 9 then
		local f = filterTable
		local caster = EntIndexToHScript(f.units["0"]) 
		local ability = EntIndexToHScript(f.entindex_ability)
		caster.abilityName = ability:GetAbilityName() --用來標記技能名稱
	elseif ordertype == DOTA_UNIT_ORDER_CAST_TARGET then
		EventForSpellTarget( filterTable )
	elseif ordertype == DOTA_UNIT_ORDER_ATTACK_TARGET then
		--test 5.21 更新
		EventForAttackTarget( filterTable )
	elseif ordertype == 10 then	
		--test
		test_of_spell( filterTable )
	end


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