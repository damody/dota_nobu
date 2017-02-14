--南蠻胴具足
LinkLuaModifier( "modifier_nannbann_armor", "items/Addon_Items/item_nannbann_armor.lua",LUA_MODIFIER_MOTION_NONE )
modifier_nannbann_armor = class({})


LinkLuaModifier( "modifier_nannbann_armor2", "items/Addon_Items/item_nannbann_armor.lua",LUA_MODIFIER_MOTION_NONE )
modifier_nannbann_armor2 = class({})
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
		            if (damage_type ~= DAMAGE_TYPE_PHYSICAL) and self.caster.nannbann_armor == true then
		            	Timers:CreateTimer(0.01, function() 
		            		self.caster.nannbann_armor = false
		            		self.caster:Purge( false, true, true, true, true)
		            		event.caster = self.caster
			            	event.ability = self:GetAbility()
			            	ShockTarget(event, self.caster)
			            	local am = self.caster:FindAllModifiers()
							for _,v in pairs(am) do
								if v:GetParent():GetTeamNumber() ~= self.caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= self.caster:GetTeamNumber() then
									self.caster:RemoveModifierByName(v:GetName())
								end
							end
		            		end)

		            	if (IsValidEntity(self.caster) and self.caster:IsAlive()) then
			            	self.caster:SetHealth(self.hp)
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
									item:StartCooldown(40)
								end
							end
							Timers:CreateTimer(40, function() 
								if IsValidEntity(self.caster) then
									self.caster.nannbann_armor = true
								end
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
	caster:FindModifierByName("modifier_nannbann_armor").hp = caster:GetHealth()
	caster.has_item_nannbann_armor = true
	Timers:CreateTimer(1, function() 
		if not IsValidEntity(caster) then
			return nil
		end
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


--------------------------------------------------------------------------------

function modifier_nannbann_armor2:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_nannbann_armor2:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_nannbann_armor2:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_nannbann_armor2:OnTakeDamage(event)
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
		            			if (self.hp > self.caster:GetHealth() + self.magic_shield) then
		            				self.caster:SetHealth(self.caster:GetHealth() + self.magic_shield)
		            			else
		            				self.caster:SetHealth(self.hp)
		            			end
		            			self.magic_shield = 0
		            		end
		            	end
		            end 
		        end
		    end
		end
	end
end


function ShockTarget( keys, target )
	local caster = keys.caster
	local ability = keys.ability
	local havetime = 10
	ability:ApplyDataDrivenModifier( caster, target, "modifier_nannbann_armor2", {duration = havetime} )
	target:FindModifierByName("modifier_nannbann_armor2").caster = target
	target:FindModifierByName("modifier_nannbann_armor2").hp = target:GetHealth()
	target:FindModifierByName("modifier_nannbann_armor2").magic_shield = 1000
	local shield = ParticleManager:CreateParticle("particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	target:FindModifierByName("modifier_nannbann_armor2").shield_effect = shield
	local sumtime = 0
	local isend = false
	Timers:CreateTimer(havetime, function() 
			isend = true
		end)
	Timers:CreateTimer(0, function() 
			ParticleManager:SetParticleControl(shield,1,target:GetAbsOrigin()+Vector(0, 0, 0))
			if not isend then
				return 0.2
			else
				ParticleManager:DestroyParticle(shield, false)
				return nil
			end
		end)
end


