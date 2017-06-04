function B10E( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point   = caster:GetAbsOrigin()
	local point2  = target:GetAbsOrigin()
	local vec = nobu_atan2( point2,point )
	local distance = 35

	local temp_point = nobu_move( point, point2 , distance )

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,2,Vector(0,0,10))

	Timers:CreateTimer(function()
		point2  = target:GetAbsOrigin()
        temp_point = nobu_move( temp_point, point2 , distance )

        --temp_point = nobu_move_ver2( temp_point , distance ,RandomFloat(0,-30))

        --print(nobu_radtodeg(math.atan2(point2.y-point.y,point2.x-point.x)))

		if nobu_distance( temp_point,point2 ) < 50  or not target:IsAlive()  then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B10E",nil)
			ParticleManager:DestroyParticle(particle,false)

			--print("Stop")
			return nil
		else
			ParticleManager:SetParticleControl(particle,0,temp_point)
			return 0.01
		end
	end)
end






function B10R_buff_OnCreated( keys )
	local target = keys.target
	local ifx = ParticleManager:CreateParticle("particles/b21/b21r_old_buff_soft.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
	ParticleManager:SetParticleControl(ifx,1,Vector(target:BoundingRadius2D()*4))
	target.ifx_B21R_old_buff = ifx
end

function B10R_buff_OnDestroy( keys )
	local target = keys.target
	ParticleManager:DestroyParticle(target.ifx_B21R_old_buff,false)
end


function b10T3_OnIntervalThink( keys )
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
				caster:RemoveModifierByName(v:GetName())
			end
		end
	end
end


function B10T_heal( event )
	local ability = event.ability	
	local caster = event.caster
	caster:Heal(caster:GetMaxHealth(),caster)
end
