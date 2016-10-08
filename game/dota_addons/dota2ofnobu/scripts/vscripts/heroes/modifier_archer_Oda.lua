modifier_archer_Oda = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_archer_Oda:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_archer_Oda:GetModifierModelChange()
	return "models/archer/archer.vmdl"
end

function modifier_archer_Oda:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_archer_Oda:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_archer_Oda:IsHidden() 
	return true
end

function modifier_archer_Oda:IsDebuff()
	return false
end

