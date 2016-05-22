C20W = class({})

--[[Author: Noya
	Date: 27.01.2016.
	Changes the model of the unit into the Dragon Knight Elder Dragon Form model as long as the modifier is active]]
function C20W:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}

	return funcs
end

function C20W:GetModifierModelChange()
	return "models/heroes/shredder/shredder_chakram.vmdl"
end

function C20W:IsHidden() 
	return true
end