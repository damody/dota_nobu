--[[
BUG
	O大廳裡面也可以捕捉到，這時候caster值為nil
]]

local inspect = require("inspect")


skin_table = {
	["128732954"] = true,
	["164167573"] = true,
	["245903351"] = true,
	["89504404"] = true,
	["5491971"] = true,
	["45356591"] = true,
	["190143365"] = true,
	["161033081"] = true,
	["245761935"] = true, --買濃姬 但付1000元
	["180580201"] = true, --買濃姬跟阿市
	["237024969"] = true, --買濃姬跟阿市
	["377214232"] = true, --大陸 李維
	["100789172"] = true, --大陸 Sai
	
	["38652551"] = true,
	["159955467"] = true,
	["47467611"] = true,
	["159901591"] = true,
	["175307731"] = true,
	["175423750"] = true,
	["219044134"] = true,
	["159930923"] = true,
	["440895734"] = true,
	["411167283"] = true,
	["19350721"] = true,
	["230137710"] = true,
	["167209936"] = true,
	["21796396"] = true,
	["24066882"] = true,
	["399854621"] = true,
	["156338995"] = true,
	["78644565"] = true,
	["407915261"] = true,
	["421960552"] = true,
	["196686525"] = true,
	["246810545"] = true,
	["126912859"] = true,
	["162580111"] = true,
	["275101304"] = true,
	["68694022"] = true,
	["54971063"] = true,
	["109888730"] = true,
	["30107422"] = true,
	["6938200"] = true,
	["20304940"] = true,
	["30314550"] = true,
	["49456980"] = true,
	
	["404284631"] = true,
	["404414261"] = true,
	["100577207"] = true,
	["408231324"] = true,
	["113634843"] = true,
	["113740368"] = true,
	["113690980"] = true,
	["90426648"] = true,
	["177216989"] = true,
	["398755156"] = true,
	["251717040"] = true,
	["200372686"] = true,
	["396968659"] = true,
	["302208218"] = true,
	["171799875"] = true,
	["395315757"] = true,
	["398587433"] = true,
	["228146869"] = true,
	["116590244"] = true,
	["109942126"] = true,
	["167209936"] = true,
	["254803433"] = true,
	["60214844"] = true,
	["190108038"] = true,
	["140227500"] = true,
	["180978974"] = true,
	["264678988"] = true,
	["179204453"] = true,
	["83391337"] = true,
	["309242731"] = true,
	["165371710"] = true,
	["200824320"] = true,
	["357390739"] = true,
	["403262581"] = true,
	["98913961"] = true,
	["219797805"] = true,
	["403273081"] = true,
	["13876401"] = true,
	["183611649"] = true,
	["127008996"] = true,
	["112092405"] = true,
	["77216853"] = true,
	["406000739"] = true,
	["411167283"] = true,
	["400491255"] = true,
	["404501308"] = true,
	["410736014"] = true,
	["126912859"] = true,
	["175091151"] = true,
	["178655368"] = true,
	["178162295"] = true,
	["190893903"] = true,
	["19350721"] = true,
	["245903351"] = true,
	["67772815"] = true,
	["214260739"] = true,
	["299292950"] = true,
	["362586887"] = true,
	["80008129"] = true,
	["151910810"] = true,
	["401484673"] = true,
	["128561432"] = true,
	["92011585"] = true,
	["186995583"] = true,
	["108494462"] = true,
	["181277080"] = true,
	["297194236"] = true,
	["397235448"] = true,
	["298925966"] = true,
	["302672845"] = true,
	["164156799"] = true,
	["400642280"] = true,
	["408279637"] = true,
	["51993736"] = true,
	["134859659"] = true,
	["138927341"] = true,
	["373384051"] = true,
	["285511808"] = true,
	["140165795"] = true,
	["152151982"] = true,
	["95837015"] = true,
	["406071443"] = true,
	["190585955"] = true,
	["404550388"] = true,
	["322632934"] = true,
	["328872748"] = true,
	["136330017"] = true,
	["405867669"] = true,
	["245521237"] = true,
	["406101239"] = true,
	["176398348"] = true,
}

