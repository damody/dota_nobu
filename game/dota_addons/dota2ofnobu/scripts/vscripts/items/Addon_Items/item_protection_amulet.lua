LinkLuaModifier( "modifier_protection_amulet", "items/Addon_Items/item_protection_amulet.lua",LUA_MODIFIER_MOTION_NONE )
modifier_protection_amulet = class({})

--------------------------------------------------------------------------------

function modifier_protection_amulet:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_protection_amulet:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_protection_amulet:OnIntervalThink()
	if (self.caster ~= nil) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_protection_amulet:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    if (self.caster ~= nil) then

		    if victim:GetTeam() ~= attacker:GetTeam() and attacker == self.caster then
		        if damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
		            if (damage_type == DAMAGE_TYPE_MAGICAL) and self.caster.protection_amulet == true then
		            	Timers:CreateTimer(0.1, function() 
		            		self.caster.protection_amulet = false
		            		self.caster:Purge( false, true, true, true, true)
		            		end)
		            	self.caster:SetHealth(self.hp)
						local am = self.caster:FindAllModifiers()
						for _,v in pairs(am) do
							if v:GetParent():GetTeamNumber() ~= self.caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= self.caster:GetTeamNumber() then
								self.caster:RemoveModifierByName(v:GetName())
							end
						end
		            	-- Strong Dispel 刪除負面效果
		            	self.caster:Purge( false, true, true, true, true)
						local count = 0
						AmpDamageParticle = ParticleManager:CreateParticle("particles/a07w4/a07w4_c.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster)
						Timers:CreateTimer(1.0, function() 
							ParticleManager:DestroyParticle(AmpDamageParticle, false)
						end)
						for itemSlot=0,5 do
							local item = self.caster:GetItemInSlot(itemSlot)
							if item ~= nil and item:GetName() == "item_protection_amulet" then
								hasitem = true
								item:StartCooldown(30)
							end
						end
						Timers:CreateTimer(30, function() 
							self.caster.protection_amulet = true
							print("self.caster.protection_amulet")
						end)
		            else
		                if not victim:IsMagicImmune() then

		                end 
		            end 
		        end 
		    end
		end
	end
end


--御守

function OnEquip( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster.protection_amulet = true
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_protection_amulet", {} )
	caster:FindModifierByName("modifier_protection_amulet").caster = caster
	caster.has_item_protection_amulet = true
	Timers:CreateTimer(1, function() 
		if (caster:IsAlive() and not caster:HasModifier("modifier_protection_amulet")) then
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_protection_amulet", {} )
			caster:FindModifierByName("modifier_protection_amulet").caster = caster
		end
		if caster.has_item_protection_amulet == true then
			return 1
		else
			caster:RemoveModifierByName("modifier_protection_amulet")
			return nil
		end
		end)
end

function OnUnequip( keys )
	keys.caster.has_item_protection_amulet = nil
end
