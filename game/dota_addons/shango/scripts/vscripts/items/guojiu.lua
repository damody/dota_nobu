function guojiu_01(keys)
	target=keys.target 
	if target:GetMana()+keys.TotalHealthRegen <= target:GetMaxMana() then
		target:SetMana(target:GetMana()+keys.TotalHealthRegen)
    else 
    	target:SetMana(target:GetMaxMana())
    end
end