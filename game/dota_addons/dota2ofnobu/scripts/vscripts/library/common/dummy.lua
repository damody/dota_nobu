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
          local donkey = CreateUnitByName("cp_soldiercamp", caster.origin_pos, true, caster, caster, caster:GetTeamNumber())
          donkey:SetAbsOrigin(caster.origin_pos)
          donkey:AddAbility("majia_cp"):SetLevel(1)
          Timers:CreateTimer(1, function ()
          	if caster:IsAlive() then
          		return 1
          	else
          		donkey:ForceKill(true)
          		donkey:Destroy()
          	end
        	end)  	
          return nil
        end)
	
	--donkey:AddAbility("majia_cp"):SetLevel(1)
end
