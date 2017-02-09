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
	caster.abilityName = "A12W"

	if caster.A12D_B == true then
	    local group = {}
	    local radius = 500
	    group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)
		for _,v in ipairs(group) do
			ability:ApplyDataDrivenModifier(caster,v,"modifier_A12W",nil)
		end

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
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A12E_2",nil)
		ParticleManager:CreateParticle("particles/a12w2/a12w2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	else
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A12E",nil)
		ParticleManager:CreateParticle("particles/a12w/a12w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end

	--print("@@" .. tostring(caster.A12D_B) .. "   +   " ..  tostring(caster.A12D_Time))
	caster.A12D_B = false --最後一定要加	
end



function A12E_Attack( keys )
	local caster = keys.attacker
	local ability = keys.ability
	local cure_count = ability:GetLevelSpecialValueFor("CureMana",ability:GetLevel() - 1) 
	local chance = ability:GetLevelSpecialValueFor("Chance",ability:GetLevel() - 1) 
	--print("CHANCE"..tostring(caster.A12E_CHANCE))
	if caster:IsAlive()  then
		if caster.A12E_CHANCE >= 7 then 
			caster.A12E_CHANCE = RandomInt(0,10)
			if caster:HasModifier("modifier_A12E_2") then
				local cure = caster:GetMaxMana() * cure_count / 100
				caster:SetMana(caster:GetMana() + cure)
				caster:Heal(cure,caster)
				AMHC:CreateNumberEffect(caster,cure,2,AMHC.MSG_ORIT ,{0,0,225},0)
				AMHC:CreateNumberEffect(caster,cure,2,AMHC.MSG_ORIT ,{0,225,0},0)
				ParticleManager:CreateParticle("particles/a12w2/a12w2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)				
			elseif caster:HasModifier("modifier_A12E") then
				local cure = caster:GetMaxMana() * cure_count / 100
				caster:SetMana(caster:GetMana() + cure)
				AMHC:CreateNumberEffect(caster,cure,2,AMHC.MSG_ORIT ,{0,0,225},0)
				ParticleManager:CreateParticle("particles/a12w/a12w.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			end
		else
			caster.A12E_CHANCE = caster.A12E_CHANCE + 1
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
	local damage = 0 
		if caster:GetMana() > 30 and not target:IsBuilding() and caster.nobuorb1 == nil then
			if caster.A12T == true then
				damage = caster:GetMana()*special_dmg/100*3
			else
				damage = caster:GetMana()*special_dmg/100
			end
			
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


function A12D_HIDE( keys )
	local caster = keys.caster
	
	Timers:CreateTimer(0.1, function()
		local name = caster.abilityName
		--print("A12D_HIDE ",name)
		if  name == "A12D" then
			caster:FindAbilityByName("A12D"):SetActivated(false)
			caster.A12D_B = true
			caster.A12D_Time = 0
			ParticleManager:CreateParticle("particles/a12w2/a12w2.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		else
			if name == "A12W" or name == "A12E" or name == "A12R" then
				caster.A12D_Time  = caster.A12D_Time  + 1
				if caster.A12D_Time  >= 4 then
					caster:FindAbilityByName("A12D"):SetActivated(true)
				end
			end	
		end
		end)
end

function A12D_HIDE_Learn( keys )
	local caster = keys.caster
	caster.A12D_Time = 0
	caster.A12D_B = false
	caster.A12E_CHANCE = RandomInt(0,10)
end

function A12D( keys )
	local caster = keys.caster
	caster.abilityName = "A12D"
end

