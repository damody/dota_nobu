--妖化河童殼

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	          caster:GetAbsOrigin(),
	          nil,
	          1000,
	          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	          DOTA_UNIT_TARGET_FLAG_NONE,
	          0,
	          false)
	for _,target in pairs(direUnits) do
		target:SetMana(target:GetMana()+250)
		ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
	end

end

function Shock2( keys )
	local caster = keys.caster
	local ability = keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	          caster:GetAbsOrigin(),
	          nil,
	          1000,
	          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	          DOTA_UNIT_TARGET_FLAG_NONE,
	          0,
	          false)
	for _,target in pairs(direUnits) do
		target:SetMana(target:GetMana()+350)
		ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
	end

end
