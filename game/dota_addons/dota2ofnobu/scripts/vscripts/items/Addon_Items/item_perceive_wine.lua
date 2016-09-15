
function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() then
			caster:RemoveModifierByName(v:GetName())
		end
	end
	-- Strong Dispel 刪除負面效果
	caster:Purge( false, true, true, true, true)
end


