


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

    DeepPrintTable(filterTable)
end


function eventfororder( filterTable )
	local ordertype = filterTable.order_type 
	print("@@@"..tostring(ordertype))

	if ordertype == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
	elseif ordertype == DOTA_UNIT_ORDER_CAST_TARGET then
		EventForSpellTarget( filterTable )
	elseif ordertype == DOTA_UNIT_ORDER_ATTACK_TARGET then
		--test 5.21 更新
		EventForAttackTarget( filterTable )
	end



	--test 5.15.16 更新
	local f 		 = filterTable
	local caster     = EntIndexToHScript(f.units["0"]) 
	local skill 	 = EntIndexToHScript(f.entindex_ability)

	Timers:CreateTimer(1, 
	function()
		caster:SetMana(caster:GetMaxMana())
		for abilitySlot=0,15 do
			local ability = caster:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				ability:EndCooldown()
			end
		end
		return nil
    end)
end 