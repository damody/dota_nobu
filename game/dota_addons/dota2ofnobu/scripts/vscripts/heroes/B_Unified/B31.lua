function B31W_OnSpellStart( keys )
	--【Basic】

	local caster = keys.caster
	local caster_point = caster:GetAbsOrigin()
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--caster:FindAbilityByName("B31W"):SetActivated(false)

	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
	Timers:CreateTimer(0.2,function()
		local order = {UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()}
		ExecuteOrderFromTable(order)
		end)
	local ifx = ParticleManager:CreateParticle("particles/a12r/a12r.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	if (caster:FindModifierByName("modifier_B31W_aura")) then
		caster:RemoveModifierByName("modifier_B31W_aura")
	end
	caster:RemoveModifierByName("modifier_B31W_aura")
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		caster_point,
		nil,
		1500,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_ALL,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_ANY_ORDER,
		false)

	--effect:傷害+暈眩
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) then
			keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_B31W",nil)
		end
	end

	Timers:CreateTimer(25, function ()
		--caster:FindAbilityByName("B31W"):SetActivated(true)
		if not(caster:FindModifierByName("modifier_B31W_aura")) then
			ability:ApplyDataDrivenModifier(caster, caster,"modifier_B31W_aura",nil)
		end
		return nil
	end)
end


