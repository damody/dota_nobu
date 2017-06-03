-- 霧隱才藏 by Nian Chen
-- 2017.4.7

function B17W( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local atk = ability:GetSpecialValueFor("B17W_atk")
	local unit = CreateUnitByName("B17W_deathGuard_hero", point, true, caster, caster, caster:GetTeamNumber())
	unit:SetOwner(caster)
	unit:RemoveModifierByName("modifier_invulnerable")
	unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	ability:ApplyDataDrivenModifier(unit, unit, "modifier_B17W", nil)
	ability:ApplyDataDrivenModifier(unit, unit, "modifier_B17W_notActivate", nil)
	unit:AddNewModifier( unit, nil, "modifier_invisible", nil)
	ability:ApplyDataDrivenModifier(unit, unit, "modifier_B17W_detectorAura", nil)
	unit:SetBaseDamageMax(atk)
	unit:SetBaseDamageMin(atk)
end

function B17W_onAttackLanded( keys )
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local agiBonus = ability:GetSpecialValueFor("B17W_agiBonus")
	local damageExtra = attacker:GetOwner():GetAgility() * agiBonus
	if RandomInt(1,100) < 20 and not target:IsMagicImmune() and not target:IsBuilding() then
		ability:ApplyDataDrivenModifier(attacker,target,"modifier_stunned",{duration=0.5})
	end
	--[[
	local dmgt = {
		victim = target,
		attacker = attacker,
		ability = ability,
		damage = damageExtra ,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	}
	ApplyDamage(dmgt)
	]]
end

function B17W_onTakeDamage( keys )
	if IsServer() then
		local damage = keys.DamageTaken
		local ability = keys.ability
		if ability then
			local unit = keys.unit
			if damage > unit:GetHealth() then
				local newHealth = unit:GetMaxHealth() + damage
				unit:SetHealth(newHealth)
				unit:RemoveModifierByName("modifier_B17W_notActivate")
			end
		end
	end
end

function B17W_activate( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_invisible") then
		caster:RemoveModifierByName("modifier_invisible")
	end
	if caster:HasModifier("modifier_B17W_detectorAura") then
		caster:RemoveModifierByName("modifier_B17W_detectorAura")
	end
	ExecuteOrderFromTable( { UnitIndex = caster:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE , Position = caster:GetAbsOrigin() })
end

function B17W_activateEnd( keys )
	local caster = keys.caster
	caster:ForceKill(true)
end

function B17W_triggered( keys )
	local caster = keys.caster -- mine
	local ability = keys.ability
	local stunRadius = ability:GetSpecialValueFor("B17W_stunRadius")
	local stunDuration = ability:GetSpecialValueFor("B17W_stunDuration")

	if caster:HasModifier("modifier_invisible") then
		caster:RemoveModifierByName("modifier_invisible")
	end
	--delay 0.5
	Timers:CreateTimer(0.5, function ()
		if caster:HasModifier("modifier_B17W_notActivate") then
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_rooted",nil)
			caster:RemoveModifierByName("modifier_B17W_notActivate")

			-- 搜尋
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				caster:GetAbsOrigin(),			-- 搜尋的中心點
				nil, 							-- 好像是優化用的參數不懂怎麼用
				stunRadius,						-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 							-- 好像是優化用的參數不懂怎麼用

			-- 處理搜尋結果
			for _,unit in ipairs(units) do
				unit:AddNewModifier( caster, ability, "modifier_stunned", { duration = stunDuration })
			end

			local ifx = ParticleManager:CreateParticle("particles/b17w/b17w.vpcf",PATTACH_ABSORIGIN,caster)
			ParticleManager:SetParticleControl( ifx, 1, caster:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(ifx)
		end
	end)

end

function B17R( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("B17R_radius")
	local damage = ability:GetSpecialValueFor("B17R_damage")
	local point = ability:GetCursorPosition()
	if (point-caster:GetAbsOrigin()):Length2D() > 500 then
		local nor = (point-caster:GetAbsOrigin()):Normalized()
		point = nor*500+caster:GetAbsOrigin()
	end
	FindClearSpaceForUnit( caster, point , true)
	keys.caster:AddNewModifier( caster, nil, "modifier_phased", {duration=0.1} )

	local ifx = ParticleManager:CreateParticle("particles/b17r/b17rde.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl( ifx, 0, point)
	ParticleManager:ReleaseParticleIndex(ifx)

	local units = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for i,unit in ipairs(units) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if unit:IsMagicImmune() then
			damageTable.damage = damageTable.damage * ( 1 + ability:GetSpecialValueFor("B17R_magicimmuneBonus") )
		end
		ApplyDamage(damageTable)
	end
end

function B17T_End( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local abilityDamage = ability:GetSpecialValueFor("B17T_damage")
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			PopupCriticalDamage(target, abilityDamage)
			AMHC:Damage( caster, target, abilityDamage, AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end	
		keys.caster:RemoveModifierByName( "modifier_B17T" )
		keys.caster:RemoveModifierByName( "modifier_invisible" )
	end
end

function B17T_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster.B17T_OnAbility = nil
end

function B17T_OnAbilityExecuted( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster.B17T_OnAbility ~= nil then
		caster:RemoveModifierByName( "modifier_B17T" )
		--caster:RemoveModifierByName( "modifier_invisible" )
	else
		Timers:CreateTimer(0.01, function ()
			if IsValidEntity(caster) then
				local handle = caster:FindModifierByName("modifier_B17T")
				if handle then
					local dura = handle:GetDuration() - handle:GetElapsedTime()
					ability:ApplyDataDrivenModifier(caster,caster,"modifier_invisible",{duration = dura})
				end
			end
			end)
		caster.B17T_OnAbility = 1
	end
end

function B17W_old_End( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local abilityDamage = ability:GetSpecialValueFor("B17W_old_damage")
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			PopupCriticalDamage(target, abilityDamage)
			AMHC:Damage( caster, target, abilityDamage, AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end	
		keys.caster:RemoveModifierByName( "modifier_B17W_old" )
		keys.caster:RemoveModifierByName( "modifier_invisible" )
	end
end

function B17R_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local radius = ability:GetSpecialValueFor("B17R_old_radius")

	local unit = CreateUnitByName("B17R_old_shuriken", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster, unit, "modifier_B17R_old", nil)

	local destination = caster:GetAbsOrigin() + 2000 * caster:GetForwardVector()

	--wait for unit spawn
	Timers:CreateTimer(0.06, function ()
		unit:MoveToPosition(destination)
	end)

	Timers:CreateTimer(4, function ()
		unit:MoveToNPC(caster)
	end)

	local time = 40
	local count = 0
	Timers:CreateTimer(4, function ()
		count = count + 0.5
		local distance = CalcDistanceBetweenEntityOBB(caster,unit)
		if count > time or distance < 100 then
			unit:ForceKill(false)
			return nil
		end
		return 0.5
	end)
end

function B17R_old_onIntervalThink( keys )
	local caster = keys.caster
	local shuriken = keys.target
	local ability = keys.ability
	local damage = ability:GetSpecialValueFor("B17R_old_damage")
	local radius = ability:GetSpecialValueFor("B17R_old_radius")
	StartSoundEvent("Hero_Antimage.PreAttack", shuriken)

	local units = FindUnitsInRadius( caster:GetTeamNumber(), shuriken:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for i,unit in ipairs(units) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if unit:IsMagicImmune() then
			damageTable.damage = damageTable.damage * 0.5
		end
		local fxIndex = ParticleManager:CreateParticle( "particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_POINT, unit )
		ParticleManager:SetParticleControl( fxIndex, 0, unit:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, unit:GetAbsOrigin() )
		ApplyDamage(damageTable)
		StartSoundEvent( "hero_bloodseeker.attack", unit)
	end
end

function B17T_old( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetSpecialValueFor("B17T_old_Duration")
	local outgoingDamage = ability:GetSpecialValueFor("B17T_old_outgoingDamage")
	local incomingDamage = ability:GetSpecialValueFor("B17T_old_incomingDamage")

	local people = ability:GetSpecialValueFor("B17T_old_people") + 1 -- people + self
	local eachAngle = 6.28 / people
	local illusion = {}
	local target_pos = {}
	local radius = 200
	local origin_go_index = RandomInt(1, people)
	local random_angle = RandomInt(-20, 20) * 0.1
	local origin_pos = caster:GetOrigin()

	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
			caster:RemoveModifierByName(v:GetName())
		end
	end

	local delayTime = 0.01
	local casterLevel = caster:GetLevel()
	if IsValidEntity(caster) and caster:IsAlive() then
		for i=1,people do
			Timers:CreateTimer( delayTime*(i-1), function()
				if (i ~= origin_go_index) then
					-- handle_UnitOwner needs to be nil, else it will crash the game.
					illusion[i] = CreateUnitByName(unit_name, origin, true, nil, nil, caster:GetTeamNumber())
					illusion[i]:SetPlayerID(caster:GetPlayerID())
					illusion[i]:SetControllableByPlayer(player, true)
					
					-- Level Up the unit to the casters level
					for j=1,casterLevel-1 do
						illusion[i]:HeroLevelUp(false)
					end

					-- Set the skill points to 0 and learn the skills of the caster
					illusion[i]:SetAbilityPoints(0)
					for abilitySlot=0,15 do
						local ability = caster:GetAbilityByIndex(abilitySlot)
						if ability ~= nil then 
							local abilityLevel = ability:GetLevel()
							local abilityName = ability:GetAbilityName()
							local illusionAbility = illusion[i]:FindAbilityByName(abilityName)
							if (illusionAbility ~= nil) then
								illusionAbility:SetLevel(abilityLevel)
							end
						end
					end

					-- Recreate the items of the caster
					for itemSlot=0,5 do
						local item = caster:GetItemInSlot(itemSlot)
						if item ~= nil then
							local itemName = item:GetName()
							local newItem = CreateItem(itemName, illusion[i], illusion[i])
							illusion[i]:AddItem(newItem)
						end
					end

					-- Set the unit as an illusion
					-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
					illusion[i]:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
					-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
					illusion[i]:MakeIllusion()

					illusion[i]:SetHealth(caster:GetHealth())
					--分身不能用法球
					--illusion[i].nobuorb1 = "illusion"
					--illusion[i]:SetRenderColor(255,0,255)
				end
			end)
		end
		Timers:CreateTimer( people*delayTime, function()
			if IsValidEntity(caster) and caster:IsAlive() then
				for i=1,people do
					target_pos[i] = Vector(math.sin(eachAngle*i+random_angle), math.cos(eachAngle*i+random_angle), 0) * radius
					if (i ~= origin_go_index) then
						if IsValidEntity(illusion[i]) then
							ProjectileManager:ProjectileDodge(illusion[i])
							ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, illusion[i])
							illusion[i]:SetAbsOrigin(origin_pos+target_pos[i])
							ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, illusion[i])
							illusion[i]:SetForwardVector(target_pos[i]:Normalized())
							illusion[i]:AddNewModifier(illusion[i],ability,"modifier_phased",{duration=0.1})
						end
					else
						ProjectileManager:ProjectileDodge(caster)
						ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
						caster:SetAbsOrigin(origin_pos+target_pos[i])
						ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
						caster:SetForwardVector(target_pos[i]:Normalized())
						caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
					end
				end
			end
			return nil
		end )
	end
end


function MirrorImage( event )
	local caster = event.caster
	local ability = event.ability
	local illusions_count = ability:GetLevelSpecialValueFor( "illusions_count", ability:GetLevel() - 1 )
	caster:AddNewModifier(caster, nil, "modifier_invulnerable", {duration=1})
	if illusions_count < 1 then
		return -- wtf
	end
	
	-- Stop any actions of the caster otherwise its obvious which unit is real
	caster:Stop()

	local center = caster:GetAbsOrigin()

	local pi = 3.14159
	local model_radius = ability:GetLevelSpecialValueFor("model_radius",ability:GetLevel()-1)
	local total = illusions_count+1
	local delta_theta = pi*2/total
	local spawn_radius = model_radius/math.sin(delta_theta*0.5)
	local start_theta = RandomFloat(0,2*pi)
	local real_index = RandomInt(0,illusions_count)
	local create_delay = ability:GetLevelSpecialValueFor("create_delay",ability:GetLevel()-1)
	-- Spawn illusions
	for i=0, illusions_count do
		local dx = spawn_radius * math.cos(start_theta+delta_theta*i)
		local dy = spawn_radius * math.sin(start_theta+delta_theta*i)
		-- 慢慢產生
		Timers:CreateTimer(i*create_delay, function()
			local spawn_point = center + Vector(dx,dy,0)
			if i == real_index then
				-- At first, move the main hero to one of the random spawn positions.
				FindClearSpaceForUnit(caster,spawn_point,true)
			else
				CreateMirror(caster,ability,spawn_point)
			end
		end)
	end
end

function CreateMirror( caster, ability, spawn_point )
	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(caster:GetUnitName(), spawn_point, true, caster, nil, caster:GetTeamNumber())

	local forword = caster:GetForwardVector()
	local player_id = caster:GetPlayerID()

	illusion:SetForwardVector(forword)
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)
		
	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)

	-- 清空鏡像的技能
	for abilitySlot=0,15 do
		local ability = illusion:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			if illusionAbility ~= nil then
				illusion:RemoveAbility(abilityName)
			end
		end
	end

	-- 安裝技能至鏡像
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusion:AddAbility(abilityName):SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	local level = ability:GetLevel()-1
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", level )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", level )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", level )
	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and IsValidEntity(v:GetAbility()) then
			if (not v:GetAbility():IsItem()) then
				v:GetAbility():ApplyDataDrivenModifier(illusion,illusion,v:GetName(),{duration=v:GetDuration()})
			end
		end
	end
	-- Set the illusion hp to be the same as the caster
	illusion:SetHealth(caster:GetHealth())
	illusion:SetMana(caster:GetMana())
end