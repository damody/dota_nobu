--御魔護符
LinkLuaModifier( "modifier_magic_talisman", "items/Addon_Items/item_magic_talisman.lua",LUA_MODIFIER_MOTION_NONE )
modifier_magic_talisman = class({})

--------------------------------------------------------------------------------

function modifier_magic_talisman:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_magic_talisman:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_magic_talisman:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_magic_talisman:OnTakeDamage(event)
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
		            if (damage_type == DAMAGE_TYPE_MAGICAL) and self.caster.magic_talisman == true then
		            	Timers:CreateTimer(0.01, function() 
		            		self.caster.magic_talisman = false
		            		self.caster:Purge( false, true, true, true, true)
		            		end)
		            	if (IsValidEntity(self.caster) and self.caster:IsAlive()) then
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
								if item ~= nil and item:GetName() == "item_magic_talisman" then
									hasitem = true
									item:StartCooldown(30)
								end
							end
							Timers:CreateTimer(30, function() 
								self.caster.magic_talisman = true
								print("self.caster.magic_talisman")
							end)
						end
		            else
		                if not victim:IsMagicImmune() then

		                end 
		            end 
		        end 
		    end
		end
	end
end


function OnEquip( keys )
	local caster = keys.caster
	local ability = keys.ability
	if (caster.magic_talisman == nil) then
		caster.magic_talisman = true
	end
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_magic_talisman", {} )
	caster:FindModifierByName("modifier_magic_talisman").caster = caster
	caster:FindModifierByName("modifier_magic_talisman").hp = 1
	caster.has_item_magic_talisman = true
	Timers:CreateTimer(1, function() 
		if (caster:IsAlive() and not caster:HasModifier("modifier_magic_talisman")) then
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_magic_talisman", {} )
			caster:FindModifierByName("modifier_magic_talisman").caster = caster
		end
		if caster.has_item_magic_talisman == true then
			return 1
		else
			caster:RemoveModifierByName("modifier_magic_talisman")
			return nil
		end
		end)
end

function OnUnequip( keys )
	keys.caster.has_item_magic_talisman = nil
end
