-- 菊姬

function B11D_OnKill( keys )
	if keys.caster:IsAlive() and keys.unit:IsHero() and not keys.caster:IsSilenced() then
		keys.caster:ModifyAgility( keys.bonus_agi )
		keys.caster:CalculateStatBonus()
	end
end


function B11W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability

	for i=1,5 do
		local particle = ParticleManager:CreateParticle("particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray_sparks.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	end

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果




	for _,unit in ipairs(units) do

		--基礎傷害
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})

		--真實傷害
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = caster:GetAgility()*keys.A11W_agiMul,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})



		local dir = (caster:GetAbsOrigin()-unit:GetAbsOrigin()):Normalized()
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_base_attack_explosion_b.vpcf",PATTACH_POINT,unit)
		ParticleManager:SetParticleControlEnt(ifx,3,unit,PATTACH_POINT,"attach_hitloc",unit:GetAbsOrigin()+Vector(0,0,200),true)
		ParticleManager:SetParticleControlForward(ifx,3,dir)
		ParticleManager:ReleaseParticleIndex(ifx)
	end
end




--function B11E_OnSpellStart( keys )

--	ability=keys.ability
--	ability.modifier = ability:ApplyDataDrivenModifier(caster,caster,"modifier_B11E_heal",nil)
--	ability.modifier = ability:ApplyDataDrivenModifier(caster,caster,"modifier_B11E_agiBonus",nil)


--end




function B11E_OnChannelFinish( keys )
	caster=keys.ability:GetCaster()
	if caster:FindModifierByName("modifier_B11E_heal") then 
		caster:RemoveModifierByName("modifier_B11E_heal")
	end
end

function modifier_B11E_heal_OnCreated( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- 調息特效
	local particle = ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_shell.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	target.B11E_particle = particle

end

function modifier_B11E_heal_OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster:IsChanneling() then ability:EndChannel(true)	end
	-- 刪除調息特效
	ParticleManager:DestroyParticle(target.B11E_particle,false)
end


B11R_trigger_counter=0
B11R_trigger_in_CD=false

function modifier_B11R_trigger_OnTakeDamage( keys )
    caster=keys.caster
	ability=keys.ability
	attacker=keys.attacker
	if not B11R_trigger_in_CD then

		ability.modifier = ability:ApplyDataDrivenModifier(caster,attacker,"modifier_B11R_mark",nil)

		B11R_trigger_counter=B11R_trigger_counter+1

		--觸發五次進CD
		if B11R_trigger_counter==5 then

			--鎖住觸發 重置次數
			B11R_trigger_in_CD=true
			B11R_trigger_counter=0

			--時間到了恢復觸發
			GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("B11R_trigger_timer"), 
				function( )
					B11R_trigger_in_CD=false
					return nil
			end, ability:GetSpecialValueFor("B11R_buff_CD"))

		end

	end
	--ability.modifier = ability:ApplyDataDrivenModifier(caster,caster,"modifier_B11E_heal",nil)
	--ability.modifier = ability:ApplyDataDrivenModifier(caster,caster,"modifier_B11E_agiBonus",nil)
end



function modifier_B11R_mark_on_think( keys )

	local caster = keys.caster
	local target = keys.target
	-- 持續提供視野
	AddFOWViewer(caster:GetTeamNumber(),target:GetAbsOrigin(),600,3.0,false)
end

function modifier_B11R_mark_OnTakeDamage( keys )


    --local targets = keys.target_entities[1]
	local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability

	if target:FindModifierByName("modifier_B11R_mark") then 
		target:RemoveModifierByName("modifier_B11R_mark")
	end
	--計算傷害
	Total_damage = caster:GetAgility()*keys.B11R_mark_Damage


	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = Total_damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	})

	--回血2%


	local healpercentage=ability:GetSpecialValueFor("B11R_buff_Heal")/100
	caster:Heal(caster:GetMaxHealth()*healpercentage,caster)

	local dir = (caster:GetAbsOrigin()-target:GetAbsOrigin()):Normalized()
	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_base_attack_explosion_b.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControlEnt(ifx,3,target,PATTACH_POINT,"attach_hitloc",target:GetAbsOrigin()+Vector(0,0,200),true)
	ParticleManager:SetParticleControlForward(ifx,3,dir)
	ParticleManager:ReleaseParticleIndex(ifx)
end

--目前使用次數
B11F_counter=0

function B11T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local B11F_ability = caster:FindAbilityByName("B11F")

	B11F_ability:SetLevel(keys.ability:GetLevel())
	B11F_ability:SetActivated(true)
	--print(B11F_ability)

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("B11T_duration"), 
		function( )
			B11F_ability:SetActivated(false)
			B11F_counter=0
			if caster:FindModifierByName("modifier_B11F_Crit") then 
				caster:RemoveModifierByName("modifier_B11F_Crit")
			end
			return nil
	end, ability:GetSpecialValueFor("B11T_duration"))
end


function B11T_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local rnd = RandomInt(1,100)
	caster:RemoveModifierByName("modifier_B11T_Crit2")
	if caster.B11T_count == nil then
		caster.B11T_count = 0
	end
	caster.B11T_count = caster.B11T_count + 1
	if 15 >= rnd or caster.B11T_count > 6 then
		caster.B11T_count = 0
		local rate = caster:GetAttackSpeed()+0.1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_B11T_Crit2",{duration = rate})
		if rate < 1 then
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
		else
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end
	end
end


