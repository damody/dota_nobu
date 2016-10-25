LinkLuaModifier("modifier_ninja2", "heroes/modifier_ninja2.lua", LUA_MODIFIER_MOTION_NONE)

function tofar_goback(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()

	Timers:CreateTimer(1, function()
		if (VectorDistance(caster:GetAbsOrigin(), pos) > 1000) then
			local order = {
		 		UnitIndex = caster:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		 		Position = pos, --Optional.  Only used when targeting the ground
		 		Queue = 0 --Optional.  Used for queueing up abilities
		 	}
			ExecuteOrderFromTable(order)
		end
		return 1
		end)
end

function dead_give_item(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	print("keys.item "..keys.item)
	local item = CreateItem(keys.item,nil, nil)
	CreateItemOnPositionSync(pos, item)
end

function near_hero_then_can_use_ability(keys)
	local caster = keys.caster
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  500 , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

	for abilitySlot=0,15 do
        local ability = caster:GetAbilityByIndex(abilitySlot)
        if ability ~= nil then
          local abilityLevel = ability:GetLevel()
          local abilityName = ability:GetAbilityName()
          if abilityName ~= "near_hero_then_can_use_ability" then
          	if #group > 0 then
          		ability:SetActivated(true)
          	else
          		ability:SetActivated(false)
          	end
          end
        end
    end

    for _,it in pairs(group) do
    	caster.buyer = it
    	--print("caster.buyer "..it:GetUnitName())
    	break
    end

end

function call_ninja1(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	local donkey = CreateUnitByName("ninja_unit1", caster:GetAbsOrigin() + Vector(50, 100, 0), true, caster, caster, caster:GetTeamNumber())
    donkey:SetOwner(caster.buyer)
    donkey:SetControllableByPlayer(caster.buyer:GetPlayerOwnerID(), true)
    donkey:AddNewModifier(donkey,ability,"modifier_phased",{duration=0.1})
end

function call_ninja2(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	local donkey = CreateUnitByName("ninja_unit2", caster:GetAbsOrigin() + Vector(50, 100, 0), true, caster, caster, caster:GetTeamNumber())
    donkey:SetOwner(caster.buyer)
    donkey:SetControllableByPlayer(caster.buyer:GetPlayerOwnerID(), true)
    donkey:AddNewModifier(donkey,ability,"modifier_phased",{duration=0.1})
    donkey:FindAbilityByName("ninja_hole"):SetLevel(1)
end

function call_ninja3(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	local donkey = CreateUnitByName("ninja_unit3", caster:GetAbsOrigin() + Vector(50, 100, 0), true, caster, caster, caster:GetTeamNumber())
    donkey:SetOwner(caster.buyer)
    donkey:SetControllableByPlayer(caster.buyer:GetPlayerOwnerID(), true)
    donkey:AddNewModifier(donkey,ability,"modifier_phased",{duration=0.1})
end

function ninja_hole_start(keys)
	local caster = keys.caster
    caster:AddNewModifier(donkey,ability,"modifier_ninja2",{})
end

function ninja_hole_end(keys)
	local caster = keys.caster
    caster:RemoveModifierByName("modifier_ninja2")
end


