

function attribute_bonus(keys)
	local caster = keys.caster
	local level = keys.ability:GetLevel() - 1
	local upvalue = 2
	if (caster.bonus == nil) then
		caster.bonus = level
		caster:ModifyStrength( upvalue*level )
		caster:ModifyAgility( upvalue*level )
		caster:ModifyIntellect( upvalue*level )
		caster:CalculateStatBonus()  --This is needed to update Morphling's maximum HP when his STR is changed, for example.
	else
		local up = level - keys.caster.bonus
		caster.bonus = level
		caster:ModifyStrength( upvalue*up )
		caster:ModifyAgility( upvalue*up )
		caster:ModifyIntellect( upvalue*up )
		caster:CalculateStatBonus()
	end
	if level == 0 then
		Timers:CreateTimer(0.3,function( )
			if IsValidEntity(caster) and not caster:IsIllusion() then
				local steamID = PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID())
				local nobu_id = _G.heromap[caster:GetName()]
				local version = caster.version
				local ids = {}
				ids[tostring(steamID)] = nobu_id.."_"..version
				SendHTTPRequest("query_focus", "POST",
					ids,
					function(result)
						print(result)
						if not pcall(function()
							resultTable = json.decode(result)
						end) then
							Warning("[dota2.tools.Storage] Can't decode result: " .. result)
						end
						for i,v in pairs(resultTable) do
							caster.focus = v
						end
					end)
			end
			end)
	end
end
sp_role = {
	["128732954"] = true,
	["214260739"] = true,
}

function show_lv(keys)
	local caster = keys.caster
	local steamid = PlayerResource:GetSteamAccountID(caster:GetPlayerOwnerID())
	local ability = keys.ability
	if sp_role[tostring(steamid)] then
		caster.lvlv = caster.lvlv or 1
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_lv"..caster.lvlv .."_1", nil )
		caster.lvlv = caster.lvlv + 1
		if caster.lvlv > 4 then
			caster.lvlv = 1
		end
	end 
	if caster.focus >= 120 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_lv4_1", nil )
	elseif caster.focus >= 80 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_lv3_1", nil )
	elseif caster.focus >= 50 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_lv2_1", nil )
	elseif caster.focus >= 20 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_lv1_1", nil )
	end
end

function bonusx_lock( keys )
	keys.ability:SetActivated(false)
end

function bonusx_unlock( keys )
	keys.ability:SetActivated(true)
	keys.ability:ToggleAbility()
end
