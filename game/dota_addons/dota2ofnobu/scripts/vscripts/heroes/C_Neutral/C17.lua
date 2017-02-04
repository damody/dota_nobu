udg_C05W_stun = {}
udg_C05W_stun[1] = 0.30
udg_C05W_stun[2] = 0.50
udg_C05W_stun[3] = 0.70
udg_C05W_stun[4] = 0.90	






function new_C17R( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	--local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()

	local particle2 = ParticleManager:CreateParticle("particles/c17r/c17r.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle2,0, point2)
	ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
	ParticleManager:SetParticleControl(particle2,2, point2)	

end

function new_C17R_dmg( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = caster:GetIntellect() * 4  
	local dmg2 = ability:GetLevelSpecialValueFor("dmg",ability:GetLevel() - 1)
	--【DMG】
	if (not target:IsBuilding()) then
		AMHC:Damage( caster,target,dmg+dmg2,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
	--【DEBUG】
	----print(dmg)
end

function new_C17D( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local dmg = caster:GetIntellect() * 4  
	local point = caster:GetAbsOrigin()
	local point2 = nil
	--PopupHealing(caster, health)
	--【Group】
	local radius = 800

 	local group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius,DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	for i,v in ipairs(group) do
		point2 = v:GetAbsOrigin()
		local particle = ParticleManager:CreateParticle("particles/c17d/c17d.vpcf", PATTACH_ABSORIGIN_FOLLOW , v)
		-- Raise 1000 if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 0, point2)
		--ParticleManager:SetParticleControl(particle, 1, Vector(point2.x,point2.y,point2.z + v:GetBoundingMaxs().z ))
		ParticleManager:SetParticleControl(particle, 2, point2)

		-- Timers:CreateTimer(1,function()
		-- 	ParticleManager:DestroyParticle(particle,false)
		-- end)

		--【KV】
		local mana = v:GetMaxMana() * 0.04 
		local health = v:GetMaxHealth() * 0.05
		v:SetMana(mana + v:GetMana())
		v:SetHealth(health + v:GetHealth())

		--【DEBUG】
		--print(health)
		--print(mana)	
		--print(v:GetUnitName())	

	end	
end

function new_C17D_DMG( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local dmg = keys.dmg
	local cure = ability:GetLevelSpecialValueFor("cure",ability:GetLevel() - 1)
	--【KV】
	if caster:GetHealth() > 21 and caster.damagetype ==1 then
		if dmg < cure then
			caster:SetHealth(dmg + caster:GetHealth())
		else
			caster:SetHealth(cure + caster:GetHealth())
		end
	end
	--【DEBUG】
	-- --print(cure)
	-- --print(caster.damagetype)
	----print(mana)	
end

function new_C17D_OnCreated( keys )
	--【Basic】
	local caster = keys.caster
	local ability = keys.ability
	local ta = {damage_reduction = 1000,damage_cleanse = 1000,amage_reset_interval =100}
			-- "01"
			-- {
			-- 	"var_type"				"FIELD_INTEGER"
			-- 	"damage_reduction"		"12 24 36 48"
			-- }
			-- "02"
			-- {
			-- 	"var_type"				"FIELD_INTEGER"
			-- 	"damage_cleanse"		"600 550 500 450"
			-- }
			-- "03"
			-- {
			-- 	"var_type"				"FIELD_FLOAT"
			-- 	"damage_reset_interval"	"6.0 6.0 6.0 6.0"
			-- }
	caster:AddNewModifier(caster,nil,"modifier_tidehunter_kraken_shell",ta)
	--【DEBUG】
	if caster:HasModifier("modifier_tidehunter_kraken_shell") then
		--print("C17_SUCCEESS")
		--print(caster:GetUnitName())
	end
end

function C17E(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	--local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()
	--【Particle】
	-- local particle = ParticleManager:CreateParticle("particles/c15t5/c15t5.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point)
	-- ParticleManager:SetParticleControl(particle,1, point)
	local particle2 = ParticleManager:CreateParticle("particles/c17e/c17e.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle2,0, point2)
	ParticleManager:SetParticleControl(particle2,1, Vector(1,1,1))	
	ParticleManager:SetParticleControl(particle2,2, point2)	
	ParticleManager:SetParticleControl(particle2,3, point2)	
	--ParticleManager:SetParticleControlForward(int nFXIndex,int nPoint,vForward)
end

function C17W(keys)
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local dmg_special = ability:GetLevelSpecialValueFor("dmg_special",level)
	local duration = ability:GetLevelSpecialValueFor("duration",level)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration",level)
	--local vec = caster:GetForwardVector():Normalized()
	local ctime = 0
	Timers:CreateTimer(0.2, function ()
		ctime = ctime + 0.2
          AddFOWViewer(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), 100, 0.3, false)
          AddFOWViewer(DOTA_TEAM_BADGUYS, caster:GetAbsOrigin(), 100, 0.3, false)
          if ctime < duration+0.3 then
          	return 0.2
          else
          	return nil
          end
        end)

	-- Fire the explosion effect
	local height = 3
	local particleName = "particles/c17w2/c17w2.vpcf"
	local particle = ParticleManager:CreateParticle( particleName, PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 3, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControl(particle,6, Vector(height,height,height))		
	--【Timer】
	Timers:CreateTimer(duration,function()
		ParticleManager:DestroyParticle(particle,true)

		--【Basic】
		point = caster:GetAbsOrigin()
		point2 = target:GetAbsOrigin() 
		local r = 0
		local r2 = 0
		local time = nil
		local dis = CalcDistanceBetweenEntityOBB(caster,target)
		if dis >1000 then
			r=1000
		else
			r=dis
		end
		r2=(1000-r)
		AMHC:Damage( caster,target,r * dmg_special,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		r2=((r2/200)+1)

		time = r2*udg_C05W_stun[level + 1]

		--【Modifier】
		ability:ApplyDataDrivenModifier(caster,target,"modifier_C17W",{duration = time})		
		--ParticleManager:SetParticleControl(particle2,1, point2)

		--【SE】
		local particle3 = ParticleManager:CreateParticle("particles/c17w5/c17w5.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle3,0, point2+Vector(0,0,40))
		ParticleManager:SetParticleControl(particle3,3, point2+Vector(0,0,40))

		for i=1,3 do
			local particle2 = ParticleManager:CreateParticle("particles/c17w3/c17w3.vpcf",PATTACH_POINT,target)
			ParticleManager:SetParticleControl(particle2,0, point2+Vector(0,0,i*40))
			Timers:CreateTimer(time,function()
				ParticleManager:DestroyParticle(particle2,false)
			end)
		end		

		--【DEBUG】
		--print(r)			
		--print(time)	

	end)			
end


function C17T(keys)
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--【SE】
	local particle3 = ParticleManager:CreateParticle("particles/c17t3/c17t3.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle3,0, point2+Vector(0,0,40))
	ParticleManager:SetParticleControl(particle3,3, point2+Vector(0,0,40))
	local aoeradius = ability:GetLevelSpecialValueFor("aoe",level)
	local dmg = ability:GetLevelSpecialValueFor("dmg",level)
	local regen = ability:GetLevelSpecialValueFor("regen",level)
	local hpx = ability:GetLevelSpecialValueFor("hpx",level)

	-- local particle = ParticleManager:CreateParticle("particles/c17t2/c17t2.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0, point2+Vector(0,0,40))
	--【Group】	
 	local group = FindUnitsInRadius(caster:GetTeamNumber(), point2, nil, aoeradius,ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	for i,v in ipairs(group) do
		if (not v:IsBuilding()) then
			local dmg2 = v:GetMaxHealth()*hpx/100
			if v:GetTeamNumber() ~= caster:GetTeamNumber() then
	        	if dmg2 <= dmg then
	        		AMHC:Damage( caster,v,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	       		else
	       			AMHC:Damage( caster,v,dmg2,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	        	end
			else
				local hp = v:GetHealth() + v:GetMaxHealth() * regen / 100
				v:SetHealth(hp)
			end
		end
	end	
end

-- 阿市 11.2B
---------------------------------------------------------------------------------------------------

function C17W_old_health_recover( keys )
	local target = keys.target
	local ability = keys.ability
	local health_recover = ability:GetLevelSpecialValueFor("health_recover",ability:GetLevel()-1)
	target:SetHealth(target:GetHealth()+health_recover)
end

function C17E_old_mana_recover( keys )
	local target = keys.target
	local ability = keys.ability
	local mana_recover = ability:GetLevelSpecialValueFor("mana_recover",ability:GetLevel()-1)
	target:SetMana(target:GetMana()+mana_recover)
end

function C17R_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()

	local unit = CreateUnitByName("C17R_old_SUMMEND_UNIT",point,true,caster,caster,caster:GetTeam())
	-- 把caster換成暈帳這樣之後的modifier就能用caster拿到暈帳，用ability拿到阿市
	ability:ApplyDataDrivenModifier(unit,unit,"modifier_C17R_old_delay_enable",nil)
	unit:AddAbility("for_magic_immune"):SetLevel(1)
end

function C17R_old_OnEnable( keys )
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel()-1
	local max_life_time = ability:GetLevelSpecialValueFor("max_life_time",level)
	ability:ApplyDataDrivenModifier(target,target,"modifier_C17R_old_aura",nil)
	target:AddNewModifier(target,nil,"modifier_invisible",nil)
	target:AddNewModifier(target,nil,"modifier_kill", {duration = max_life_time})
end

function C17R_old_on_trigger( keys )
	local target = keys.caster          -- 暈障
	local ability = keys.ability
	local caster = ability:GetCaster()	-- 阿市

	-- 移除光環，光環在角色死亡時不會刪除，似乎要等到實體被移除後才會刪除
	target:RemoveModifierByName("modifier_C17R_old_aura")

	-- 殺死暈障
	target:ForceKill(true)

	local level = ability:GetLevel()-1
	local delay_stun = ability:GetLevelSpecialValueFor("delay_stun",level)
	local aoe_radius = ability:GetLevelSpecialValueFor("radius_stun",level)
	local duration_stun = ability:GetLevelSpecialValueFor("duration_stun",level)

	-- 搜尋參數
	local center = target:GetAbsOrigin()
	local target_team = ability:GetAbilityTargetTeam()
	local target_type = ability:GetAbilityTargetType()
	local target_flags = ability:GetAbilityTargetFlags()
	local damage_type = ability:GetAbilityDamageType()
	local ability_damage = ability:GetAbilityDamage()

	Timers:CreateTimer(delay_stun, function()
		-- 砍樹
		GridNav:DestroyTreesAroundPoint(center, aoe_radius, false)
		-- 搜尋
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係
                              center,				-- 搜尋的中心點
                              nil, 					-- 好像是優化用的參數不懂怎麼用
                              aoe_radius,			-- 搜尋半徑
                              target_team,			-- 目標隊伍
                              target_type,			-- 目標類型
                              target_flags,			-- 額外選擇或排除特定目標
                              FIND_ANY_ORDER,		-- 結果的排列方式
                              false) 				-- 好像是優化用的參數不懂怎麼用
		-- 處理搜尋結果
		for _,unit in ipairs(units) do
			-- 製造傷害
			local damage_table = {}
			damage_table.victim = unit
  			damage_table.attacker = caster
 			damage_table.damage_type = damage_type
 			damage_table.damage = ability_damage
			ApplyDamage(damage_table)
			-- 暈眩
			unit:AddNewModifier(caster,ability,"modifier_stunned",{duration=duration_stun})
		end
		-- 特效
		local ifx = ParticleManager:CreateParticle("particles/c17/c17r_old_boom.vpcf",PATTACH_ABSORIGIN,caster)
		ParticleManager:SetParticleControl(ifx,0,center)
		ParticleManager:ReleaseParticleIndex(ifx)
	end)
end

function C17T_old( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()

	local particle = ParticleManager:CreateParticle("particles/c17/c17t_old.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(particle,3,point)

	local level = ability:GetLevel()-1
	local damage = ability:GetLevelSpecialValueFor("damage",level)
	local target_entities = keys.target_entities
	for k,v in ipairs(target_entities) do
		if v:GetTeamNumber() ~= caster:GetTeamNumber() then
			AMHC:Damage(caster,v,damage,AMHC:DamageType("DAMAGE_TYPE_MAGICAL"))
		else
			ParticleManager:CreateParticle("particles/c17/c17t_old_health.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
			v:SetHealth(v:GetMaxHealth())
		end
	end
end