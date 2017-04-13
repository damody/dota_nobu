--[[ ============================================================================================================
	作者:Jerry Yao
	時間: 2017,3,9
	龍川一益技能lua部分
================================================================================================================= ]]

A32T_castPoistion= Vector(0,0,0)--瀧川大絕紀錄點

--[[ ============================================================================================================
	技能:瀧川 W 技能
	功能:使腳色跳往指定點。
	可變參數:knockbackProperties
================================================================================================================= ]]
function A32W_knockBack( event )
	local caster = event.caster 
	local point =event.target_points[1]
	local vec = caster:GetOrigin()
	--local distance =math.sqrt(math.pow(vec.x-point.x,2)+math.pow(vec.y-point.y,2))

	local distance =(point - vec):Length()--目標點跟施法者的距離
	local knockbackProperties =
	{
		center_x = point.x,
		center_y = point.y,
		center_z = point.z,
		duration = event.ability:GetLevelSpecialValueFor("A32W_flyTime", 0),
		knockback_duration = event.ability:GetLevelSpecialValueFor("A32W_flyTime", 0),
		knockback_distance = -distance,--負數往目標點移動
		knockback_height = 300,
		should_stun = 0
	}
	caster:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
	caster:RemoveGesture(ACT_DOTA_FLAIL)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)

end




--[[ ============================================================================================================
	技能:瀧川 W 技能
	功能:在跳躍的秒數後會呼叫此函數，對指定範圍地點造成傷害與暈眩跟地板特效。
	可變參數:A32W2_duration
================================================================================================================= ]]
function A32W_stunAndDamage( keys )

	local caster = keys.caster             
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("A32W_Radius")
	--第二次跳躍有效時間
	local A32W2_duration=5
	--地板特效
	local particle = ParticleManager:CreateParticle("particles/econ/items/sand_king/sandking_barren_crown/sandking_rubyspire_cracks.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())

	local targets = FindUnitsInRadius(caster:GetTeamNumber(),	
				caster:GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		FIND_ANY_ORDER, 
				false) 
	local count=0
	--對所有範圍內的敵人執行動作
	for i,unit in pairs(targets) do
		--對目標傷害
		if not unit:IsBuilding() then
			count=count+1
			local damageTable = {victim=unit,   
				attacker=caster,          
				damage=ability:GetSpecialValueFor("A32W_damage"),
				damage_type=keys.ability:GetAbilityDamageType()}
			if not unit:IsMagicImmune() then
				ApplyDamage(damageTable)
				--對目標暈眩
				ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = ability:GetSpecialValueFor("A32W_stunDuration")})
			end
		end
	end


	--有敵人在範圍內造成傷害則開啟第二次跳躍
	if count > 0 then
		--caster:AddAbility("skill2")

		--設定第二次跳躍等級為目前W等級 並把技能設為啟動狀態
		caster:FindAbilityByName("A32D"):SetLevel(keys.ability:GetLevel())
		caster:FindAbilityByName("A32D"):SetActivated(true)
		--skill2:SetLevel(keys.ability:GetLevel())
		--print(caster:FindAbilityByName("skill2"):GetLevel())

		--設定秒數後關閉第二次跳躍技能
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("A32W1_timer"), 
			function( )
				caster:FindAbilityByName("A32D"):SetActivated(false)
				return nil
		end, A32W2_duration)
	end

end

