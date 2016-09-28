--大典太光世．銘刀

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

    ability:ApplyDataDrivenModifier(caster,target,"modifier_great_sword_of_banish",{duration = 3})
    Timers:CreateTimer(0.1, function ()
		chaos_effect = ParticleManager:CreateParticle("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(chaos_effect, 3, point)
	end)
end