function B11F_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level  = keys.ability:GetLevel()
	
	--瞬移
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())

	--暈眩
	target:AddNewModifier(caster,ability,"modifier_stunned",{duration=ability:GetSpecialValueFor("B11F_Stun_Time")})

	--傷害
	local dmg = caster:GetAgility()*ability:GetSpecialValueFor("B11F_Damage")

	AMHC:Damage( caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	local order = {UnitIndex = caster:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()}

	ExecuteOrderFromTable(order)
	--計算刺數
	B11F_counter=B11F_counter+1

	--次數到了關掉技能 爆擊BUFF
	if B11F_counter >= ability:GetSpecialValueFor("B11F_useable_times") then
		ability:SetActivated(false)
		B11F_counter=0
		if caster:FindModifierByName("modifier_B11F_Crit") then 
			caster:RemoveModifierByName("modifier_B11F_Crit")
		end
	end
end


function B11W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local particle = ParticleManager:CreateParticle("particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray_sparks.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do

		--基礎傷害
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		local dir = (caster:GetAbsOrigin()-unit:GetAbsOrigin()):Normalized()
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_base_attack_explosion_b.vpcf",PATTACH_POINT,unit)
		ParticleManager:SetParticleControlEnt(ifx,3,unit,PATTACH_POINT,"attach_hitloc",unit:GetAbsOrigin()+Vector(0,0,200),true)
		ParticleManager:SetParticleControlForward(ifx,3,dir)
		ParticleManager:ReleaseParticleIndex(ifx)
	end
end


function B11E_old_OnSpellStart(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local ability = keys.ability
	--local particle = ParticleManager:CreateParticle("particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray_sparks.vpcf", PATTACH_ABSORIGIN, caster)
	--ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		point,							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		keys.radius,					-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if not unit:IsMagicImmune() then
			local dir = (caster:GetAbsOrigin()-unit:GetAbsOrigin()):Normalized()
			local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_base_attack_explosion_b.vpcf",PATTACH_POINT,unit)
			ParticleManager:SetParticleControlEnt(ifx,3,unit,PATTACH_POINT,"attach_hitloc",unit:GetAbsOrigin()+Vector(0,0,200),true)
			ParticleManager:SetParticleControlForward(ifx,3,dir)
			ParticleManager:ReleaseParticleIndex(ifx)
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_B11E_old",nil)
		end
	end
end



function B11F_old_OnSpellStart( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "B11R_old_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "B11R_old_attack", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )
	local people = ability:GetLevel() + 1
	local eachAngle = 6.28 / people
	local illusion = {}
	local target_pos = {}
	local radius = 700
	local people = 1
	local origin_pos = caster:GetOrigin()
	caster:AddNewModifier(caster, nil, "modifier_invulnerable", {duration=0.5})
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
			caster:RemoveModifierByName(v:GetName())
		end
	end

	if IsValidEntity(caster.B11F) and caster.B11F:IsAlive() then
		caster.B11F:ForceKill(true)
	end

	for i=1,people do
			-- handle_UnitOwner needs to be nil, else it will crash the game.
			illusion[i] = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
			illusion[i]:SetOwner(caster)
			illusion[i]:SetControllableByPlayer(player, true)
			
			-- Level Up the unit to the casters level
			local casterLevel = caster:GetLevel()
			for j=1,casterLevel-1 do
				illusion[i]:HeroLevelUp(false)
			end

			-- Set the skill points to 0 and learn the skills of the caster
			illusion[i]:SetAbilityPoints(0)
			for abilitySlot=0,15 do
				local ability = illusion[i]:GetAbilityByIndex(abilitySlot)
				if ability ~= nil then 
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					local illusionAbility = illusion[i]:FindAbilityByName(abilityName)
					if (illusionAbility ~= nil) then
						illusion[i]:RemoveAbility(abilityName)
					end
				end
			end
			for abilitySlot=0,15 do
				local ability = caster:GetAbilityByIndex(abilitySlot)
				if ability ~= nil then 
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					illusion[i]:AddAbility(abilityName):SetLevel(abilityLevel)
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
			--illusion[i]:SetRenderColor(255,0,255)

	end
	caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	for i=1,people do
		illusion[i]:AddNewModifier(illusion[i],ability,"modifier_phased",{duration=0.1})
		if (caster:HasModifier("modifier_B11F_old")) then
			ability:ApplyDataDrivenModifier(illusion[i],illusion[i],"modifier_B11F_old",{duration = 200})
			break
		end
	end
	caster.B11F = illusion[1]
end


function modifier_B11T_old_OnAttackStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local crit_chance = ability:GetSpecialValueFor("crit_chance")
	local rnd = RandomInt(1,100)
	caster:RemoveModifierByName("modifier_B11T_old_critical_strike")
	if caster.B11R_count == nil then
		caster.B11R_count = 0
	end
	caster.B11R_count = caster.B11R_count + 1
	if crit_chance >= rnd or caster.B11R_count > (100/crit_chance) then
		caster.B11R_count = 0
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_B11T_old_critical_strike",{})
		ApplyDamage({
			victim = target,
			attacker = caster,
			ability = ability,
			damage = ability:GetSpecialValueFor("pure_damage"),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		local rate = caster:GetAttackSpeed()
		if rate < 1 then
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
		else
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end
	end
end


function B11R_old_OnUpgrade( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("B11F_old")
	local level = keys.ability:GetLevel()
	
	if ability ~= nil then
		ability:SetLevel(level+1)
	end
end
