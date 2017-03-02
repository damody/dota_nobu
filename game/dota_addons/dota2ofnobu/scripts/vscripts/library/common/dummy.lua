
function top_broken( keys )
  local caster = keys.caster
  local team = caster:GetTeamNumber()
  _G.team_broken[team]["top"] = _G.team_broken[team]["top"] + 1
end

function mid_broken( keys )
  local caster = keys.caster
  local team = caster:GetTeamNumber()
  _G.team_broken[team]["mid"] = _G.team_broken[team]["mid"] + 1
end

function down_broken( keys )
  local caster = keys.caster
  local team = caster:GetTeamNumber()
  _G.team_broken[team]["down"] = _G.team_broken[team]["down"] + 1
end


function killdummy( keys )
	local dummy = keys.target
	--print(dummy:GetUnitName())
	if dummy ~= nil then
    if IsValidEntity(dummy) then
		  dummy:ForceKill(true)
    end
		print(dummy:GetUnitName())
	end
end


function CP_Posistion( keys )
	local caster = keys.caster
	caster.origin_pos = caster:GetAbsOrigin()
	Timers:CreateTimer(1, function ()
    if IsValidEntity(caster) and not caster:IsIllusion() then
      local donkey = CreateUnitByName("cp_soldiercamp", caster.origin_pos, true, caster, caster, caster:GetTeamNumber())
      donkey:SetAbsOrigin(caster.origin_pos)
      donkey:AddAbility("majia_cp"):SetLevel(1)
      Timers:CreateTimer(1, function ()
      	if caster~= nil and IsValidEntity(caster) and caster:IsAlive() then
      		return 1
      	else
          Timers:CreateTimer(10, function ()
      		  donkey:ForceKill(true)
            end)
      	end
    	end)  	
      return nil
    end
  end)
	--donkey:AddAbility("majia_cp"):SetLevel(1)
end
