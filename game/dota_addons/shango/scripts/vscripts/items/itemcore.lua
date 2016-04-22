if ItemCore == nil then ItemCore = class({  }) end

function ItemCore:Init()
	ListenToGameEvent("dota_item_purchased",Dynamic_Wrap(ItemCore, "OnItemPurchased"),self)
end

function ItemCore:FindItemFuzzyEnquiry(hero, search_name)
	for i=0,10 do
		local item = hero:GetItemInSlot(i)
		if item then
			local item_name = item:GetAbilityName()
			if string.find(item_name, search_name) then
				return item
			end
		end
	end
end

function ItemCore:FindItem(hero, item_name)
	for i = 0, 11 do
		local item = hero:GetItemInSlot(i)
		if item then
			if item:GetAbilityName() == item_name then
				return item
			end
		end
	end
end

function ItemCore:OnItemPurchased(keys)
	for k,v in pairs(keys) do
		print(k,v)
	end
	local player_id = keys.PlayerID
	local player = PlayerResource:GetPlayer(player_id)
	local hero = player:GetAssignedHero()
	local item_name = keys.item_name

	local item = self:FindItem(hero, item_name)

	if item and self.__check_lumber__[item_name] then
		if not self.__check_lumber__[item_name]:Check(player, item) then return end
	end

	if item and self[item_name] and self[item_name].PurchasedHandler then
		self[item_name].PurchasedHandler(player,item)
	end
end

if ItemCore.item_chongche == nil then ItemCore.item_chongche = class({}) end
if ItemCore.__check_lumber__ == nil then ItemCore.__check_lumber__ = class({}) end
if ItemCore.__check_lumber__.item_chongche == nil then ItemCore.__check_lumber__.item_chongche = class({}) end

function ItemCore.__check_lumber__.item_chongche:Check(player, item)
	local hero = player:GetAssignedHero()
	if hero.__lumber_data < 200 then
		UTIL_RemoveImmediate(item)
		FireGameEvent( 'custom_error_show', { player_ID = hero:GetPlayerID(), _error = "#not_enough_lumber" } )
	end
end

function ItemCore.item_chongche:PurchasedHandler(player,item)
	UTIL_RemoveImmediate(item)
	local hero = player:GetAssignedHero()
	local pos = nil
	if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
		pos = Vector() --TODO
	else
		pos = Vector() --TODO
	end

	local che = CreateUnitByName("unit_chongche",pos,true,hero,hero,hero:GetTeam())
	che:SetOwner(hero)
	che:SetControllableByPlayer(hero:GetPlayerID(), true)
end
