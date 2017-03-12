modifier_long_a31 = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_long_a31:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function modifier_long_a31:GetModifierModelChange()
	return "models/a31/a31_long.vmdl"
end


function modifier_long_a31:CheckState()
	local state = {
	}

	return state
end

function modifier_long_a31:IsHidden() 
	return false
end

function modifier_long_a31:IsDebuff()
	return true
end

function modifier_long_a31:IsPurgable()
	return true
end
