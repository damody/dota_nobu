-- LinkLuaModifier( "A12W_modifier", "scripts/vscripts/heroes/A_Oda/A12.lua",LUA_MODIFIER_MOTION_NONE )

-- A12W_modifier = class ({})
-- function A12W_modifier:OnCreated(event)
-- 	AMHC:CreateParticle("particles/b15t/b15t.vpcf",PATTACH_ABSORIGIN,false,self:GetCaster(),2.0,nil)
-- 	print("A12W")
-- end
-- function A12W_modifier:IsHidden()
-- 	return false
-- end

-- function A12W_modifier:IsDebuff()
-- 	return true
-- end

function A12W( keys )
	-- if keys.ability:GetLevel() == 1 then
	-- 	keys.caster:AddNewModifier(keys.caster, keys.ability, "A12W_modifier", { duration = nil}) 
	-- 	if keys.caster:FindModifierByName("A12W_modifier") 	~= nil then
	-- 		print("A12W learn")
	-- 	end
	-- end
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	caster.abilityName = "A12W"
	local group = {}
    local radius = 500
    group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
    local knockbackProperties =
	{
		center_x = point.x,
		center_y = point.y,
		center_z = point.z,
		duration = 0.3,
		knockback_duration = 0.3,
		knockback_distance = 400,
		knockback_height = 0,
		should_stun = 1
	}
	for _,v in ipairs(group) do
		ParticleManager:CreateParticle("particles/a12w/a12w.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
		v:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
	end
	if caster.A12D_B == true then
		ability:ApplyDataDrivenModifier(caster,v,"modifier_A12W",nil)
		ParticleManager:CreateParticle("particles/a12w2/a12w2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	else
		ParticleManager:CreateParticle("particles/a12w/a12w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end

	caster.A12D_B = false --最後一定要加
end

function A12E( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster.abilityName = "A12E"
	if caster.A12D_B == true then
		print("A12E A12D_B")
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A12E_2",nil)
		ParticleManager:CreateParticle("particles/a12w2/a12w2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	else
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A12E",nil)
		ParticleManager:CreateParticle("particles/a12w/a12w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end

	--print("@@" .. tostring(caster.A12D_B) .. "   +   " ..  tostring(caster.A12D_Time))
	caster.A12D_B = false --最後一定要加	
end

function A12E_OnAttackLanded1( keys )
	local caster = keys.attacker
	local ability = keys.ability
	local cure_count = ability:GetLevelSpecialValueFor("CureMana",ability:GetLevel() - 1) 
	local chance = ability:GetLevelSpecialValueFor("Chance",ability:GetLevel() - 1) 
	--print("CHANCE"..tostring(caster.A12E_CHANCE))
	caster.A12E_CHANCE = RandomInt(0,10)
	if caster:IsAlive()  then
		if caster.A12E_CHANCE >= 7 then 
			local cure = caster:GetMaxMana() * cure_count / 100
			caster:SetMana(caster:GetMana() + cure)
			AMHC:CreateNumberEffect(caster,cure,2,AMHC.MSG_ORIT ,{0,0,225},0)
			ParticleManager:CreateParticle("particles/a12w/a12w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		end
	end
end

function A12E_OnAttackLanded2( keys )
	local caster = keys.attacker
	local ability = keys.ability
	local cure_count = ability:GetLevelSpecialValueFor("CureMana",ability:GetLevel() - 1) 
	local chance = ability:GetLevelSpecialValueFor("Chance",ability:GetLevel() - 1) 
	--print("CHANCE"..tostring(caster.A12E_CHANCE))
	if caster.A12E_CHANCE == nil then
		caster.A12E_CHANCE = 0
	end
	caster.A12E_CHANCE = RandomInt(0,10)
	if caster:IsAlive()  then
		if caster.A12E_CHANCE >= 7 then 
			local cure = caster:GetMaxMana() * cure_count / 100
			caster:SetMana(caster:GetMana() + cure)
			caster:Heal(cure,caster)
			AMHC:CreateNumberEffect(caster,cure,2,AMHC.MSG_ORIT ,{0,0,225},0)
			AMHC:CreateNumberEffect(caster,cure,2,AMHC.MSG_ORIT ,{0,225,0},0)
			ParticleManager:CreateParticle("particles/a12w2/a12w2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
		end
	end
end

function A12R( keys )
	local caster		= keys.caster
	local ability	= keys.ability
	local point = ability:GetCursorPosition()
	caster.abilityName = "A12R"
	local particle=ParticleManager:CreateParticle("particles/a12r2/a12r2.vpcf",PATTACH_POINT,caster)
	local Special_damage = ability:GetLevelSpecialValueFor("Special_damage",ability:GetLevel() - 1)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,1,Vector(1000,1000,0))

	ParticleManager:SetParticleControl(ParticleManager:CreateParticle("particles/a12r/a12r.vpcf",PATTACH_POINT,caster),0,point)
	Timers:CreateTimer( 0.4, function()
		ParticleManager:DestroyParticle(particle,true)
	end )

	if caster.A12D_B == true then
		ParticleManager:CreateParticle("particles/a12w2/a12w2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	    local group = {}
	    local radius = 500
	    local damage = 0
	    group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		for _,v in ipairs(group) do
			damage = v:GetMaxHealth()*Special_damage/100
			AMHC:Damage( caster,v,damage,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end

	caster.A12D_B = false --最後一定要加	
end

function OnToggleOn( keys )
	local caster = keys.caster
	caster.nobuorb1 = nil
end

function OnToggleOff( keys )
	local caster = keys.caster
end

function A12T( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local special_dmg = ability:GetLevelSpecialValueFor("Special_Damage",ability:GetLevel() - 1)
	local SpendMana = ability:GetLevelSpecialValueFor("SpendMana",ability:GetLevel() - 1)
	local damage = 0 
		if caster:GetMana() > 30 and not target:IsBuilding() and caster.nobuorb1 == nil then
			if caster.A12T == true then
				caster:SetMana(SpendMana*5+caster:GetMana())
			end
			damage = caster:GetMana()*special_dmg/100
			if (target:IsMagicImmune()) then
				AMHC:Damage( caster,target,damage*0.30,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			else
				AMHC:Damage( caster,target,damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
			AMHC:CreateNumberEffect(target,damage,2,AMHC.MSG_ORIT ,{0,0,225},4)
			--print("A12T"..tostring(damage))		
		end
	caster.A12T = false
end

function A12T_Start( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local special_dmg = ability:GetLevelSpecialValueFor("Special_Damage",ability:GetLevel() - 1)
	local damage = 0
	local SpendMana = ability:GetLevelSpecialValueFor("SpendMana",ability:GetLevel() - 1)
	
	if caster:GetMana() > 30 and not target:IsBuilding() then
		print("SpendManaSpendMana")
		caster:SpendMana(SpendMana,ability)	--消耗mana
		if caster:GetMana() < SpendMana then
		else
			caster.A12D_Time  = caster.A12D_Time  + 1
			if caster.A12D_Time  == 4 then
				caster:FindAbilityByName("A12D"):SetLevel(1)
			end

			if caster.A12D_B == true then
				ParticleManager:CreateParticle("particles/a12w2/a12w2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				caster.A12T = true
			else
				caster.A12T = false
			end
			caster.A12D_B = false			
		end
	end	
end


function A12D_OnAbilityExecuted( keys )
	if keys.event_ability:IsToggle() then return end
	local caster = keys.caster
	local handle = caster:FindModifierByName("modifier_A12D")
	
	if handle then
		if handle:GetStackCount() < 4 then
			handle:SetStackCount(handle:GetStackCount() + 1)
		end
		if handle:GetStackCount() >= 4 then
			caster:FindAbilityByName("A12D"):SetActivated(true)
		end
		caster.A12D_Time = handle:GetStackCount()

		local name = keys.event_ability:GetName()
		if name == "A12D" then
			caster:FindAbilityByName("A12D"):SetActivated(false)
			caster.A12D_B = true
			caster.A12D_Time = 0
			handle:SetStackCount(0)
		end
	end
end

function A12D( keys )
	local caster = keys.caster
	caster.abilityName = "A12D"
end

