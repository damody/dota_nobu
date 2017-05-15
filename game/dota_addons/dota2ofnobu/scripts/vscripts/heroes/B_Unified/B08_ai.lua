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

--------------------------------------------------------------------------------------------------------

BehaviorLearn = {}
LearnString = "WEWEWTWEERRTRR+++T+++++++++++++++++++++++++++"

function GetLearnLevel( str, level )
	local w ={}
	for i=1,level do
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
	learn = GetLearnLevel(LearnString, thisEntity:GetLevel())
	for k,v in pairs(learn) do
		if k ~= "+" then
			local sk = "B08"..k.."_old"
			local ab = thisEntity:FindAbilityByName(sk)
			if ab then
				ab:SetLevel(v)
			end
		else
			local ab = thisEntity:FindAbilityByName("attribute_bonusx")
			if ab then
				ab:SetLevel(v)
			end
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
	if thisEntity:GetTeamNumber() == 2 then
		ancient =  Entities:FindByName( nil, "dota_badguys_fort" )
	else
		ancient =  Entities:FindByName( nil, "dota_goodguys_fort" )
	end
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

function GetItemAbility(caster, name)
	for i=0,DOTA_ITEM_MAX-1 do
		local item = caster:GetItemInSlot( i )
		if item and item:GetAbilityName() == name then
			return item
		end
	end
	return nil
end

