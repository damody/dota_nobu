function ability_judian(keys)	
    local target = keys.target_entities   
	for _,_target in pairs(target)  do
   
        local hp = _target:GetHealth()
	    local mp = _target:GetMana()
   
	    if hp ~= _target:GetMaxHealth()  then 
             _target:SetHealth(hp+100)	
        end	 	
        if mp ~= _target:GetMaxMana() then         
             _target:SetMana(mp+50)	
        end 
    end
	return nil 											
end
