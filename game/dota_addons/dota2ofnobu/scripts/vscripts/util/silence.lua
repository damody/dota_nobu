function UnitSilenceTarget( caster,target,duration)
	target:AddNewModifier(caster, nil, "modifier_silence", {duration=duration})
end