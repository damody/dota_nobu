
function Shock2( keys )

	-- 開關型技能不能用
	if keys.event_ability:IsToggle() then return end

	local caster = keys.caster
	local ability = keys.ability
	if (caster:GetMana() >= 75) then
		caster:SpendMana(75, ability)
		local SEARCH_RADIUS = 1000
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              caster:GetAbsOrigin(),
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				local flame = ParticleManager:CreateParticle("particles/a07t2/a07t2.vpcf", PATTACH_ABSORIGIN, it)
				AMHC:Damage(caster,it, 100,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				Timers:CreateTimer(0.5, function ()
					ParticleManager:DestroyParticle(flame, false)
				end)
			end
		end
	end
end



function Shock( keys )
	local caster = keys.caster
	local point = caster:GetAbsOrigin()
	local ability = keys.ability
	GridNav:DestroyTreesAroundPoint(point, 500, false)

	local dummy =  CreateUnitByName("hide_unit", point , true, nil, caster, caster:GetTeamNumber()) 
	dummy:AddAbility("majia"):SetLevel(1)
	dummy:SetOwner(caster)
	local spell_hint_table = {
		duration   = 11.4,		-- 持續時間
		radius     = 500,		-- 半徑
	}
	dummy:AddNewModifier(dummy,nil,"nobu_modifier_spell_hint",spell_hint_table)
	local count = 0
	local sumtime = 0
	Timers:CreateTimer(0.2, function ()
		if math.mod(count, 3) == 0 then
			dummy:EmitSound("lightningbolt")
		end
		count = count + 1
		sumtime = sumtime + 0.2
		for i=1,3 do
			local pp = point + RandomVector(RandomInt(1, 400))

			local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN, dummy)
			-- Raise 1000 if you increase the camera height above 1000
			ParticleManager:SetParticleControl(particle, 0, Vector(pp.x,pp.y,1000 ))
			ParticleManager:SetParticleControl(particle, 1, Vector(pp.x,pp.y,pp.z + 10 ))
			ParticleManager:SetParticleControl(particle, 2, Vector(pp.x,pp.y,pp.z + 10 ))
		end
		
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		      point,
		      nil,
		      500,
		      DOTA_UNIT_TARGET_TEAM_ENEMY,
		      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		      FIND_ANY_ORDER,
		      false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			if _G.EXCLUDE_TARGET_NAME[it:GetUnitName()] == nil then
				if it:IsMagicImmune() then
					AMHC:Damage(dummy,it, it:GetMaxHealth()*0.016,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				else
					AMHC:Damage(dummy,it, it:GetMaxHealth()*0.016,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				end
			end
		end

		if sumtime < 11 then
			return 0.2
		else
			dummy:ForceKill( true )
			return nil
		end
	end)

	
end


