modifier_cavalry = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_cavalry:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_cavalry:GetModifierModelChange()
	return "models/cavalry/cavalry.vmdl"
end

function modifier_cavalry:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_cavalry:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end

function modifier_cavalry:IsHidden() 
	return true
end

function modifier_cavalry:IsDebuff()
	return false
end