function A32T_old_OnIntervalThink( keys )

	local caster = keys.caster             
	local ability = keys.ability
	if caster:GetMana() < ability:GetSpecialValueFor("mana") then
		caster:CastAbilityToggle(ability,-1)
	else
		local targets = FindUnitsInRadius(caster:GetTeamNumber(),	
					caster:GetAbsOrigin(),nil,400,DOTA_UNIT_TARGET_TEAM_ENEMY, 
			   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			   		0, 
			   		FIND_ANY_ORDER, 
					false) 
		--對所有範圍內的敵人執行動作
		for i,unit in pairs(targets) do
			--對目標傷害
			AMHC:Damage(caster,unit, ability:GetAbilityDamage(), AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end


--[[ ============================================================================================================
	技能:瀧川 W 技能 第二次使用
	功能:在跳躍的秒數後會呼叫此函數，對指定範圍地點造成傷害與暈眩跟地板特效。 部分內容同上。
	可變參數:A32W2_duration
================================================================================================================= ]]



function A32W2_stunAndDamage( keys )
	local caster = keys.caster            
	local targets = keys.target_entities  
	local al = keys.ability:GetLevel() - 1  

	local particle = ParticleManager:CreateParticle("particles/econ/items/sand_king/sandking_barren_crown/sandking_rubyspire_cracks.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())


	for i,unit in pairs(targets) do
		local damageTable = {victim=unit,   
			attacker=caster,         
			damage=keys.ability:GetLevelSpecialValueFor("A32W2_damage", al),   
			damage_type=keys.ability:GetAbilityDamageType()}   
		--print(keys.ability:GetLevelSpecialValueFor("A32W2_damage", al))
		ApplyDamage(damageTable)   
		--print("applystun")
		unit:AddNewModifier( unit, nil, "modifier_stunned", {duration = keys.ability:GetLevelSpecialValueFor("A32W2_stunDuration", al)} )
	end

end




--[[ ============================================================================================================
	技能:瀧川 E 技能 
	功能:呼叫後產生特效並且對目標造成傷害，對自己補血，固定時間檢查是否超出距離。
	可變參數:castDistance,healPencentTage
================================================================================================================= ]]



function A32E( event )
	local duration = event.ability:GetSpecialValueFor("A32E_duration")
	local ability = event.ability
	local target = event.target
	local caster = event.caster

	--治療量等同自身所失去生命值的 15 % 
	local healPencentTage=0.15

	--超過此設定距離就會取消技能跟特效
	local castDistance =event.ability:GetSpecialValueFor("A32E_distance")

	local al = event.ability:GetLevel() - 1 

	local damageTable = {victim=target, 
	attacker=caster,         
	damage=event.ability:GetLevelSpecialValueFor("A32E_damage", al),      
	damage_type=event.ability:GetAbilityDamageType()}  
	
	--產生特效 並且設定目標跟施法者座標給特效綁定點
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_spiritsiphon.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(particle, 5, Vector(duration, 0, 0))

	--定時檢查是否超出設定距離 每0.5秒檢查一次
	local count = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("A32E_timer"), 
		function( )
			--當設定時間還沒超過而且施法者跟目標都還沒死亡時執行以下動作
			if count < duration*2 and caster:IsAlive() and target:IsAlive() then
				ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				--計算施法者跟目標距離
				local distance=(caster:GetAbsOrigin()-target:GetAbsOrigin()):Length()

				--超出距離摧毀特效 停止計時
				if distance>castDistance then
					ParticleManager:DestroyParticle(particle,false)
					return nil
				else
					--每一秒(0.5S*2) 對施法者回血 並對 目標造成傷害
					if count % 2 ==1 then
						--損失血量15%
						caster:Heal(caster:GetHealthDeficit()*healPencentTage,caster)
						--如果沒魔免
						if not target:IsMagicImmune() then
							ApplyDamage(damageTable)
						end
					end 
				end
				count=count+1
				return 0.5
			else
				--否則摧毀特效 停止計時
				ParticleManager:DestroyParticle(particle,false)
				return nil
			end
	end, 0.5)
end





--[[ ============================================================================================================
	技能:瀧川 R 技能 
	功能:呼叫後產生特效，設定時間到後摧毀特效。
	可變參數:皆在技能設定
================================================================================================================= ]]


function A32R_OnSpellStart( event )
	local duration = event.ability:GetSpecialValueFor("A32R_duration")
	local ability = event.ability
	local target = event.target
	local caster = event.caster
	target:SetRenderColor(150,255,150)
	target.isvoid = 1
end



--[[ ============================================================================================================
	技能:瀧川 T 技能 
	功能:紀錄使用時的施法者位置
	可變參數:無
================================================================================================================= ]]

function A32T_SaveCastPosition( event )
	A32T_castPoistion=event.caster:GetAbsOrigin()
end



--[[ ============================================================================================================
	技能:瀧川 T 技能 
	功能:當技能投擲物觸碰時呼叫，計算目標與施法點距離之後，把他們拉至施法點，並且造成傷害
	可變參數:knockbackProperties,Damage
================================================================================================================= ]]

function A32T_OnProjectileHit( event )
	local caster = event.caster 
	local target = event.target
	local ability = event.ability
	local point=target:GetOrigin()
	--施法點
	local vec = A32T_castPoistion

	--計算目標與施法點距離
	local distance =300

	local knockbackProperties =
	{
		center_x = vec.x,
		center_y = vec.y,
		center_z = vec.z,
		duration = 0.5,
		knockback_duration = 0.5,
		knockback_distance = -distance,
		knockback_height = 0,
		should_stun = 0
	}

	target:AddNewModifier( target, nil, "modifier_knockback", knockbackProperties )


	--傷害為當前血量設定百分比
	local Damage=target:GetHealth()*event.Damage/100

	--至少傷害
	if Damage<400 then
		Damage=400
	end
	local damageTable = {victim=target, 
		attacker=caster,    
		damage=Damage,      
		damage_type=event.ability:GetAbilityDamageType()}
	ApplyDamage(damageTable)
end


function A32F_OnToggleOn( event )
	local ability = event.ability
	local caster = event.caster
	caster.attackvoid = 1
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A32F",nil)
	Timers:CreateTimer(0.1,function()
		if caster.next_attack ~= nil then
			caster.next_attack.ability = ability

			local targetArmor = caster.next_attack.victim:GetPhysicalArmorValue()
			local damageReduction = ((0.06 * targetArmor) / (1 + 0.06* targetArmor))
			caster.next_attack.damage = caster.next_attack.damage/(1-damageReduction)

			ApplyDamage(caster.next_attack)
			caster.next_attack = nil

		end
		return 0.1
		end)
end

function A32F_OnToggleOff( event )
	local ability = event.ability
	local caster = event.caster
	caster.attackvoid = nil
	caster:RemoveModifierByName("modifier_A32F")
end


function A32F_OnAttackLanded( event )
	local ability = event.ability
	local target = event.target
	local caster = event.caster
	
end







function A32W_old_knockBack( event )
	local caster = event.caster 
	local point =event.target_points[1]
	local vec = caster:GetOrigin()
	--local distance =math.sqrt(math.pow(vec.x-point.x,2)+math.pow(vec.y-point.y,2))

	local distance =(point - vec):Length()--目標點跟施法者的距離
	local knockbackProperties =
	{
		center_x = point.x,
		center_y = point.y,
		center_z = point.z,
		duration = event.ability:GetLevelSpecialValueFor("A32W_flyTime", 0),
		knockback_duration = event.ability:GetLevelSpecialValueFor("A32W_flyTime", 0),
		knockback_distance = -distance,--負數往目標點移動
		knockback_height = 300,
		should_stun = 0
	}
	caster:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
	caster:RemoveGesture(ACT_DOTA_FLAIL)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)

