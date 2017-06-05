
function A05D_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		if ability then
			local caster =ability:GetCaster()
			local A05D = caster:FindAbilityByName("A05D")
			if damage > caster:GetHealth() and not caster:IsIllusion() and A05D:IsCooldownReady() then
				caster:StartGestureWithPlaybackRate(ACT_DOTA_DIE,1)
				caster:SetHealth(caster:GetMaxHealth())
				caster:SetMana(caster:GetMaxMana())
				local am = caster:FindAllModifiers()
				for _,v in pairs(am) do
					if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
						if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
							caster:RemoveModifierByName(v:GetName())
						end
					end
				end
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_A05D2",{duration = 2})
				local cd = ability:GetSpecialValueFor("cd")
				A05D:StartCooldown(cd)
			end
		end
	end
end

function A05W_RunScript( keys )
	local caster = keys.caster
	local ability = keys.ability

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
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
end

function A05W_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )

	if (not(target:IsBuilding())) then
		if IsValidEntity(target) then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = ability:GetLevel()*0.1})
		end
	end
	--動作
	local rate = caster:GetAttackSpeed()
	--print(tostring(rate))
	--播放動畫
    --caster:StartGesture( ACT_SLAM_TRIPMINE_ATTACH )
	if rate < 1 then
	    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
	else
	    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
	end
end

function A05R_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		if ability then
			local caster = ability:GetCaster()
			if caster.A05R == nil then caster.A05R = 0 end
			caster.A05R = caster.A05R + damage
			if caster.A05R > 250 then
				caster.A05R = 0
				ability:SetActivated(true)
			end
		end
	end
end

function A05R_OnUpgrade( keys )
	local caster = keys.caster
	local ability = keys.ability
	if ability:GetLevel() == 1 then
		Timers:CreateTimer(1, function() 
			if IsValidEntity(caster) and not caster:IsIllusion() and caster:IsAlive() then
				if not caster:HasModifier("modifier_A05R") then
					ability:ApplyDataDrivenModifier(caster,caster,"modifier_A05R",nil)
				end
			end
		return 1
		end)
	end
end

function A05R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability

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
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = 1})
	end

	local ifx = ParticleManager:CreateParticle( "particles/a05/a05r.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	caster:EmitSound( "Hero_Nevermore.ROS_Flames")
	ability:SetActivated(false)
end

function A05T_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local duration = ability:GetSpecialValueFor("duration")
	caster.A05T = true
	target.A05T_target = true
	Timers:CreateTimer(duration, function() 
		caster.A05T = nil
		target.A05T_target = nil
		end)
end

function A05T_OnDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	target.A05T_target = nil
end

function A05R_old_OnAttackLanded( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = ability:GetSpecialValueFor("dmg")
	if not target:IsBuilding() then
		local rnd = RandomInt(1,100)
		if caster.A05R == nil then
			caster.A05R = 0
		end
		caster.A05R = caster.A05R + 1
		if rnd <= 25 or caster.A05R > 4 then
			caster.A05R = 0
			caster.A05R_go = 1
			local rate = caster:GetAttackSpeed()+0.1
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_C03R_nomiss",{duration=rate})
		end
		if caster.A05R_go == 1 then
			caster.A05R_go = 0
			caster:EmitSound("ITEM_D09.sound")
			local ifx = ParticleManager:CreateParticle("particles/a07t2/a07t2.vpcf",PATTACH_ABSORIGIN_FOLLOW,target)
			ParticleManager:SetParticleControl(ifx,0,target:GetAbsOrigin())
			
			Timers:CreateTimer(0.3,function()
				ParticleManager:DestroyParticle(ifx, true)
			end)
			ability:ApplyDataDrivenModifier( caster, target, "modifier_stunned", {duration=0.35} )
			if not target:IsMagicImmune() then
				AMHC:Damage(caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			end
		end
	end
end

function A05E_old_OnAttackStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local crit_chance = ability:GetSpecialValueFor("crit_chance")
	if caster.A05Ecount == nil then caster.A05Ecount = 0 end
	caster.A05Ecount = caster.A05Ecount + 1
	if RandomInt(1,100)<=crit_chance or caster.A05Ecount >= 5 then
		caster.A05Ecount = 0
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_A05E_old_critical_strike",nil)
	end
end


function A05T_old_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		if ability then
			local caster =ability:GetCaster()
			local A05T_old = caster:FindAbilityByName("A05T_old")
			if damage > caster:GetHealth() and not caster:IsIllusion() and A05T_old:IsCooldownReady() then
				caster:SetHealth(caster:GetMaxHealth())
				caster:SetMana(caster:GetMaxMana())
				local am = caster:FindAllModifiers()
				for _,v in pairs(am) do
					if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
						if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
							caster:RemoveModifierByName(v:GetName())
						end
					end
				end
				ability:ApplyDataDrivenModifier(caster,caster,"modifier_A05T_old2",{duration = 0.5})
				local cd = ability:GetSpecialValueFor("cd")
				A05T_old:StartCooldown(cd)
			end
		end
	end
end