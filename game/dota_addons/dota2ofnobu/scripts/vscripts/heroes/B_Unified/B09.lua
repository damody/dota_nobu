--真田昌幸

function modifier_B09W_OnCreated( keys )
	local ability= keys.ability
	local caster = keys.caster
	local target = keys.target
	local B09W_counter=0
	target.max_count=8
	--local buff=target:FindModifierByName("modifier_B09W_counter")
	--buff:SetStackCount(8)
	--local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_trigger_ground_symbol_add.vpcf", PATTACH_ABSORIGIN, caster)
	--ParticleManager:SetParticleControl(particle, 0, point)
	--AMHC:Damage( caster,target,ability:GetAbilityDamage(),AMHC:DamageType("DAMAGE_TYPE_MAGICAL") )
	local count = 0
	Timers:CreateTimer(0, function()
		print(count - math.floor(count/10)*10)
		if target:HasModifier("modifier_B09W_counter") then
			if math.mod(count, 10) == 0 then
				if target:IsMagicImmune() then
					AMHC:Damage( caster,target,ability:GetAbilityDamage()*B09W_counter*0.5,AMHC:DamageType("DAMAGE_TYPE_PURE") )
				else
					AMHC:Damage( caster,target,ability:GetAbilityDamage()*B09W_counter,AMHC:DamageType("DAMAGE_TYPE_PURE") )
				end
			end
		elseif target:IsMagicImmune() then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B09W_counter", {duration=20-B09W_counter})
		else
			return nil
		end
		B09W_counter=B09W_counter+0.1
		count = count + 1
		if B09W_counter>=target.max_count then
			target:RemoveModifierByName("modifier_B09W")
			target:RemoveModifierByName("modifier_B09W_counter")
			return nil
		else
			return 0.1
		end
    end)
end

function modifier_B09W_OnAbilityExecuted( keys )
	local target =keys.unit
	local ability=keys.ability
	local b09W_max_count=keys.ability:GetSpecialValueFor("max_count")
	local buff=target:FindModifierByName("modifier_B09W")
	local buff_count=target:FindModifierByName("modifier_B09W_counter")
	if target.max_count<b09W_max_count then
		target.max_count=target.max_count+1
		buff_count:SetStackCount(target.max_count)
		print(buff:GetRemainingTime())
		buff:SetDuration(buff:GetRemainingTime()+1,true)
	end

end



function modifier_B09E_OnIntervalThink( keys )
	for i,v in pairs(keys) do
        print(tostring(i).."="..tostring(v))
    end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point = target:GetAbsOrigin()
	local damage = ability:GetSpecialValueFor("damage")/100*caster:GetMaxMana()+55
	local ifx = ParticleManager:CreateParticle( "particles/b09e/b09e3.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,50))
	ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,50))
	Timers:CreateTimer(0.5, function ()
		ParticleManager:DestroyParticle(ifx,true)
	end)
	local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 400, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if not unit:IsBuilding() then
			ApplyDamage(damageTable)
		end
	end

	local distance=(caster:GetAbsOrigin()-target:GetAbsOrigin()):Length()

				--超出距離摧毀特效 停止計時
	if distance> ability:GetSpecialValueFor("max_range") then
		caster:InterruptChannel()	
	end
end


function B09E_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	caster.B09E_target = target

	local particle3 = ParticleManager:CreateParticle("particles/b09e/b09e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle3, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle3, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	Timers:CreateTimer(0.2, function ()
      	if target ~= nil and IsValidEntity(target) and target:HasModifier("modifier_B09E") then
      		local particle2 = ParticleManager:CreateParticle("particles/b09e/b09e.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(particle2, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle2, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
      		return 0.2
      	else
      		caster.B09E_target = nil
      		--ParticleManager:DestroyParticle(particle,false)
      		return nil
      	end
    end)
end


LinkLuaModifier( "modifier_B09R", "heroes/B_Unified/B09.lua",LUA_MODIFIER_MOTION_NONE )
modifier_B09R = class({})

--------------------------------------------------------------------------------

function modifier_B09R:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_B09R:OnCreated( event )
	self:StartIntervalThink(0.1)
end

function modifier_B09R:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_B09R:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    if (self.caster ~= nil) and IsValidEntity(self.caster) then

		    if victim:GetTeam() ~= attacker:GetTeam() and attacker == self.caster and self.hp ~= nil then
		        local dmg = self.hp - self.caster:GetHealth()
				local healmax = dmg*0.3
				local mana = healmax / self.b09r_manadamage
				if (self.caster:GetMana() >= mana and self.caster:GetHealth() > healmax) then
					self.caster:SpendMana(mana,ability)
					self.caster:SetHealth(self.caster:GetHealth() + healmax)
				end
		    end
		end
	end
end



function B09R_OnToggleOn( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	caster:AddNewModifier(caster,ability,"modifier_B09R",nil)
	caster:FindModifierByName("modifier_B09R").caster = caster
	caster:FindModifierByName("modifier_B09R").hp = caster:GetHealth()
	caster:FindModifierByName("modifier_B09R").b09r_manadamage=ability:GetSpecialValueFor("manadamage")
	caster.b09r_particle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local shield_size = 50
	ParticleManager:SetParticleControl(caster.b09r_particle, 1, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(caster.b09r_particle, 2, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(caster.b09r_particle, 4, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(caster.b09r_particle, 5, Vector(shield_size,0,0))
	ParticleManager:SetParticleControlEnt(caster.b09r_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
end

function B09R_OnToggleOff( keys )
	keys.caster:RemoveModifierByName("modifier_B09R")
	if keys.caster.b09r_particle then
		ParticleManager:DestroyParticle(keys.caster.b09r_particle, true)
	end
end


function B09T_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
          point,
          nil,
          700,
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
          0,
          false)
	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=1} )
	dummy:SetOwner( caster)
	dummy:AddAbility( "majia"):SetLevel(1)
	local flame = ParticleManager:CreateParticle("particles/b09/b09_t.vpcf", PATTACH_ABSORIGIN, dummy)
	ParticleManager:SetParticleControl(flame,4,point+Vector(0, 0, 20))
	Timers:CreateTimer(1, function ()
		ParticleManager:DestroyParticle(flame, false)
	end)	
	
	for _,target in pairs(direUnits) do
		if not target:IsBuilding() then
			if (target:IsMagicImmune()) then
				ability:ApplyDataDrivenModifier(caster,target,"modifier_B09T",{duration = duration*0.5})
				target:SetMana(target:GetMana()*0.4)
			else
				target:SetMana(target:GetMana()*0.4)
				ability:ApplyDataDrivenModifier(caster,target,"modifier_B09T",{duration = duration})
				AMHC:Damage(caster,target, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			end
		end
	end
end


