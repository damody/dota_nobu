
function judian_enter(trigger)
	-- body
	local nt=trigger.activator
	local ability=nt:FindAbilityByName("toushiche_toushi_2")
	if nt:GetUnitName() ~= "npc_che" then return end
	if not nt:HasAbility("ability_judian_granter") then 
		nt:AddAbility("ability_judian_granter")
	end
    local ability=nt:FindAbilityByName("ability_judian_granter")
    if ability then
       ability:SetLevel(1)
    end
end
function judian_out(trigger)
	-- body
	local nt=trigger.activator
	if nt:GetUnitName() ~= "npc_che" then return end
	if nt:HasAbility("ability_judian_granter") then 
		nt:RemoveAbility("ability_judian_granter")
	end
	if nt:HasModifier("judian_granter_buff") then 
		nt:RemoveModifierByName("judian_granter_buff")
	end
end