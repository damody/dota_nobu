
	function UnitInvulnerableTarget( caster,target,invulnerabletime)
		target:AddNewModifier(caster, nil, "modifier_invulnerable", {duration=invulnerabletime})
    end