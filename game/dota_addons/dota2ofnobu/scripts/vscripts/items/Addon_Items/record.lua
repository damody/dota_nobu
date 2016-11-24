--記錄傷害用

modifier_record = class({})

--------------------------------------------------------------------------------

function modifier_record:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_record:OnCreated( event )
	
end

function modifier_record:IsHidden()
    return true
end

function modifier_record:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    if (self.caster ~= nil) and IsValidEntity(self.caster) then
	    	if self.caster.damage == nil then
	    		self.caster.damage = 0
	    	end
	    	if self.caster.takedamage == nil then
	    		self.caster.takedamage = 0
	    	end
	    	if self.caster.herodamage == nil then
	    		self.caster.herodamage = 0
	    	end
	    	if attacker:GetEntityIndex() == self.caster:GetEntityIndex() then
	    		self.caster.damage = self.caster.damage + return_damage
	    	end

		    if victim:GetEntityIndex() == self.caster:GetEntityIndex() then
		    	self.caster.takedamage = self.caster.takedamage + return_damage
		    	if attacker:IsRealHero() and not attacker:IsIllusion() then
		    		self.caster.herodamage = self.caster.herodamage + return_damage
		    	end
		    end
		end
	end
end

function Start( keys )
	local caster = keys.caster
	local ability = keys.ability
	--local target = keys.target
	caster.damage = 0
	caster.takedamage = 0
	caster.herodamage = 0
	caster:AddNewModifier(caster,ability,"modifier_record",{})
	caster:FindModifierByName("modifier_record").caster = caster
	Timers:CreateTimer(1,function()
		if not caster:HasModifier("modifier_record") then
			caster:AddNewModifier(caster,ability,"modifier_record",{})
			caster:FindModifierByName("modifier_record").caster = caster
		end
		return 1
		end)
	
end

