
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local Time = keys.Time
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
			caster:RemoveModifierByName(v:GetName())
		end
	end
	ability:ApplyDataDrivenModifier(caster, caster,"modifier_perceive_wine",{duration=Time})
	-- Strong Dispel 刪除負面效果
	caster:Purge( false, true, true, true, true)
	local sumt = 0
	Timers:CreateTimer(0.1, function()
		sumt = sumt + 0.1
		if sumt < Time then
			if (not caster:HasModifier("modifier_perceive_wine")) and caster.nomagic == nil then
				local tt = Time-sumt
				ability:ApplyDataDrivenModifier(caster, caster,"modifier_perceive_wine",{duration=tt})
			end
			return 0.1
		end
		end)
end


