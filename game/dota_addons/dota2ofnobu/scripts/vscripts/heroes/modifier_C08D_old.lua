modifier_C08D_old = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_C08D_old:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_C08D_old:GetModifierModelChange()
	--找不到模組
	return "models/props_tree/cypress/tree_cypress009.vmdl"
end

function modifier_C08D_old:GetModifierMoveSpeedOverride()
	return 50
end

function modifier_C08D_old:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_EVADE_DISABLED] = true,
	[MODIFIER_STATE_BLOCK_DISABLED] = true,
	[MODIFIER_STATE_SILENCED] = true,
	[MODIFIER_STATE_ROOTED] = true
	}

	return state
end

function modifier_C08D_old:IsHidden() 
	return false
end

function modifier_C08D_old:IsDebuff()
	return true
end

function modifier_C08D_old:IsPurgable()
	return true
end
