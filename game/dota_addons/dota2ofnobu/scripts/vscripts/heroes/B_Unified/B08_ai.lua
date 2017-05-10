     --[[
淺井長政 AI
]]
inspect = require('inspect')
require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorEat, BehaviorKill, BehaviorPKill, BehaviorRunAway, BehaviorLearn } ) 
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

function CollectRetreatMarkers()
	local result = {}
	local i = 1
	local wp = nil
	table.insert( result, Entities:FindByName( nil, "dota_badguys_fort" ) )
	return result
end
POSITIONS_retreat = CollectRetreatMarkers()

--------------------------------------------------------------------------------------------------------

BehaviorLearn = {}
LearnString = "WEWEWTWEERRTRR+++T+++++++++++++++++++++++++++"

function GetLearnLevel( str )
	local w ={}
	for i=1,#str do
	  if w[string.sub(str, i,i)] == nil then
	    w[string.sub(str, i,i)] = 1
	  else
	    w[string.sub(str, i,i)] = w[string.sub(str, i,i)] +1
	  end
	end
	return w
end

function BehaviorLearn:Evaluate()
	self.LearnAbility1 = thisEntity:FindAbilityByName("choose_11")
	if self.LearnAbility1 and self.LearnAbility1:IsFullyCastable() then
		return 99999
	end
	learn = GetLearnLevel(LearnString)
	for k,v in pairs(learn) do
		local sk = "B08"..k.."_old"
		local ab = thisEntity:FindAbilityByName(sk)
		if ab then
			ab:SetLevel(v)
		end
	end
	return 1
end

function BehaviorLearn:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	
	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = self.LearnAbility1:entindex()
	}
end

function BehaviorLearn:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

BehaviorNone = {}

function BehaviorNone:Evaluate()
	return 1 -- must return a value > 0, so we have a default
end

function BehaviorNone:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	
	local ancient =  Entities:FindByName( nil, "dota_goodguys_fort" )
	
	if ancient then
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = ancient:GetOrigin()
		}
	else
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP
		}
	end
	self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP
		}
end

function BehaviorNone:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

--------------------------------------------------------------------------------------------------------

BehaviorEat = {}

function BehaviorEat:Evaluate()
	self.EatAbility1 = thisEntity:FindAbilityByName("B08W_old")
	self.EatAbility2 = thisEntity:FindAbilityByName("B08E_old")
	self.EatAbility4 = nil
	for i=0,DOTA_ITEM_MAX-1 do
		local item = thisEntity:GetItemInSlot( i )
		if item and item:GetAbilityName() == "item_lightning_scroll" then
			self.EatAbility4 = item
		end
	end
	-- 初始化
	local target
	local desire = 0

	local range = 0
	local damage = 0
	self.Eatab = {}
	for i=1,4 do
		local sk = "EatAbility"..i
		if self[sk] and self[sk]:IsFullyCastable() then
			if self[sk]:GetCastRange() > range then
				range = self[sk]:GetCastRange()
			end
			damage = damage + self[sk]:GetAbilityDamage()
			table.insert(self.Eatab, self[sk])
		end
	end
	print("eat range", range, damage)
	target = AICore:RandomEnemyBasicInRange( thisEntity, range, damage*4 )
	if target then
		print("EAT", target:GetUnitName())
	end
	self.target = nil
	if target then
		desire = 30
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorEat:Begin()
	print("BehaviorEat:Begin")
	if #self.Eatab > 0 then
		self.endTime = GameRules:GetGameTime() + 1
		self.orderTable = {}
		for k,v in pairs(self.Eatab) do
			local order =
			{
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				UnitIndex = thisEntity:entindex(),
				TargetIndex = self.target:entindex(),
				AbilityIndex = v:entindex()
			}
			table.insert(self.orderTable, order)
			print("EAT ".. inspect(self.orderTable, {depth =2}))
			self.order = order
		end
	end
end

function BehaviorEat:Continue()
	print("BehaviorEat:Continue")
	if #self.Eatab > 0 then
		self.endTime = GameRules:GetGameTime() + 1
		self.orderTable = {}
		for k,v in pairs(self.Eatab) do
			local order =
			{
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				UnitIndex = thisEntity:entindex(),
				TargetIndex = self.target:entindex(),
				AbilityIndex = v:entindex()
			}
			table.insert(self.orderTable, order)
			print("EAT ".. inspect(self.orderTable, {depth =2}))
			self.order = order
		end
	end
end

function BehaviorEat:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end

--------------------------------------------------------------------------------------------------------

BehaviorPKill = {}

