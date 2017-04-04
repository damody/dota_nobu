--制魔腹卷
LinkLuaModifier( "modifier_devil_supressor_armor", "items/Addon_Items/item_devil_supressor_armor.lua",LUA_MODIFIER_MOTION_NONE )
modifier_devil_supressor_armor = class({})

--------------------------------------------------------------------------------

function modifier_devil_supressor_armor:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_devil_supressor_armor:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_devil_supressor_armor:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_devil_supressor_armor:OnTakeDamage(event)
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
		            	if self.magic_shield > 0 then
		            		print("999 "..self.magic_shield)
		            		if self.magic_shield > return_damage then
		            			self.magic_shield = self.magic_shield - return_damage
		            			self.caster:SetHealth(self.hp)
		            		else
		            			ParticleManager:DestroyParticle(self.shield_effect, false)
		            			self.caster:SetHealth(self.caster:GetHealth() + self.magic_shield)
		            			self.magic_shield = 0
		            		end
		            	end
		            end 
		        end
		    end
		end
	end
end


function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	keys.SHP1 = tonumber(keys.SHP1)
	keys.SHP2 = tonumber(keys.SHP2)

	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	          caster:GetAbsOrigin(),
	          nil,
	          1000,
	          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	          DOTA_UNIT_TARGET_FLAG_NONE,
	          0,
	          false)
	for _,target in pairs(direUnits) do
		ShockTarget(keys, target)
	end

end

function ShockTarget( keys, target )
	local caster = keys.caster
	local ability = keys.ability
	local havetime = 20
	ability:ApplyDataDrivenModifier( caster, target, "modifier_devil_supressor_armor", {duration = havetime} )
	target:FindModifierByName("modifier_devil_supressor_armor").caster = target
	target:FindModifierByName("modifier_devil_supressor_armor").hp = target:GetHealth()
	if target:IsHero() then
		target:FindModifierByName("modifier_devil_supressor_armor").magic_shield = keys.SHP2
	else
		target:FindModifierByName("modifier_devil_supressor_armor").magic_shield = keys.SHP1
	end
	local shield = ParticleManager:CreateParticle("particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	target:FindModifierByName("modifier_devil_supressor_armor").shield_effect = shield
	local sumtime = 0
	local isend = false
	Timers:CreateTimer(havetime, function() 
			isend = true
		end)
	Timers:CreateTimer(0, function() 
			if IsValidEntity(target) then
				ParticleManager:SetParticleControl(shield,1,target:GetAbsOrigin()+Vector(0, 0, 0))
			else
				isend = true
			end
			if not isend then
				return 0.2
			else
				ParticleManager:DestroyParticle(shield, false)
				return nil
			end
		end)
end
