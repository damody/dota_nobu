
function A06R_OnAttack(keys)
	local caster = keys.caster
	local id  = caster:GetPlayerID()
	local skill = keys.ability
	local level = keys.ability:GetLevel()
	if caster:HasModifier("modifier_A06R_to_A06D") == false then
		skill:ApplyDataDrivenModifier(caster,caster,"modifier_A06R_to_A06D",nil)
		local hModifier = caster:FindModifierByNameAndCaster("modifier_A06R_to_A06D", hCaster)
		hModifier:SetStackCount(1)
	else
		local hModifier = caster:FindModifierByNameAndCaster("modifier_A06R_to_A06D", hCaster)
		local scount = hModifier:GetStackCount()
		scount = scount + 1
		if (scount <= 13) then
			hModifier:SetStackCount(scount)
		end
		if (scount >= 5) then
			local ability = caster:FindAbilityByName("A06D")
			ability:SetLevel(level)
			ability:SetActivated(true)
		end
	end
end

function A06D_Use(keys)
	local caster = keys.caster
	local hModifier = caster:FindModifierByNameAndCaster("modifier_A06R_to_A06D", hCaster)
	hModifier:SetStackCount(hModifier:GetStackCount() - 5)
	if (hModifier:GetStackCount() < 5) then
		caster:FindAbilityByName("A06D"):SetActivated(false)
	end	
end

function A06T_Start(keys)
	local caster = keys.caster
	caster.a06t_count = 0
end

function A06T_Count(keys)
	local caster = keys.caster
	caster.a06t_count = caster.a06t_count + 1
	if caster.a06t_count >= 7 then
		caster.a06t_count = nil
		caster:RemoveModifierByName("modifier_A06T")
	end
end
