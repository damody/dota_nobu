function A36W_first_hit( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	
	--【DMG】
	local dmg = ability:GetLevelSpecialValueFor("bonus_damage",level)
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )	
end

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
	mine:AddNewModifier(caster,ability,"modifier_invisible",{})
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
		nil, 							-- 好像是優化用的參數不懂怎麼用
		radius_explosion,				-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

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


function A36R_invulnerable( keys )
	local caster = keys.caster
	local ability = keys.ability
	local hp_hold=ability:GetSpecialValueFor("hp_hold")	
	if 		caster:GetHealth()	<=	caster:GetMaxHealth()*hp_hold		then
		caster:SetHealth(caster:GetMaxHealth()*hp_hold)
	end
end




function A36T_OnAttackLanded( keys )
	local target = keys.target
	if not target:IsBuilding() then
		local ability = keys.ability
		local caster = keys.caster
		local damage = ability:GetSpecialValueFor("A36T_damage")
		local stunDuration = ability:GetSpecialValueFor("A36T_stunDuration")
		local fxIndex = ParticleManager:CreateParticle( "particles/a17/a17tecon/items/sniper/sniper_charlie/sniper_assassinate_impact_blood_charlie.vpcf", PATTACH_POINT, target )
		ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType()
		}
		target:AddNewModifier( caster, ability, "modifier_stunned" , { duration = stunDuration } )
		--if unit:IsMagicImmune() then
			---		ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned", {duration=stun_time2})
			--	else
				--	ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned", {duration=stun_time})
			--	end
		ApplyDamage(damageTable)
	end
end

