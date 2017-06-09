function C25D_Action1( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level  = keys.ability:GetLevel()
	
	--move
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())
	if not target:IsMagicImmune() then
		local dmg = keys.ability:GetLevelSpecialValueFor("C25D_Damage", keys.ability:GetLevel() - 1 )
		AMHC:Damage( caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end

function C25W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local particle = ParticleManager:CreateParticle("particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray_sparks.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
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


function C25E( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local point   = caster:GetAbsOrigin()
	local point2  = target:GetAbsOrigin()
	local vec = nobu_atan2( point2,point )
	local distance = 35

	local temp_point = nobu_move( point, point2 , distance )

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_wildaxe.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0,point)
	ParticleManager:SetParticleControl(particle,2,Vector(0,0,10))

	Timers:CreateTimer(function()
		point2  = target:GetAbsOrigin()
        temp_point = nobu_move( temp_point, point2 , distance )

        --temp_point = nobu_move_ver2( temp_point , distance ,RandomFloat(0,-30))

        --print(nobu_radtodeg(math.atan2(point2.y-point.y,point2.x-point.x)))

		if nobu_distance( temp_point,point2 ) < 50  or not target:IsAlive()  then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_C25E",nil)
			ParticleManager:DestroyParticle(particle,false)

			--print("Stop")
			return nil
		else
			ParticleManager:SetParticleControl(particle,0,temp_point)
			return 0.01
		end
	end)
end


function C25T_OnSpellStart( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
	ability:ApplyDataDrivenModifier(caster,target,"modifier_C25T_bleeding",{})
	--ability:ApplyDataDrivenModifier(caster,target,"modifier_C25T_slience",{})
	local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )		
	AddFOWViewer(caster:GetTeamNumber(),target:GetAbsOrigin(),600,3.0,false)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
end


function modifier_C25T_bleeding_OnIntervalThink( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local abilityDamage = ability:GetSpecialValueFor("damage")
	local abilityDamageType = ability:GetAbilityDamageType()
	local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )	
	StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )	
	if(not target:IsMagicImmune()) then
		if IsValidEntity(caster) and caster:IsAlive() then
			AMHC:Damage( caster,target,abilityDamage,ability:GetAbilityDamageType() )
		else
			AMHC:Damage( caster.donkey,target,abilityDamage,ability:GetAbilityDamageType() )
		end
		--ExecuteOrderFromTable({UnitIndex = target:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP, Queue = false}) 
		target:Stop()
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = ability:GetSpecialValueFor("stun_time")})
	end
	AddFOWViewer(caster:GetTeamNumber(),target:GetAbsOrigin(),600,3.0,false)
	
end