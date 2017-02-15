
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	
	--math.random(-100, 100)
	local chaos = {}
	local idx = 1
	local dummy = CreateUnitByName( "npc_dummy", point, false, caster, caster, caster:GetTeamNumber() )
	dummy:SetOwner(caster)
	for i=0,3 do
		Timers:CreateTimer( i*2.5, function()
				dummy:EmitSound( "war.sound1" )
				local id1 = idx
				Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
					chaos[id1] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, dummy)
					ParticleManager:SetParticleControl(chaos[id1], 0, point)
					Timers:CreateTimer(8, function ()
						ParticleManager:DestroyParticle(chaos[id1], true)
						end)
				end)
				idx = idx + 1
				local id2 = idx
				Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
					chaos[id2] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, dummy)
					ParticleManager:SetParticleControl(chaos[id2], 0, point + Vector(300, 0, 0))
					Timers:CreateTimer(8, function ()
						ParticleManager:DestroyParticle(chaos[id2], true)
						end)
				end)
				idx = idx + 1
				local id3 = idx
				Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
					chaos[id3] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, dummy)
					ParticleManager:SetParticleControl(chaos[id3], 0, point + Vector(-300, 0, 0))
					Timers:CreateTimer(8, function ()
						ParticleManager:DestroyParticle(chaos[id3], true)
						end)
				end)
				idx = idx + 1
				local id4 = idx
				Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
					chaos[id4] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, dummy)
					ParticleManager:SetParticleControl(chaos[id4], 0, point + Vector(250, 200, 0))
					Timers:CreateTimer(8, function ()
						ParticleManager:DestroyParticle(chaos[id4], true)
						end)
				end)
				idx = idx + 1
				local id5 = idx
				Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
					chaos[id5] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, dummy)
					ParticleManager:SetParticleControl(chaos[id5], 0, point + Vector(-100, -300, 0))
					Timers:CreateTimer(8, function ()
						ParticleManager:DestroyParticle(chaos[id5], true)
						end)
				end)
				idx = idx + 1
				local id6 = idx
				Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
					chaos[id6] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, dummy)
					ParticleManager:SetParticleControl(chaos[id6], 0, point + Vector(200, -300, 0))
					Timers:CreateTimer(8, function ()
						ParticleManager:DestroyParticle(chaos[id6], true)
						end)
				end)
				idx = idx + 1
				local id7 = idx
				Timers:CreateTimer(math.random(0, 5) * 0.1, function ()
					chaos[id7] = ParticleManager:CreateParticle("particles/item/item_the_overflame_art_of_war.vpcf", PATTACH_ABSORIGIN, dummy)
					ParticleManager:SetParticleControl(chaos[id7], 0, point + Vector(-250, 200, 0))
					Timers:CreateTimer(8, function ()
						ParticleManager:DestroyParticle(chaos[id7], true)
						end)
				end)
				idx = idx + 1
				return nil
			end)
	end
	Timers:CreateTimer( 15, function()
					dummy:ForceKill( true )
					return nil
				end)


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
	                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) and IsValidEntity(it) then
				AMHC:Damage(dummy,it,ability:GetLevelSpecialValueFor("damage", 0 ),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				ability:ApplyDataDrivenModifier(dummy, it,"modifier_the_overflame_art_of_war",nil)
				if IsValidEntity(it) then
					local rock_effect = ParticleManager:CreateParticle("particles/b26t/b26t.vpcf", PATTACH_ABSORIGIN, it)
					ParticleManager:SetParticleControl(rock_effect, 0, it:GetAbsOrigin())
				end
			else
				AMHC:Damage(dummy,it,ability:GetLevelSpecialValueFor("damage", 0 )*0.3,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		if count > 13 then
			return nil
		else
			return 0.8
		end
	end)
	
	
end