function BehaviorEat:Evaluate()
	self.EatAbility = {}
	for i=1,10 do
		self.EatAbility[i] = {}
	end
	self.EatAbility[1][1] = thisEntity:FindAbilityByName("B08W_old")
	self.EatAbility[1][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.EatAbility[2][1] = thisEntity:FindAbilityByName("B08E_old")
	self.EatAbility[2][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.EatAbility[3][1] = GetItemAbility(thisEntity, "item_lightning_scroll")
	self.EatAbility[3][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.EatAbility[4][1] = GetItemAbility(thisEntity, "item_the_red_lightning_chapter_hyper")
	self.EatAbility[4][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.EatAbility[5][1] = GetItemAbility(thisEntity, "item_the_red_lightning_chapter")
	self.EatAbility[5][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.EatAbility[6][1] = GetItemAbility(thisEntity, "item_rockfall_book")
	self.EatAbility[6][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.EatAbility[7][1] = GetItemAbility(thisEntity, "item_great_dragon")
	self.EatAbility[7][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.EatAbility[8][1] = GetItemAbility(thisEntity, "item_the_club_of_nebula")
	self.EatAbility[8][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.EatAbility[9][1] = GetItemAbility(thisEntity, "item_the_great_sword_of_anger")
	self.EatAbility[9][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.EatAbility[10][1] = GetItemAbility(thisEntity, "item_ignite_book")
	self.EatAbility[10][2] = DOTA_UNIT_ORDER_CAST_POSITION
	-- 初始化
	local target
	local desire = 0

	local range = 0
	local damage = 0
	local manacost = 0
	local abcount = 0
	target = AICore:RandomEnemyBasicInRange( thisEntity, 1000, 10000 )
	self.Eatab = {}
	if target then
		for k,v in ipairs(self.EatAbility) do
			if v[1] and v[1]:IsFullyCastable() then
				if v[1]:GetCastRange() > range then
					range = v[1]:GetCastRange()
				end
				manacost = manacost + v[1]:GetManaCost(-1)
				damage = damage + v[1]:GetAbilityDamage()
				abcount = abcount + 1
				if v[2] == DOTA_UNIT_ORDER_CAST_TARGET then
					self.Eatab[abcount] = {
						OrderType = v[2],
						UnitIndex = thisEntity:entindex(),
						TargetIndex = target:entindex(),
						AbilityIndex = v[1]:entindex()
					}
				elseif v[2] == DOTA_UNIT_ORDER_CAST_POSITION then
					self.Eatab[abcount] = {
						OrderType = v[2],
						UnitIndex = thisEntity:entindex(),
						Position = target:GetOrigin(),
						TargetIndex = target:entindex(),
						AbilityIndex = v[1]:entindex()
					}
				end
			end
		end
		print("eat range", range, damage)
	end
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
		self.orderTable = table.shallow_copy(self.Eatab)
		self.Eatab = {}
	end
end

function BehaviorEat:Continue()
	print("BehaviorEat:Continue")
	if #self.Eatab > 0 then
		self.endTime = GameRules:GetGameTime() + 1
		self.orderTable = table.shallow_copy(self.Eatab)
		self.Eatab = {}
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
	self.PKillAbility = {}
	for i=1,10 do
		self.PKillAbility[i] = {}
	end
	self.PKillAbility[1][1] = thisEntity:FindAbilityByName("B08W_old")
	self.PKillAbility[1][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.PKillAbility[2][1] = thisEntity:FindAbilityByName("B08E_old")
	self.PKillAbility[2][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.PKillAbility[3][1] = GetItemAbility(thisEntity, "item_lightning_scroll")
	self.PKillAbility[3][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.PKillAbility[4][1] = GetItemAbility(thisEntity, "item_the_red_lightning_chapter_hyper")
	self.PKillAbility[4][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.PKillAbility[5][1] = GetItemAbility(thisEntity, "item_the_red_lightning_chapter")
	self.PKillAbility[5][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.PKillAbility[6][1] = GetItemAbility(thisEntity, "item_rockfall_book")
	self.PKillAbility[6][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.PKillAbility[7][1] = GetItemAbility(thisEntity, "item_great_dragon")
	self.PKillAbility[7][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.PKillAbility[8][1] = GetItemAbility(thisEntity, "item_the_club_of_nebula")
	self.PKillAbility[8][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.PKillAbility[9][1] = GetItemAbility(thisEntity, "item_the_great_sword_of_anger")
	self.PKillAbility[9][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.PKillAbility[10][1] = GetItemAbility(thisEntity, "item_kat_steel")
	self.PKillAbility[10][2] = DOTA_UNIT_ORDER_CAST_POSITION
	
	-- 初始化
	local target
	local desire = 0

	local range = 0
	local damage = 0
	local manacost = 0
	local abcount = 0
	target = AICore:EnemyHeroInRange( thisEntity, 1300, 10000 )
	self.PKillab = {}
	if target then
		for k,v in ipairs(self.PKillAbility) do
			if v[1] and v[1]:IsFullyCastable() then
				if v[1]:GetCastRange() > range then
					range = v[1]:GetCastRange()
				end
				manacost = manacost + v[1]:GetManaCost(-1)
				damage = damage + v[1]:GetAbilityDamage()
				abcount = abcount + 1
				if v[2] == DOTA_UNIT_ORDER_CAST_TARGET then
					self.PKillab[abcount] = {
						OrderType = v[2],
						UnitIndex = thisEntity:entindex(),
						TargetIndex = target:entindex(),
						AbilityIndex = v[1]:entindex()
					}
				elseif v[2] == DOTA_UNIT_ORDER_CAST_POSITION then
					self.PKillab[abcount] = {
						OrderType = v[2],
						UnitIndex = thisEntity:entindex(),
						Position = target:GetOrigin(),
						TargetIndex = target:entindex(),
						AbilityIndex = v[1]:entindex()
					}
				end
			end
		end
		print("PKill range", range, damage)
	end
	target = AICore:EnemyHeroInRange( thisEntity, range, damage*4 )
	if target then
		for i=1,#self.PKillab do
			if self.PKillab[i].TargetIndex then
				self.PKillab[i].TargetIndex = target:entindex()
			end
		end
		print("PKill", target:GetUnitName())
	end
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
		self.orderTable = table.shallow_copy(self.PKillab)
		self.PKillab = {}
	end
end

function BehaviorPKill:Continue()
	print("BehaviorPKill:Continue")
	if #self.PKillab > 0 then
		self.endTime = GameRules:GetGameTime() + 1
		self.orderTable = table.shallow_copy(self.PKillab)
		self.PKillab = {}
	end
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
	self.KillAbility = {}
	for i=1,15 do
		self.KillAbility[i] = {}
	end
	self.KillAbility[1][1] = thisEntity:FindAbilityByName("B08W_old")
	self.KillAbility[1][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.KillAbility[2][1] = thisEntity:FindAbilityByName("B08E_old")
	self.KillAbility[2][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.KillAbility[3][1] = GetItemAbility(thisEntity, "item_the_great_sword_of_banish")
	self.KillAbility[3][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.KillAbility[4][1] = GetItemAbility(thisEntity, "item_the_great_sword_of_spike")
	self.KillAbility[4][2] = DOTA_UNIT_ORDER_CAST_NO_TARGET
	self.KillAbility[5][1] = GetItemAbility(thisEntity, "item_the_red_lightning_chapter")
	self.KillAbility[5][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.KillAbility[6][1] = GetItemAbility(thisEntity, "item_rockfall_book")
	self.KillAbility[6][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.KillAbility[7][1] = GetItemAbility(thisEntity, "item_great_dragon")
	self.KillAbility[7][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.KillAbility[8][1] = GetItemAbility(thisEntity, "item_the_club_of_nebula")
	self.KillAbility[8][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.KillAbility[9][1] = thisEntity:FindAbilityByName("B08D_old")
	self.KillAbility[9][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.KillAbility[10][1] = thisEntity:FindAbilityByName("B08T_old")
	self.KillAbility[10][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.KillAbility[11][1] = GetItemAbility(thisEntity, "item_the_great_sword_of_anger")
	self.KillAbility[11][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.KillAbility[12][1] = GetItemAbility(thisEntity, "item_lightning_scroll")
	self.KillAbility[12][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.KillAbility[13][1] = GetItemAbility(thisEntity, "item_the_red_lightning_chapter_hyper")
	self.KillAbility[13][2] = DOTA_UNIT_ORDER_CAST_TARGET
	self.KillAbility[14][1] = GetItemAbility(thisEntity, "item_kat_steel")
	self.KillAbility[14][2] = DOTA_UNIT_ORDER_CAST_POSITION
	self.KillAbility[15][1] = GetItemAbility(thisEntity, "item_ignite_book")
	self.KillAbility[15][2] = DOTA_UNIT_ORDER_CAST_POSITION
	-- 初始化
	local target
	local desire = 0

	local range = 3000
	local damage = 0
	local manacost = 0
	local abcount = 0
	target = AICore:EnemyHeroInRange( thisEntity, 1300, 10000 )
	self.Killab = {}
	if target then
		for k,v in ipairs(self.KillAbility) do
			if v[1] and v[1]:IsFullyCastable() then
				if v[1]:GetCastRange() < range and v[1]:GetCastRange() > 100 then
					range = v[1]:GetCastRange()
				end
				if v[1]:GetName() == "B08T_old" then
					print("B08T_old",v[1]:GetAbilityDamage())
				end
				manacost = manacost + v[1]:GetManaCost(-1)
				damage = damage + v[1]:GetAbilityDamage()
				abcount = abcount + 1
				if v[2] == DOTA_UNIT_ORDER_CAST_TARGET then
					self.Killab[abcount] = {
						OrderType = v[2],
						UnitIndex = thisEntity:entindex(),
						TargetIndex = target:entindex(),
						AbilityIndex = v[1]:entindex()
					}
				elseif v[2] == DOTA_UNIT_ORDER_CAST_POSITION then
					self.Killab[abcount] = {
						OrderType = v[2],
						UnitIndex = thisEntity:entindex(),
						Position = target:GetOrigin(),
						TargetIndex = target:entindex(),
						AbilityIndex = v[1]:entindex()
					}
				elseif v[2] == DOTA_UNIT_ORDER_CAST_NO_TARGET then
					self.Killab[abcount] = {
						OrderType = v[2],
						UnitIndex = thisEntity:entindex(),
						AbilityIndex = v[1]:entindex()
					}
				end
			end
		end
		print("Kill range", range, damage)
	end
	target = AICore:EnemyHeroInRange( thisEntity, range, damage*4 )
	if target then
		for i=1,#self.Killab do
			if self.Killab[i].TargetIndex then
				self.Killab[i].TargetIndex = target:entindex()
			end
		end
		print("Kill", target:GetUnitName())
	end
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
		self.orderTable = table.shallow_copy(self.Killab)
		self.Killab = {}
	end
end


function BehaviorKill:Continue()
	print("BehaviorKill:Continue")
	if #self.Killab > 0 then
		self.endTime = GameRules:GetGameTime() + 1
		self.orderTable = table.shallow_copy(self.Killab)
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
	if thisEntity:GetTeamNumber() == 2 then
		escapePoint =  Entities:FindByName( nil, "dota_goodguys_fort" )
	else
		escapePoint =  Entities:FindByName( nil, "dota_badguys_fort" )
	end
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
