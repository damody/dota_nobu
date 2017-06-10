--真田昌幸

function modifier_B09W_OnCreated( keys )
	local ability= keys.ability
	local caster = keys.caster
	local target = keys.target
	local B09W_counter=0
	target.max_count=8
	--local buff=target:FindModifierByName("modifier_B09W_counter")
	--buff:SetStackCount(8)
	--local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_trigger_ground_symbol_add.vpcf", PATTACH_ABSORIGIN, caster)
	--ParticleManager:SetParticleControl(particle, 0, point)
	--AMHC:Damage( caster,target,ability:GetAbilityDamage(),AMHC:DamageType("DAMAGE_TYPE_MAGICAL") )
	local count = 0
	Timers:CreateTimer(0, function()
		print(count - math.floor(count/10)*10)
		if target:HasModifier("modifier_B09W_counter") then
			if math.mod(count, 10) == 0 then
				if target:IsMagicImmune() then
					AMHC:Damage( caster,target,ability:GetAbilityDamage()*B09W_counter*0.5,AMHC:DamageType("DAMAGE_TYPE_PURE") )
				else
					AMHC:Damage( caster,target,ability:GetAbilityDamage()*B09W_counter,AMHC:DamageType("DAMAGE_TYPE_PURE") )
				end
			end
		elseif target:IsMagicImmune() then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B09W_counter", {duration=20-B09W_counter})
		else
			return nil
		end
		B09W_counter=B09W_counter+0.1
		count = count + 1
		if B09W_counter>=target.max_count then
			target:RemoveModifierByName("modifier_B09W")
			target:RemoveModifierByName("modifier_B09W_counter")
			return nil
		else
			return 0.1
		end
    end)
end

function modifier_B09W_OnAbilityExecuted( keys )
	local target =keys.unit
	local ability=keys.ability
	local b09W_max_count=keys.ability:GetSpecialValueFor("max_count")
	local buff=target:FindModifierByName("modifier_B09W")
	local buff_count=target:FindModifierByName("modifier_B09W_counter")
	if target.max_count<b09W_max_count then
		target.max_count=target.max_count+1
		buff_count:SetStackCount(target.max_count)
		print(buff:GetRemainingTime())
		buff:SetDuration(buff:GetRemainingTime()+1,true)
	end

end


function modifier_B09E_OnChannelInterrupted( keys )
	if IsValidEntity(keys.target) then
		if keys.target:FindModifierByName("modifier_B09E") then
			keys.target:RemoveModifierByName("modifier_B09E")
		end
	end
end


function modifier_B09E_OnIntervalThink( keys )
	--for i,v in pairs(keys) do
   --     print(tostring(i).."="..tostring(v))
    --end
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point = target:GetAbsOrigin()
	local damage = ability:GetSpecialValueFor("damage")/100*caster:GetMaxMana()+55
	local ifx = ParticleManager:CreateParticle( "particles/b09e/b09e3.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,50))
	ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,50))
	Timers:CreateTimer(0.5, function ()
		ParticleManager:DestroyParticle(ifx,true)
	end)
	local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 400, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if not unit:IsBuilding() then
			ApplyDamage(damageTable)
		end
	end


	local distance=(caster:GetAbsOrigin()-target:GetAbsOrigin()):Length()

				--超出距離摧毀特效 停止計時
	if distance> ability:GetSpecialValueFor("max_range") or target:IsMagicImmune() or not caster:IsAlive() then
		target:RemoveModifierByName("modifier_B09E")
		caster:InterruptChannel()	
	end
end


