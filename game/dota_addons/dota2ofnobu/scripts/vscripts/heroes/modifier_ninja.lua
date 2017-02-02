modifier_ninja = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_ninja:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_ninja:GetModifierModelChange()
	return "models/heroes/rikimaru/rikimaru.vmdl"
end

function modifier_ninja:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_ninja:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_ROOTED] = true,
	}

	return state
end

function modifier_ninja:IsHidden() 
	return true
end

function modifier_ninja:IsDebuff()
	return false
end

