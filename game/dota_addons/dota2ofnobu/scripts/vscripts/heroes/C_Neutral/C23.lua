--加藤清正

function C23W_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	local ability = caster:FindAbilityByName("C23R")

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C23R_onSpell",{duration=4})
end

function modifier_C23W_OnIntervalThink( keys )

	local caster = keys.caster             
	local ability = keys.ability
	local targets = FindUnitsInRadius(caster:GetTeamNumber(),	
					caster:GetAbsOrigin(),nil,400,DOTA_UNIT_TARGET_TEAM_ENEMY, 
			   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			   		0, 
			   		FIND_ANY_ORDER, 
					false) 
		--對所有範圍內的敵人執行動作
	for i,unit in pairs(targets) do
		--對目標傷害
		for i=1,3 do
			local ifx = ParticleManager:CreateParticle("particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf",PATTACH_ABSORIGIN,unit)
			ParticleManager:SetParticleControl(ifx,0,unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(ifx,1,unit:GetAbsOrigin())
		end
		damage=ability:GetSpecialValueFor("damage")+ability:GetSpecialValueFor("health_damage")*caster:GetMaxHealth()/100
		AMHC:Damage(caster,unit, damage, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end




function C23E_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	local targetpoint = keys.target_points[1]
	local ability = keys.ability
	local ability2 = caster:FindAbilityByName("C23R")
	ability2:ApplyDataDrivenModifier(caster,caster,"modifier_C23R_onSpell",{duration=4})
	local point = caster:GetAbsOrigin()
	local dir = (targetpoint-point):Normalized()
	caster:SetForwardVector(dir)
	local point2 = point + dir * 300
 	local player = caster:GetPlayerID()
 	local level = ability:GetLevel() - 1
 	local life_time = ability:GetLevelSpecialValueFor("life_time",level)
 	local base_hp = ability:GetLevelSpecialValueFor("base_hp",level)

 	for i=1,14 do
 		local point3=point + dir * 161 * i
 		local targets = FindUnitsInRadius(caster:GetTeamNumber(),	
					point3,nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY, 
			   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			   		0, 
			   		FIND_ANY_ORDER, 
					false) 
		--對所有範圍內的敵人執行動作
		for i,unit in pairs(targets) do
			unit:AddNewModifier(unit,nil,"modifier_phased",{duration=0.1})
		end
		local Kagutsuchi = CreateUnitByName("C23W_unit", point3,false,caster,caster,caster:GetTeam())
	 	Kagutsuchi:SetOwner(caster)
	 	-- 設定火神數值
	 	Kagutsuchi:SetForwardVector(dir)
		--Kagutsuchi:SetControllableByPlayer(player, true)
		Kagutsuchi:AddNewModifier(Kagutsuchi,nil,"modifier_kill",{duration=life_time})
		ability:ApplyDataDrivenModifier(caster,Kagutsuchi,"modifier_C23E_aura",{duration=life_time})
		ability:ApplyDataDrivenModifier(caster,Kagutsuchi,"modifier_C23E_aura_checkFly",{duration=life_time})
		ExecuteOrderFromTable( { UnitIndex = Kagutsuchi:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = Kagutsuchi:GetAbsOrigin() })
	end
 
end


function modifier_C23R_OnTakeDamage( event )
	-- Variables

	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		local caster = event.caster
		local attacker= event.attacker
		if ability then
			local crit_chance = ability:GetSpecialValueFor("chance")
			local rnd = RandomInt(1,100)
			if caster.C23R_count == nil then
				caster.C23R_count = 0
			end
			caster.C23R_count = caster.C23R_count + 1
			if crit_chance >= rnd or caster.C23R_count > (100/crit_chance) and not caster:FindModifierByName("modifier_C23R_onSpell") then
				local heal = ability:GetSpecialValueFor("heal")
				caster.C23R_count = 0
				local newHealth = caster:GetHealth() + damage + damage*heal/100
				caster:SetHealth(newHealth)
			end
		end
	end
end


function modifier_C23R_onSpell_OnTakeDamage( event )
	-- Variables

	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		local caster = event.caster
		local attacker= event.attacker
		if ability then
			local heal = ability:GetSpecialValueFor("heal")
			local newHealth = caster:GetHealth() + damage + damage*heal/100
			caster:SetHealth(newHealth)
			if caster:FindModifierByName("modifier_C23R_onSpell") then
				caster:RemoveModifierByName("modifier_C23R_onSpell")
			end
		end
	end
end


function C23T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local casterhealth=caster:GetHealthPercent()
	local targethealth=target:GetHealthPercent()
	local ability2 = caster:FindAbilityByName("C23R")
	ability2:ApplyDataDrivenModifier(caster,caster,"modifier_C23R_onSpell",{duration=4})
	caster:SetHealth(caster:GetMaxHealth()*targethealth/100)
	if not target:IsMagicImmune() then
		target:SetHealth(target:GetMaxHealth()*casterhealth/100)
	end
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
	Timers:CreateTimer(0.2,function()
		local order = {UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()}
		ExecuteOrderFromTable(order)
		end)
end

function modifier_C23E_aura_onAttackLanded( keys )
	local unit = keys.target
	local ifx = ParticleManager:CreateParticle("particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf",PATTACH_ABSORIGIN,unit)
	ParticleManager:SetParticleControl(ifx,0,unit:GetAbsOrigin())
	ParticleManager:SetParticleControl(ifx,1,unit:GetAbsOrigin())
end

function modifier_C23E_checkFly_OnCreated( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target==caster then
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C23E_fly",{})
	end
end

function modifier_C23E_checkFly_OnDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target==caster then
		caster:RemoveModifierByName("modifier_C23E_fly")
	end
end