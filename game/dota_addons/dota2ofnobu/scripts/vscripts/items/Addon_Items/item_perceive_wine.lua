
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() then
			caster:RemoveModifierByName(v:GetName())
		end
		
	end
	Timers:CreateTimer(0.1, function() 
			if (caster:HasModifier("modifier_perceive_wine") or caster:HasModifier("modifier_perceive_wine_hyper")) then
				if caster:HasModifier("Passive_liquor") then
					caster:RemoveModifierByName("Passive_liquor")
				end
				if caster:HasModifier("Passive_sake") then
					caster:RemoveModifierByName("Passive_sake")
				end
				return 1
			end
			return nil
		end)
	-- Strong Dispel 刪除負面效果
	caster:Purge( false, true, true, true, true)
end


