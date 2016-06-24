
	function UnitDisarmedTarget( caster,target,disarmedtime)
		target:AddNewModifier(caster, nil, "modifier_disarmed", {duration=disarmedtime})
    end