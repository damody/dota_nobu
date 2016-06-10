

function C10T_Init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.caster:GetAbsOrigin()
	if keys.caster.C10T_T ~= nil then
		keys.caster.C10T_T = nil
	end 
	keys.caster.C10T_T = {}

    local group = keys.caster.C10T_T
   	group = FindUnitsInRadius(caster:GetTeam(), point, nil, 900, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for i,v in ipairs(group) do
		table.insert(keys.caster.C10T_T,v)
		ability:ApplyDataDrivenModifier(caster,v,"modifier_C10T",nil)
	end	
end

function C10T_PutIn( keys )
	table.insert(keys.caster.C10T_T,keys.target)
end

function C10T_END( keys )
	local point = keys.caster:GetAbsOrigin()
	keys.caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.01})
	for i,v in ipairs(keys.caster.C10T_T) do
		v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.01})
		v:SetAbsOrigin(point)
	end
end

function C10T_SE( keys )
	keys.caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2,2.0)
end

function C10W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point  = keys.caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local forwardVec =(point2 - point ):Normalized()

	print("1"..tostring(forwardVec))
	print("2"..tostring(caster:GetForwardVector()))
	local level = ability:GetLevel() - 1

	-- Necessary variables from KV
	local movespeed = ability:GetLevelSpecialValueFor("speed",level)
	local start_radius = ability:GetLevelSpecialValueFor("start_radius",level)
	local end_radius = ability:GetLevelSpecialValueFor("end_radius",level)
	local distance = ability:GetLevelSpecialValueFor("distance",level)
	local movespeed = ability:GetLevelSpecialValueFor("start_radius",level)

	local projectileTable =
	{
		EffectName = "particles/c10w/c10w.vpcf",
		Ability = ability,
		vSpawnOrigin = point,
		vVelocity = forwardVec * movespeed * 8,
		fDistance = distance,
		fStartRadius = start_radius,
		fEndRadius = end_radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iVisionRadius = end_radius,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	caster.powershot_projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
end
