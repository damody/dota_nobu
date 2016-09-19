

function C10T_Init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.caster:GetAbsOrigin()
	if keys.caster.C10T_T ~= nil then
		keys.caster.C10T_T = nil
	end 
	keys.caster.C10T_T = {}

    local group = keys.caster.C10T_T
   	group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	for i,v in ipairs(group) do
		table.insert(keys.caster.C10T_T,v)
		ability:ApplyDataDrivenModifier(caster,v,"modifier_C10T",nil)
	end	
	local delay = ability:GetLevelSpecialValueFor("delay",0)
	local count = 0
	Timers:CreateTimer(0, function()
		count = count + 0.1
		-- 死了就清掉
		if (not caster:IsAlive()) then
			keys.caster.C10T_T = {}
		end
		if (count > delay) then
			return nil
		else
			return 0.1
		end
    	end)
end

function C10T_PutIn( keys )
	table.insert(keys.caster.C10T_T,keys.target)
end

function C10T_END( keys )
	local point = keys.caster:GetAbsOrigin()
	keys.caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	for i,v in ipairs(keys.caster.C10T_T) do
		v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
		if (v:HasModifier("modifier_C10T")) then
			v:SetAbsOrigin(point)
		end
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


function C10R(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local dmg = keys.dmg
	local per_atk = 0
	local targetArmor = target:GetPhysicalArmorValue()
	local damageReduction = ((0.06 * targetArmor) / (1 + 0.06 * targetArmor))
	local dmg = dmg / (1 - damageReduction)
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil, 385 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

	dmg = dmg * ability:GetLevelSpecialValueFor("CleavePercent",level)
	for _, it in pairs(group) do
		if it ~= target then
			AMHC:Damage( caster,it,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end
	end
end
