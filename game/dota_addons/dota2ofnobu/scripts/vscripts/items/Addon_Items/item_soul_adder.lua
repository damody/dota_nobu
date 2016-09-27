--御魂

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	Timers:CreateTimer(2.9, function() 
    		if (target:HasModifier("modifier_soul_adder")) then
    			print("target modifier_soul_adder")
    			Timers:CreateTimer(0.11, function()
    				ability:ApplyDataDrivenModifier(target,target,"modifier_soul_adder2",{duration = 8})
    			end)
    		end
    	end)
end

