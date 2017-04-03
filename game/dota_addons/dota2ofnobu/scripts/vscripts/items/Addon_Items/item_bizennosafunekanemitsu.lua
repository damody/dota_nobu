
function Shock( keys )
	-- 開關型技能不能用
	if keys.event_ability:IsToggle() then return end

	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_bizennosafunekanemitsu") then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_bizennosafunekanemitsu",nil)
		local handle = caster:FindModifierByName("modifier_bizennosafunekanemitsu")
		if handle then
			handle:SetStackCount(1)
		end
	else
		local handle = caster:FindModifierByName("modifier_bizennosafunekanemitsu")
		if handle then
			local c = handle:GetStackCount()
			c = c + 1
			if c > 5 then
				c = 5
			end
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_bizennosafunekanemitsu",nil)
			handle:SetStackCount(c)
		end
	end

end
