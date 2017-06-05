-- 德川家康

function A01D_OnTakeDamage( keys )
	--[[
	O在這邊放計時器是因為節省particle的使用
	O魔免的時候，不能在KV裡面傷害單位
		要在lua裡面
	]]
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = keys.dmg * 0.1
	caster:SetMana(caster:GetMana() + dmg*2)
	if dmg < caster:GetHealth() then
		caster:Heal(dmg,caster)
	end
end

function A01E(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()
	local level = ability:GetLevel() - 1

	local Time = ability:GetLevelSpecialValueFor("time",level)

	for i=0,3 do
		local particle2 = ParticleManager:CreateParticle("particles/b02r3/b02r3.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle2,0, point2+Vector(0,0,i*40))
		ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
		ParticleManager:SetParticleControl(particle2,3, point2)	
		Timers:CreateTimer(Time,function ()
			ParticleManager:DestroyParticle(particle2,true)
		end	)
	end
	local point_tem = point
	local dummy = CreateUnitByName("npc_dummy_unit_Ver2",point_tem ,false,caster,caster,caster:GetTeam())	
	dummy:FindAbilityByName("majia"):SetLevel(1)		
	
	dummy.A01E_D = 0
	local tem_P =Vector( point2.x + 420*math.cos(dummy.A01E_D*3.14159/180.0) ,point2.y + 420*math.sin(dummy.A01E_D*3.14159/180.0),point2.z)
	dummy:SetAbsOrigin(tem_P)	
	ability:ApplyDataDrivenModifier(dummy,target,"modifier_A01E_2",nil)--一定要放MOVE後面
	--【Timer】
	local num = 0
	Timers:CreateTimer(3,function()
		if IsValidEntity(dummy) then
			dummy:ForceKill(true)
		end
	end)	
	--【MODIFIER】
	ability:ApplyDataDrivenModifier(dummy,target,"modifier_A01E",nil)--綑綁 

	local sumt = 0
	Timers:CreateTimer(0.1, function()
		sumt = sumt + 0.1
		if sumt < Time then
			if (not target:HasModifier("modifier_A01E")) then
				local tt = Time-sumt
				ability:ApplyDataDrivenModifier(caster, target,"modifier_A01E",{duration=tt})
			end
			return 0.1
		end
		end)
end

function A01E_hit(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	if not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_A01E_3",nil)
	end
	local dmg = ability:GetLevelSpecialValueFor("dmg",level)
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
end

function A01E_MOVE(keys)
	--【Basic】
	local dummy = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	--local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--【MOVE】
	if dummy.A01E_D == nil then
		dummy.A01E_D = 0
	end
	dummy.A01E_D = dummy.A01E_D + 20
	local tem_P =Vector( point2.x + 420*math.cos(dummy.A01E_D*3.14159/180.0) ,point2.y + 420*math.sin(dummy.A01E_D*3.14159/180.0),point2.z)
	dummy:SetAbsOrigin(tem_P)
	--【PROJECTILE】
	local info = {
		Target = target,
		Source = dummy,
		Ability = ability,
		EffectName = "particles/a01/a01e.vpcf",
		bDodgeable = false,
		bProvidesVision = true,
		iMoveSpeed = 1000,
        iVisionRadius = 10,
        iVisionTeamNumber = dummy:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )	
	-- Play the sound on Bristleback.
	EmitSoundOn("Hero_BountyHunter.Shuriken.Impact", target)	
end


function A01R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius2")
	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		radius,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)
	caster:EmitSound("ITEM_D09.sound")
	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if IsValidEntity(unit) then
			local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN , caster)
			-- Raise 1000 if you increase the camera height above 1000
			ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(particle, 1, unit:GetAbsOrigin()+Vector(0,0,100))
			ParticleManager:SetParticleControl(particle, 2, unit:GetAbsOrigin()+Vector(0,0,100))
		end
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
end


function A01R_OnAttackLanded( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local dmg = ability:GetSpecialValueFor("dmg")
	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		radius,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)
	caster:EmitSound("ITEM_D09.sound")
	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if IsValidEntity(unit) then
			local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN , caster)
			-- Raise 1000 if you increase the camera height above 1000
			ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(particle, 1, unit:GetAbsOrigin()+Vector(0,0,100))
			ParticleManager:SetParticleControl(particle, 2, unit:GetAbsOrigin()+Vector(0,0,100))
		end
		local dt = {
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = dmg,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if unit:IsMagicImmune() then
			dt.damage = dmg * 0.5
		end
		ApplyDamage(dt)
	end
end


function A01R_old_OnAttackLanded( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local dmg = ability:GetSpecialValueFor("dmg")
	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil,
		radius,			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false)
	caster:EmitSound("ITEM_D09.sound")
	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if IsValidEntity(unit) then
			local particle = ParticleManager:CreateParticle("particles/b05e/b05e.vpcf", PATTACH_ABSORIGIN , caster)
			-- Raise 1000 if you increase the camera height above 1000
			ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(particle, 1, unit:GetAbsOrigin()+Vector(0,0,100))
			ParticleManager:SetParticleControl(particle, 2, unit:GetAbsOrigin()+Vector(0,0,100))
		end
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = dmg,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
	end
end

function A01E_old_OnProjectileHitUnit(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin()

	local Time = ability:GetSpecialValueFor("time")
	for i=0,3 do
		local particle2 = ParticleManager:CreateParticle("particles/b02r3/b02r3.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle2,0, point2+Vector(0,0,i*40))
		ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
		ParticleManager:SetParticleControl(particle2,3, point2)	
		Timers:CreateTimer(Time,function ()
			ParticleManager:DestroyParticle(particle2,true)
		end	)
	end

	ability:ApplyDataDrivenModifier(caster,target,"modifier_A01E_old",nil)--綑綁 

	local sumt = 0
	Timers:CreateTimer(0.1, function()
		sumt = sumt + 0.1
		if sumt < Time then
			if (not target:HasModifier("modifier_A01E_old")) then
				local tt = Time-sumt
				--print("tt "..tt)
				ability:ApplyDataDrivenModifier(caster, target,"modifier_A01E_old",{duration=tt})
			end
			return 0.1
		end
		end)
end

function A01E_old_OnSpellStart(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	--local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()

	--【PROJECTILE】
	local info = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = "particles/a01/a01e.vpcf",
		bDodgeable = false,
		bProvidesVision = true,
		iMoveSpeed = 1000,
        iVisionRadius = 10,
        iVisionTeamNumber = caster:GetTeamNumber(), -- Vision still belongs to the one that casted the ability
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )	
	-- Play the sound on Bristleback.
	EmitSoundOn("Hero_BountyHunter.Shuriken.Impact", target)	
end