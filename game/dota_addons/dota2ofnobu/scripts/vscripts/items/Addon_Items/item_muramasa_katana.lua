
function OnEquip( keys )	
	local caster = keys.caster
	if (caster.nobuorb1 == nil) then
		caster:AddAbility("ability_muramasa_katana"):SetLevel(1)
		caster.nobuorb1 = "muramasa_katana"
	end
end

function OnUnequip( keys )	
	local caster = keys.caster
	if (caster.nobuorb1 == "muramasa_katana") then
		caster:RemoveAbility("ability_muramasa_katana")
		caster.nobuorb1 = nil
	end
end


function StealLife(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dmg = keys.dmg
	if not target:IsBuilding() then
		caster:Heal(dmg*keys.StealPercent*0.01, ability)
	    ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
	end
end

