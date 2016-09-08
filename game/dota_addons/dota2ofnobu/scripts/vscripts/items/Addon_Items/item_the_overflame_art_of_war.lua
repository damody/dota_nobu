
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	
	--math.random(-100, 100)
	local chaos = {}
	Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
		chaos[1] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(chaos[1], 0, point)
	end)

	Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
		chaos[2] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(chaos[2], 0, point + Vector(300, 0, 0))
	end)
	Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
		chaos[3] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(chaos[3], 0, point + Vector(-300, 0, 0))
	end)
	Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
		chaos[4] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(chaos[4], 0, point + Vector(250, 200, 0))
	end)
	Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
		chaos[5] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(chaos[5], 0, point + Vector(-100, -300, 0))
	end)
	Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
		chaos[6] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(chaos[6], 0, point + Vector(200, -300, 0))
	end)
	Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
		chaos[7] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(chaos[7], 0, point + Vector(-250, 200, 0))
	end)

	local dummy = CreateUnitByName( "npc_dummy", point, false, caster, caster, caster:GetTeamNumber() )
	dummy:EmitSound( "war.sound1" )
	Timers:CreateTimer( 1.5, function()
				dummy:EmitSound( "war.sound1" )
				return nil
			end
			)
	Timers:CreateTimer( 6.5, function()
					dummy:ForceKill( true )
					return nil
				end
			)

	local count = 0
	Timers:CreateTimer(1, function ()
		count = count + 1
		local SEARCH_RADIUS = 650
		GridNav:DestroyTreesAroundPoint(point, SEARCH_RADIUS, false)
			local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		                              point,
		                              nil,
		                              SEARCH_RADIUS,
		                              DOTA_UNIT_TARGET_TEAM_ENEMY,
		                              DOTA_UNIT_TARGET_ALL,
		                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		                              FIND_ANY_ORDER,
		                              false)
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				AMHC:Damage(caster,it,ability:GetLevelSpecialValueFor("damage", 0 ),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				ability:ApplyDataDrivenModifier(caster, it,"modifier_the_overflame_art_of_war",nil)
				local rock_effect = ParticleManager:CreateParticle("particles/b26t/b26t.vpcf", PATTACH_ABSORIGIN, it)
				ParticleManager:SetParticleControl(rock_effect, 0, it:GetAbsOrigin())
			else
				AMHC:Damage(caster,it,ability:GetLevelSpecialValueFor("damage", 0 )*0.3,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		if count > 5 then
			for i=1,#chaos do
				ParticleManager:DestroyParticle(chaos[i], false)
			end
			return nil
		else
			return 0.8
		end
	end)
	
	
end


