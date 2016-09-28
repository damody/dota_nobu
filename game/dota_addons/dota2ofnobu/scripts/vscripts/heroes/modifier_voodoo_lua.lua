modifier_voodoo_lua = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_voodoo_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_voodoo_lua:GetModifierModelChange()
	local res = math.random(1,10)
	if res == 1 then
		return "models/props_gameplay/frog.vmdl"
	elseif res == 2 then
		return "models/props_gameplay/chicken.vmdl"
	elseif res == 3 then
		return "models/courier/f2p_courier/f2p_courier.vmdl"
	elseif res == 4 then
		return "models/courier/donkey_crummy_wizard_2014/donkey_crummy_wizard_2014.vmdl"
	elseif res == 5 then
		return "models/props_gameplay/pig_sfm_low.vmdl"
	elseif res == 6 then
		return "models/courier/donkey_trio/mesh/donkey_trio.vmdl"
	elseif res == 7 then
		return "models/courier/mighty_boar/mighty_boar.vmdl"
	elseif res == 8 then
		return "models/courier/otter_dragon/otter_dragon.vmdl"
	elseif res == 9 then
		return "models/creeps/lane_creeps/creep_radiant_ranged_diretide/creep_radiant_ranged_diretide.vmdl"
	elseif res == 10 then
		return "models/creeps/lane_creeps/creep_radiant_melee/radiant_melee_mega.vmdl"
	end
end

function modifier_voodoo_lua:GetModifierMoveSpeedOverride()
	return 50
end

function modifier_voodoo_lua:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_EVADE_DISABLED] = true,
	[MODIFIER_STATE_BLOCK_DISABLED] = true,
	[MODIFIER_STATE_SILENCED] = true
	}

	return state
end

function modifier_voodoo_lua:IsHidden() 
	return false
end

function modifier_voodoo_lua:IsDebuff()
	return true
end

function modifier_voodoo_lua:IsPurgable()
	return true
end
