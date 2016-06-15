function killdummy( keys )
	local dummy = keys.target
	--print(dummy:GetUnitName())
	if dummy ~= nil then
		dummy:ForceKill(true)
		print(dummy:GetUnitName())
	end
end