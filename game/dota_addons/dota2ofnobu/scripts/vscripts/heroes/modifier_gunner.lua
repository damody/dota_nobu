modifier_gunner = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_gunner:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_gunner:GetModifierModelChange()
	return "models/arquebusier/arquebusier.vmdl"
end

function modifier_gunner:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_gunner:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_gunner:IsHidden() 
	return true
end

function modifier_gunner:IsDebuff()
	return false
end