function B09E_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	caster.B09E_target = target

	local particle3 = ParticleManager:CreateParticle("particles/b09e/b09e.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle3, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle3, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	Timers:CreateTimer(0.2, function ()
      	if target ~= nil and IsValidEntity(target) and target:HasModifier("modifier_B09E") and caster:IsChanneling() then
      		local particle2 = ParticleManager:CreateParticle("particles/b09e/b09e.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControlEnt(particle2, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(particle2, 4, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
      		return 0.2
      	else
      		caster.B09E_target = nil
      		--ParticleManager:DestroyParticle(particle,false)
      		return nil
      	end
    end)
end


LinkLuaModifier( "modifier_B09R", "heroes/B_Unified/B09.lua",LUA_MODIFIER_MOTION_NONE )
modifier_B09R = class({})

--------------------------------------------------------------------------------

function modifier_B09R:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_B09R:OnCreated( event )
	self:StartIntervalThink(0.1)
end

function modifier_B09R:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_B09R:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    if (self.caster ~= nil) and IsValidEntity(self.caster) then

		    if victim:GetTeam() ~= attacker:GetTeam() and attacker == self.caster and self.hp ~= nil then
		        local dmg = self.hp - self.caster:GetHealth()
				local healmax = dmg*0.3
				local mana = healmax / self.b09r_manadamage
				if (self.caster:GetMana() >= mana and self.caster:GetHealth() > healmax) then
					self.caster:SpendMana(mana,ability)
					self.caster:SetHealth(self.caster:GetHealth() + healmax)
				end
		    end
		end
	end
end



function B09R_OnToggleOn( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	caster:AddNewModifier(caster,ability,"modifier_B09R",nil)
	caster:FindModifierByName("modifier_B09R").caster = caster
	caster:FindModifierByName("modifier_B09R").hp = caster:GetHealth()
	caster:FindModifierByName("modifier_B09R").b09r_manadamage=ability:GetSpecialValueFor("manadamage")
	caster.b09r_particle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	local shield_size = 50
	ParticleManager:SetParticleControl(caster.b09r_particle, 1, Vector(99999,0,1))
	ParticleManager:SetParticleControl(caster.b09r_particle, 2, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(caster.b09r_particle, 4, Vector(shield_size,0,shield_size))
	ParticleManager:SetParticleControl(caster.b09r_particle, 5, Vector(shield_size,0,0))
	ParticleManager:SetParticleControlEnt(caster.b09r_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
end

function B09R_OnToggleOff( keys )
	keys.caster:RemoveModifierByName("modifier_B09R")
	if keys.caster.b09r_particle then
		ParticleManager:DestroyParticle(keys.caster.b09r_particle, true)
	end
end


function B09T_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
          point,
          nil,
          700,
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
          0,
          false)
	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=1} )
	dummy:SetOwner( caster)
	dummy:AddAbility( "majia"):SetLevel(1)
	local flame = ParticleManager:CreateParticle("particles/b09/b09_t.vpcf", PATTACH_ABSORIGIN, dummy)
	ParticleManager:SetParticleControl(flame,4,point+Vector(0, 0, 20))
	Timers:CreateTimer(1, function ()
		ParticleManager:DestroyParticle(flame, false)
	end)	
	
	for _,target in pairs(direUnits) do
		if not target:IsBuilding() then
			if (target:IsMagicImmune()) then
				ability:ApplyDataDrivenModifier(caster,target,"modifier_B09T",{duration = duration*0.5})
				target:SetMana(target:GetMana()*0.4)
			else
				target:SetMana(target:GetMana()*0.4)
				ability:ApplyDataDrivenModifier(caster,target,"modifier_B09T",{duration = duration})
				AMHC:Damage(caster,target, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			end
		end
	end
end



function B09W_old_OnSpellStart( keys )
	local caster = keys.caster
	local dummy = keys.target
	local ability = keys.ability
	local point = keys.target_points[1] 
	local point2
	StartSoundEvent( "Hero_Leshrac.Lightning_Storm", dummy )
	StartSoundEvent( "Hero_Leshrac.Lightning_Storm", v )
	point2 = point
	local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN , caster)
	local particle2 = ParticleManager:CreateParticle("particles/b09w_old/b09w_old.vpcf", PATTACH_ABSORIGIN , caster)
	ParticleManager:SetParticleControl(particle2, 0, Vector(point2.x,point2.y,point2.z+30 ))

	-- Raise 1000 if you increase the camera height above 1000
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(0,0,800))
	ParticleManager:SetParticleControl(particle, 1, Vector(point2.x,point2.y,point2.z ))
	ParticleManager:SetParticleControl(particle, 2, Vector(point2.x,point2.y,point2.z ))
end



