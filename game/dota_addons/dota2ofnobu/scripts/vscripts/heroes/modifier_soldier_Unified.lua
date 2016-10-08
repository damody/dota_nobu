modifier_soldier_Unified = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_soldier_Unified:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_soldier_Unified:GetModifierModelChange()
	return "models/ashigaru/ashigaru.vmdl"
end

function modifier_soldier_Unified:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_soldier_Unified:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_soldier_Unified:IsHidden() 
	return true
end

function modifier_soldier_Unified:IsDebuff()
	return false
end

