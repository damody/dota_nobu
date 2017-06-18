
function item_soul_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		if ability then
			local caster =ability:GetCaster()
			if damage > caster:GetHealth() and not caster:IsIllusion() then
				caster:StartGestureWithPlaybackRate(ACT_DOTA_DIE,1)
				caster:SetHealth(caster:GetMaxHealth())
				caster:SetMana(caster:GetMaxMana())
				local am = caster:FindAllModifiers()
				for _,v in pairs(am) do
					if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
						if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
							caster:RemoveModifierByName(v:GetName())
						end
					end
				end
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_the_soul_of_power2",{duration = 3})
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_invulnerable",{duration = 8})
				Timers:CreateTimer(1, function()
					for itemSlot=0,5 do
						local item = caster:GetItemInSlot(itemSlot)
						if item ~= nil then
							local itemName = item:GetName()
							if (itemName == "item_the_soul_of_power") then
								item:Destroy()
								break
							end
						end
					end
					end)
			end
		end
	end
end

function getMVP_value(hero)
	if hero.building_count then
		local kda = hero:GetKills()*1.5-hero:GetDeaths()+hero:GetAssists()+hero.building_count
		return kda
	end
	return 0
end

function getK_value(hero)
	if hero.building_count then
		local kda = hero:GetKills()
		return kda
	end
	return 0
end

function getD_value(hero)
	if hero.building_count then
		local kda = hero:GetDeaths()
		return kda
	end
	return 0
end

function getA_value(hero)
	if hero.building_count then
		local kda = hero:GetAssists()
		return kda
	end
	return 0
end

function MVP_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		if ability then
			local caster =ability:GetCaster()
			if damage > caster:GetHealth() then
				caster:SetHealth(1000)
				caster:AddNewModifier(caster, nil, "modifier_invulnerable", nil )
				caster:AddNewModifier(caster, nil, "modifier_kill", {duration=10} )
				local mvp = nil
				local mvp_value = -100
				for _,hero in ipairs(HeroList:GetAllHeroes()) do
					if not hero:IsIllusion() then
						if not hero:IsAlive() then
							hero:SetTimeUntilRespawn(0)
						end
						if getMVP_value(hero)>mvp_value then
							mvp_value = getMVP_value(hero)
							mvp = hero
							
						end
					end
				end
				
				Timers:CreateTimer(0.1, function()
					local pos = caster:GetAbsOrigin()
					if mvp then
						for i=0,9 do
							AMHC:SetCamera(i, mvp)
						end
						mvp:SetAbsOrigin(pos+Vector(0,0,250))
						local nobu_id = _G.heromap[mvp:GetName()]
						GameRules:SetCustomVictoryMessage("本場MVP為 ".._G.hero_name_zh[nobu_id])
						Timers:CreateTimer(0.1, function()
							mvp:SetAbsOrigin(pos+Vector(0,0,250))
							mvp:AddNewModifier(mvp, nil, "modifier_invulnerable", nil )
							return 0.1
						end)
					end
					end)
			end
		end
	end
end
