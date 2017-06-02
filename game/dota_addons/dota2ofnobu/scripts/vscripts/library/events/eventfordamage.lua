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
	local caster = EntIndexToHScript(filterTable.entindex_attacker_const)
	local target = EntIndexToHScript(filterTable.entindex_victim_const)
	-- if EntIndexToHScript(filterTable.entindex_victim_const):IsHero() then
	-- 	--local attacker = EntIndexToHScript(filterTable.entindex_attacker_const)
	-- 	local victim = EntIndexToHScript(filterTable.entindex_victim_const)
	-- 	local damagetype_const =  filterTable.damagetype_const
	-- 	--紀錄傷害類型
	-- 	--attacker.damagetype = damagetype_const 
	-- 	victim.damagetype = damagetype_const 
	-- 	--print(victim:GetUnitName())
	-- end 
	if target.isvoid == 1 and caster.attackvoid == nil and filterTable.damagetype_const == DAMAGE_TYPE_PHYSICAL then
		return false
	end
	if caster.attackvoid == 1 and filterTable.damagetype_const == DAMAGE_TYPE_PHYSICAL and not target:IsBuilding() then
		caster.next_attack = {
			victim = target,
			attacker = caster,
			damage = filterTable.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		return false
	end
	if caster.modify_damage then
		filterTable.damage = filterTable.damage*caster.modify_damage
	end
	if caster.illusion_damage and filterTable.damagetype_const ~= DAMAGE_TYPE_PHYSICAL then
		filterTable.damage = filterTable.damage*caster.illusion_damage
	end
	if caster.magic_damage and filterTable.damagetype_const == DAMAGE_TYPE_MAGICAL and not target:IsBuilding() then
		if (caster:GetAbsOrigin()-target:GetAbsOrigin()):Length2D() < 2500 then
			filterTable.damage = filterTable.damage*caster.magic_damage
		end
	end
	if target.A05T then
		if caster.A05T_target == nil then
			if target:HasModifier("modifier_A05E") then
				target:Heal(filterTable.damage*0.5,target:FindAbilityByName("A05E"))
			end
			return false
		end
	end
	if caster.A05T_target and target.A05T == nil then
		filterTable.damage = filterTable.damage * 0.5
	end
	return true 
end