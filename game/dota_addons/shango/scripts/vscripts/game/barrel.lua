

function OnBarrelKilled(keys)

	local BARREL_RESPAWN_INTERVAL = 160

	PrintTable(keys)
	-- print("a barrel was killed @ position")
	local killedBarrelPosition = keys.caster:GetOrigin()
	Timers:CreateTimer(BARREL_RESPAWN_INTERVAL,
		function()
			-- print("a barrel was respawn @ position")
			local barrel = CreateUnitByName(BARREL_UNIT_NAME,killedBarrelPosition,false,nil,nil,DOTA_TEAM_NEUTRALS)
			local ability_passive = barrel:FindAbilityByName("barrel_passive")
			ability_passive:SetLevel(1)
			return nil
		end
	)

	-- 创建BUFF物品
	local itemName = BUFF_ITEM_NAMES[RandomInt(1,5)]
	-- print("attemp to create item", itemName, "at position", killedBarrelPosition)

	local item = CreateItemOnPositionSync(killedBarrelPosition, CreateItem(itemName, nil, nil))
end

function OnLaojiuBuffCreated(keys)
	-- print("LAOJIU WAS PICKED UP")
	local caster = keys.caster
	local mana_amount = keys.mana_amount
	caster:SetMana(caster:GetMana() + mana_amount)
end

function OnZhanshenfuBuffCreated(keys)
	-- print("ZHANSHENFU WAS PICKED UP")
	local caster = keys.caster
	local damage = math.floor((caster:GetBaseDamageMin() + caster:GetBaseDamageMax() ) / 2)
	local ability = keys.ability
	caster:SetModifierStackCount("modifeir_barrel_zhanshenfu_buff",ability,damage)
end