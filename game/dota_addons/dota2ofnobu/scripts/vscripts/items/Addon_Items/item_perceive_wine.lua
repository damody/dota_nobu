
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local Time = keys.Time
	local am = caster:FindAllModifiers()
	ability:ApplyDataDrivenModifier(caster, caster,"modifier_perceive_wine",{duration=Time})
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
				caster:RemoveModifierByName(v:GetName())
			end
		end
	end
	
	-- Strong Dispel 刪除負面效果
	caster:Purge( false, true, true, true, true)
	local sumt = 0
	Timers:CreateTimer(0.1, function()
		sumt = sumt + 0.1
		if sumt < Time then
			if (not caster:HasModifier("modifier_perceive_wine")) and caster.nomagic == nil then
				local tt = Time-sumt
				if IsValidEntity(caster) then
					ability:ApplyDataDrivenModifier(caster, caster,"modifier_perceive_wine",{duration=tt})
				end
			end
			return 0.1
		end
		end)
end


