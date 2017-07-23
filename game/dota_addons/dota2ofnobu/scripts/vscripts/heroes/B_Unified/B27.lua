LinkLuaModifier( "modifier_protection_b27r_old", "scripts/vscripts/heroes/B_Unified/B27.lua",LUA_MODIFIER_MOTION_NONE )
modifier_protection_b27r_old = class({})

--------------------------------------------------------------------------------

function modifier_protection_b27r_old:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_protection_b27r_old:OnCreated( event )
	self:StartIntervalThink(0.2)
end

function modifier_protection_b27r_old:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
		self.mp = self.caster:GetMana()
	end
end

function modifier_protection_b27r_old:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    if (self.caster ~= nil) and IsValidEntity(self.caster) then

		    if victim:GetTeam() ~= attacker:GetTeam() and attacker == self.caster then
		        if damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
		            if (damage_type ~= DAMAGE_TYPE_PHYSICAL) then
		            	Timers:CreateTimer(0.01, function() 
		            		if IsValidEntity(self.caster) then
			            		self.caster:Purge( false, true, true, true, true)
			            		local am = self.caster:FindAllModifiers()
								for _,v in pairs(am) do
									if IsValidEntity(v:GetParent()) and IsValidEntity(self.caster) and IsValidEntity(v:GetCaster()) then
										if v:GetParent():GetTeamNumber() ~= self.caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= self.caster:GetTeamNumber() then
											if _G.EXCLUDE_MODIFIER_NAME[v:GetName()] == nil then
												self.caster:RemoveModifierByName(v:GetName())
											end
											if v:GetElapsedTime() < 0.1 and _G.EXCLUDE_MODIFIER_NAME[v:GetName()] == true then
												self.caster:RemoveModifierByName(v:GetName())
											end
										end
									end
								end
								if IsValidEntity(self.caster) then
									if self:GetStackCount() > 1 then
										self:SetStackCount(self:GetStackCount() - 1)
									else
										self.caster:RemoveModifierByName("modifier_protection_b27r_old")
										ParticleManager:DestroyParticle(self.caster.B27R_effect,false)
										caster.B27R_effect = nil
									end
								end
							end
		            		end)
		            	
		            	if (IsValidEntity(self.caster) and self.caster:IsAlive()) then
			            	self.caster:SetHealth(self.hp)
			            	self.caster:SetMana(self.mp)
							local count = 0
							AmpDamageParticle = ParticleManager:CreateParticle("particles/econ/items/puck/puck_merry_wanderer/puck_illusory_orb_explode_merry_wanderer.vpcf", PATTACH_POINT_FOLLOW, self.caster)
							ParticleManager:SetParticleControlEnt(AmpDamageParticle,3,self.caster,PATTACH_POINT_FOLLOW,"attach_hitloc",self.caster:GetAbsOrigin(),true)
							ParticleManager:ReleaseParticleIndex(AmpDamageParticle)
							EmitSoundOn("DOTA_Item.VeilofDiscord.Activate",self.caster)
						end
		            end 
		        end 
		    end
		end
	end
end

function B27R_old_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	if not caster:HasModifier("modifier_protection_b27r_old") and IsValidEntity(ability) and ability:IsCooldownReady() then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_protection_b27r_old", {} )
		local handle = caster:FindModifierByName("modifier_protection_b27r_old")
		handle.caster = caster
		handle.hp = caster:GetHealth()
		handle.mp = caster:GetMana()
		handle:SetStackCount(1)
		ability:StartCooldown(ability:GetCooldown(-1))

		local shield_size = 1000
		if caster.B27R_effect then
			ParticleManager:DestroyParticle(caster.B27R_effect,false)
		end
		caster.B27R_effect = ParticleManager:CreateParticle("particles/b27/b27r_old.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(caster.B27R_effect, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.B27R_effect, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.B27R_effect, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(caster.B27R_effect, 5, Vector(shield_size,0,0))
		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(caster.B27R_effect, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end
	local handle = caster:FindModifierByName("modifier_protection_b27r_old")
	if handle then
		if handle:GetStackCount() < ability:GetLevel()*2 and ability:IsCooldownReady() then
			handle:SetStackCount(handle:GetStackCount()+1)
			ability:StartCooldown(ability:GetCooldown(-1))
		end
	end
end

function B27R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local center = caster:GetAbsOrigin()
	local duration = ability:GetSpecialValueFor("duration")
	AMHC:AddModelScale(caster, 1.3, duration)
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
				caster:RemoveModifierByName(v:GetName())
			end
		end
	end
end

function B27E_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	Timers:CreateTimer(0.1, function()
		if IsValidEntity(target) and target:HasModifier("modifier_B27E") then
			caster:SetAbsOrigin(target:GetAbsOrigin())
			caster:AddNewModifier( nil, nil, "modifier_phased", { duration = 0.1 } )
			local order = {UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()}
			ExecuteOrderFromTable(order)
		end
		end)
end

function B27T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration",level)
	local particle = ParticleManager:CreateParticle("particles/b27/b27t.vpcf", PATTACH_ABSORIGIN, caster)

	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  1000 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	for _, it in pairs(group) do
		if it:IsHero() then
			ParticleManager:CreateParticle("particles/shake2.vpcf", PATTACH_ABSORIGIN, it)
		end
		AMHC:Damage( caster,it, ability:GetLevelSpecialValueFor("dmg",level),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		ability:ApplyDataDrivenModifier(it,it,"modifier_B27T",{duration = duration})
	end
	tsum = 0.1
	Timers:CreateTimer(0.1, function()
		for _, it in pairs(group) do
			if it:IsHero() then
				if IsValidEntity(it) and not it:HasModifier("modifier_B27T") then
					ability:ApplyDataDrivenModifier(it,it,"modifier_B27T",{duration = duration-tsum})
				end
			end
		end
		tsum = tsum + 0.1
		end)
end

function B27T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration",level)
	local particle = ParticleManager:CreateParticle("particles/b27/b27t.vpcf", PATTACH_ABSORIGIN, caster)

	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  1000 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	for _, it in pairs(group) do
		if it:IsHero() then
			ParticleManager:CreateParticle("particles/shake2.vpcf", PATTACH_ABSORIGIN, it)
		end
		AMHC:Damage( caster,it, ability:GetLevelSpecialValueFor("dmg",level),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		ability:ApplyDataDrivenModifier(it,it,"modifier_B27T",{duration = duration})
	end
	tsum = 0.1
	Timers:CreateTimer(0.1, function()
		for _, it in pairs(group) do
			if it:IsHero() then
				if IsValidEntity(it) and not it:HasModifier("modifier_B27T") then
					ability:ApplyDataDrivenModifier(it,it,"modifier_B27T",{duration = duration-tsum})
				end
			end
		end
		tsum = tsum + 0.1
		end)
end
