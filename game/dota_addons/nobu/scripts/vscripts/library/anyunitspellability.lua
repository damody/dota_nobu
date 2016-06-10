
function anyunitspellability( keys )
	local caster     = keys.caster
	local skill = keys.ability

	--local unit = EntIndexToHScript(f.units["0"]) --单位
	--GameRules: SendCustomMessage(unit:GetUnitName(),0,0)
	--DeepPrintTable(keys)  --多用这个来print各种表，能学会挺多，下面比如什么position_x 都在这个filterTable里，print一下就知道这里面有什么了

	Timers:CreateTimer(0, function()
	    caster:SetMana(caster:GetMaxMana())
	    for abilitySlot=0,15 do
	     local ability = caster:GetAbilityByIndex(abilitySlot)
	     if ability ~= nil then 
	      ability:EndCooldown()
	     end
	    end
	    
	    return 0.1
    end)

	--debug
	--GameRules: SendCustomMessage("Hello World",DOTA_TEAM_GOODGUYS,0)

 end 