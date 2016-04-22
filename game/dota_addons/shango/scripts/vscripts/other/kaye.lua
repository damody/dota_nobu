function kaye_start(trigger)
	-- body
	print("enter trigger")
	local nt=trigger.activator
	if nt:GetContext("iswild")==1 then 
		nt:AddAbility("wild_trigger")
		local ability=nt:FindAbilityByName("wild_trigger")
		ability:SetLevel(1)	
	end
end
function kaye_end(trigger)
	-- body
	local nt=trigger.activator
	if nt:GetContext("iswild")==1 then 
		nt:RemoveAbility("wild_trigger")
		if nt:HasModifier("wild_trigger_buff")  then 
		   nt:RemoveModifierByName("wild_trigger_buff")
		end 	
	end
end