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
	local multiple = 1

	if target:HasModifier("modifier_B13W_debuff") then 
		multiple = 2
	end
	if not target:IsBuilding() then
		local dmgt = {
					victim = target,
					attacker = attacker,
					ability = ability,
					damage = ability:GetSpecialValueFor("B13R_damageBonus") * attacker:GetMaxHealth() * multiple,
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
	keys.attacker:Heal( keys.unit:GetMaxHealth() * keys.ability:GetSpecialValueFor("B13R_heal") , keys.attacker)
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

	local radius = 500
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
