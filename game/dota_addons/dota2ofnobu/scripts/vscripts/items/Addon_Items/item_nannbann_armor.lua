--南蠻胴具足
LinkLuaModifier( "modifier_nannbann_armor", "items/Addon_Items/item_nannbann_armor.lua",LUA_MODIFIER_MOTION_NONE )
modifier_nannbann_armor = class({})

--------------------------------------------------------------------------------

function modifier_nannbann_armor:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_nannbann_armor:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_nannbann_armor:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_nannbann_armor:OnTakeDamage(event)
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
		            if (damage_type == DAMAGE_TYPE_MAGICAL) and self.caster.nannbann_armor == true then
		            	Timers:CreateTimer(0.01, function() 
		            		self.caster.nannbann_armor = false
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
								if item ~= nil and item:GetName() == "item_nannbann_armor" then
									hasitem = true
									item:StartCooldown(20)
								end
							end
							Timers:CreateTimer(20, function() 
								self.caster.nannbann_armor = true
								print("self.caster.nannbann_armor")
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
	if (caster.nannbann_armor == nil) then
		caster.nannbann_armor = true
	end
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_nannbann_armor", {} )
	caster:FindModifierByName("modifier_nannbann_armor").caster = caster
	caster:FindModifierByName("modifier_nannbann_armor").hp = 1
	caster.has_item_nannbann_armor = true
	Timers:CreateTimer(1, function() 
		if (caster:IsAlive() and not caster:HasModifier("modifier_nannbann_armor")) then
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_nannbann_armor", {} )
			caster:FindModifierByName("modifier_nannbann_armor").caster = caster
		end
		if caster.has_item_nannbann_armor == true then
			return 1
		else
			caster:RemoveModifierByName("modifier_nannbann_armor")
			return nil
		end
		end)
end

function OnUnequip( keys )
	keys.caster.has_item_nannbann_armor = nil
end
