-- 稻葉一鐵

function A18W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local damage = ability:GetAbilityDamage()
	local radius = ability:GetSpecialValueFor("radius")
	local regen = ability:GetSpecialValueFor("regen")

	local units = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius, 
		ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		local ifx = ParticleManager:CreateParticle("particles/a18/a18w.vpcf",PATTACH_POINT_FOLLOW,unit)
			ParticleManager:SetParticleControlEnt(ifx,0,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit:GetAbsOrigin(),true)
			ParticleManager:SetParticleControlEnt(ifx,1,caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster:GetAbsOrigin(),true)
			ParticleManager:ReleaseParticleIndex(ifx)
		local damageTable = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		ApplyDamage(damageTable)
		caster:Heal(regen,ability)
	end
end

function DumpTable( tTable )
	local inspect = require('inspect')
	local iDepth = 2
 	print(inspect(tTable,
 		{depth=iDepth} 
 	))
end

function A18R_OnAttackStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local unit = keys.attacker
	local crit_chance = ability:GetSpecialValueFor("crit_chance")
	unit:RemoveModifierByName("modifier_A18R_critical_strike")
	if unit.C21Rcount == nil then unit.C21Rcount = 0 end
	unit.C21Rcount = unit.C21Rcount + 1
	if RandomInt(1,100)<=crit_chance or unit.C21Rcount > (100/crit_chance) then
		unit.C21Rcount = 0
		local rate = unit:GetAttackSpeed()+0.1
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_A18R_critical_strike",{duration=rate})
		if rate < 1 then
		    unit:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
		else
		    unit:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end
	end
end


function A18T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local Stun_Time = ability:GetSpecialValueFor("Stun_Time")
	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = Stun_Time})
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
	local ifx = ParticleManager:CreateParticle("particles/a18/a18t.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(ifx,0,caster:GetAbsOrigin()) -- 起點
	ParticleManager:SetParticleControl(ifx,1,caster:GetAbsOrigin()-caster:GetForwardVector()*200) -- 終點
	ParticleManager:SetParticleControl(ifx,3,Vector(0,0.5,0)) -- 延遲
	ParticleManager:ReleaseParticleIndex(ifx)
end

function A18T_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local Stun_Time = ability:GetSpecialValueFor("Stun_Time")
	local dmg = ability:GetSpecialValueFor("dmg")
	-- 處理搜尋結果
	AMHC:Damage( caster,caster,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_stunned",{duration = Stun_Time})
	ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = Stun_Time})
	ApplyDamage({
		victim = target,
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
	})
	local ifx = ParticleManager:CreateParticle("particles/a18/a18t.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(ifx,0,target:GetAbsOrigin()) -- 起點
	ParticleManager:SetParticleControl(ifx,1,caster:GetAbsOrigin()) -- 終點
	ParticleManager:SetParticleControl(ifx,3,Vector(0,0.5,0)) -- 延遲
	ParticleManager:ReleaseParticleIndex(ifx)
end

function A18W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A18W_old",{duration=6})
	local handle = caster:FindModifierByName("modifier_A18W_old")
	if handle then
		if caster:GetHealthPercent() <= 20 then
			handle:SetStackCount(3)
		elseif caster:GetHealthPercent() <= 50 then
			handle:SetStackCount(2)
		end
	end
end
