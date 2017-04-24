--石川武又位門
function modifier_C06D_OnKill( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	if target:IsHero() and not target:IsIllusion() and not caster:IsIllusion() then
		AMHC:GivePlayerGold_UnReliable(caster:GetPlayerOwnerID(), 100)
	else
		AMHC:GivePlayerGold_UnReliable(caster:GetPlayerOwnerID(), 4)
	end
end

function C06W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability


	caster.c06w_atk_time=ability:GetSpecialValueFor("attack_times")
	if caster:FindModifierByName("modifier_C06T") then
		caster.c06w_atk_time=ability:GetSpecialValueFor("attack_times")+2
	end
	--print(caster.c06w_atk_time)
	--local item = CreateItem("item_money",nil, nil)
	--CreateItemOnPositionSync(caster:GetAbsOrigin(), item)
	--caster.item_money = item
	--item:SetAbsOrigin(caster:GetAbsOrigin())
end


function modifier_C06W_OnAttackLanded( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster.c06w_atk_time=caster.c06w_atk_time-1
	if caster.c06w_atk_time <=0 then
		caster:RemoveModifierByName("modifier_C06W")
	end
end




function C06E_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local itemnumber=caster:GetNumItemsInInventory()
	local rnd = RandomInt(0,5)
	for i=1,10 do
		local particle = ParticleManager:CreateParticle("particles/c06e/c06e2.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle,0, target:GetAbsOrigin())
	end
	local money=ability:GetSpecialValueFor("money")

	AMHC:GivePlayerGold_UnReliable(caster:GetPlayerOwnerID(), money)
	AMHC:GivePlayerGold_UnReliable(target:GetPlayerOwnerID(), -money)
	
	--local item=CreateItem("item_c06e",caster,caster)
	local item1=target:GetItemInSlot(rnd)
	local number={}
	for i=0,5 do
		item1=target:GetItemInSlot(i)
		if item1 and item1:GetAbilityName()~="item_c06e" then
			table.insert(number,i)
		end
	end
	if #number > 0 then
        local rnd = RandomInt(1,table.getn(number))
		item1=target:GetItemInSlot(number[rnd])

		--print("total"..itemnumber)
		--print(item1:GetAbilityName())
		item2=CreateItem("item_c06e",target,target)
		item2.c06edamage=ability:GetSpecialValueFor("damage")
		item2.swapitem=item1:GetAbilityName()
		target:RemoveItem(item1)
		target:AddItem(item2)
	else
		print("no legal")
	end

	if caster:FindModifierByName("modifier_C06T") then
		AMHC:Damage(keys.target,keys.target,400,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
end


function C06EW_OnSpellStart( keys )
		--print("testlegal")
end

function item_c06e_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.caster
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()

	--【Varible】
	--local duration = ability:GetLevelSpecialValueFor("duration",level)
	--local radius = ability:GetLevelSpecialValueFor("radius",level)
	local time = 2
	if target:IsMagicImmune() then

	else
		ability:ApplyDataDrivenModifier( caster, target, "modifier_item_c06e", {duration = 2.5} )
	end
	AMHC:Damage(caster,target, ability.c06edamage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )

	for i=0,3 do
		local particle2 = ParticleManager:CreateParticle("particles/c06e/c06e.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle2,0, point2+Vector(0,0,i*40))
		ParticleManager:SetParticleControl(particle2,1, Vector(1.5,1.5,1.5))	
		ParticleManager:SetParticleControl(particle2,3, point2)	
		Timers:CreateTimer(1,function ()
			ParticleManager:DestroyParticle(particle2,true)
		end	)
	end
	--caster
	--caster:AddItem(ability.swapitem
	caster:RemoveItem(ability)
	caster:AddItemByName(ability.swapitem)
end

function C06R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C06R",nil)
	local target=keys.target
	local shield_size = 30 
	Timers:CreateTimer(0.01, function() 
		caster.ShieldParticle = ParticleManager:CreateParticle("particles/a07w5/a07w5.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(caster.ShieldParticle, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.ShieldParticle, 5, Vector(shield_size,0,0))

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(caster.ShieldParticle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)--attach_attack1
	end)
end

function modifier_C06R_OnDestroy( event )
	local target = event.target
	if target.ShieldParticle ~= nil then
		ParticleManager:DestroyParticle(target.ShieldParticle,false)
		target.ShieldParticle = nil
	end
	target:RemoveModifierByName("modifier_C06R")
end

function modifier_C06R_OnCreated( event )
	local unit = event.target
	local ability=event.ability
	local caster =ability:GetCaster()
	local shield = ability:GetSpecialValueFor("shield")
	--print(caster:GetGold())
	local max_damage_absorb = ability:GetSpecialValueFor("damage_absorb")+caster:GetGold()*shield

	-- Reset the shield
	if event.caster:FindModifierByName("modifier_C06T") then
		max_damage_absorb = ability:GetSpecialValueFor("damage_absorb")+caster:GetGold()*5/100 +300
	end
	unit.AphoticShieldRemaining = max_damage_absorb

end

function modifier_C06R_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local damage = event.DamageTaken
		local unit = event.unit
		local ability = event.ability
		local caster =ability:GetCaster()
		
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
			unit.AphoticShieldRemaining = nil
			--移除特效
			unit:RemoveModifierByName("modifier_C06R")
		end
	end
end


function modifier_C06R_onattack_OnAttackLanded( event )
	local target = event.target
	--print(target:GetMagicalArmorValue())
	--print(event.caster:GetMagicalArmorValue())
	--print(100-target:GetMagicalArmorValue())
	if not target:IsBuilding() then
		local ability = event.ability
		local caster = ability:GetCaster()
		local damage = caster:GetGold()*0.04
		local maxdamage = ability:GetSpecialValueFor("maxdamage")
		if damage > maxdamage then
			damage = maxdamage
		end
		local damageTable = {victim=target,   
			attacker=caster,         
			damage=damage,
			damage_type=ability:GetAbilityDamageType()}
		if event.caster:IsIllusion() then
			damageTable.damage = 0
		end
		if event.caster:FindModifierByName("modifier_C06T") then
			damageTable.damage=damageTable.damage+50
		end
		if target:IsMagicImmune() then
			damageTable.damage=damageTable.damage*0.5
			ApplyDamage(damageTable)
		else
			ApplyDamage(damageTable)
		end
	end
end



function C06T_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	for i=1,3 do
		local particle = ParticleManager:CreateParticle("particles/c06t/c06t.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle,0, target:GetAbsOrigin())
	end
	local money=300
	--[[
	ability2=caster:AddAbility("C06EW")
	ability2:SetLevel(1)
	for i=1,money do
		--ability2:CastAbility()
	end
	caster:RemoveAbility("C06EW")
	]]
	for i=1,10 do
		if PlayerResource:GetGold(target:GetPlayerOwnerID()) > 50 then
			local item = CreateItem("item_money",nil, nil)
			local r=RandomVector(RandomInt(100,500))
			r=r+caster:GetAbsOrigin()
			CreateItemOnPositionSync(r, item)
			--caster.item_money = item

			--print(r)
			item:SetAbsOrigin(r)
			AMHC:GivePlayerGold_UnReliable(target:GetPlayerOwnerID(), -50)
		end
	end


	AMHC:GivePlayerGold_UnReliable(caster:GetPlayerOwnerID(), 300)
	AMHC:GivePlayerGold_UnReliable(target:GetPlayerOwnerID(), -300)
		local order = {UnitIndex =  keys.caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = keys.target:entindex()}

	ExecuteOrderFromTable(order)

end

function C06D_old_OnAbilityPhaseStart( keys )
	local caster = keys.caster
	--caster:Stop()
	print("C06D_old_OnAbilityPhaseStart")
	if GameRules:IsDaytime() or caster:FindModifierByName("modifier_C06D_old_check") then
		caster:Interrupt()
		print("C06D_old_OnAbilityPhaseStart")
	end
end

function C06D_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	caster:Stop()
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_C06D_old", {} )
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_invisible", {} )
end



function C06E_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	for i=1,10 do
		local particle = ParticleManager:CreateParticle("particles/c06e/c06e2.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle,0, target:GetAbsOrigin())
	end
	local level=ability:GetSpecialValueFor("level")
	local money=target:GetGoldBounty()
	
	ExecuteOrderFromTable(order)
	if not target:IsHero() then
		AMHC:GivePlayerGold_UnReliable(caster:GetPlayerOwnerID(), money)
		AMHC:Damage(caster,keys.target,keys.target:GetMaxHealth(),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	end
end




function C06T_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	for i=1,3 do
		local particle = ParticleManager:CreateParticle("particles/c06t/c06t.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle,0, target:GetAbsOrigin())
	end
	AMHC:GivePlayerGold_UnReliable(caster:GetPlayerOwnerID(), 800)
	AMHC:GivePlayerGold_UnReliable(target:GetPlayerOwnerID(), -800)
		local order = {UnitIndex =  keys.caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = keys.target:entindex()}

	ExecuteOrderFromTable(order)
	ability:ApplyDataDrivenModifier( caster, target , "modifier_stunned" , {duration=ability:GetSpecialValueFor("stun")} )
	AMHC:Damage(keys.caster,keys.target,ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
end
