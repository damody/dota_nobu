modifier_archer = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_archer:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_archer:GetModifierModelChange()
	return "models/archer/archer.vmdl"
end

function modifier_archer:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_archer:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end

function modifier_archer:IsHidden() 
	return true
end

function modifier_archer:IsDebuff()
	return false
end

