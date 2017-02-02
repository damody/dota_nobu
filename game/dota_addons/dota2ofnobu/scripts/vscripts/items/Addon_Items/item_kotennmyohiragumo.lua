--平蜘蛛釜
LinkLuaModifier( "modifier_kotennmyohiragumo", "items/Addon_Items/item_kotennmyohiragumo.lua",LUA_MODIFIER_MOTION_NONE )
modifier_kotennmyohiragumo = class({})

--------------------------------------------------------------------------------

function modifier_kotennmyohiragumo:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_kotennmyohiragumo:OnCreated( event )
	self:StartIntervalThink(0.1) 
end

function modifier_kotennmyohiragumo:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_kotennmyohiragumo:OnTakeDamage(event)
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
		            if (damage_type == DAMAGE_TYPE_MAGICAL) then
		            	self.caster:SetHealth(self.hp+return_damage)
		            end 
		        end
		    end
		end
	end
end


function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	ShockTarget(keys, keys.target)
end

function ShockTarget( keys, target )
	local caster = keys.caster
	local ability = keys.ability
	local havetime = 10
	ability:ApplyDataDrivenModifier( caster, target, "modifier_kotennmyohiragumo", {duration = havetime} )
	target:FindModifierByName("modifier_kotennmyohiragumo").caster = target
	target:FindModifierByName("modifier_kotennmyohiragumo").hp = caster:GetHealth()
	target:FindModifierByName("modifier_kotennmyohiragumo").magic_shield = 1000
	local shield = ParticleManager:CreateParticle("particles/econ/events/ti6/radiance_owner_ti6_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	target:FindModifierByName("modifier_kotennmyohiragumo").shield_effect = shield
	local sumtime = 0
	local isend = false
	Timers:CreateTimer(havetime, function() 
			isend = true
		end)
	Timers:CreateTimer(0, function() 
			ParticleManager:SetParticleControl(shield,3,target:GetAbsOrigin()+Vector(0, 0, 0))
			if not isend then
				return 0.2
			else
				ParticleManager:DestroyParticle(shield, false)
				return nil
			end
		end)
end
