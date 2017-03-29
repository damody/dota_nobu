

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local pos = caster:GetAbsOrigin()
	Timers:CreateTimer(1, function()
		if IsValidEntity(caster) and caster:IsRealHero() then
		caster:SetTimeUntilRespawn(0)
		Timers:CreateTimer(0.3, function()
			caster:SetAbsOrigin(pos)
			AMHC:SetCamera( caster:GetPlayerOwnerID(),caster )
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_invulnerable",{duration = 5})
			caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
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
			end)
		end
		end)
end


