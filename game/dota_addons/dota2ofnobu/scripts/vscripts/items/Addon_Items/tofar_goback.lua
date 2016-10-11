
function tofar_goback(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()

	Timers:CreateTimer(1, function()
		if (VectorDistance(caster:GetAbsOrigin(), pos) > 1000) then
			local order = {
		 		UnitIndex = caster:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		 		Position = pos, --Optional.  Only used when targeting the ground
		 		Queue = 0 --Optional.  Used for queueing up abilities
		 	}
			ExecuteOrderFromTable(order)
		end
		return 1
		end)
end