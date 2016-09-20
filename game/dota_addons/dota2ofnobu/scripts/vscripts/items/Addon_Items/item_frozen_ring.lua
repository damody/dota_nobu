
--凍牙輪

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
						caster:GetAbsOrigin(),
						nil,
						350,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						DOTA_UNIT_TARGET_ALL,
						DOTA_UNIT_TARGET_FLAG_NONE,
						FIND_ANY_ORDER,
						false)
	for _,it in pairs(direUnits) do
		ability:ApplyDataDrivenModifier(caster, it,"modifier_frozen_ring",{duration=5})
		AMHC:Damage(caster,it,350,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
	local particle = ParticleManager:CreateParticle("particles/a34e2/a34e2.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer(5, function ()
		ParticleManager:DestroyParticle(particle, true)
		end)
	--跟電卷共用CD
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if (itemName == "item_lightning_scroll") then
				item:StartCooldown(17)
			end
		end
	end
end


