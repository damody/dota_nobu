modifier_war_magic = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_war_magic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_war_magic:GetModifierModelChange()
	return "models/heroes/juggernaut/jugg_healing_ward.vmdl"
end

function modifier_war_magic:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_war_magic:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_war_magic:IsHidden() 
	return true
end

function modifier_war_magic:IsDebuff()
	return false
end

