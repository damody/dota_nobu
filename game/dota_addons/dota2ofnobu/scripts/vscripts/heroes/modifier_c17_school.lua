modifier_c17_school = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_c17_school:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE
	}

	return funcs
end

function modifier_c17_school:GetModifierModelChange()
	return "models/c17/c17_school.vmdl"
end

function modifier_c17_school:GetModifierModelScale()
	return 2
end

function modifier_c17_school:CheckState()
	local state = {
	}

	return state
end

function modifier_c17_school:IsHidden() 
	return false
end

function modifier_c17_school:IsDebuff()
	return false
end

function modifier_c17_school:IsBuff()
	return true
end

function modifier_c17_school:IsPurgable()
	return false
end
