--大典太光世．銘刀

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	AMHC:Damage(caster,keys.target, caster:GetIntellect()*3.5,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
    ability:ApplyDataDrivenModifier(caster,target,"modifier_great_sword_of_banish",{duration = 3})
    target.isvoid = 1
    Timers:CreateTimer(0.1, function ()
		if target:HasModifier("modifier_great_sword_of_banish") then
			target:SetRenderColor(100, 255, 100)
			return 0.1
		else
			target.isvoid = nil
			target:SetRenderColor(255, 255, 255)
			return nil
		end
	end)
end

