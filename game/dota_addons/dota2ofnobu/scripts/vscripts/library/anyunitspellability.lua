function test_of_ability(keys)
	local spell = keys.ability 
	local u  = keys.caster

	spell: EndCooldown()
end

function anyunitspellability( keys )
	local skill = keys.ability



	if skill ~= nil then
		GameRules:SendCustomMessage("是技能",DOTA_TEAM_GOODGUYS,0)
		GameRules:SendCustomMessage(skill:GetAbilityName(),DOTA_TEAM_GOODGUYS,0)
	else
		GameRules:SendCustomMessage("不是技能",DOTA_TEAM_GOODGUYS,0)
	end




 	-- test
 	test_of_ability(keys)
 end 