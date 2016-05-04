function test_of_ability(keys)
	local spell = keys.ability 
	local u  = keys.caster

	spell: EndCooldown()
end

function anyunitspellability( keys )
	local f     = keys
	local skill = keys.ability
	--local unit = EntIndexToHScript(f.units["0"]) --单位

	--GameRules: SendCustomMessage(unit:GetUnitName(),0,0)
	--DeepPrintTable(keys)  --多用这个来print各种表，能学会挺多，下面比如什么position_x 都在这个filterTable里，print一下就知道这里面有什么了

	GameRules: SendCustomMessage(skill:GetAbilityName(),DOTA_TEAM_GOODGUYS,0)

 	-- test
 	test_of_ability(keys)
 end 