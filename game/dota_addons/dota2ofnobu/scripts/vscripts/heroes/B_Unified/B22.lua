

function B22D_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local radius = ability:GetSpecialValueFor("radius")
	local spike = ParticleManager:CreateParticle("particles/b22/b22dbirda.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(spike, 0, target:GetAbsOrigin() + Vector(0,0,400))
	local dummy = CreateUnitByName("npc_dummy",target:GetAbsOrigin(),false,nil,nil,caster:GetTeam())
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_invulnerable",nil)
	ability:ApplyDataDrivenModifier(dummy,dummy,"Passive_B22D",nil)
	
	Timers:CreateTimer(1, function() 
		if IsValidEntity(target) and target:IsStanding() then
			AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), radius, 1, false)
			return 1
		end
		dummy:Destroy()
		ParticleManager:DestroyParticle(spike,true)
		return nil
	end)
end

function B22W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local radius = ability:GetSpecialValueFor("radius")
	local maxrock = ability:GetSpecialValueFor("maxrock")
	local duration = ability:GetSpecialValueFor("duration")
	local pointx = point.x
	local pointy = point.y
	local pointz = point.z
	local pointx2
	local pointy2
	local a	
	local rocks = {}
	for i=1,maxrock do
		a	=	(	(360.0/maxrock)	*	i	)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	radius 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	radius 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)

		local dummy = CreateUnitByName("B22_rock_hero",point,false,nil,nil,caster:GetTeam())
		ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_kill",{duration = duration})
		ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_magic_immune",{duration = duration})
		dummy:RemoveModifierByName("modifier_invulnerable")
		table.insert(rocks, dummy)
	end
	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius+300, 
		DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for _,it in pairs(enemies) do
		if _G.EXCLUDE_TARGET_NAME[it:GetUnitName()] == nil then
			it:AddNewModifier(it,ability,"modifier_phased",{duration=0.1})
		end
	end
	
	Timers:CreateTimer(duration, function() 
		for i,rock in pairs(rocks) do
			rock:Destroy()
		end
		end)
end

function B22E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	target:CutDown(caster:GetTeam())
	local duration = ability:GetSpecialValueFor("duration")
	local hp_buff = ability:GetSpecialValueFor("hp_buff")
	local atk_buff = ability:GetSpecialValueFor("atk_buff")
	local dummy = CreateUnitByName("B22E_treant",target:GetAbsOrigin(),false,nil,nil,caster:GetTeam())
	dummy:SetOwner(caster)
	dummy:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_kill",{duration = duration})
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_fly",{duration = 3})
	dummy:SetBaseMaxHealth(1500+caster:GetLevel()*hp_buff)
	dummy:SetMaxHealth(1500+caster:GetLevel()*hp_buff)
	dummy:SetHealth(dummy:GetMaxHealth())
	dummy:SetBaseDamageMax(51+caster:GetLevel()*atk_buff)
	dummy:SetBaseDamageMin(41+caster:GetLevel()*atk_buff)
	dummy:AddNewModifier(dummy,ability,"modifier_phased",{duration=3})
end

function B22R_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B22R2",{duration = 0.8})
		local am = caster:FindAllModifiers()
		for _,v in pairs(am) do
			if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
				if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
					caster:RemoveModifierByName(v:GetName())
				end
			end
		end
	else
		if target:IsIllusion() then
			target:ForceKill(true)
		else
			target:RemoveModifierByName("modifier_perceive_wine")
			target.nomagic = true
			Timers:CreateTimer(10, function() 
				target.nomagic = nil
			end)
			AMHC:Damage(caster,target,ability:GetAbilityDamage(),AMHC:DamageType("DAMAGE_TYPE_MAGICAL"))
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B22R",{duration = 0.8})
		end
	end
end


