-- 百第三太夫 by Nian Chen
-- 2017.3.20

LinkLuaModifier("modifier_B13D", "heroes/modifier_B13D.lua", LUA_MODIFIER_MOTION_NONE)


--D 忍法．遁地術
function B13D( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_B13D_underground") == false then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_B13D_underground", {} )
		caster:AddNewModifier(caster, ability, "modifier_B13D", nil )
		keys.caster:FindAbilityByName("B13B"):SetActivated(true)
	else
		caster:RemoveModifierByName("modifier_B13D_underground")
		caster:RemoveModifierByName("modifier_B13D")
		keys.caster:FindAbilityByName("B13B"):SetActivated(false)
	end
end

function B13D_remove( keys )
	keys.caster:FindAbilityByName("B13B"):SetActivated(false)
end
function B13D_OnDeath( keys )
	local caster = keys.caster
	local ability = keys.ability
	keys.caster:FindAbilityByName("B13B"):SetActivated(false)
	caster:RemoveModifierByName("modifier_B13D_underground")
	caster:RemoveModifierByName("modifier_B13D")
end
function B13D_onCreated( keys )
	keys.ability:SetLevel(1)
end

--B 縮地
function B13B( keys )
	FindClearSpaceForUnit( keys.caster, keys.ability:GetCursorPosition() , true)
	keys.caster:AddNewModifier(keys.caster,nil,"modifier_phased",{duration=0.1})
end

function B13B_onCreated( keys )
	keys.ability:SetLevel(1)
	keys.ability:SetActivated(false)
end


--R 忍法．血化裝
function B13R( keys )
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability

	if not target:IsBuilding() then
		local dmgt = {
					victim = target,
					attacker = attacker,
					ability = ability,
					damage = ability:GetSpecialValueFor("B13R_damageBonus") * attacker:GetHealth() ,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if target:IsMagicImmune() then
			dmgt.damage = dmgt.damage * 0.5
		end
		ApplyDamage(dmgt)
	end
end

function B13R_heal( keys )
	if not keys.unit:IsBuilding() then
		keys.attacker:Heal( keys.unit:GetMaxHealth() * keys.ability:GetSpecialValueFor("B13R_heal") , keys.attacker)
	end
end

--T 忍法密傳．暴風
function B13T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local tickPerSec = 10

	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=5.5} )
	dummy:SetOwner(caster)
	dummy:AddAbility( "majia_vison"):SetLevel(1)

	ability:ApplyDataDrivenModifier( caster, dummy, "modifier_B13T_veryslowAura", nil)

	local radius = ability:GetSpecialValueFor("B13T_radius")
	local time = 0.1 + 5.5
	local count = 0
--
	Timers:CreateTimer(0,function()
		count = count + 1 / tickPerSec
		if count > time then
			return nil
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
		for _,unit in ipairs(units) do
			if unit:IsBuilding() then
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = ability:GetSpecialValueFor("B13T_damage") / tickPerSec * 0.3,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			else
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = ability:GetSpecialValueFor("B13T_damage") / tickPerSec,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		end	
		return 1 / tickPerSec
	end)
end

---------THIS BLOCK NEVER RUN---------------
function B13T_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
		nil,  500 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for _,enemy in pairs(group) do
		if enemy:IsMagicImmune() then
			ability:ApplyDataDrivenModifier(caster,enemy,"modifier_B13T_veryslow",{duration = 1})
		end
	end
end
--------------------------------------------
--old背刺
function B13D_old( keys )
	local attacker = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local targetAngle = VectorToAngles(target:GetForwardVector()) 
	local attackerAngle = VectorToAngles(attacker:GetForwardVector())
	local angle = targetAngle[2]-attackerAngle[2]

	if angle < 0 then
		angle = angle * -1
	end

	if angle < 90 or angle > 270 then
		if not target:IsBuilding() then
			local dmgt = {
						victim = target,
						attacker = attacker,
						ability = ability,
						damage = ability:GetSpecialValueFor("B13D_old_damage") ,
						damage_type = ability:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE,
			}
			ApplyDamage(dmgt)
		end
	end
end
--old遁地
function B13W_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_B13W_old_underground") == false then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_B13W_old_underground", {} )
		caster:AddNewModifier(caster, ability, "modifier_B13D", nil )
	else
		caster:RemoveModifierByName("modifier_B13W_old_underground")
		caster:RemoveModifierByName("modifier_B13D")
	end