function B31E_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              target:GetAbsOrigin(),
	                              nil,
	                              ability:GetSpecialValueFor( "splash_radius" ),
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) then
			if it:IsMagicImmune() then
				AMHC:Damage(caster,it, ability:GetSpecialValueFor( "damage")*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			else
				AMHC:Damage(caster,it, ability:GetSpecialValueFor( "damage"),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			end
			
		end
	end
end

function B31E_OnSpellStart( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = casterLoc + caster:GetForwardVector()*100
	local dir = caster:GetForwardVector()
	local distance = ability:GetLevelSpecialValueFor( "distance", ability:GetLevel() - 1 )
	local radius =  ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local collision_radius = ability:GetLevelSpecialValueFor( "collision_radius", ability:GetLevel() - 1 )
	local projectile_speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
	local right = caster:GetRightVector()
	--casterLoc = keys.target_points[1] - right:Normalized() * 300
	if (caster:FindModifierByName("modifier_B31E_aura")) then
		caster:RemoveModifierByName("modifier_B31E_aura")
	end
	
	
	
	
	local sumtime = 0
	-- Create timer to spawn projectile
	Timers:CreateTimer( function()
		-- Find forward vector
	local forwardVec = caster:GetForwardVector()
	
	-- Find backward vector
	local backwardVec = -caster:GetForwardVector()
		-- Find middle point of the spawning line
		local middlePoint = caster:GetAbsOrigin() + ( distance * 0.5 * backwardVec )
		
		-- Find perpendicular vector
		local v = middlePoint - caster:GetAbsOrigin()
		local dx = -v.y
		local dy = v.x
		local perpendicularVec = Vector( dx, dy, v.z )
		perpendicularVec = perpendicularVec:Normalized()
			-- Get random location for projectile
			for c = 1,1 do
				local random_distance = RandomInt( -radius, radius )
				local spawn_location = middlePoint + perpendicularVec * random_distance
				--local spawn_location = Vector( spawn_location2.x, spawn_location2.y, 0)
				local velocityVec = Vector( forwardVec.x, forwardVec.y, 0)
				-- Spawn projectiles
				local projectileTable = {
					Ability = ability,
					EffectName = "particles/b31e/b31e.vpcf",
					vSpawnOrigin = spawn_location,
					fDistance = distance,
					fStartRadius = collision_radius,
					fEndRadius = collision_radius,
					Source = caster,
					bHasFrontalCone = false,
					bReplaceExisting = false,
					bProvidesVision = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE,
					vVelocity = velocityVec * projectile_speed
				}
				ProjectileManager:CreateLinearProjectile( projectileTable )
			end
			-- Check if the number of machines have been reached
			if sumtime < 7 then
				sumtime = sumtime + 1/6
				return 1/6
			end
		end
	)
	Timers:CreateTimer(1, function()
		if caster:IsChanneling() == false then
			return nil
		else
			caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,0.8)
			return 1
		end
	end)
	Timers:CreateTimer(20, function ()
		--caster:FindAbilityByName("B31W"):SetActivated(true)
		if not(caster:FindModifierByName("modifier_B31E_aura")) then
			ability:ApplyDataDrivenModifier(caster, caster,"modifier_B31E_aura",nil)
		end
		return nil
	end)
end



function modifier_B31R_debuff_OnIntervalThink( keys )
	local caster = keys.caster
	if caster~=nil and IsValidEntity(caster) then
		if keys.target:CanEntityBeSeenByMyTeam(caster) then
			AMHC:Damage(caster,keys.target, keys.Damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			local flame = ParticleManager:CreateParticle("particles/econ/items/axe/axe_cinder/axe_cinder_battle_hunger_flames_b.vpcf", PATTACH_ABSORIGIN, keys.target)
			Timers:CreateTimer(0.9, function ()
				ParticleManager:DestroyParticle(flame, false)
			end)
		end
	end
end


function B31R_OnSpellStart( keys )
	local caster = keys.caster
	local ability= keys.ability
	if (caster:FindModifierByName("modifier_B31R_aura")) then
		caster:RemoveModifierByName("modifier_B31R_aura")
	end
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
	Timers:CreateTimer(0.2,function()
		local order = {UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()}
		ExecuteOrderFromTable(order)
		end)
	local ifx = ParticleManager:CreateParticle("particles/a19/a19_wfire/monkey_king_spring_arcana_fire.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(ifx)
	local targets=FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 500, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for i,unit in pairs(targets) do
		local damageTable = {victim=unit,   
			attacker=caster,         
			damage=ability:GetAbilityDamage(),   
			damage_type=ability:GetAbilityDamageType()} 
		if not unit:IsMagicImmune() then
			ApplyDamage(damageTable)   
		end
	end

	Timers:CreateTimer(9, function ()
		--caster:FindAbilityByName("B31W"):SetActivated(true)
		if not(caster:FindModifierByName("modifier_B31R_aura")) then
			ability:ApplyDataDrivenModifier(caster, caster,"modifier_B31R_aura",nil)
		end
		return nil
	end)
end



function B31T_OnSpellStart( keys )
	local caster = keys.caster
	local ability= keys.ability
	AMHC:AddModelScale(caster, 2, 25)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,1)
	local ifx2 = ParticleManager:CreateParticle("particles/b31t/b31t2.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx2,0,caster:GetAbsOrigin())
	local ifx = ParticleManager:CreateParticle("particles/b31t/b31t.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	Timers:CreateTimer(26, function ()
		ParticleManager:DestroyParticle(ifx2,false)
		return nil
	end)
end




function modifier_B31T_OnIntervalThink( keys )
	local caster = keys.caster
	local ability= keys.ability
	local ifx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_trigger_sphere.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	local ifx = ParticleManager:CreateParticle("particles/b31t/b31t.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
end





function B31E_old_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              target:GetAbsOrigin(),
	                              nil,
	                              ability:GetSpecialValueFor( "splash_radius" ),
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) then
			AMHC:Damage(caster,it, ability:GetSpecialValueFor( "damage"),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end


function B31E_old_OnSpellStart( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = ability:GetCursorPosition()
	local dir = ability:GetCursorPosition() - caster:GetAbsOrigin()
	if dir:Length2D() < 1 then
		dir = caster:GetForwardVector()
		targetLoc = caster:GetAbsOrigin() + dir*100
	end
	caster:SetForwardVector(dir:Normalized())
	local distance = ability:GetLevelSpecialValueFor( "distance", ability:GetLevel() - 1 )
	local radius =  ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local collision_radius = ability:GetLevelSpecialValueFor( "collision_radius", ability:GetLevel() - 1 )
	local projectile_speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
	local right = caster:GetRightVector()
	--casterLoc = keys.target_points[1] - right:Normalized() * 300
	local pertime=ability:GetSpecialValueFor("pertime_mount")
	-- Find forward vector
	local forwardVec = targetLoc - casterLoc
	forwardVec = forwardVec:Normalized()
	
	-- Find backward vector
	local backwardVec = casterLoc - targetLoc
	backwardVec = backwardVec:Normalized()
	
	-- Find middle point of the spawning line
	local middlePoint = casterLoc + ( radius * 2 * backwardVec )
	
	-- Find perpendicular vector
	local v = middlePoint - casterLoc
	local dx = -v.y
	local dy = v.x
	local perpendicularVec = Vector( dx, dy, v.z )
	perpendicularVec = perpendicularVec:Normalized()
	
	local sumtime = 0
	-- Create timer to spawn projectile
	Timers:CreateTimer( function()
			-- Get random location for projectile
			for c = 1,1 do
				local random_distance = RandomInt( -radius, radius )
				local spawn_location = middlePoint + perpendicularVec * random_distance
				--local spawn_location = Vector( spawn_location2.x, spawn_location2.y, 0)
				local velocityVec = Vector( forwardVec.x, forwardVec.y, 0)
				-- Spawn projectiles
				local projectileTable = {
					Ability = ability,
					EffectName = "particles/b31e/b31e.vpcf",
					vSpawnOrigin = spawn_location,
					fDistance = distance,
					fStartRadius = collision_radius,
					fEndRadius = collision_radius,
					Source = caster,
					bHasFrontalCone = false,
					bReplaceExisting = false,
					bProvidesVision = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NONE,
					vVelocity = velocityVec * projectile_speed
				}
				ProjectileManager:CreateLinearProjectile( projectileTable )
			end
			-- Check if the number of machines have been reached
			if caster:IsChanneling() == false then
				return nil
			else
				sumtime = sumtime + 1/pertime
				return 1/pertime
			end
		end
	)
	Timers:CreateTimer(1, function()
		if caster:IsChanneling() == false then
			return nil
		else
			caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,0.8)
			return 1
		end
	end)
end

		


function B31T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability= keys.ability
	AMHC:AddModelScale(caster, 2, 38)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_4,1)
	local ifx2 = ParticleManager:CreateParticle("particles/b31t/b31t2.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx2,0,caster:GetAbsOrigin())
	local ifx = ParticleManager:CreateParticle("particles/b31t/b31t.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	Timers:CreateTimer(38, function ()
		ParticleManager:DestroyParticle(ifx2,false)
		return nil
	end)
end




function modifier_B31T_old_OnIntervalThink( keys )
	local caster = keys.caster
	local ability= keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              caster:GetAbsOrigin(),
	                              nil,
	                              650,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) and it:IsAlive() then
			Timers:CreateTimer(0.3, function()
				ability:ApplyDataDrivenModifier(caster,it,"modifier_B31T_old_dot",nil)
				AMHC:Damage(caster,it,200,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end)
		
			local ifx = ParticleManager:CreateParticle("particles/a23r/a23rfly.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(ifx, 0, caster:GetAbsOrigin() + Vector (0, 0, 1000)) -- 隕石產生的位置
			ParticleManager:SetParticleControl(ifx, 1, it:GetAbsOrigin()) -- 命中位置
			ParticleManager:SetParticleControl(ifx, 2, Vector(0.5, 0, 0)) -- 效果存活時間
			
		end
		break
	end

	local ifx = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_trigger_sphere.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
	local ifx = ParticleManager:CreateParticle("particles/b31t/b31t.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
end
