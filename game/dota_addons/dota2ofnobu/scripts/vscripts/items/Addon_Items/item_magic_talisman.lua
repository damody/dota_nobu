--御魔護符
LinkLuaModifier( "modifier_magic_talisman", "items/Addon_Items/item_magic_talisman.lua",LUA_MODIFIER_MOTION_NONE )
modifier_magic_talisman = class({})


LinkLuaModifier( "modifier_magic_talisman2", "items/Addon_Items/item_magic_talisman.lua",LUA_MODIFIER_MOTION_NONE )
modifier_magic_talisman2 = class({})
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
		self.mp = self.caster:GetMana()
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
		            if (damage_type ~= DAMAGE_TYPE_PHYSICAL) then
		            	Timers:CreateTimer(0.01, function() 
		            		if IsValidEntity(self.caster) then
			            		self.caster:Purge( false, true, true, true, true)
			            		event.caster = self.caster
				            	if IsValidEntity(ability) then
					            	event.ability = self:GetAbility()
					            	ShockTarget(event, self.caster)
					            end
				            	local am = self.caster:FindAllModifiers()
								for _,v in pairs(am) do
									if IsValidEntity(v:GetParent()) and IsValidEntity(self.caster) and IsValidEntity(v:GetCaster()) then
										if v:GetParent():GetTeamNumber() ~= self.caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= self.caster:GetTeamNumber() then
											self.caster:RemoveModifierByName(v:GetName())
										end
									end
								end
								self.caster:RemoveModifierByName("modifier_magic_talisman")
							end
		            		end)
		            	if (IsValidEntity(self.caster) and self.caster:IsAlive()) then

		            		if self.caster:HasModifier("modifier_magic_talisman2") then
		            			self.caster:RemoveModifierByName("modifier_magic_talisman2")
		            		end 
			            	self.caster:SetHealth(self.hp)
			            	self.caster:SetMana(self.mp)
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
									item:StartCooldown(20)
								end
							end
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
	caster.has_item_magic_talisman = true
	Timers:CreateTimer(1, function()
		if caster:IsAlive() then
			if not caster:HasModifier("modifier_magic_talisman") and IsValidEntity(ability) and ability:IsCooldownReady() then
				ability:ApplyDataDrivenModifier( caster, caster, "modifier_magic_talisman", {} )
				local handle = caster:FindModifierByName("modifier_magic_talisman")
				handle.caster = caster
				handle.hp = caster:GetHealth()
				handle.mp = caster:GetMana()
			elseif caster.has_item_magic_talisman == true then
				return 0.5
			else
				caster:RemoveModifierByName("modifier_magic_talisman")
				return nil
			end
		end
		return 1
		end)
end

function OnUnequip( keys )
	keys.caster.has_item_magic_talisman = nil
end

--------------------------------------------------------------------------------

function modifier_magic_talisman2:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_magic_talisman2:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_magic_talisman2:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_magic_talisman2:OnTakeDamage(event)
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
	local havetime = 5
	local shield = -1
	ability:ApplyDataDrivenModifier( caster, target, "modifier_magic_talisman2", {duration = havetime} )
	if target:FindModifierByName("modifier_magic_talisman2") then
		target:FindModifierByName("modifier_magic_talisman2").caster = target
		target:FindModifierByName("modifier_magic_talisman2").hp = target:GetHealth()
		target:FindModifierByName("modifier_magic_talisman2").magic_shield = 500
		shield = ParticleManager:CreateParticle("particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		target:FindModifierByName("modifier_magic_talisman2").shield_effect = shield
	end
	local sumtime = 0
	local isend = false
	Timers:CreateTimer(havetime, function() 
			isend = true
		end)
	Timers:CreateTimer(0, function()
			if shield == -1 then
				return nil
			end
			if IsValidEntity(target) then
				ParticleManager:SetParticleControl(shield,1,target:GetAbsOrigin()+Vector(0, 0, 0))
			else
				ParticleManager:DestroyParticle(shield, false)
				return nil
			end
			if not isend then
				return 0.2
			else
				ParticleManager:DestroyParticle(shield, false)
				return nil
			end
		end)
end

