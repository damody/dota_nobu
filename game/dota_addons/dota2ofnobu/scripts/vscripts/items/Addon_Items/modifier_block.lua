LinkLuaModifier( "modifier_block15", "items/Addon_Items/modifier_block.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_block25", "items/Addon_Items/modifier_block.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_block25", "items/Addon_Items/modifier_block.lua",LUA_MODIFIER_MOTION_NONE )
modifier_block25 = class({})

function modifier_block25:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_block25:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_block25:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_block25:GetAttributes()
        return        MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_block25:OnTakeDamage(event)
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
	if (caster:FindModifierByName("modifier_block25") ~= nil) then
		local hModifier = caster:FindModifierByName("modifier_block25")
		local scount = hModifier:GetStackCount()
		hModifier:SetStackCount(scount + 1)
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_block25", {} )
		local hModifier = caster:FindModifierByName("modifier_block25")
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
		if (caster:IsAlive() and not caster:HasModifier("modifier_block25")) then
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_block25", {} )
			caster:FindModifierByName("modifier_block25").caster = caster
			caster:FindModifierByName("modifier_block25").hp = caster:GetHealth()
		end
		if caster.has_item_block > 0 then
			return 1
		else
			caster:RemoveModifierByName("modifier_block25")
			return nil
		end
		end)
end

function OnUnequip( keys )
	local caster = keys.caster
	caster.has_item_block = caster.has_item_block - 1
	if (caster:FindModifierByName("modifier_block25") ~= nil) then
		local hModifier = caster:FindModifierByName("modifier_block25")
		local scount = hModifier:GetStackCount()
		hModifier:SetStackCount(scount - 1)
	end
end


modifier_block15 = class({})

function modifier_block15:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

--------------------------------------------------------------------------------

function modifier_block15:OnCreated( event )
	self:StartIntervalThink(0.2) 
end

function modifier_block15:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_block15:GetAttributes()
        return        MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_block15:OnTakeDamage(event)
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


function OnEquip15( keys )
	local caster = keys.caster
	local ability = keys.ability
	if (caster:FindModifierByName("modifier_block15") ~= nil) then
		local hModifier = caster:FindModifierByName("modifier_block15")
		local scount = hModifier:GetStackCount()
		hModifier:SetStackCount(scount + 1)
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_block15", {} )
		local hModifier = caster:FindModifierByName("modifier_block15")
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
		if (caster:IsAlive() and not caster:HasModifier("modifier_block15")) then
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_block15", {} )
			caster:FindModifierByName("modifier_block15").caster = caster
			caster:FindModifierByName("modifier_block15").hp = caster:GetHealth()
		end
		if caster.has_item_block > 0 then
			return 1
		else
			caster:RemoveModifierByName("modifier_block15")
			return nil
		end
		end)
end

function OnUnequip15( keys )
	local caster = keys.caster
	caster.has_item_block = caster.has_item_block - 1
	if (caster:FindModifierByName("modifier_block15") ~= nil) then
		local hModifier = caster:FindModifierByName("modifier_block15")
		local scount = hModifier:GetStackCount()
		hModifier:SetStackCount(scount - 1)
	end
end