end
--old地雷 ref A26D
function B13R_old( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local ability = keys.ability

	local active_delay = 0
	local mine = CreateUnitByName("B13_MINE_hero", center, false, caster, caster, caster:GetTeamNumber())
	mine:RemoveModifierByName("modifier_invulnerable")
	mine.caster = caster
	mine:AddAbility("for_no_collision"):SetLevel(1)
	mine:AddAbility("for_magic_immune"):SetLevel(1)
	mine:SetOwner(caster)
	mine:SetBaseMaxHealth( ability:GetSpecialValueFor("B13R_old_hp") )
	mine:SetHealth( mine:GetMaxHealth() )
	ability:ApplyDataDrivenModifier(caster,mine,"modifier_B13R_old_rooted",{})
	Timers:CreateTimer( active_delay, function()
		if IsValidEntity(mine) and mine:IsAlive() then
			ability:ApplyDataDrivenModifier( mine, mine,"modifier_B13R_old_detectorAura", nil )
		end
	end)
end

--old地雷爆炸 ref A26D
function B13R_old_explosion( keys )
	local caster = keys.caster -- mine
	local ccaster = caster.caster -- caster
	local ability = keys.ability
	local radius_explosion = ability:GetSpecialValueFor("B13R_old_radius_explosion")

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		radius_explosion,				-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	local attacker = ability:GetCaster()
	for _,unit in ipairs(units) do
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetSpecialValueFor("B13R_old_damage"),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE
		}
		if unit:IsHero() then
			damageTable.damage = damageTable.damage
		end
		if ccaster and ccaster:IsAlive() then
			damageTable.attacker = ccaster
		end
		if not unit:IsMagicImmune() then
			ApplyDamage(damageTable)
		end
	end

	local center = caster:GetAbsOrigin()
	local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(ifx,0,center)
	ParticleManager:SetParticleControl(ifx,1,Vector(0,0,radius_explosion))
	ParticleManager:SetParticleControl(ifx,2,Vector(1,0,0))
	ParticleManager:ReleaseParticleIndex(ifx)

	caster:RemoveModifierByName("modifier_B13R_old_detectorAura")
	for _,unit in ipairs(units) do
		unit:RemoveModifierByName("modifier_B13R_old_explosion")
	end
	caster:ForceKill(true)
end

--T_old 忍法密傳．暴風
function B13T_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local tickPerSec = 10

	local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
	dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=7} )
	dummy:SetOwner(caster)
	dummy:AddAbility( "majia_vison"):SetLevel(1)

	ability:ApplyDataDrivenModifier( caster, dummy, "modifier_B13T_old_veryslowAura", nil)

	local radius = ability:GetSpecialValueFor("B13T_old_radius")
	local time = 0.1 + 7
	local count = 0
--
	Timers:CreateTimer(0,function()
		count = count + 1 / tickPerSec
		if count > time then
			return nil
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
		for _,unit in ipairs(units) do
			if unit:IsBuilding() then
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = ability:GetSpecialValueFor("B13T_old_damage") / tickPerSec * 0.5,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			else
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = ability:GetSpecialValueFor("B13T_old_damage") / tickPerSec,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		end	
		return 1 / tickPerSec
	end)
end

function B13E_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster.can_dmg = 1
	caster.B13E_old_target = target
	target:EmitSound("SleepBirth1")
	ability:ApplyDataDrivenModifier(caster,target,"modifier_B13E_old_sleep",{duration = ability:GetSpecialValueFor("B13E_old_duration")})
	AMHC:Damage(caster,target, 1,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	Timers:CreateTimer(0.1, function()
		caster.can_dmg = nil
		if target:HasModifier("modifier_B13E_old_sleep") then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B13E_old_invulnerable",{duration = 1})
		else
			--caster.B13E_old_target:RemoveModifierByName("modifier_B13E_old_sleep")
		end
    end)
end

function B13E_old_OnTakeDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster.can_dmg == nil then
		ability:ApplyDataDrivenModifier(caster,caster.B13E_old_target,"modifier_stunned",{duration=0.1})
		caster.B13E_old_target:RemoveModifierByName("modifier_B13E_old_sleep")
	end
end


function B13E_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster.can_dmg = 1
	caster.B13E_old_target = target
	target:EmitSound("SleepBirth1")
	ability:ApplyDataDrivenModifier(caster,target,"modifier_B13E_sleep", nil)
	AMHC:Damage(caster,target, 1,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	Timers:CreateTimer(0.1, function()
		caster.can_dmg = nil
    end)
end

function B13E_OnTakeDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster.can_dmg == nil then
		ability:ApplyDataDrivenModifier(caster,caster.B13E_old_target,"modifier_stunned",{duration=0.1})
		caster.B13E_old_target:RemoveModifierByName("modifier_B13E_sleep")
	end
end

function B13T_old_upgrade( keys )
	keys.caster:FindAbilityByName("B13D_old"):SetLevel(keys.ability:GetLevel()+1)
end