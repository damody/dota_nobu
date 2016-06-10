A07T = class({})

--[[Author: Noya
	Date: 27.01.2016.
	Changes the model of the unit into the Dragon Knight Elder Dragon Form model as long as the modifier is active]]
function A07T:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function A07T:GetModifierModelChange()
	return "models/honda/honde_possessed.vmdl"
end

function A07T:IsHidden() 
	return true
end