-- 明智秀滿

function CreateMirror( keys )
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetPlayerID()
	local ability = keys.ability
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin()
	local duration = ability:GetSpecialValueFor( "illusion_duration")
	local outgoingDamage = ability:GetSpecialValueFor( "illusion_outgoing_damage")
	local incomingDamage = ability:GetSpecialValueFor( "illusion_incoming_damage")

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	--分身不能用法球
	illusion.nobuorb1 = "illusion"
	
	if illusion:IsHero() then
		illusion:SetPlayerID(caster:GetPlayerID())

		-- Level Up the unit to the casters level
		local casterLevel = target:GetLevel()
		for i=1,casterLevel-1 do
			illusion:HeroLevelUp(false)
		end	
		-- Set the skill points to 0 and learn the skills of the caster
		illusion:SetAbilityPoints(0)
	end
	illusion:SetControllableByPlayer(player, true)
	

	-- Set the skill points to 0 and learn the skills of the caster
	for abilitySlot=0,15 do
		local ability = illusion:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if (illusionAbility ~= nil) then
				illusion:RemoveAbility(abilityName)
			end
		end
	end
	for abilitySlot=0,15 do
		local ability = target:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			illusion:AddAbility(abilityName):SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = target:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	illusion:MakeIllusion()
	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(target, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	--illusion:SetRenderColor(0,0,200)
	

	--【KV】
	illusion:SetForwardVector(target:GetForwardVector())
	illusion:SetControllableByPlayer(caster:GetPlayerID(), true)

	return illusion
end

function C02W_launch_projectile( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local point = keys.target_points[1]
	local ability = keys.ability
	local speed = 2000

	-- 計算攻擊方向
	local angle = VectorToAngles(point-center).y
	local dx = math.cos(angle*(3.14/180))
	local dy = math.sin(angle*(3.14/180))
	local dir = Vector(dx,dy,0)

	-- 實際造成傷害的投射物
	ProjectileManager:CreateLinearProjectile({
		Ability				= ability,
		EffectName			= "",
		vSpawnOrigin		= center+Vector(0,0,100),
		fDistance			= 1500,
		fStartRadius		= 350,
		fEndRadius			= 400,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= ability:GetAbilityTargetTeam(),
		iUnitTargetFlags	= ability:GetAbilityTargetFlags(),
		iUnitTargetType		= ability:GetAbilityTargetType(),
		fExpireTime			= GameRules:GetGameTime() + 2,
		bDeleteOnHit		= false,
		vVelocity			= dir*speed,
		bProvidesVision		= false,
		iVisionRadius		= 0,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	})

	-- 特效投射物
	local num = 2
	local delta_angle = 1
	for i=-num,num do
		print(i)
	end
end

function C02W_clone_hero( keys )
	local target = keys.target

	if target:IsHero() and target:IsRealHero() and target:IsIllusion()==false then
		local effect_name = "particles/units/heroes/hero_siren/naga_siren_portrait.vpcf"
		local player = PlayerResource:GetPlayer(target:GetPlayerID())
		local ifx = ParticleManager:CreateParticleForPlayer(effect_name,PATTACH_ABSORIGIN_FOLLOW,target,player)
		Timers:CreateTimer(1, function ()
			ParticleManager:DestroyParticle(ifx,false)
		end)

		local illusion = CreateMirror( keys )
		-- 命令攻擊目標
		local order = {
			UnitIndex = illusion:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}
		ExecuteOrderFromTable(order)
	end
end