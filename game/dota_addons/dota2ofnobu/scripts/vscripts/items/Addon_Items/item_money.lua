--money
function item_money_OnEquip( keys )
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer(0.1,function ()
		--print("oncreat")
		--print(caster:GetNumItemsInInventory())
		AMHC:GivePlayerGold_UnReliable(caster:GetPlayerOwnerID(), 50)
		for i=0,8 do
			item1=caster:GetItemInSlot(i)
			if item1 and item1:GetAbilityName()=="item_money" then
				--print(item1:GetAbilityName())
				caster:RemoveItem(item1)
			end
		end
	end	)
end
