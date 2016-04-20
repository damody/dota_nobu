
--莉娜 龙破斩
function OnAbility1( keys )
	local caster = keys.caster

	--获取施法点
	local point = keys.target_points[1]

	--获取施法者位置
	local caster_abs = caster:GetAbsOrigin()

	--获取施法方向向量
	local caster_face = (point - caster_abs):Normalized()
	
	--获取技能等级
	local i = keys.ability:GetLevel() - 1

	--获取距离
	local distance = keys.ability:GetLevelSpecialValueFor("distance", i)

	--用一个table来装3个点
	local over_vec = {}
	over_vec[1] = caster_abs + caster_face * distance
	over_vec[2] = RotatePosition(caster_abs, QAngle(0,25,0), over_vec[1])
	over_vec[3] = RotatePosition(caster_abs, QAngle(0,-25,0), over_vec[1])

	--循环创建线性投射物
	for k,vec in pairs(over_vec) do
		local face = (vec - caster_abs):Normalized()
		local info = 
	    {
	        Ability = keys.ability,
	        EffectName = "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf",
	        vSpawnOrigin = caster:GetAbsOrigin(),
	        fDistance = distance,
	        fStartRadius = 0,
	        fEndRadius = 200,
	        Source = caster,
	        bHasFrontalCone = false,
	        bReplaceExisting = false,
	        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
	        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	        fExpireTime = GameRules:GetGameTime() + 2,
	        bDeleteOnHit = false,
	        vVelocity = face * 1800,
	        bProvidesVision = true,
	        iVisionRadius = 300,
	        iVisionTeamNumber = caster:GetTeamNumber()
	    }
	    local projectile = ProjectileManager:CreateLinearProjectile(info)
	end
end

--莉娜 炽魂
function OnFierySoul( keys )
	local caster = keys.caster

	--获取叠加的modifier数量
	local i = caster:GetContext("FierySoul")

	--获取技能等级
	local lv = keys.ability:GetLevel() - 1

	--获取叠加次数
	local max = keys.ability:GetLevelSpecialValueFor("fiery_soul_max_stacks", lv)

	--如果得到一个nil就设置i=0
	if i then
		if i>=max then
			caster:RemoveModifierByName("modifier_lina_fiery_soul_buff")
			return
		end
	else
		i=0
	end

	--记录modifier数量
	caster:SetContextNum("FierySoul", i+1, 0)

	--设置modifier数量
	caster:SetModifierStackCount("modifier_lina_fiery_soul_buff_icon",caster,i+1)
end

function DestroyFierySoul( keys )
	local caster = keys.caster

	--获取叠加的modifier数量
	local i = caster:GetContext("FierySoul")

	for k=1,i do
		caster:RemoveModifierByName("modifier_lina_fiery_soul_buff")
	end

	--清空记录modifier数量
	caster:SetContextNum("FierySoul", 0, 0)
end

function OnAbility4Effect( unit,time )
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnAbility4Effect"),
		function( )
			if IsValidEntity(unit) then
				local vec = unit:GetAbsOrigin()
				local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf",PATTACH_WORLDORIGIN,unit)
				ParticleManager:SetParticleControl(particle,0,vec)
				ParticleManager:SetParticleControl(particle,1,Vector(50,50,50))
				ParticleManager:SetParticleControl(particle,3,vec)
				ParticleManager:ReleaseParticleIndex(particle)
				return time
			end
			return nil
		end,0)
end

function OnAbility4( keys )
	local caster = keys.caster
	local caster_abs = caster:GetAbsOrigin()
	local caster_face = caster:GetForwardVector()

	--获取技能等级
	local lvl = keys.ability:GetLevel() - 1

	--获取旋转距离
	local turn_radius = keys.ability:GetLevelSpecialValueFor("turn_radius",lvl)

	--获取伤害范围
	local damage_radius = keys.ability:GetLevelSpecialValueFor("damage_radius",lvl)

	local majia = {}
	local num = 8
	for i=1,num do
		local vec = caster_abs + caster_face*turn_radius
		local rotate = RotatePosition(caster_abs,QAngle(0,(360/num)*i,0),vec)

		majia[i]=CreateUnitByName("npc_majia",rotate,false,nil,nil,caster:GetTeamNumber())
		keys.ability:ApplyDataDrivenModifier(caster,majia[i],"modifier_ability4_majia",nil)
		OnAbility4Effect(majia[i],0.3)
	end

	local speed = 45
	local angle = -7
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnAbility4"),
		function( )
			turn_radius = turn_radius - speed

			if turn_radius <= speed then
				for i=1,num do
					UTIL_RemoveImmediate(majia[i])
				end
				return nil
			end

			for i=1,num do
				local vec = caster_abs + caster_face*turn_radius
				local rotate = RotatePosition(caster_abs,QAngle(0,(360/num)*i+angle,0),vec)

				majia[i]:SetAbsOrigin(rotate)
			end
			angle = angle + angle
			return 0.1
		end,0)
end