--閃避

function OnEquip( keys )
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_ninja_cloth") then
		caster.use_equip_ninja_cloth = 1
		ability:ApplyDataDrivenModifier(caster, caster,"modifier_ninja_cloth",nil)
	end
end

function OnUnequip( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster.use_equip_ninja_cloth == 1 then
		caster.use_equip_ninja_cloth = nil
		caster:RemoveModifierByName("modifier_ninja_cloth")
	end
end
