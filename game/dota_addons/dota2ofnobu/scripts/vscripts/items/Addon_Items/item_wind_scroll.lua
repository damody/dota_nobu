-- 風之卷

function Shock( keys )
	--【Basic】
	local caster = keys.caster
	local caster_point = caster:GetAbsOrigin()
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local dummy = CreateUnitByName( "npc_dummy_unit_Ver2", caster_point, false, caster, caster, caster:GetTeamNumber() )
	dummy:FindAbilityByName("majia"):SetLevel(1)
	local particle2 = ParticleManager:CreateParticle("particles/item_d01_3/d01_3.vpcf",PATTACH_POINT,dummy)
	ParticleManager:SetParticleControl(particle2,0, point+Vector(0,0,0))
	local particle3 = ParticleManager:CreateParticle("particles/item/d01_2/d01_2.vpcf",PATTACH_POINT,dummy)
	ParticleManager:SetParticleControl(particle3,0, point+Vector(0,0,400))

	local particle = ParticleManager:CreateParticle("particles/item_d01_3/d01_3_c.vpcf",PATTACH_POINT,dummy)
	ParticleManager:SetParticleControl(particle,0, point+Vector(0,0,0))
	local num = 0
	local time = 0
	
	local tem_p1 = point+Vector(0,0,400)
	local tem_p2 = nil

	Timers:CreateTimer(0, function ()
		time = time + 0.25
		if time > 20 then
			return nil
		else
			local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
					caster_point,
					nil,
					1500,
					DOTA_UNIT_TARGET_TEAM_FRIENDLY,
					DOTA_UNIT_TARGET_ALL,
					DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
					FIND_ANY_ORDER,
					false)

			for _,it in pairs(direUnits) do
				if (not(it:IsBuilding()) and IsValidEntity(it) ) then
					keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_item_wind_scroll",nil)
				end
			end
			return 0.2	
		end
	end)

	Timers:CreateTimer(0, function ()
		num = num + 1
		if num == 10 then
			ParticleManager:DestroyParticle(particle,false)
			ParticleManager:DestroyParticle(particle2,true)
			ParticleManager:DestroyParticle(particle3,true)
			if IsValidEntity(dummy) then
				dummy:ForceKill(true)
			end
			return nil
		else
 			ParticleManager:DestroyParticle(particle,false)
			particle = ParticleManager:CreateParticle("particles/item_d01_3/d01_3_c.vpcf",PATTACH_POINT,dummy)
			ParticleManager:SetParticleControl(particle,0, tem_p1)
			return 2	
		end
	end)

end
