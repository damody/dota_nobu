--money
function item_money_OnEquip( keys )
	local caster = keys.caster
	local ability = keys.ability
	AMHC:GivePlayerGold_UnReliable(caster:GetPlayerOwnerID(), 50)
	--print("test2")
end
