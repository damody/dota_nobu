--御魔護符
LinkLuaModifier( "modifier_block", "items/Addon_Items/modifier_block.lua",LUA_MODIFIER_MOTION_NONE )
modifier_block = class({})

function modifier_block:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_ATTRIBUTE_MULTIPLE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_block:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_block:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_block:GetAttributes()
        return        MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_block:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    local shield = nil
	    if (self.caster ~= nil) and IsValidEntity(self.caster) then
		    if victim:GetTeam() ~= attacker:GetTeam() and attacker == self.caster then
		        if damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
		            if (damage_type ~= DAMAGE_TYPE_MAGICAL) then
		            	for i=1,self:GetStackCount() do
			            	if RandomInt(0,100) < 25 then
			            		local hp = self.hp-self.caster:GetHealth()
			            		PopupDamageBlock(attacker, hp)
			            		self.caster:SetHealth(self.hp)
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
	if (caster:FindModifierByName("modifier_block") ~= nil) then
		local hModifier = caster:FindModifierByName("modifier_block")
		local scount = hModifier:GetStackCount()
		hModifier:SetStackCount(scount + 1)
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_block", {} )
		local hModifier = caster:FindModifierByName("modifier_block")
		hModifier:SetStackCount(1)
		hModifier.caster = caster
		hModifier.hp = caster:GetHealth()
	end
	
	if caster.has_item_block == nil then
		caster.has_item_block = 1
	else
		caster.has_item_block = caster.has_item_block + 1
	end
	Timers:CreateTimer(1, function() 
		if (caster:IsAlive() and not caster:HasModifier("modifier_block")) then
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_block", {} )
			caster:FindModifierByName("modifier_block").caster = caster
			caster:FindModifierByName("modifier_block").hp = caster:GetHealth()
		end
		if caster.has_item_block > 0 then
			return 1
		else
			caster:RemoveModifierByName("modifier_block")
			return nil
		end
		end)
end

function OnUnequip( keys )
	local caster = keys.caster
	caster.has_item_block = caster.has_item_block - 1
	if (caster:FindModifierByName("modifier_block") ~= nil) then
		local hModifier = caster:FindModifierByName("modifier_block")
		local scount = hModifier:GetStackCount()
		hModifier:SetStackCount(scount - 1)
	end
end
