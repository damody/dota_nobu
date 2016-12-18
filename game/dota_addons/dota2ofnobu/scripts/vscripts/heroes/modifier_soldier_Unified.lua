modifier_soldier_unified = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_soldier_unified:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_soldier_unified:GetModifierModelChange()
	return "models/ashigaru/ashigaru.vmdl"
end

function modifier_soldier_unified:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_soldier_unified:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_soldier_unified:IsHidden() 
	return true
end

function modifier_soldier_unified:IsDebuff()
	return false
end

