modifier_ninja2 = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_ninja2:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}

	return funcs
end

function modifier_ninja2:GetModifierModelChange()
	return "models/particle/crater.vmdl"
end

function modifier_ninja2:GetModifierModelScale()
	return 10
end

function modifier_ninja2:GetModifierMoveSpeedOverride()
	return 0
end

function modifier_ninja2:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end

function modifier_ninja2:IsHidden() 
	return true
end

function modifier_ninja2:IsDebuff()
	return false
end

