

function Shock( keys )
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	Timers:CreateTimer(1, function()
		caster:SetTimeUntilRespawn(0)
		Timers:CreateTimer(0.1, function()
			caster:SetAbsOrigin(pos)

			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					local itemName = item:GetName()
					if (itemName == "item_the_soul_of_power") then
						item:Destroy()
					end
				end
			end

			end)
		end)
end

