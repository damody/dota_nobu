
--鬼丸國剛

function Shock( keys )
	local caster = keys.caster

	local point = caster:GetAbsOrigin()
	local pointx = point.x
	local pointy = point.y
	local pointz = point.z
	local pointx2
	local pointy2
	local a	
	local maxrock = 6

	for radius=100,800,100 do
		maxrock = maxrock + 8
		local maxspike = maxrock
		Timers:CreateTimer(radius*0.0003, function() 
			for i=1,maxspike do
				a	=	(	(360.0/maxspike)	*	i	)* bj_DEGTORAD
				pointx2 	=  	pointx 	+ 	radius 	* 	math.cos(a)
				pointy2 	=  	pointy 	+ 	radius 	*	math.sin(a)
				point = Vector(pointx2 ,pointy2 , pointz)
				local spike = ParticleManager:CreateParticle("particles/item/item_the_great_sword_of_spike.vpcf", PATTACH_ABSORIGIN, keys.caster)
				ParticleManager:SetParticleControl(spike, 0, point)
				Timers:CreateTimer(2, function() 
					ParticleManager:DestroyParticle(spike,true)
				end)
			end
		end)
	end

	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                              caster:GetAbsOrigin(),
                              nil,
                              800,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

	--effect:傷害+暈眩
	for _,it in pairs(direUnits) do
		if not(it:IsBuilding()) then
			AMHC:Damage(caster, it, 250, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			if IsValidEntity(it) then
				Physics:Unit(it)
				keys.ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = 2.6})
				keys.ability:ApplyDataDrivenModifier(caster,it,"modifier_invulnerable",{duration = 1})
				it:SetPhysicsVelocity(Vector(0,0,1500))
			end
		end
	end
	Timers:CreateTimer(0.5, function()
		for _,it in pairs(direUnits) do
			if not(it:IsBuilding()) then
				if IsValidEntity(it) then
					it:SetPhysicsVelocity(Vector(0,0,-1500))
				end
			end
		end
	end)
end


