function killdummy( keys )
	local dummy = keys.caster
	print(dummy:GetUnitName())
	if dummy ~= nil then
		dummy:ForceKill(true)
		print(dummy:GetUnitName())
	end
end