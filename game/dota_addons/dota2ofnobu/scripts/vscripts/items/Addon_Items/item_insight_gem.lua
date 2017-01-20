
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local eff1 = ParticleManager:CreateParticle("particles/b05t3/b05t3_j0.vpcf", PATTACH_ABSORIGIN, keys.caster)
	ParticleManager:SetParticleControl(eff1, 0, caster:GetAbsOrigin())

end


function Death( keys )
	local caster = keys.caster
	local ability = keys.ability
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if (itemName == "item_insight_gem_s") then
				item:Destroy()
			end
		end
	end
end

