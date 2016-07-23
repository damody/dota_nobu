
function Nobu:test_chat(keys)
	local s   	   = keys.text
	local id  	   = 1 --keys.userid --BUG:會1.2的調換，不知道為甚麼
	local p 	     = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家
	local caster 	   = p:GetAssignedHero() --获取该玩家的英雄
	local point    = caster:GetAbsOrigin()

	if s == "tlv" then
		--等級
		for i=1,25 do
			caster:HeroLevelUp(false)
			--caster.HeroLevelUp(caster,true)
		end
	end

	--自訂義血量
	if string.match(s,"thp") then
		local hp = tonumber(string.match(s, '%d+'))
		--caster:SetBaseMaxHealth(hp) --false
		_G.TestUnit:SetMaxHealth(hp)
		_G.TestUnit:SetHealth(hp)

		print(hp)
	end

	--自訂義防禦
	--自訂義傷害
	--自訂義魔法抗性
	--自訂義模型大小
	if string.match(s,"tml") then
		local s2 = string.sub(s,4,8)
		local num = tonumber(s2)
		--tonumber(string.match(s,'%f[0~9]'))
		--tonumber(string.match(s, '%d+'))
		print(num)
		_G.TestUnit:SetModelScale(num)
	elseif string.match(s,"ml") then
		local s2 = string.sub(s,3,7)
		local num = tonumber(s2)
		--tonumber(string.match(s,'%f[0~9]'))
		--tonumber(string.match(s, '%d+'))
		print(num)
		caster:SetModelScale(num)
	end


end

function Test_main(self)
	ListenToGameEvent("player_chat",Nobu.test_chat,self)
	print("Lua test main")
	print(self)
	DeepPrintTable(self)
end

--[[ ============================================================================================================
	Author: Rook, with help from some of Pizzalol's SpellLibrary code
	Date: January 25, 2015
	Called when Blink Dagger is cast.  Blinks the caster in the targeted direction.
	Additional parameters: keys.MaxBlinkRange and keys.BlinkRangeClamp
================================================================================================================= ]]
function item_blink_datadriven_on_spell_start(keys)
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.

	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, keys.caster)
	keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")

	local origin_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local difference_vector = target_point - origin_point

	-- if difference_vector:Length2D() > keys.MaxBlinkRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
	-- 	target_point = origin_point + (target_point - origin_point):Normalized() * keys.BlinkRangeClamp
	-- end

	keys.caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(keys.caster, target_point, false)

	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, keys.caster)
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
	local attacker_name = keys.attacker:GetName()

	if keys.Damage > 0 and (attacker_name == "npc_dota_roshan" or keys.attacker:IsControllableByAnyPlayer()) then  --If the damage was dealt by neutrals or lane creeps, essentially.
		if keys.ability:GetCooldownTimeRemaining() < keys.BlinkDamageCooldown then
			keys.ability:StartCooldown(keys.BlinkDamageCooldown)
		end
	end
end

function test_1()
	--print("lua"..tostring(DOTA_MAX_PLAYERS))
	Timers:CreateTimer(2,function()
		--【測試單位】
		_G.TestUnit = CreateUnitByName("TestUnit_nomagicresist", Vector(0,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
	end)

	Timers:CreateTimer(2,function()

		--【HP/MP滿血】
		for playerID = 0, 10 do
			local id       = playerID
		  local p        = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家

			--print("lua"..tostring(p))

			if p ~= nil and (p: GetAssignedHero()) ~= nil then
			  local caster     = p: GetAssignedHero()
			  local point    = caster:GetAbsOrigin()
			  local owner = caster:GetPlayerOwner()

				GameRules: SendCustomMessage("每20秒 全場狀態回復",DOTA_TEAM_GOODGUYS,0)

				caster:SetMana(caster:GetMaxMana() )
				caster:SetHealth(caster:GetMaxHealth())

				-- Reset cooldown for abilities that is not rearm
				for i = 0, caster:GetAbilityCount() - 1 do
					local ability = caster:GetAbilityByIndex( i )
					if ability  then
						ability:EndCooldown()
					end
				end

				-- Put item exemption in here
				local exempt_table = {}

				-- Reset cooldown for items
				for i = 0, 5 do
					local item = caster:GetItemInSlot( i )
					if item then--if item and not exempt_table( item:GetAbilityName() ) then
						item:EndCooldown()
					end
				end
			end
		end

		return 20
	end)
end

-----------------
test_1()
