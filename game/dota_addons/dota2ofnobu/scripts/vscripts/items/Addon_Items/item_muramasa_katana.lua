
function OnEquip( keys )	
	local caster = keys.caster
	if (caster.nobuorb1 == nil) then
		caster.nobuorb1 = "muramasa_katana"
	end
end

function OnUnequip( keys )	
	local caster = keys.caster
	if (caster.nobuorb1 == "muramasa_katana") then
		caster.nobuorb1 = nil
	end
end


function StealLife(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	if target.isvoid == nil then
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local dmg = keys.dmg
		if (caster.nobuorb1 == "muramasa_katana" or caster.nobuorb1 == "illusion" or caster.nobuorb1 == nil) and not target:IsBuilding() then
			caster.nobuorb1 = "muramasa_katana"
			local damageReduction = 0
			local targetArmor = target:GetPhysicalArmorValue()
			if target:IsHero() then
				damageReduction = ((0.06 * targetArmor) / (1 + 0.06* targetArmor))
			else
				damageReduction = ((0.06 * targetArmor) / (1 + 0.06* targetArmor))
			end
			--print("steal1 "..dmg*keys.StealPercent*0.02*(damageReduction))
			--print("steal2 "..dmg*keys.StealPercent*0.02)
			if damageReduction < 0 then
				damageReduction = 1
			end
			if damageReduction > 1 then
				damageReduction = 1
			end
			--print(dmg, damageReduction, target:GetPhysicalArmorValue(), dmg*keys.StealPercent*0.01*(1-damageReduction))
			caster:Heal(dmg*keys.StealPercent*0.01*(1-damageReduction), ability)
		    ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
		end
	end
end


function StealLife2(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	if target.isvoid == nil then
		local ability = keys.ability
		local level = ability:GetLevel() - 1
		local dmg = keys.dmg
		if not target:IsBuilding() then
			local damageReduction = 0
			local targetArmor = target:GetPhysicalArmorValue()
			if target:IsHero() then
				damageReduction = ((0.06 * targetArmor) / (1 + 0.06* targetArmor))
			else
				damageReduction = ((0.06 * targetArmor) / (1 + 0.06* targetArmor))
			end
			if damageReduction < 0 then
				damageReduction = 1
			end
			if damageReduction > 1 then
				damageReduction = 1
			end
			--print("steal "..dmg*keys.StealPercent*0.02*(1-damageReduction))
			caster:Heal(dmg*keys.StealPercent*0.01*(1-damageReduction), ability)
		    ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
		end
	end
end
