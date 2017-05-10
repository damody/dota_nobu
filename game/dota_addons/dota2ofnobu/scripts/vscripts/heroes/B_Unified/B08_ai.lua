--[[
淺井長政 AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorEat, BehaviorRunAway, BehaviorLearn } ) 
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

function BehaviorLearn:Evaluate()
	self.LearnAbility1 = thisEntity:FindAbilityByName("choose_11")
	if self.LearnAbility1 and self.LearnAbility1:IsFullyCastable() then
		print("self.LearnAbility1 99999")
		return 99999
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
end

function BehaviorNone:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

--------------------------------------------------------------------------------------------------------

BehaviorEat = {}

function BehaviorEat:Evaluate()
	self.EatAbility1 = thisEntity:FindAbilityByName("B08W_old")
	self.EatAbility2 = nil
	for i=0,DOTA_ITEM_MAX-1 do
		local item = thisEntity:GetItemInSlot( i )
		if item and item:GetAbilityName() == "item_lightning_scroll" then
			self.EatAbility2 = item
		end
	end
	-- 初始化
	local target
	local desire = 0
	self.use_eat1 = nil
	self.use_eat2 = nil
	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end
	if self.EatAbility2 and self.EatAbility2:IsFullyCastable() and self.EatAbility1 and self.EatAbility1:IsFullyCastable() then
		local range = math.min(self.EatAbility1:GetCastRange(), self.EatAbility2:GetCastRange())
		local damage = self.EatAbility1:GetAbilityDamage() + self.EatAbility2:GetAbilityDamage()
		target = AICore:RandomEnemyBasicInRange( thisEntity, range, damage )
		self.use_eat1 = true
		self.use_eat2 = true
	elseif self.EatAbility1 and self.EatAbility1:IsFullyCastable() then
		local range = self.EatAbility1:GetCastRange()
		local damage = self.EatAbility1:GetAbilityDamage()
		target = AICore:RandomEnemyBasicInRange( thisEntity, range, damage )
		self.use_eat1 = true
	end

	if target then
		desire = 5
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorEat:Begin()
	self.endTime = GameRules:GetGameTime() + 5
	if use_eat1 and use_eat2 then
		self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			UnitIndex = thisEntity:entindex(),
			TargetIndex = self.target:entindex(),
			AbilityIndex = self.EatAbility1:entindex()
		}
	end
	
end

BehaviorEat.Continue = BehaviorEat.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorEat:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end

--------------------------------------------------------------------------------------------------------

BehaviorThrowHook = {}

function BehaviorThrowHook:Evaluate()
	local desire = 0
	
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.hookAbility = thisEntity:FindAbilityByName( "creature_meat_hook" )
	
	if self.hookAbility and self.hookAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRange( thisEntity, self.hookAbility:GetCastRange() )
		if self.target then
			desire = 4
		end
	end
	
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			local enemyVec = enemy:GetOrigin() - thisEntity:GetOrigin()
			local myForward = thisEntity:GetForwardVector()
			local dotProduct = enemyVec:Dot( myForward ) 
			if dotProduct > 0 then
				desire = 2
			end
		end
	end 

	return desire
end

function BehaviorThrowHook:Begin()
	self.endTime = GameRules:GetGameTime() + 1

	local targetPoint = self.target:GetOrigin() + RandomVector( 100 )
	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.hookAbility:entindex(),
		Position = targetPoint
	}

end

BehaviorThrowHook.Continue = BehaviorThrowHook.Begin

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

AICore.possibleBehaviors = { BehaviorNone, BehaviorEat, BehaviorRunAway, BehaviorLearn }
