



function A25E_Damage( event )
	-- -- Variables
	local damage = event.DamageTaken
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability

	if attacker:IsBuilding() or damage > 45 then
		caster.A25E_Damage_Count = caster.A25E_Damage_Count - 1
	end

	if caster.A25E_Damage_Count <= 0  then
		caster:RemoveModifierByName("modifier_A25E")
	end

	--debug
	--print("傷害值"..tostring(damage))

end

function A25E_Ability_Start( event )
	-- -- Variables
	local caster = event.caster
	local ability = event.ability
	caster.A25E_Damage_Count = (ability:GetLevel() - 1)

	--debug
	--print("抵擋次數"..tostring(caster.A25E_Damage_Count))

end