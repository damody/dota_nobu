-- Barrel.lua
-- 处理木桶BUFF
-- XavierCHN@2015.03.20

-- 木桶被击杀后，创建一个木桶物品在目标点所在位置
-- 木桶被击杀后160秒，刷新下一个木桶 -- DEBUG 刷新间隔为10秒
-- @2015.3.21 尝试添加BUFF，看看是否能成功

-- 木桶BUFF
-- 战神斧 Attack x2 30sec 攻击力提高2倍，持续30秒
-- 战神铠 Defense + 30 30sec 防御力提高30，持续30秒
-- 韦马太天靴 Speed x 2 30sec 移动加速持续30秒
-- 肉包 Life Recov +500 恢复500点生命值
-- 老酒 Musou Recov + 500 恢复500点魔法值

-- 刷新点1 坐标 3072 -2752
BARREL_SPAWN_POSITIONS_1 = Vector(3072, -2752, 0)
-- 刷新点2 坐标 -3649 2530
BARREL_SPAWN_POSITIONS_2 = Vector(-3649, 2530, 0)

BARREL_UNIT_NAME = "npc_zs_barrel"



BUFF_ITEM_NAMES = {
	"item_barrel_zhanshenfu",
	"item_barrel_zhanshenkai",
	"item_barrel_mataitianxue",
	"item_barrel_roubao",
	"item_barrel_laojiu"
}

if Barrel == nil then Barrel = class({}) end

function Barrel:Init()
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(Barrel, "OnStateChanged"), self)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(Barrel, "OnItemPickedUp"), self)
	self.buffApplier = CreateUnitByName("npc_zs_barrel", Vector(9000,9000,-300), false, nil, nil, DOTA_TEAM_GOODGUYS)
	self.buffApplier:FindAbilityByName("barrel_passive"):SetLevel(1)
	
end

function Barrel:OnStateChanged()
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		-- print("INITING BARRELS ON POSITIONS")
		-- 在游戏开始阶段，刷新两个木桶
		local barrel_1 = CreateUnitByName(BARREL_UNIT_NAME,BARREL_SPAWN_POSITIONS_1,false,nil,nil,DOTA_TEAM_NEUTRALS)
		local ability_passive = barrel_1:FindAbilityByName("barrel_passive")
		ability_passive:SetLevel(1)
		local barrel_2 = CreateUnitByName(BARREL_UNIT_NAME,BARREL_SPAWN_POSITIONS_2,false,nil,nil,DOTA_TEAM_NEUTRALS)
		ability_passive = barrel_2:FindAbilityByName("barrel_passive")
		ability_passive:SetLevel(1)
	end
end

function Barrel:OnItemPickedUp(keys)

	print("an item was picked up")
	local itemName = keys.itemname
	PrintTable(keys)
	local hero = EntIndexToHScript(keys.HeroEntityIndex)
	local item = EntIndexToHScript(keys.ItemEntityIndex)

	if string.find(itemName, "item_barrel_") then
		print("AN BARREL ITEM WAS PICKED UP")

		local BUFF_NAME_ALIAS = {
			["item_barrel_zhanshenkai"] = "modifier_barrel_zhanshenkai_buff",
			["item_barrel_zhanshenfu"] = "modifier_barrel_zhanshenfu_buff",
			["item_barrel_mataitianxue"] = "modifier_barrel_mataitianxue_buff",
			["item_barrel_laojiu"] = "modifier_barrel_laojiu_buff",
			["item_barrel_roubao"] = "modifier_barrel_roubao_buff"
		}
		local BUFF_POPUP_IMAGE_NAMES = {
			["item_barrel_zhanshenkai"] = "images/popup/defx2.png",
			["item_barrel_zhanshenfu"] = "images/popup/atkx2.png",
			["item_barrel_mataitianxue"] = "images/popup/msmax.png",
			["item_barrel_laojiu"] = "images/popup/health500.png",
			["item_barrel_roubao"] = "images/popup/mana500.png"
		}
		PopupImageForPlayer(hero, BUFF_POPUP_IMAGE_NAMES[itemName], hero:GetPlayerID())

		print("Attempt to apply modifier", BUFF_NAME_ALIAS[itemName], "to picker")
		local abilityBuff = self.buffApplier:FindAbilityByName("barrel_passive")
		abilityBuff:ApplyDataDrivenModifier(self.buffApplier, hero, BUFF_NAME_ALIAS[itemName], {})
		item:RemoveSelf()

		UTIL_MessageText(hero:GetPlayerID(),"hahaha",255,255,255,255)
	end
end
