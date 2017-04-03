
function item_soul_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		if ability then
			local caster =ability:GetCaster()
			if damage > caster:GetHealth() and caster:GetMana()>=800 and not caster:IsIllusion() then
				caster:StartGestureWithPlaybackRate(ACT_DOTA_DIE,1)
				caster:SetHealth(caster:GetMaxHealth())
				caster:SetHealth(caster:GetMaxMana())
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_the_soul_of_power2",{duration = 3})
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_invulnerable",{duration = 8})
				Timers:CreateTimer(1, function()
					for itemSlot=0,5 do
						local item = caster:GetItemInSlot(itemSlot)
						if item ~= nil then
							local itemName = item:GetName()
							if (itemName == "item_the_soul_of_power") then
								item:Destroy()
								break
							end
						end
					end
					end)
			end
		end
	end
end
