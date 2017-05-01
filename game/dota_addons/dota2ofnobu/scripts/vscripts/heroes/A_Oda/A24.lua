-- 佐久間盛政

function modifier_A24D_OnIntervalThink( event )
	local unit = event.target
	local ability=event.ability


	local caster =ability:GetCaster()
	--local max_damage_absorb = ability:GetSpecialValueFor("damage_absorb")+caster:GetMana()*ability:GetSpecialValueFor("addition_absord_mul_mana_percent")/100
	-- Reset the shield

	if unit.AphoticShieldRemaining == nil then
		unit.AphoticShieldRemaining=0
			--abilityA24D:ApplyDataDrivenModifier(caster,caster,"modifier_A24D", {})
	end
	unit.AphoticShieldRemaining = unit.AphoticShieldRemaining - 16
	
	if unit.AphoticShieldRemaining <= 0 then
		unit.AphoticShieldRemaining = 0
		--移除特效
		if caster.a24d_particle then
			--print("test2")
			ParticleManager:DestroyParticle(caster.a24d_particle,false)
			caster.a24d_particle=nil
		end
		modifier=caster:FindModifierByName("modifier_A24D_count")
		modifier:SetStackCount(0)
		--unit:RemoveModifierByName("modifier_A24D")
	else
		if caster.a24d_particle==nil then
			--print("test")
			local ifx = ParticleManager:CreateParticle("particles/a24d/a24d.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
			ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
			caster.a24d_particle=ifx
		end
		modifier=caster:FindModifierByName("modifier_A24D_count")
		modifier:SetStackCount(unit.AphoticShieldRemaining)
	end
end

function modifier_A24D_OnTakeDamage( event )
	-- Variable
	local ability = event.ability
	local caster =ability:GetCaster()
	if caster.selfdamage ==nil then
		caster.selfdamage=false
	end
	print (caster.selfdamage)
	if IsServer() and not caster.selfdamage then

		local damage = event.DamageTaken
		local unit = event.unit
		
		
		-- Track how much damage was already absorbed by the shield
		local shield_remaining = unit.AphoticShieldRemaining

		-- -- Check if the unit has the borrowed time modifier
		-- if not unit:HasModifier("modifier_borrowed_time") then
			-- If the damage is bigger than what the shield can absorb, heal a portion
		if damage > shield_remaining then
			local newHealth = unit:GetHealth() + shield_remaining
			unit:SetHealth(newHealth)
		else
			local newHealth = unit:GetHealth() + damage			
			unit:SetHealth(newHealth)
		end

		-- Reduce the shield remaining and remove
		unit.AphoticShieldRemaining = unit.AphoticShieldRemaining-damage
		if unit.AphoticShieldRemaining <= 0 then
			unit.AphoticShieldRemaining = 0
			--移除特效
			modifier=caster:FindModifierByName("modifier_A24D_count")
			modifier:SetStackCount(0)

			--unit:RemoveModifierByName("modifier_A24D")
		else
			modifier=caster:FindModifierByName("modifier_A24D_count")
			modifier:SetStackCount(unit.AphoticShieldRemaining)
		end
	end

	if caster.selfdamage then 
		caster.selfdamage=false
	end
end


function A24W_OnSpellStart( keys )

	local caster = keys.caster
	local ability = keys.ability
	for i=1,10 do
		local ifx = ParticleManager:CreateParticle("particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf",PATTACH_ABSORIGIN,caster)
		ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(ifx,1,caster:GetAbsOrigin())
	end
	local unit = caster
	local abilityA24D = caster:FindAbilityByName("A24D")
	if caster:GetHealthPercent() > 10 then

		local healthCost=caster:GetMaxHealth()*8/100
		local shield=healthCost*2
		local shield_max=abilityA24D:GetSpecialValueFor("shield_max")
		--AMHC:Damage(caster,caster,healthCost,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		if not caster:FindModifierByName("modifier_A24T") then
			--caster:SetHealth(caster:GetHealth()-healthCost)
			caster.selfdamage=true
			AMHC:Damage(caster,caster,healthCost,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
		if unit.AphoticShieldRemaining == nil then
			unit.AphoticShieldRemaining=0
			--abilityA24D:ApplyDataDrivenModifier(caster,caster,"modifier_A24D", {})
		end

		unit.AphoticShieldRemaining = unit.AphoticShieldRemaining +shield
		--print(unit.AphoticShieldRemaining)
		--print(shield_max)
		if unit.AphoticShieldRemaining>shield_max then
			unit.AphoticShieldRemaining=shield_max
		end

		if caster.a24d_particle==nil then
			--print("test")
			local ifx = ParticleManager:CreateParticle("particles/a24d/a24d.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
			ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
			caster.a24d_particle=ifx
		end
		modifier=keys.caster:FindModifierByName("modifier_A24D_count")
		modifier:SetStackCount(unit.AphoticShieldRemaining)
	else

	end

	local targetpoint = keys.target_points[1]
	local dir=targetpoint-caster:GetAbsOrigin()
	caster:SetForwardVector(dir:Normalized())
	--local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local distance = 1200
	local radius =  400
	local collision_radius = 150
	local projectile_speed = 1000
	local projectileTable = {
							Ability = ability,
							EffectName =  "particles/a24w2/a24w2.vpcf",
							vSpawnOrigin = caster:GetAbsOrigin(),
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
							vVelocity = caster:GetForwardVector():Normalized() * projectile_speed
						}
	ProjectileManager:CreateLinearProjectile( projectileTable )
	--local ifx = ParticleManager:CreateParticle("particles/a24w2/a24w2.vpcf",PATTACH_ABSORIGIN,caster)
	--local projectile_locate=caster:GetAbsOrigin()
	--local vVelocity = caster:GetForwardVector():Normalized() * projectile_speed
	--Timers:CreateTimer(0, function ()
	--	projectile_locate=projectile_locate+vVelocity/100
	--	ParticleManager:SetParticleControl(ifx,0,projectile_locate)
		--print(projectile_locate)
	--	return 0.01
   	--end)
end

A24_EXCLUDE_TARGET_NAME = {
	npc_dota_cursed_warrior_souls	= true,
	npc_dota_the_king_of_robbers	= true,
	com_general = true,
	com_general2 = true,
}

function A24W_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point =target:GetAbsOrigin()
	local ifx = ParticleManager:CreateParticle(  "particles/a24w3/a24w3.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 1, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 2, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 4, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 5, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 6, point + Vector(0,0,100))
	ParticleManager:SetParticleControl( ifx, 20, point + Vector(0,0,100))

	Timers:CreateTimer(1, function ()
		ParticleManager:DestroyParticle(ifx,false)
	end)
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              target:GetAbsOrigin(),
	                              nil,
	                              300,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
	for _,it in pairs(direUnits) do
		if (not(it:IsBuilding())) and A24_EXCLUDE_TARGET_NAME[it:GetUnitName()] == nil then
			damage=ability:GetAbilityDamage()+it:GetMaxHealth()*11/100

			if it:IsMagicImmune() then
				--local magicresitence=(100-it:GetModifierMagicalResistanceBonus())/100
				--print(magicresitence)
				ability:ApplyDataDrivenModifier(caster,it,"modifier_A24W", {})
				AMHC:Damage(caster,it, damage*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			else
				ability:ApplyDataDrivenModifier(caster,it,"modifier_A24W", {})
				AMHC:Damage(caster,it, damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
	end
end




function A24E_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	StartSoundEvent( "Hero_Batrider.StickyNapalm.Impact", target )
	--StartSoundEvent( "Hero_Clinkz.SearingArrows.Impact", caster )
	local ability = keys.ability
	local unit=caster
	for i=1,10 do
		local ifx = ParticleManager:CreateParticle("particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf",PATTACH_ABSORIGIN,caster)
		ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(ifx,1,caster:GetAbsOrigin())
	end
	local abilityA24D = caster:FindAbilityByName("A24D")
	if caster:GetHealthPercent() > 10 then

		local healthCost=caster:GetMaxHealth()*10/100
		local shield=healthCost*2
		local shield_max=abilityA24D:GetSpecialValueFor("shield_max")
		--AMHC:Damage(caster,caster,healthCost,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		if not caster:FindModifierByName("modifier_A24T") then
			--caster:SetHealth(caster:GetHealth()-healthCost)
			caster.selfdamage=true
			AMHC:Damage(caster,caster,healthCost,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
		if unit.AphoticShieldRemaining == nil then
			unit.AphoticShieldRemaining=0
			--abilityA24D:ApplyDataDrivenModifier(caster,caster,"modifier_A24D", {})
		end

		local sheild_bonus=ability:GetSpecialValueFor("sheild_bonus")
		unit.AphoticShieldRemaining = unit.AphoticShieldRemaining +shield +sheild_bonus
		if unit.AphoticShieldRemaining>shield_max then
			unit.AphoticShieldRemaining=shield_max
		end
		if caster.a24d_particle==nil then
			--print("test")
			local ifx = ParticleManager:CreateParticle("particles/a24d/a24d.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
			ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
			caster.a24d_particle=ifx
		end
		modifier=keys.caster:FindModifierByName("modifier_A24D_count")
		modifier:SetStackCount(unit.AphoticShieldRemaining)
	else
		if unit.AphoticShieldRemaining == nil then
			unit.AphoticShieldRemaining=0
			--abilityA24D:ApplyDataDrivenModifier(caster,caster,"modifier_A24D", {})
		end
		local shield_max=abilityA24D:GetSpecialValueFor("shield_max")
		local sheild_bonus=ability:GetSpecialValueFor("sheild_bonus")
		unit.AphoticShieldRemaining = unit.AphoticShieldRemaining+sheild_bonus
		if unit.AphoticShieldRemaining>shield_max then
			unit.AphoticShieldRemaining=shield_max
		end
		if caster.a24d_particle==nil then
			--print("test")
			local ifx = ParticleManager:CreateParticle("particles/a24d/a24d.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
			ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
			caster.a24d_particle=ifx
		end
		modifier=keys.caster:FindModifierByName("modifier_A24D_count")
		modifier:SetStackCount(unit.AphoticShieldRemaining)
	end

	local distance=(target:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D()

	if distance<200 then
		distance=200
	end
	distance=distance-200

	local stun_duration=1.8-distance*1.5/(800-200)
	--move
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())
	if not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = stun_duration})
	end
	AMHC:Damage(caster,target,1,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	
end

function A24R_OnSpellStart( keys )

	local caster = keys.caster
	local ability = keys.ability
	local unit = caster
	for i=1,10 do
		local ifx = ParticleManager:CreateParticle("particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf",PATTACH_ABSORIGIN,caster)
		ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(ifx,1,caster:GetAbsOrigin())
	end
	local abilityA24D = caster:FindAbilityByName("A24D")
	if caster:GetHealthPercent() > 10 then

		local healthCost=caster:GetMaxHealth()*6/100
		local shield=healthCost*2
		local shield_max=abilityA24D:GetSpecialValueFor("shield_max")
		--AMHC:Damage(caster,caster,healthCost,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		if not caster:FindModifierByName("modifier_A24T") then
			--caster:SetHealth(caster:GetHealth()-healthCost)
			caster.selfdamage=true
			AMHC:Damage(caster,caster,healthCost,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
		if unit.AphoticShieldRemaining == nil then
			unit.AphoticShieldRemaining=0
			--abilityA24D:ApplyDataDrivenModifier(caster,caster,"modifier_A24D", {})
		end

		unit.AphoticShieldRemaining = unit.AphoticShieldRemaining +shield
		--print(unit.AphoticShieldRemaining)
		--print(shield_max)
		if unit.AphoticShieldRemaining>shield_max then
			unit.AphoticShieldRemaining=shield_max
		end
		if caster.a24d_particle==nil then
			--print("test")
			local ifx = ParticleManager:CreateParticle("particles/a24d/a24d.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
			ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
			caster.a24d_particle=ifx
		end
		modifier=keys.caster:FindModifierByName("modifier_A24D_count")
		modifier:SetStackCount(unit.AphoticShieldRemaining)
	else

	end
end


function modifier_A24R_passive_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              caster:GetAbsOrigin(),
	                              nil,
	                              2500,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_HERO,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
	for _,it in pairs(direUnits) do
		local health = ability:GetSpecialValueFor("life_above") 
		if it:GetHealthPercent()<=health then
			AddFOWViewer(caster:GetTeamNumber(),it:GetAbsOrigin(),700,3.0,false)
		end
	end
end


function A24T_OnSpellStart( keys )

	local caster = keys.caster
	local unit = caster
	for i=1,10 do
		local ifx = ParticleManager:CreateParticle("particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf",PATTACH_ABSORIGIN,caster)
		ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(ifx,1,caster:GetAbsOrigin())
	end
	local ability = keys.ability
	local abilityA24D = caster:FindAbilityByName("A24D")
	local healthCost=caster:GetHealth()*17/100
	local shield=healthCost*2
	local shield_max=abilityA24D:GetSpecialValueFor("shield_max")
	--caster:SetHealth(caster:GetHealth()-healthCost)
	caster.selfdamage=true
	AMHC:Damage(caster,caster,healthCost,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	if unit.AphoticShieldRemaining == nil then
		unit.AphoticShieldRemaining=0
	end
	unit.AphoticShieldRemaining = unit.AphoticShieldRemaining +shield
	if unit.AphoticShieldRemaining>shield_max then
		unit.AphoticShieldRemaining=shield_max
	end
	if caster.a24d_particle==nil then
		--print("test")
		local ifx = ParticleManager:CreateParticle("particles/a24d/a24d.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
		ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin())
		caster.a24d_particle=ifx
	end
	modifier=keys.caster:FindModifierByName("modifier_A24D_count")
	modifier:SetStackCount(unit.AphoticShieldRemaining)

	local stun_duration = ability:GetSpecialValueFor("stun") 
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              caster:GetAbsOrigin(),
	                              nil,
	                              500,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_HERO+ DOTA_UNIT_TARGET_BASIC,
	                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	                              FIND_ANY_ORDER,
	                              false)
	for _,it in pairs(direUnits) do
		ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = stun_duration})
		AMHC:Damage(caster,it,1,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end

	Timers:CreateTimer(17, function ()
		if IsValidEntity(caster) and AMHC:IsAlive(caster) == true then
			caster:Heal(caster:GetMaxHealth()/2,caster)
 	 	end
   	end)
	
end

function A24T_OnUpgrade( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("A24D")
	local level = keys.ability:GetLevel()
	ability:SetLevel(level+1)
end