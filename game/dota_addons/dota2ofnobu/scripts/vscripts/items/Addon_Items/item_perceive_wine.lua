
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	
	local count = caster:GetModifierCount()
	for i=count, 1, -1 do
		local modifier = caster:GetModifierNameByIndex(i)
		if (modifier ~= nil and modifier:IsDebuff()) then
			caster:RemoveModifierByName(modifier)
		end
	end
end