function B09E_old_OnSpellStart( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local dir = ability:GetCursorPosition() - caster:GetOrigin()

	for i=1,3 do
		local pos = caster:GetOrigin() + dir:Normalized() * (i * 300)
		local ifx = ParticleManager:CreateParticle( "particles/b09e/b09e3.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl( ifx, 0, pos + Vector(0,0,50))
		ParticleManager:SetParticleControl( ifx, 3, pos + Vector(0,0,50))

		local SEARCH_RADIUS = 300
		GridNav:DestroyTreesAroundPoint(pos, SEARCH_RADIUS, false)
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              pos,
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
				if it.b09e == nil then
					duration=ability:GetSpecialValueFor("duration")
					AMHC:Damage(caster,it, ability:GetSpecialValueFor("damage"),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
					ability:ApplyDataDrivenModifier(caster, it,"modifier_B09E_old",nil)
					it.b09e = 1
				end
			end
		end
	end

	for i=1,3 do
		local pos = caster:GetOrigin() + dir:Normalized() * (i * 300)
		local SEARCH_RADIUS = 300
		local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
	                              pos,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		for _,it in pairs(direUnits) do
			if (not(it:IsBuilding())) then
				it.b09e = nil
			end
		end
	end

end



function B09T_old_OnSpellStart( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local dir = caster:GetForwardVector()
	local point2 = point + dir * 300
 	local player = caster:GetPlayerID()
 	local level = ability:GetLevel() - 1
 	local life_time = ability:GetLevelSpecialValueFor("life_time",level)
 	local base_hp = ability:GetLevelSpecialValueFor("base_hp",level)

 	local Kagutsuchi = CreateUnitByName("b09t_old_wind",point2 ,true,caster,caster,caster:GetTeam())
 	Kagutsuchi:SetOwner(caster)
 	-- 設定火神數值
 	Kagutsuchi:AddAbility("B09TW_old"):SetLevel(ability:GetLevel())
 	Kagutsuchi:SetForwardVector(dir)
	Kagutsuchi:SetControllableByPlayer(player, true)
	Kagutsuchi:AddNewModifier(Kagutsuchi,nil,"modifier_kill",{duration=life_time})
	--ability:ApplyDataDrivenModifier(caster,Kagutsuchi,"modifier_A28T_old",nil)
	--local hModifier = Kagutsuchi:FindModifierByNameAndCaster("modifier_A28T_old", caster)
	--hModifier:SetStackCount(level+1)
	
	-- 配合特效稍微條快動畫速度
	--Kagutsuchi:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, 1.3)
	-- 特效
	local ifx = ParticleManager:CreateParticle("particles/b09/b09t.vpcf",PATTACH_ABSORIGIN_FOLLOW,Kagutsuchi)
	ParticleManager:SetParticleControl(ifx,0,Kagutsuchi:GetAbsOrigin())
	Timers:CreateTimer(life_time, function ()
		ParticleManager:DestroyParticle(ifx,true)
	end)

end



function modifier_B09TE_old_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local aoe_radius = ability:GetLevelSpecialValueFor("aoe_radius",level)
	local aoe_damage = ability:GetLevelSpecialValueFor("aoe_damage",level)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  aoe_radius , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

	for _,enemy in pairs(enemies) do
		if not enemy:IsBuilding() then
			AMHC:Damage(caster,enemy,aoe_damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end

function modifier_B09TE_old_building_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local aoe_radius = ability:GetLevelSpecialValueFor("aoe_radius",level)
	local aoe_damage = ability:GetLevelSpecialValueFor("aoe_damage_building",level)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
		caster:GetAbsOrigin(),
		nil,
		aoe_radius,
		ability:GetAbilityTargetTeam(),
		DOTA_UNIT_TARGET_BUILDING,
		ability:GetAbilityTargetFlags(),
		FIND_ANY_ORDER,
		false)

	for _,enemy in pairs(enemies) do
		if enemy:IsBuilding() then
			AMHC:Damage(caster,enemy,aoe_damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end


function modifier_B09TW_old_aura_debuff_OnIntervalThink( keys )
	--【Basic】
	local unit = keys.target
	local ifx = ParticleManager:CreateParticle("particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf",PATTACH_ABSORIGIN,unit)
	ParticleManager:SetParticleControl(ifx,0,unit:GetAbsOrigin())
	ParticleManager:SetParticleControl(ifx,1,unit:GetAbsOrigin())

end