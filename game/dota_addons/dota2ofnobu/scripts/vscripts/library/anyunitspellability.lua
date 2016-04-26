function test_of_ability(keys)
	local spell = keys.ability 
	local u  = keys.caster

	spell: EndCooldown()
end

function anyunitspellability( keys )






 	-- test
 	GameRules:SendCustomMessage("清CD",DOTA_TEAM_GOODGUYS,0)
 	test_of_ability(keys)
 end 