function B22T_OnSpellStart( keys )
	GridNav:RegrowAllTrees()
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local radius = ability:GetSpecialValueFor("radius")
	local dummy = CreateUnitByName("B22E_treant2",point,false,nil,nil,caster:GetTeam())
	AddFOWViewer(DOTA_TEAM_GOODGUYS, point, 1000, 3, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, point, 1000, 3, false)
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_kill",{duration = 3.2})
	Timers:CreateTimer(3, function() 
		if dummy:IsAlive() then
			local ifx = ParticleManager:CreateParticle("particles/a10e/a10e_hitexplosion_alliance_trail.vpcf",PATTACH_CUSTOMORIGIN,nil)
				ParticleManager:SetParticleControl(ifx, 0, dummy:GetAbsOrigin())
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				dummy:GetAbsOrigin(),			-- 搜尋的中心點
				nil,
				radius,			-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false)
			dummy:Destroy()
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
				if IsValidEntity(unit) then
					local dir = (caster:GetAbsOrigin()-unit:GetAbsOrigin()):Normalized()
					local ifx = ParticleManager:CreateParticle("particles/a10e/a10e_hitexplosion_alliance_trail.vpcf",PATTACH_POINT,unit)
					ParticleManager:SetParticleControl(ifx, 0, unit:GetAbsOrigin())
				end
			end
		end
		end)
	point.z = 400
	dummy:SetAbsOrigin(point)
	local ifx = ParticleManager:CreateParticle("particles/a10e/a10e_hitexplosion_alliance_trail.vpcf",PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl(ifx, 0, dummy:GetAbsOrigin())
end

--11.2B


function B22E_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	target:CutDown(caster:GetTeam())
	local duration = ability:GetSpecialValueFor("duration")
	local hp_buff = ability:GetSpecialValueFor("hp_buff")
	local atk_buff = ability:GetSpecialValueFor("atk_buff")
	local dummy = CreateUnitByName("B22E_treant",target:GetAbsOrigin(),false,nil,nil,caster:GetTeam())
	dummy:SetOwner(caster)
	dummy:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_kill",{duration = duration})
	dummy:SetBaseMaxHealth(1500+caster:GetLevel()*hp_buff)
	dummy:SetMaxHealth(1500+caster:GetLevel()*hp_buff)
	dummy:SetHealth(dummy:GetMaxHealth())
	dummy:SetBaseDamageMax(71+caster:GetLevel()*atk_buff)
	dummy:SetBaseDamageMin(61+caster:GetLevel()*atk_buff)
	dummy:AddNewModifier(dummy,ability,"modifier_phased",{duration=3})
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_fly",{duration = 3})
end


function B22R_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_B22R2",{duration = 0.8})
		local am = caster:FindAllModifiers()
		for _,v in pairs(am) do
			if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
				if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
					caster:RemoveModifierByName(v:GetName())
				end
			end
		end
	else
		if target:IsIllusion() then
			target:ForceKill(true)
		else
			target:RemoveModifierByName("modifier_perceive_wine")
			target.nomagic = true
			Timers:CreateTimer(10, function() 
				target.nomagic = nil
			end)
			AMHC:Damage(caster,target,ability:GetAbilityDamage(),AMHC:DamageType("DAMAGE_TYPE_MAGICAL"))
			ability:ApplyDataDrivenModifier(caster,target,"modifier_B22R",{duration = 3})
		end
	end
end


function B22T_old_OnSpellStart( keys )
	GridNav:RegrowAllTrees()
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local radius = ability:GetSpecialValueFor("radius")
	local stun = ability:GetSpecialValueFor("stun")
	local stun2 = ability:GetSpecialValueFor("stun2")
	local duration = 3
	AddFOWViewer(DOTA_TEAM_GOODGUYS, point, 1000, 3, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, point, 1000, 3, false)
	local ifx = ParticleManager:CreateParticle("particles/b22/b22tattack.vpcf",PATTACH_CUSTOMORIGIN,nil)
	local dummy = CreateUnitByName("npc_dummy",point,false,nil,nil,caster:GetTeam())
	ability:ApplyDataDrivenModifier(dummy,dummy,"modifier_kill",{duration = 5})
	ParticleManager:SetParticleControl(ifx, 0, point)
	local maxrock = 60
	local pos = {}
	local pointx = point.x
	local pointy = point.y
	local pointz = point.z
	local ct = 0
	local interval = 0.02
	Timers:CreateTimer(interval, function() 
		ct = ct + 1
		if math.fmod(ct, 3) == 0 then
			local split_shot_targets = FindUnitsInRadius( caster:GetTeamNumber(), point, nil, radius+50, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

			if #split_shot_targets > 0 then
				-- 隨機選擇一個敵方單位
				local rnd = RandomInt(1,#split_shot_targets)

				-- 打出風之傷
				local info = {
					Target = split_shot_targets[rnd],
					Source = dummy,
					Ability = ability,
					EffectName = "particles/b22t_old.vpcf",
					bDodgeable = false,
					bProvidesVision = false,
					iMoveSpeed = 600,
			        iVisionRadius = 0,
			        iVisionTeamNumber = caster:GetTeamNumber(),
					iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
				}
				ProjectileManager:CreateTrackingProjectile( info )
			end
		end
		local len = radius*(1-ct*(interval*1.5) / duration)
		a	=	(	(360.0/maxrock)	* ct)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	len 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	len 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)
		
		point.z = 500*(1-ct*interval / duration)
		dummy:SetAbsOrigin(point)
		ParticleManager:SetParticleControl(ifx, 0, point)
		-- 飛高高
		if ct*interval < duration then
			return interval
		end
		end)
	Timers:CreateTimer(duration, function() 
			dummy:EmitSound("B22T.sound1")
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				point,			-- 搜尋的中心點
				nil,
				radius,			-- 搜尋半徑
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
				if unit:IsHero() then
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = stun})
				elseif unit:IsBuilding() then
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = stun})
				else
					ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = stun2})
				end
			end
			end)
end
