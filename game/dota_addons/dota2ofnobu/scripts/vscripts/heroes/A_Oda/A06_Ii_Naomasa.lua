--global
	A06E_B = {}

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
		if (scount <= 15) then
			hModifier:SetStackCount(scount)
		end
		if (scount >= 5) then
			local ability = caster:FindAbilityByName("A06D")
			ability:SetLevel(level)
			ability:SetActivated(true)
		end
	end
	
	A06E_B[id] = true
end

function A06D_Use(keys)
	local caster = keys.caster
	local hModifier = caster:FindModifierByNameAndCaster("modifier_A06R_to_A06D", hCaster)
	hModifier:SetStackCount(hModifier:GetStackCount() - 5)
	if (hModifier:GetStackCount() < 5) then
		caster:FindAbilityByName("A06D"):SetActivated(false)
	end	
end

