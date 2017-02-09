function killdummy( keys )
	local dummy = keys.target
	--print(dummy:GetUnitName())
	if dummy ~= nil then
		dummy:ForceKill(true)
		print(dummy:GetUnitName())
	end
end

function CP_Posistion( keys )
	local caster = keys.caster
	
	Timers:CreateTimer(1, function ()
		  caster.origin_pos = caster:GetAbsOrigin()
        if not caster:IsIllusion() then
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
