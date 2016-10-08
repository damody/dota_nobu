modifier_soldier_Oda = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_soldier_Oda:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_soldier_Oda:GetModifierModelChange()
	return "models/ashigaru/ashigaru_b.vmdl"
end

function modifier_soldier_Oda:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_soldier_Oda:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

function modifier_soldier_Oda:IsHidden() 
	return true
end

function modifier_soldier_Oda:IsDebuff()
	return false
end