end


function A32W_old_stunAndDamage( keys )

	local caster = keys.caster             
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("A32W_Radius")
	--第二次跳躍有效時間
	local A32W2_duration=5
	--地板特效
	local particle = ParticleManager:CreateParticle("particles/econ/items/sand_king/sandking_barren_crown/sandking_rubyspire_cracks.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())

	local targets = FindUnitsInRadius(caster:GetTeamNumber(),	
				caster:GetAbsOrigin(),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY, 
		   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		   		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
		   		FIND_ANY_ORDER, 
				false) 
	local count=0
	--對所有範圍內的敵人執行動作
	for i,unit in pairs(targets) do
		--對目標傷害
		if not unit:IsBuilding() then
			count=count+1
			local damageTable = {victim=unit,   
				attacker=caster,          
				damage=ability:GetSpecialValueFor("A32W_damage"),
				damage_type=keys.ability:GetAbilityDamageType()}
			if not unit:IsMagicImmune() then
				ApplyDamage(damageTable)
				--對目標暈眩
				ability:ApplyDataDrivenModifier(caster,unit,"modifier_stunned",{duration = ability:GetSpecialValueFor("A32W_stunDuration")})
			end
		end
	end


end



function A32E_old_OnSpellStart( event )
	local duration = event.ability:GetSpecialValueFor("A32E_old_duration")
	local ability = event.ability
	local target = event.target
	local caster = event.caster
	target.isvoid = 1
	target:SetRenderColor(150,255,150)
end

function A32E_old_OnDestroy( event )
	local ability = event.ability
	local target = event.target
	local caster = event.caster
	target.isvoid = nil
	target:SetRenderColor(255,255,255)
end

function A32T_lock( keys )
	keys.ability:SetActivated(false)
end

function A32T_unlock( keys )
	keys.ability:SetActivated(true)
end

function A32T_old_OnToggleOn( event )
	local ability = event.ability
	local caster = event.caster
	caster.attackvoid = 1
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A32F",nil)
	Timers:CreateTimer(0.1,function()
		if caster.next_attack ~= nil then
			caster.next_attack.ability = ability
			--[[
			local targetArmor = caster.next_attack.victim:GetPhysicalArmorValue()
			local damageReduction = ((0.06 * targetArmor) / (1 + 0.06* targetArmor))
			caster.next_attack.damage = caster.next_attack.damage/(1-damageReduction)
			]]
			ApplyDamage(caster.next_attack)
			caster.next_attack = nil
		end
		return 0.1
		end)

end

function A32T_old_OnToggleOff( event )
	local ability = event.ability
	local caster = event.caster
	caster.attackvoid = nil
	caster:RemoveModifierByName("modifier_A32F")
end