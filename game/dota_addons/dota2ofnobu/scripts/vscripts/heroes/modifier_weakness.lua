modifier_weakness = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_weakness:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_weakness:GetModifierModelChange()
	return "models/items/undying/idol_of_ruination/ruin_wight_minion_gold.vmdl"
end

function modifier_weakness:GetModifierMoveSpeedOverride()
	return 150
end

function modifier_weakness:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_EVADE_DISABLED] = true,
	[MODIFIER_STATE_BLOCK_DISABLED] = true,
	[MODIFIER_STATE_SILENCED] = true
	}

	return state
end

function modifier_weakness:IsHidden() 
	return false
end

function modifier_weakness:IsDebuff()
	return true
end

function modifier_weakness:IsPurgable()
	return true
end
