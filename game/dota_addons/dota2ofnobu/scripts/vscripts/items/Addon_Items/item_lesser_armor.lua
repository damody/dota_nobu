--短甲
function Shock( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local dmg = keys.dmg
	local cure = 50
	--【KV】
	if (caster.armor_heal == nil) then
		caster.armor_heal = 0
	end
	if math.random(1,100) > 50 and caster.armor_heal < cure and caster:GetHealth() > cure then
		if dmg < cure then
			if caster.armor_heal + dmg > dmg then
				caster:SetHealth((dmg-caster.armor_heal) + caster:GetHealth())
			else
				caster:SetHealth(dmg + caster:GetHealth())
			end
			caster.armor_heal = caster.armor_heal + dmg
		else
			if caster.armor_heal + cure > dmg then
				caster:SetHealth((dmg-caster.armor_heal) + caster:GetHealth())
			else
				caster:SetHealth(cure + caster:GetHealth())
			end
			caster.armor_heal = caster.armor_heal + cure
		end
		Timers:CreateTimer(0.05, function ()
			caster.armor_heal = 0
		end)
	end
end