function DumpTable( tTable )
	local inspect = require('inspect')
	local iDepth = 5
 	print(inspect(tTable,
 		{depth=iDepth} 
 	))
end


function SendHTTPRequest_local(path, method, values, callback)
	local req = CreateHTTPRequestScriptVM( method, "http://127.0.0.1/"..path )
	for key, value in pairs(values) do
		req:SetHTTPRequestGetOrPostParameter(key, value)
	end
	req:Send(function(result)
		callback(result.Body)
	end)
end

local function chat_of_test(keys)
	--DeepPrintTable(keys)
	-- [   VScript ]:    playerid                        	= 0 (number)
	-- [   VScript ]:    text                            	= "3" (string)
	-- [   VScript ]:    teamonly                        	= 1 (number)
	-- [   VScript ]:    userid                          	= 1 (number)
	-- [   VScript ]:    splitscreenplayer               	= -1 (number)

	--local id    = keys.player --BUG:在講話事件裡，讀取不到玩家，是整數。
	local s   	   = keys.text:lower()
	local p 	     = PlayerResource:GetPlayer(keys.playerid)--可以用索引轉換玩家方式，來捕捉玩家
	local caster 	   = p:GetAssignedHero() --获取该玩家的英雄
	if caster == nil then return end
	local point    = caster:GetAbsOrigin()
	-- if string.match(s,"test") then
	-- 	local pID = tonumber(string.match(s, '%d+'))
	-- 	local steamID = PlayerResource:GetSteamAccountID(pID)
	-- 	GameRules: SendCustomMessage(tostring(steamID),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
	-- end
	if _G.CountUsedAbility_Table == nil then
		_G.CountUsedAbility_Table = {}
	end
	if _G.CountUsedAbility_Table[keys.playerid + 1] == nil then
		_G.CountUsedAbility_Table[keys.playerid + 1] = {}
	end
	if s == "-se" then
		_G.CountUsedAbility_Table["winteam"] = DOTA_TEAM_GOODGUYS
		for playerID = 0, 9 do
			local id       = playerID
	  		local p        = PlayerResource:GetPlayer(id)
	  		local steamid = PlayerResource:GetSteamAccountID(id)
	    	if p ~= nil and (p:GetAssignedHero()) ~= nil then
			  local hero = p:GetAssignedHero()

			  if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			  	_G.CountUsedAbility_Table[id+1]["res"] = "W"
			  else
			  	_G.CountUsedAbility_Table[id+1]["res"] = "L"
			  end
			  _G.CountUsedAbility_Table[id+1]["name"] = hero.name
			  _G.CountUsedAbility_Table[id+1]["version"] = hero.version
			  _G.CountUsedAbility_Table[id+1]["damage"] = hero.damage
			  _G.CountUsedAbility_Table[id+1]["takedamage"] = hero.takedamage
			  _G.CountUsedAbility_Table[id+1]["herodamage"] = hero.herodamage
			  _G.CountUsedAbility_Table[id+1]["building_count"] = hero.building_count
			  _G.CountUsedAbility_Table[id+1]["team"] = hero:GetTeamNumber()
			  _G.CountUsedAbility_Table[id+1]["kda"] = {}
			  _G.CountUsedAbility_Table[id+1]["kda"]["k"] = tostring(hero:GetKills())
			  _G.CountUsedAbility_Table[id+1]["kda"]["d"] = tostring(hero:GetDeaths())
			  _G.CountUsedAbility_Table[id+1]["kda"]["a"] = tostring(hero:GetAssists())
			  _G.CountUsedAbility_Table[id+1]["kda"]["kcount"] = tostring(hero.kill_count)
			  _G.CountUsedAbility_Table[id+1]["kda"]["steamid"] = steamid
			end
		end
		if _G.game_level > 0 and _G.game_level < 10 then
			_G.CountUsedAbility_Table.rank = 1
		end
		DeepPrintTable(_G.CountUsedAbility_Table)
		
		SendHTTPRequest_local("save_ability_data", "GET",
			{
			  data = tostring(inspect(_G.CountUsedAbility_Table)),
			},
			function(result)
				print("SendHTTPRequest_local")
			  print(result)
			end)
		
	end
	local steamid = PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID())
	local skin = false
	if skin_table[tostring(steamid)] == true then
		skin = true
	end
	
	--DebugDrawText(caster:GetAbsOrigin(), "殺爆全場就是現在", false, 10)
	--舊版模式
	local nobu_id = _G.heromap[caster:GetName()]

	if (s == "-skin" and nobu_id == "C17" and skin) then
		caster.skin = "school"
		caster:SetModel("models/c17/c17_school.vmdl")
		caster:SetOriginalModel("models/c17/c17_school.vmdl")
	end
	if (s == "-skin" and nobu_id == "A26" and skin) then
		caster.skin = "school"
		caster:SetModel("models/a26/a26_school.vmdl")
		caster:SetOriginalModel("models/a26/a26_school.vmdl")
	end
	if (s == "-skin" and nobu_id == "B16" and skin) then
		caster.skin = "school"
		caster:SetModel("models/b16/b16_school.vmdl")
		caster:SetOriginalModel("models/b16/b16_school.vmdl")
	end
	if (s == "-skin" and nobu_id == "C19" and skin) then
		caster.skin = "school"
		caster:SetModel("models/c19/c19_school.vmdl")
		caster:SetOriginalModel("models/c19/c19_school.vmdl")
		caster:AddAbility("C19_school"):SetLevel(1)
	end
	if (s == "-long" and nobu_id == "A31") then
		caster:SetModel("models/a31/a31_long.vmdl")
		caster:SetOriginalModel("models/a31/a31_long.vmdl")
	end
	if (s == "-short" and nobu_id == "A31") then
		caster:SetModel("models/a31/a31.vmdl")
		caster:SetOriginalModel("models/a31/a31.vmdl")
	end
	if (s == "-donkey" and caster.has_dota_donkey == nil and not _G.hardcore) then
		caster.has_dota_donkey = 1
		local donkey = CreateUnitByName("npc_dota_courier", caster:GetAbsOrigin()+Vector(100, 100, 0), true, caster, caster, caster:GetTeam())
		donkey:SetOwner(caster)
		donkey:SetControllableByPlayer(caster:GetPlayerID(), true)
        donkey:FindAbilityByName("courier_return_to_base"):SetLevel(1)
        donkey:FindAbilityByName("courier_go_to_secretshop"):SetLevel(1)
        donkey:FindAbilityByName("courier_return_stash_items"):SetLevel(1)
        donkey:FindAbilityByName("courier_take_stash_items"):SetLevel(1)
        donkey:FindAbilityByName("courier_transfer_items"):SetLevel(1)
        donkey:FindAbilityByName("courier_burst"):SetLevel(1)
        donkey:FindAbilityByName("courier_morph"):SetLevel(1)
        donkey:FindAbilityByName("courier_take_stash_and_transfer_items"):SetLevel(1)
        donkey:FindAbilityByName("for_magic_immune"):SetLevel(1)
	end
	
			
	local sump = 0
	for playerID = 0, 9 do
		local id       = playerID
  		local p        = PlayerResource:GetPlayer(id)
    	if p ~= nil then
		  sump = sump + 1
		end
	end
	if _G.mo then
		sump = 99
	end
	local steamid = PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID())
	if tostring(steamid) == "128732954" then
		sump = 1
	end
	if s == "-me" then
		local nobu_id = _G.heromap[caster:GetName()]
		GameRules: SendCustomMessage(_G.hero_name_zh[nobu_id].." 英雄勝場為 " .. caster.focus, DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
	end
	if sump <= 2 then
		if string.match(s,"uion") then
		local GameMode = GameRules:GetGameModeEntity()
		GameMode:SetHUDVisible(0,  true) --Clock
		GameMode:SetHUDVisible(1,  true)
		GameMode:SetHUDVisible(2,  true)
		GameMode:SetHUDVisible(3,  true) --Action Panel
		GameMode:SetHUDVisible(4,  true) --Minimap
		GameMode:SetHUDVisible(5,  true) --Inventory
		GameMode:SetHUDVisible(6,  true)
		GameMode:SetHUDVisible(7,  true)
		GameMode:SetHUDVisible(8,  true)
		GameMode:SetHUDVisible(9,  true)
		GameMode:SetHUDVisible(11, true)
		GameMode:SetHUDVisible(12, true)
		end
		if string.match(s,"uioff") then
			local GameMode = GameRules:GetGameModeEntity()
			GameMode:SetHUDVisible(0,  false) --Clock
			GameMode:SetHUDVisible(1,  false)
			GameMode:SetHUDVisible(2,  false)
			GameMode:SetHUDVisible(3,  false) --Action Panel
			GameMode:SetHUDVisible(4,  false) --Minimap
			GameMode:SetHUDVisible(5,  false) --Inventory
			GameMode:SetHUDVisible(6,  false)
			GameMode:SetHUDVisible(7,  false)
			GameMode:SetHUDVisible(8,  false)
			GameMode:SetHUDVisible(9,  false)
			GameMode:SetHUDVisible(11, false)
			GameMode:SetHUDVisible(12, false)
		end
		if string.match(s,"cam") then
		local dis = tonumber(string.match(s, '%d+'))
			GameRules: GetGameModeEntity() :SetCameraDistanceOverride(dis)
		end
		if string.match(s,"-gg") then
			GameRules:SetCustomGameEndDelay(1)
			GameRules:SetCustomVictoryMessage("遊戲時間到了喔~")
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		end
		if string.match(s,"ss") then
			caster:AddAbility("for_move1500"):SetLevel(1)
		end
		if string.match(s,"xx") then
			caster:RemoveAbility("for_move1500")
			caster:RemoveModifierByName("modifier_for_move1500")
		end
		if s=="re" then
			caster:SetTimeUntilRespawn(0)
		end
		if string.match(s,"gold") then
			PlayerResource:SetGold(keys.playerid,99999,false)
		end
		if string.match(s,"money") then
			local money = tonumber(string.match(s, '%d+'))
			PlayerResource:SetGold(keys.playerid,PlayerResource:GetGold(keys.playerid) + money,false)
		end
		if string.match(s,"nogo") then
			PlayerResource:SetGold(keys.playerid,0,false)
		end
		if string.match(s,"cd") then
			--【Timer】
			Timers:CreateTimer(function()
				caster:SetMana(caster:GetMaxMana() )
				--caster:SetHealth(caster:GetMaxHealth())
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
				return nil
			end)
		end

		if string.match(s,"supercd") or string.match(s,"scd") then
			--【Timer】
			Timers:CreateTimer(0.1, function()
				caster:SetMana(caster:GetMaxMana() )
				--caster:SetHealth(caster:GetMaxHealth())
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
				return 0.1
			end)
		end

		if string.match(s,"test") then
			local pID = tonumber(string.match(s, '%d+'))
			local steamID = PlayerResource:GetSteamAccountID(pID)
			GameRules: SendCustomMessage(tostring(steamID),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			local res = PlayerResource:GetConnectionState(pID)
			if (res == 0) then
				GameRules: SendCustomMessage("no connection",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			elseif (res == 1) then
				GameRules: SendCustomMessage("bot connected",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			elseif (res == 2) then
				GameRules: SendCustomMessage("player connected",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			elseif (res == 3) then
				GameRules: SendCustomMessage("bot/player disconnected",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			end
		end
		
		if string.match(s,"item") then
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					print(item:GetName())
				end
			end
		end
		
		if string.match(s,"lv") then
			local lvmax = tonumber(string.match(s, '%d+'))
			if lvmax then
				for i=1,lvmax do
			      caster:HeroLevelUp(true)
			    end
			end
		end
		if s == "creep" then
			ShuaGuai_Of_AA( 10 )
			ShuaGuai_Of_AB( 2 )
			ShuaGuai_Of_B( 2 )
			ShuaGuai_Of_C( 2 )
		end

		if s == "h" then
			GameRules: SendCustomMessage("` = 快速測試，內容不一定",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("r1 = 產生一個被綁住的淺井",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("sa = show ability",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("sm = show modifier",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("cu_es = CreateUnit_EarthShaker",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			GameRules: SendCustomMessage("team + nobu_id = 可以產生該英雄team=0(織田軍), team=1(聯合軍), e.g. 0C01=織田軍-明智光秀 ",DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
		end

		if s == "`" then
			local mds = {}
			for _,m in ipairs(mds) do
				GameRules: SendCustomMessage("[Act-Trans:Modifier] "..m:GetName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			end
		end

		if s == "r1" then
			local  u = CreateUnitByName("npc_dota_hero_magnataur",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			u:AddNewModifier(keys.caster,nil,"modifier_rooted",nil)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		if s == "sa" then
			for i = 0, caster:GetAbilityCount() - 1 do
				local ability = caster:GetAbilityByIndex( i )
				if ability  then
					GameRules: SendCustomMessage("[Ability] "..ability:GetName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
				end
			end
		end

		if s == "sm" then
			for _,m in ipairs(caster:FindAllModifiers()) do
				GameRules: SendCustomMessage("[Modifier] "..m:GetName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			end
		end

		if s == "smm" then
			for _,m in ipairs(caster.donkey:FindAllModifiers()) do
				GameRules: SendCustomMessage("[Modifier] "..m:GetName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
			end
		end

		if s == "model" then
			GameRules: SendCustomMessage("[ModelName] "..caster:GetModelName(),DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS,0)
		end

		if s == "cu_es" then
			local  u = CreateUnitByName("npc_dota_hero_earthshaker",caster:GetAbsOrigin()+Vector(1000,100,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
			u:SetControllableByPlayer(keys.playerid,true)
			for i=1,30 do
			u:HeroLevelUp(true)
			end 
		end

		local upper = s:upper()
		local ai = upper:sub(5,7) == "AI"
		local team = upper:sub(1,1)
		local nobu_id = upper:sub(2,4)
		local dota_hero_name = _G.nobu2dota[nobu_id]
		if dota_hero_name ~= nil then
			if team == "0" then
				-- 織田軍
				local u = CreateUnitByName(dota_hero_name,caster:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_GOODGUYS)
				u:SetControllableByPlayer(keys.playerid,true)
				for i=1,caster:GetLevel() do
					u:HeroLevelUp(true)
				end
				for itemSlot=0,5 do
					local item = caster:GetItemInSlot(itemSlot)
					if item ~= nil then
						local itemName = item:GetName()
						local newItem = CreateItem(itemName, u, u)
						u:AddItem(newItem)
					end
				end
			elseif team == "1" then
				-- 聯合軍
				local u = CreateUnitByName(dota_hero_name,caster:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_BADGUYS)
				u:SetControllableByPlayer(keys.playerid,true)
				for i=1,caster:GetLevel() do
					u:HeroLevelUp(true)
				end

				for itemSlot=0,5 do
					local item = caster:GetItemInSlot(itemSlot)
					if item ~= nil then
						local itemName = item:GetName()
						local newItem = CreateItem(itemName, u, u)
						u:AddItem(newItem)
					end
				end
			end
		end

		--【測試指令】
		if s == "ShuaGuai" then
			print("ShuaGuai")
			ShuaGuai_Of_AA( 10 )
			ShuaGuai_Of_AB( 10 )
			ShuaGuai_Of_B( 10 )
			ShuaGuai_Of_C( 10 )
		elseif s == "hp" then
			caster:SetHealth(caster:GetMaxHealth())
		elseif s == "mp" then
			Timers:CreateTimer(function()
				caster:SetMana(caster:GetMaxMana())
				return 0.1
			end)
		end
	end
end

function Nobu:Chat( keys )
	--【測試模式】
	--if nobu_debug then
		chat_of_test(keys)
	--end
end
