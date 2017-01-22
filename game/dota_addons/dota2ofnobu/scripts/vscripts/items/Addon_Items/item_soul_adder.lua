--御魂

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    if target:IsMagicImmune() then
        ability:ApplyDataDrivenModifier(target,target,"modifier_soul_adder",{duration = 1.5})
    else
        ability:ApplyDataDrivenModifier(target,target,"modifier_soul_adder",{duration = 3})
        Timers:CreateTimer(2.9, function() 
            if (target:HasModifier("modifier_soul_adder")) then
                Timers:CreateTimer(0.11, function()
                    ability:ApplyDataDrivenModifier(target,target,"modifier_soul_adder2",{duration = 8})
                end)
            end
        end)
    end
end

