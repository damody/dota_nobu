
    function UnitNoCollision( caster,target,duration)
		target:AddNewModifier(caster, nil, "modifier_phased", {duration=duration})
    end


    function UnitNoPathingfix( caster,target,duration)
		target:AddNewModifier(caster, nil, "modifier_spectre_spectral_dagger_path_phased", {duration=duration})
    end