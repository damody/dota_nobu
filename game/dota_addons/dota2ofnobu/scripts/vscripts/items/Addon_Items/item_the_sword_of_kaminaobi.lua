--神直毘御劍

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

    caster:SetAbsOrigin(target:GetAbsOrigin())
    caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
	    local order = {UnitIndex = caster:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
						TargetIndex = target:entindex()}

		ExecuteOrderFromTable(order)
	end
end

