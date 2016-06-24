function Nobu:DamageFilterEvent( filterTable )
	 --DeepPrintTable(filterTable) 

	-- [   VScript                ]: {
	-- [   VScript                ]:    damagetype_const                	= 1 (number)
	-- [   VScript                ]:    damage                          	= 113.23529815674 (number)
	-- [   VScript                ]:    entindex_attacker_const         	= 232 (number)
	-- [   VScript                ]:    entindex_victim_const           	= 366 (number)
	-- [   VScript                ]: }


	-- [   VScript                ]: {
	-- [   VScript                ]:    entindex_inflictor_const        	= 182 (number)
	-- [   VScript                ]:    entindex_victim_const           	= 366 (number)
	-- [   VScript                ]:    damage                          	= 157.03125 (number)
	-- [   VScript                ]:    entindex_attacker_const         	= 232 (number)
	-- [   VScript                ]:    damagetype_const                	= 2 (number)
	-- [   VScript                ]: }
	if EntIndexToHScript(filterTable.entindex_victim_const):IsHero() then
		--local attacker = EntIndexToHScript(filterTable.entindex_attacker_const)
		local victim = EntIndexToHScript(filterTable.entindex_victim_const)
		local damagetype_const =  filterTable.damagetype_const
		--紀錄傷害類型
		--attacker.damagetype = damagetype_const 
		victim.damagetype = damagetype_const 
		--print(victim:GetUnitName())
	end 
	return true 
end