function BehaviorPKill:Evaluate()
	self.PKillability1 = thisEntity:FindAbilityByName("B08W_old")
	self.PKillability2 = thisEntity:FindAbilityByName("B08E_old")
	self.PKillability4 = nil
	for i=0,DOTA_ITEM_MAX-1 do
		local item = thisEntity:GetItemInSlot( i )
		if item and item:GetAbilityName() == "item_lightning_scroll" then
			self.PKillability4 = item
		end
	end
	-- 初始化
	local target
	local desire = 0

	local range = 0
	local damage = 0
	self.PKillab = {}
	for i=1,4 do
		local sk = "PKillability"..i
		if self[sk] and self[sk]:IsFullyCastable() then
			if self[sk]:GetCastRange() > range then
				range = self[sk]:GetCastRange()
			end
			damage = damage + self[sk]:GetAbilityDamage()
			table.insert(self.PKillab, self[sk])
		end
	end
	target = AICore:EnemyHeroInRange( thisEntity, range, damage*4 )

	self.target = nil
	if target then
		desire = 40
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorPKill:Begin()
	print("BehaviorPKill:Begin")
	if #self.PKillab > 0 then
		self.endTime = GameRules:GetGameTime() + 1
		self.orderTable = {}
		for k,v in pairs(self.PKillab) do
			local order =
			{
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				UnitIndex = thisEntity:entindex(),
				TargetIndex = self.target:entindex(),
				AbilityIndex = v:entindex()
			}
			table.insert(self.orderTable, order)
			print("PKill ".. inspect(self.orderTable, {depth =2}))
			self.order = order
		end
		self.PKillab = {}
	end
end

function BehaviorPKill:Continue()
	print("BehaviorPKill:Continue")
	self.endTime = GameRules:GetGameTime()
end

function BehaviorPKill:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------

BehaviorKill = {}

function BehaviorKill:Evaluate()
	self.Killability1 = thisEntity:FindAbilityByName("B08W_old")
	self.Killability2 = thisEntity:FindAbilityByName("B08E_old")
	self.Killability3 = thisEntity:FindAbilityByName("B08T_old")
	self.Killability4 = nil
	for i=0,DOTA_ITEM_MAX-1 do
		local item = thisEntity:GetItemInSlot( i )
		if item and item:GetAbilityName() == "item_lightning_scroll" then
			self.Killability4 = item
		end
	end
	-- 初始化
	local target
	local desire = 0

	local range = 9999
	local damage = 0
	self.Killab = {}
	for i=1,4 do
		local sk = "Killability"..i
		if self[sk] and self[sk]:IsFullyCastable() then
			if self[sk]:GetCastRange() < range and self[sk]:GetCastRange() > 100 then
				range = self[sk]:GetCastRange()
			end
			damage = damage + self[sk]:GetAbilityDamage()
			table.insert(self.Killab, self[sk])
		end
	end
	target = AICore:EnemyHeroInRange( thisEntity, range, damage )

	self.target = nil
	if target then
		desire = 50
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorKill:Begin()
	print("BehaviorKill:Begin")
	if #self.Killab > 0 then
		self.endTime = GameRules:GetGameTime() + 1
		self.orderTable = {}
		for k,v in pairs(self.Killab) do
			local order =
			{
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				UnitIndex = thisEntity:entindex(),
				TargetIndex = self.target:entindex(),
				AbilityIndex = v:entindex()
			}
			table.insert(self.orderTable, order)
			print("PKill ".. inspect(self.orderTable, {depth =2}))
			self.order = order
		end
		self.Killab = {}
	end
end


function BehaviorKill:Continue()
	print("BehaviorKill:Continue")
	if #self.Killab > 0 then
		self.endTime = GameRules:GetGameTime() + 1
		self.orderTable = {}
		for k,v in pairs(self.Killab) do
			local order =
			{
				OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
				UnitIndex = thisEntity:entindex(),
				TargetIndex = self.target:entindex(),
				AbilityIndex = v:entindex()
			}
			table.insert(self.orderTable, order)
			print("PKill ".. inspect(self.orderTable, {depth =2}))
			self.order = order
		end
		self.Killab = {}
	end
end

function BehaviorKill:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end

--------------------------------------------------------------------------------------------------------

BehaviorRunAway = {}

function BehaviorRunAway:Evaluate()
	local desire = 0
	local happyPlaceIndex =  RandomInt( 1, #POSITIONS_retreat )
	escapePoint = POSITIONS_retreat[ happyPlaceIndex ]
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end
	
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	if #enemies > 0 then
		desire = #enemies
	end 
	
	for i=0,DOTA_ITEM_MAX-1 do
		local item = thisEntity:GetItemInSlot( i )
		if item and item:GetAbilityName() == "item_magic_ring" then
			self.RunAwayAbility1 = item
		end
		if item and item:GetAbilityName() == "item_flash_ring" then
			self.RunAwayAbility2 = item
		end
		if item and item:GetAbilityName() == "item_ninja_sword" then
			self.RunAwayAbility3 = item
		end
	end
	
	return desire
end


function BehaviorRunAway:Begin()
	self.endTime = GameRules:GetGameTime() + 6

	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = thisEntity:entindex(),
		AbilityIndex = self.RunAwayAbility1:entindex()
	}
end

function BehaviorRunAway:Think(dt)
	
	ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = thisEntity:entindex(),
			AbilityIndex = self.forceAbility:entindex()
		})
		
	if self.forceAbility and not self.forceAbility:IsFullyCastable() then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = escapePoint
		})
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = self.drumAbility:entindex()
		})
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = self.phaseAbility:entindex()
		})
	end
	
	if self.urnAbility and self.urnAbility:IsFullyCastable() and self.endTime < GameRules:GetGameTime() + 2 then
		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			TargetIndex = thisEntity:entindex(),
			AbilityIndex = self.urnAbility:entindex()
		})
	end
end

BehaviorRunAway.Continue = BehaviorRunAway.Begin

--------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorEat, BehaviorKill, BehaviorPKill, BehaviorRunAway, BehaviorLearn }
