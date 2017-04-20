
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
			caster.bizennosafunekanemitsu = 1
		end
	else
		local handle = caster:FindModifierByName("modifier_bizennosafunekanemitsu")
		if handle then
			local c = handle:GetStackCount()
			c = c + 1
			if c > 3 then
				c = 3
			end
			--ability:ApplyDataDrivenModifier(caster,caster,"modifier_bizennosafunekanemitsu",nil)
			handle:SetStackCount(c)
			caster.bizennosafunekanemitsu = c
		end
	end

end


function OnDestroy( keys )
	-- 開關型技能不能用
	local caster = keys.caster
	local ability = keys.ability
	caster.bizennosafunekanemitsu = caster.bizennosafunekanemitsu - 1
	if caster.bizennosafunekanemitsu > 0 then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_bizennosafunekanemitsu",nil)
		local handle = caster:FindModifierByName("modifier_bizennosafunekanemitsu")
		if handle then
			handle:SetStackCount(caster.bizennosafunekanemitsu)
		end
	end
end
	