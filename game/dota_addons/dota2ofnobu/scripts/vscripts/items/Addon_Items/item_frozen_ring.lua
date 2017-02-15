
--凍牙輪

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
						caster:GetAbsOrigin(),
						nil,
						375,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
						DOTA_UNIT_TARGET_FLAG_NONE,
						FIND_ANY_ORDER,
						false)
	for _,it in pairs(direUnits) do
		ability:ApplyDataDrivenModifier(caster, it,"modifier_frozen_ring",{duration=3.5})
		AMHC:Damage(caster,it,275,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
	local particle = ParticleManager:CreateParticle("particles/a34e2/a34e2.vpcf", PATTACH_ABSORIGIN, caster)
	Timers:CreateTimer(1, function ()
		ParticleManager:DestroyParticle(particle, true)
		end)
	--跟電卷共用CD
	--[[
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if (itemName == "item_lightning_scroll") then
				item:StartCooldown(10)
			end
		end
	end
	]]
end

--雪走

function Shock2( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
						target:GetAbsOrigin(),
						nil,
						400,
						DOTA_UNIT_TARGET_TEAM_ENEMY,
						DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
						DOTA_UNIT_TARGET_FLAG_NONE,
						FIND_ANY_ORDER,
						false)
	AMHC:Damage(caster,target,300,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	for _,it in pairs(direUnits) do
		ability:ApplyDataDrivenModifier(caster, it,"modifier_frozen_ring",{duration=7})
		if it ~= target then
		AMHC:Damage(caster,it,200,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
	local particle = ParticleManager:CreateParticle("particles/a34e2/a34e2.vpcf", PATTACH_ABSORIGIN, target)
	Timers:CreateTimer(7, function ()
		ParticleManager:DestroyParticle(particle, true)
		end)
end

--凍雲

function OnEquip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == nil) then
		caster.nobuorb1 = "item_kokumo"
	end
end

function OnUnequip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == "item_kokumo") then
		caster.nobuorb1 = nil
	end
end

function Shock3( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if (caster.nobuorb1 == "item_kokumo" or caster.nobuorb1 == nil) and not target:IsBuilding() and caster.gokokumo == nil then
		caster.nobuorb1 = "item_kokumo"
		caster.gokokumo = 1
		Timers:CreateTimer(0.1, function() 
				caster.gokokumo = nil
			end)
		local ran =  RandomInt(0, 100)
		if (caster.kokumo == nil) then
			caster.kokumo = 0
		end
		if (ran > 16) then
			caster.kokumo = caster.kokumo + 1
		end
		if (caster.kokumo > (100/16) or ran <= 16) then
			caster.kokumo = 0
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
							target:GetAbsOrigin(),
							nil,
							225,
							DOTA_UNIT_TARGET_TEAM_ENEMY,
							DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
							DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
							FIND_ANY_ORDER,
							false)
		AMHC:Damage(caster,target,300,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		for _,it in pairs(direUnits) do
			ability:ApplyDataDrivenModifier(caster, it,"modifier_frozen_ring",{duration=2})
			if it ~= target then
				AMHC:Damage(caster,it,200,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		local particle = ParticleManager:CreateParticle("particles/a34e2/a34e2.vpcf", PATTACH_ABSORIGIN, target)
		Timers:CreateTimer(2, function ()
			ParticleManager:DestroyParticle(particle, true)
			end)
		end
	end
end


function Shock4( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if (caster.nobuorb1 == "item_kokumo" or caster.nobuorb1 == nil) and not target:IsBuilding() and caster.gokokumo == nil then
		caster.nobuorb1 = "item_kokumo"
		caster.gokokumo = 1
		Timers:CreateTimer(0.1, function() 
				caster.gokokumo = nil
			end)
		local ran =  RandomInt(0, 100)
		if (caster.kokumo == nil) then
			caster.kokumo = 0
		end
		if (ran > 18) then
			caster.kokumo = caster.kokumo + 1
		end
		if (caster.kokumo > (100/18) or ran <= 18) then
			caster.kokumo = 0
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
							target:GetAbsOrigin(),
							nil,
							325,
							DOTA_UNIT_TARGET_TEAM_ENEMY,
							DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
							DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
							FIND_ANY_ORDER,
							false)
		AMHC:Damage(caster,target,450,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		for _,it in pairs(direUnits) do
			ability:ApplyDataDrivenModifier(caster, it,"modifier_frozen_ring",{duration=3})
			if it ~= target then
				AMHC:Damage(caster,it,250,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		local particle = ParticleManager:CreateParticle("particles/a34e2/a34e2.vpcf", PATTACH_ABSORIGIN, target)
		Timers:CreateTimer(3, function ()
			ParticleManager:DestroyParticle(particle, true)
			end)
		end
	end
end


function Shock5( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if (caster.nobuorb1 == "item_kokumo" or caster.nobuorb1 == nil) and not target:IsBuilding() and caster.gokokumo == nil then
		caster.nobuorb1 = "item_kokumo"
		caster.gokokumo = 1
		Timers:CreateTimer(0.1, function() 
				caster.gokokumo = nil
			end)
		local ran =  RandomInt(0, 100)
		if (caster.kokumo == nil) then
			caster.kokumo = 0
		end
		if (ran > 20) then
			caster.kokumo = caster.kokumo + 1
		end
		if (caster.kokumo > (100/20) or ran <= 20) then
			caster.kokumo = 0
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
							target:GetAbsOrigin(),
							nil,
							425,
							DOTA_UNIT_TARGET_TEAM_ENEMY,
							DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
							DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
							FIND_ANY_ORDER,
							false)
		AMHC:Damage(caster,target,600,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		for _,it in pairs(direUnits) do
			ability:ApplyDataDrivenModifier(caster, it,"modifier_frozen_ring",{duration=4})
			if it ~= target then
				AMHC:Damage(caster,it,300,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		local particle = ParticleManager:CreateParticle("particles/a34e2/a34e2.vpcf", PATTACH_ABSORIGIN, target)
		Timers:CreateTimer(4, function ()
			ParticleManager:DestroyParticle(particle, true)
			end)
		end
	end
end

