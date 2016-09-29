--大典太光世．銘刀

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

    ability:ApplyDataDrivenModifier(caster,target,"modifier_great_sword_of_banish",{duration = 3})
    Timers:CreateTimer(0.1, function ()
		if target:HasModifier("modifier_great_sword_of_banish") then
			target:SetRenderColor(100, 255, 100)
			return 0.1
		else
			target:SetRenderColor(255, 255, 255)
			return nil
		end
	end)
end

