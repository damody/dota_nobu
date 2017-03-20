modifier_B13D = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_B13D:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}

	return funcs
end

function modifier_B13D:GetModifierModelChange()
	--找不到模組
	return "models/particle/crater.vmdl"
end

function modifier_B13D:GetModifierModelScale()
	return 5
end

function modifier_B13D:CheckState()
	local state = {
	[MODIFIER_STATE_INVISIBLE] = true,
	}

	return state
end

function modifier_B13D:IsHidden() 
	return true
end

function modifier_B13D:IsDebuff()
	return false
end

function modifier_B13D:IsPurgable()
	return false
end
