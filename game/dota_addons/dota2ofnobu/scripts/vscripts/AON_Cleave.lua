

function AON_Cleave_A07(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dmg = keys.dmg
	local per_atk = 0
	local targetArmor = target:GetPhysicalArmorValue()
	local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
	--local dmg = dmg / (1 - damageReduction)
	local group = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),
		nil,  500 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	for _, it in pairs(group) do
		AMHC:Damage( caster,it,keys.dmg*0.2,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
	end

	local group = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),
		nil,  400 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	for _, it in pairs(group) do
		AMHC:Damage( caster,it,keys.dmg*0.2,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
	end

	local group = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),
		nil,  300 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	for _, it in pairs(group) do
		AMHC:Damage( caster,it,keys.dmg*0.2,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
	end

	local group = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(),
		nil,  200 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	for _, it in pairs(group) do
		AMHC:Damage( caster,it,keys.dmg*0.4,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
	end
end


function AON_Cleave(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dmg = keys.dmg
	local per_atk = 0
	local targetArmor = target:GetPhysicalArmorValue()
	local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
	--local dmg = dmg / (1 - damageReduction)
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  ability:GetLevelSpecialValueFor("CleaveRadius",level) , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	dmg = dmg * ability:GetLevelSpecialValueFor("CleavePercent",level) / 100


	for _, it in pairs(group) do
		AMHC:Damage( caster,it,keys.dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		--看防的擴散
		--[[
		if it ~= target and it:IsHero() then
			local targetArmor = it:GetPhysicalArmorValue()
			local damageReduction = ((0.003 * targetArmor) / (1 + 0.003* targetArmor))
			print(keys.dmg.." damageReduction "..damageReduction)
			
		elseif it ~= target then
			local targetArmor = it:GetPhysicalArmorValue()
			local damageReduction = ((0.5 * targetArmor) / (1 + 0.5* targetArmor))
			print(keys.dmg.." damageReduction "..damageReduction)
			AMHC:Damage( caster,it,keys.dmg*(1-damageReduction),AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end
		]]
	end
end
