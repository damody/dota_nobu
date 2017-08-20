
function OnEquip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == nil) then
		caster.nobuorb1 = "spear_of_saddle"
	end
end

function OnUnequip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == "spear_of_saddle") then
		caster.nobuorb1 = nil
	end
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if (string.match(itemName,"spear_of_saddle")) then
				caster.nobuorb1 = "spear_of_saddle"
				break
			end
		end
	end
end

function Shock( keys )
	local caster = keys.caster
	local skill = keys.ability

	if (caster.nobuorb1 == "spear_of_saddle" or caster.nobuorb1 == nil) and not keys.target:IsBuilding() then
		caster.nobuorb1 = "spear_of_saddle"
		if _G.EXCLUDE_TARGET_NAME[keys.target:GetUnitName()] == nil then
			skill:ApplyDataDrivenModifier(caster, keys.target,"modifier_spear_of_saddle",{ duration = 1 })
		end
	end
end

