
function OnEquip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == nil) then
		caster.nobuorb1 = "spear_of_saddle"
	end
end

function OnUnequip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == "spear_of_saddle") then
		caster.nobuorb1 = nil
	end
end

function Shock( keys )
	local caster = keys.caster
	local skill = keys.ability
	if caster.nobuorb1 == "spear_of_saddle" then
		skill:ApplyDataDrivenModifier(caster, keys.target,"modifier_spear_of_saddle",{ duration = 3.5 })
	end
end



function OnEquip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == nil) then
		caster.nobuorb1 = "spear_of_saddle"
	end
end

function OnUnequip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == "spear_of_saddle") then
		caster.nobuorb1 = nil
	end
end

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local skill = keys.ability
	if caster.nobuorb1 == "spear_of_saddle" and not target:IsBuilding() then
		skill:ApplyDataDrivenModifier(caster, keys.target,"modifier_spear_of_saddle",{ duration = 3.5 })
	end
end

function Shock1( keys )
	local caster = keys.caster
	local target = keys.target
	local skill = keys.ability
	if caster.nobuorb1 == "spear_of_saddle" and not target:IsBuilding() then
		skill:ApplyDataDrivenModifier(caster, keys.target,"modifier_spear_of_saddle_1",{ duration = 3.5 })
	end
end


function Shock2( keys )
	local caster = keys.caster
	local target = keys.target
	local skill = keys.ability
	if caster.nobuorb1 == "spear_of_saddle" and not target:IsBuilding() then
		skill:ApplyDataDrivenModifier(caster, keys.target,"modifier_spear_of_saddle_2",{ duration = 3.5 })
	end
end



