--吹箭

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_blowgun",nil)
	end
end

--薩摩銃

function Shock2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_satsuma_gun",nil)
	end
end