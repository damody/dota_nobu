--[[ ============================================================================================================
	Author: Rook, with help from some of Pizzalol's SpellLibrary code
	Date: January 25, 2015
	Called when Blink Dagger is cast.  Blinks the caster in the targeted direction.
	Additional parameters: keys.MaxBlinkRange and keys.BlinkRangeClamp
================================================================================================================= ]]
hasSet = {}

function item_blink_datadriven_on_spell_start(keys)
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
		
	keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	
	local origin_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local difference_vector = target_point - origin_point
	
	if difference_vector:Length2D() > keys.MaxBlinkRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
		target_point = origin_point + (target_point - origin_point):Normalized() * keys.BlinkRangeClamp
	end
	
	keys.caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(keys.caster, target_point, false)

	-- local caster = keys.caster
	
	-- -- if (hasSet[2] == nil) then
	-- -- 	hasSet[2] = 1
	-- -- 	Timers:CreateTimer(0, function()
	-- -- 		caster:SetMana(caster:GetMaxMana())
	-- -- 			for abilitySlot=0,15 do
	-- -- 				local ability = caster:GetAbilityByIndex(abilitySlot)
	-- -- 				if ability ~= nil then 
	-- -- 					ability:EndCooldown()
	-- -- 				end
	-- -- 			end
	-- -- 			return 0.1
	-- -- 		end)
	-- -- end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 25, 2015
	Called when a unit with Blink Dagger in their inventory takes damage.  Puts the Blink Dagger on a brief cooldown
	if the damage is nonzero (after reductions) and originated from any player or Roshan.
	Additional parameters: keys.BlinkDamageCooldown and keys.Damage
	Known Bugs: keys.Damage contains the damage before reductions, whereas we want to compare the damage to 0 after reductions.
================================================================================================================= ]]
function modifier_item_blink_datadriven_damage_cooldown_on_take_damage(keys)
	if (keys.attacker ~= nil) then
		local attacker_name = keys.attacker:GetName()

		if keys.Damage > 0 and (attacker_name == "npc_dota_roshan" or keys.attacker:IsControllableByAnyPlayer()) then  --If the damage was dealt by neutrals or lane creeps, essentially.
			if keys.ability:GetCooldownTimeRemaining() < keys.BlinkDamageCooldown then
				keys.ability:StartCooldown(keys.BlinkDamageCooldown)
			end
		end
	end
end