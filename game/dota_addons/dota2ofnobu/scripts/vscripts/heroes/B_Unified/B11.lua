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

function modifier_B11E_OnIntervalThink( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local heal_hp = ability:GetSpecialValueFor("B11E_heal_hp")
	caster:Heal(heal_hp,caster)
end

function modifier_B11E_heal_OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if ability:IsChanneling() then ability:EndChannel(true)	end
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






function B11F_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level  = keys.ability:GetLevel()
	
	--瞬移
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())

	--暈眩
	if not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stun",{duration = ability:GetSpecialValueFor("B11F_Stun_Time")})
	end

	--傷害
	local dmg = caster:GetAgility()*ability:GetSpecialValueFor("B11F_Damage")

	AMHC:Damage( caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )


		
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

