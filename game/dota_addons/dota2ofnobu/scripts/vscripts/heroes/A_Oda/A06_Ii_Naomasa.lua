
LinkLuaModifier( "modifier_A06W_old", "scripts/vscripts/heroes/A_Oda/A06_Ii_Naomasa.lua",LUA_MODIFIER_MOTION_NONE )
modifier_A06W_old = class({})

--------------------------------------------------------------------------------

function modifier_A06W_old:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_A06W_old:OnCreated( event )
	self:StartIntervalThink(0.1)
end

function modifier_A06W_old:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_A06W_old:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    if (self.caster ~= nil) and IsValidEntity(self.caster) and self.caster.compute == nil then
	    	self.caster.compute = 1
	    	if attacker:GetEntityIndex() == self.caster:GetEntityIndex() then
	    		AMHC:Damage( victim,self.caster,return_damage * self.percent,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	    	end
		end
		self.caster.compute = nil
	end
end

function A06W_old( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
	caster:AddNewModifier(caster,ability,"modifier_A06W_old",{duration=14})
	caster:FindModifierByName("modifier_A06W_old").caster = caster
	caster:FindModifierByName("modifier_A06W_old").percent = ability:GetSpecialValueFor("A06W_dmg")
end

function A06E_old( keys )
	-- Variables
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
	ability:ApplyDataDrivenModifier(caster,target,"modifier_A06E",{})
	Physics:Unit(target)
	target:SetPhysicsVelocity((target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()*2000)
end

function A06R_OnAttack(keys)
	local caster = keys.caster
	local id  = caster:GetPlayerID()
	local skill = keys.ability
	local level = keys.ability:GetLevel()
	if caster:HasModifier("modifier_A06R_to_A06D") == false then
		skill:ApplyDataDrivenModifier(caster,caster,"modifier_A06R_to_A06D",{})
		local hModifier = caster:FindModifierByNameAndCaster("modifier_A06R_to_A06D", hCaster)
		hModifier:SetStackCount(1)
	else
		local hModifier = caster:FindModifierByNameAndCaster("modifier_A06R_to_A06D", hCaster)
		local scount = hModifier:GetStackCount()
		scount = scount + 1
		if (scount <= 14) then
			hModifier:SetStackCount(scount)
		end
		if (scount >= 5) then
			local ability = caster:FindAbilityByName("A06D")
			ability:SetLevel(level)
			ability:SetActivated(true)
		end
	end
end

function A06D_Use(keys)
	local caster = keys.caster
	local hModifier = caster:FindModifierByNameAndCaster("modifier_A06R_to_A06D", hCaster)
	if hModifier~= nil then
		hModifier:SetStackCount(hModifier:GetStackCount() - 5)
		if (hModifier:GetStackCount() < 5) then
			caster:FindAbilityByName("A06D"):SetActivated(false)
		end	
	else
		caster:FindAbilityByName("A06D"):SetActivated(false)
	end
end

function A06T_Start(keys)
	local caster = keys.caster
	caster.a06t_count = 0
end

function A06T_Count(keys)
	local caster = keys.caster
	caster.a06t_count = caster.a06t_count + 1
	if caster.a06t_count >= 7 then
		caster.a06t_count = nil
		caster:RemoveModifierByName("modifier_A06T")
	end
end

function A06T_old(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if not target:IsBuilding() then
		local ran =  RandomInt(1, 100)
		if ran > 25 or caster.nextA06T_old == 1 then
			local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
			nil,  450 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
			for _, it in pairs(group) do
				AMHC:CreateParticle("particles/b06e4/b06e4_b.vpcf",PATTACH_ABSORIGIN,false,it,0.5,nil)
				if it:IsMagicImmune() then
					AMHC:Damage( caster,it, ability:GetSpecialValueFor("dmg")*0.5,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				else
					AMHC:Damage( caster,it, ability:GetSpecialValueFor("dmg"),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				end
			end
			caster.nextA06T_old = nil
		else
			caster.nextA06T_old = 1
		end
	end
end