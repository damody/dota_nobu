

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local pos = caster:GetAbsOrigin()
	Timers:CreateTimer(1, function()
		if IsValidEntity(caster) and caster:IsRealHero() then
		caster:SetTimeUntilRespawn(0)
		Timers:CreateTimer(0.3, function()
			caster:SetAbsOrigin(pos)
			caster:AddAbility("for_no_damage"):SetLevel(1)
			Timers:CreateTimer(5, function()
				caster:RemoveAbility("for_no_damage")
				caster:RemoveModifierByName("modifier_for_no_damage")
				end)
			caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
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
		end)
end


