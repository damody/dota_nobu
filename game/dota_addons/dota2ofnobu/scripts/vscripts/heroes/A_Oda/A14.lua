
function A14W_OnSpellStart( event )
	local ability = event.ability
	local caster = event.caster 
	local target =event.target
	local vec = caster:GetAbsOrigin()
	local point = target:GetAbsOrigin()
	local tmpvec=(point-vec):Normalized()*300
	local targetvec=Vector(tmpvec.x,tmpvec.y,0)
	--print(targetvec)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
	Timers:CreateTimer(0.2,function()
		local order = {UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()}
		ExecuteOrderFromTable(order)
		end)
	if not target:IsBuilding() and target:GetUnitName() ~= "B24W_DUMMY" and target:GetUnitName() ~= "B24T_HIDE" and
		not string.match(target:GetUnitName(), "com_general") and not target:HasAbility("majia") then
		Physics:Unit(target)
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = 0.8})
		target:SetPhysicsVelocity((point - vec):Normalized()*1700)
		local x=math.ceil(target:GetPhysicsVelocity():Normalized().x*100)
		local y=math.ceil(target:GetPhysicsVelocity():Normalized().y*100)
		cur_target_vec=Vector(x,y,0)
	end
	timecounter=0
	Timers:CreateTimer(0.01,function()
		local x=math.ceil(target:GetPhysicsVelocity():Normalized().x*100)
		local y=math.ceil(target:GetPhysicsVelocity():Normalized().y*100)
		cur_target_vec2=Vector(x,y,0)
		--print(cur_target_vec)
		--print(cur_target_vec2)
		--print(cur_target_vec2==cur_target_vec)
		if not (cur_target_vec==cur_target_vec2) then
			StartSoundEvent( "A07T.attack", target )
				target:RemoveModifierByName("modifier_stunned")
				Physics:Unit(target)
				target:SetPhysicsVelocity(Vector(0,0,0))
				local unitss = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				target:GetAbsOrigin(),							-- 搜尋的中心點
				nil, 							-- 好像是優化用的參數不懂怎麼用
				350,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 							-- 好像是優化用的參數不懂怎麼用
				AMHC:CreateParticle("particles/a07e/a07e.vpcf",PATTACH_ABSORIGIN,false,target,0.5,nil)
				for _a,unit2 in ipairs(unitss) do
					local damageTable = {victim=unit2,   
						attacker=caster,         
						damage=ability:GetSpecialValueFor("damage"),   
						damage_type=ability:GetAbilityDamageType()} 
					if not unit2:IsMagicImmune() then
						ability:ApplyDataDrivenModifier(caster,unit2,"modifier_A14W",nil)
						ApplyDamage(damageTable)  
					end
				end
				target:AddNewModifier(target,ability,"modifier_phased",{duration=0.1})
				FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
			return nil
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		target:GetAbsOrigin()+targetvec,							-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		300,					-- 搜尋半徑
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
		for _,unit in ipairs(units) do
			if (unit~=target and CalcDistanceBetweenEntityOBB(unit,target)<=100)or timecounter==80 or target:GetPhysicsVelocity():Length()<100 then
				StartSoundEvent( "A07T.attack", target )
				target:RemoveModifierByName("modifier_stunned")
				Physics:Unit(target)
				target:SetPhysicsVelocity(Vector(0,0,0))
				local unitss = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				target:GetAbsOrigin(),							-- 搜尋的中心點
				nil, 							-- 好像是優化用的參數不懂怎麼用
				350,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 							-- 好像是優化用的參數不懂怎麼用
				AMHC:CreateParticle("particles/a07e/a07e.vpcf",PATTACH_ABSORIGIN,false,target,0.5,nil)
				for _a,unit2 in ipairs(unitss) do
					local damageTable = {victim=unit2,   
						attacker=caster,         
						damage=ability:GetSpecialValueFor("damage"),   
						damage_type=ability:GetAbilityDamageType()} 
					if not unit2:IsMagicImmune() then
						ability:ApplyDataDrivenModifier(caster,unit2,"modifier_A14W",nil)
						ApplyDamage(damageTable)  
					end
				end
				target:AddNewModifier(target,ability,"modifier_phased",{duration=0.1})
				FindClearSpaceForUnit(target, target:GetAbsOrigin(), false)
				return nil
			else
				timecounter=timecounter+1
				return 0.01
			end
		end
		timecounter=timecounter+1
		return 0.01
		end)
end






function A14E_OnSpellStart(keys)
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
	local caster = keys.caster
	local dummy = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin(),false,nil,nil,caster:GetTeamNumber())
	dummy:AddNewModifier(nil,nil,"modifier_kill",{duration=5})
	local origin_point = keys.caster:GetAbsOrigin()
	local target = keys.target
	local target_point = keys.target:GetAbsOrigin()
	local difference_vector = target_point - origin_point
	local ability=keys.ability
	local damageTable = {victim=target,   
	attacker=caster,         
	damage=ability:GetAbilityDamage(),   
	damage_type=ability:GetAbilityDamageType()} 
	if not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = ability:GetSpecialValueFor("Duration")})
		ApplyDamage(damageTable)  
	end
	for i=1,8 do
		local particle = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start_sparkles.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()+difference_vector:Normalized()*100*i)
	end
	
	target_point = origin_point + difference_vector:Normalized() * ability:GetSpecialValueFor("max_blink_range")
	keys.caster:AddNewModifier(keys.caster,keys.ability,"modifier_phased",{duration=0.1})
	keys.caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(keys.caster, target_point, false)
end

attack_target={}
A14R_current_time=0
A14T_first=false
function modifier_A14R_OnAttackLanded(keys)
	local target_point = keys.target:GetAbsOrigin()
	local ability=keys.ability
	local caster = keys.caster
	if attack_target==keys.target or A14T_first then
		A14T_first=false
		attack_target = keys.target
		A14R_current_time=A14R_current_time+1
		modifier=caster:FindModifierByName("modifier_A14R_atk_bonus")
		if A14R_current_time>= ability:GetSpecialValueFor("buff_max_time") then
			A14R_current_time=ability:GetSpecialValueFor("buff_max_time")
		end
		modifier:SetStackCount(A14R_current_time)
	else
		modifier=caster:FindModifierByName("modifier_A14R_atk_bonus")
		A14R_current_time=1
		attack_target = keys.target
		modifier:SetStackCount(1)
	end
end


function A14T_OnSpellStart( keys )
	if keys.caster:FindModifierByName("modifier_A14R_atk_bonus") then
		A14T_first=true
		A14R_current_time=A14R_current_time+5
		ability=keys.caster:FindAbilityByName("A14R")
		if A14R_current_time>= ability:GetSpecialValueFor("buff_max_time") then
			A14R_current_time=ability:GetSpecialValueFor("buff_max_time")
		end
		modifier=keys.caster:FindModifierByName("modifier_A14R_atk_bonus")
		modifier:SetStackCount(A14R_current_time)
	end
end