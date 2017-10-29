--吹雪護肩

LinkLuaModifier( "modifier_fubuki_shoulders", "items/Addon_Items/item_fubuki_shoulders.lua",LUA_MODIFIER_MOTION_NONE )
modifier_fubuki_shoulders = class({})

--------------------------------------------------------------------------------

function modifier_fubuki_shoulders:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_fubuki_shoulders:OnCreated( event )
	self:StartIntervalThink(0.1)
end

function modifier_fubuki_shoulders:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_fubuki_shoulders:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    if (self.caster ~= nil) and IsValidEntity(self.caster) then

		    if victim:GetTeam() ~= attacker:GetTeam() and attacker == self.caster and self.hp ~= nil then
		        local dmg = event.damage
				local healmax = dmg*0.30
				local mana = healmax / 2.5

				if (self.caster:GetMana() >= mana and self.caster:GetHealth() > healmax) then
					self.caster:SpendMana(mana,ability)
					self.caster:SetHealth(self.caster:GetHealth() + healmax)
				end
		    end
		end
	end
end

function Start( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	caster:AddNewModifier(caster,ability,"modifier_fubuki_shoulders",{duration=7})
	caster:FindModifierByName("modifier_fubuki_shoulders").caster = caster
	caster:FindModifierByName("modifier_fubuki_shoulders").hp = caster:GetHealth()
	local particle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local shield_size = 50
	ParticleManager:SetParticleControl(particle, 1, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(particle, 2, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(particle, 4, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(particle, 5, Vector(shield_size,0,0))
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	Timers:CreateTimer(7, function ()
		ParticleManager:DestroyParticle(particle, true)
		end)
end

function Start2( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	caster:AddNewModifier(caster,ability,"modifier_fubuki_shoulders",{duration=14})
	caster:FindModifierByName("modifier_fubuki_shoulders").caster = caster
	local particle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local shield_size = 50
	ParticleManager:SetParticleControl(particle, 1, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(particle, 2, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(particle, 4, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(particle, 5, Vector(shield_size,0,0))
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	Timers:CreateTimer(14, function ()
		ParticleManager:DestroyParticle(particle, true)
		end)
end

