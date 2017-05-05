-- 鐵碎牙．妖刀 11.2B

function Spell( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")

	local dummy = CreateUnitByName("npc_dummy_unit_new",point,false,caster,caster,caster:GetTeamNumber())
	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_the_great_sword_of_iron_fragmentor",{duration=duration})
	dummy:AddAbility("for_no_damage"):SetLevel(1)

	local ifx = ParticleManager:CreateParticle("particles/item/item_the_great_sword_of_iron_fragmentor/item_the_great_sword_of_iron_fragmentor.vpcf",PATTACH_ABSORIGIN,dummy)
	ParticleManager:SetParticleControl(ifx,3,point+Vector(0,0,50))
	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(ifx,false)
	end)
	EmitSoundOn("Item.Iron_Fragmentor.Tornado",dummy)
end

function DealDamage( keys )
	local caster = keys.caster
	local target = keys.target -- dummy
	local ability = keys.ability
	local aoe_radius = ability:GetSpecialValueFor("aoe_radius")

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		target:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		aoe_radius,						-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 傷害資訊
	local damage_table = {
		victim = nil, -- 之後再填
		attacker = caster,
		ability = ability,
		damage = ability:GetAbilityDamage(),
		damage_type = ability:GetAbilityDamageType(),
		--damage_flags = DOTA_DAMAGE_FLAG_NONE
	}

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		damage_table.victim = unit
		ApplyDamage(damage_table)
		local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf",PATTACH_POINT,unit)
		ParticleManager:ReleaseParticleIndex(ifx)

		local ifx = ParticleManager:CreateParticle("particles/item/item_the_great_sword_of_iron_fragmentor/item_the_great_sword_of_iron_fragmentor_hit.vpcf",PATTACH_POINT,unit)
		ParticleManager:SetParticleControlForward(ifx,0,RandomVector(1))
		ParticleManager:ReleaseParticleIndex(ifx)

		EmitSoundOn("Hero_Abaddon.Attack",unit)
	end
end

function End( keys )
	local target = keys.target
	target:ForceKill(false)
end