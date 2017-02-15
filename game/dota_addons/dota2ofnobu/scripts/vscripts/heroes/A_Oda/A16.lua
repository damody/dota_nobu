LinkLuaModifier( "modifier_A16R2", "scripts/vscripts/heroes/A_Oda/A16.lua",LUA_MODIFIER_MOTION_NONE )
modifier_A16R2 = class({})

--------------------------------------------------------------------------------

function modifier_A16R2:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_A16R2:OnCreated( event )
	self:StartIntervalThink(0.2)
end

function modifier_A16R2:OnIntervalThink()
	if (self.caster ~= nil) and IsValidEntity(self.caster) then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_A16R2:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local caster = self.caster
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    local dmg = {0.35, 0.45, 0.55, 0.65}
	    local dmg2 = event.damage*dmg[self.level]
	    if (caster ~= nil) and IsValidEntity(caster) then
		    if victim:GetTeam() ~= attacker:GetTeam() and attacker == self.caster then
		        if damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
	            	if (IsValidEntity(caster) and caster:IsAlive()) then
		            	local group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
							nil,  500 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
							DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
		            	for _,enemy in pairs(group) do
							local damageTable = {
						        victim = enemy, 
						        attacker = caster,
						        damage = dmg2,
						        damage_type = DAMAGE_TYPE_PURE,
						        damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
						    }
						    ApplyDamage(damageTable)
						end
					end
		        end 
		    end
		end
	end
end

function A16R_OnUpgrade( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_A16R2", {} )
	caster:FindModifierByName("modifier_A16R2").caster = caster
	caster:FindModifierByName("modifier_A16R2").level = ability:GetLevel()
	if ability:GetLevel() == 1 then
		Timers:CreateTimer(1,function()
			if not caster:HasModifier("modifier_A16R2") then
				ability:ApplyDataDrivenModifier( caster, caster, "modifier_A16R2", {} )
				caster:FindModifierByName("modifier_A16R2").caster = caster
				caster:FindModifierByName("modifier_A16R2").level = ability:GetLevel()
			end
			return 1
		end)
	end
end



function A16T( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition()
	local point3 = point
	local rad = nobu_atan2( point2,point )
	local level = ability:GetLevel() - 1

	local time = ability:GetLevelSpecialValueFor("crack_time",level)
	local distance = ability:GetLevelSpecialValueFor("crack_distance",level)
	local vec = (point2 - point):Normalized()

	-- local x1 = point.x
	-- local y1 = point.y
	-- local z1 = point.z
	-- x1 = x1 + distance * math.cos(rad)
	-- y1 = y1 + distance * math.sin(rad)
	-- point2 = Vector(x1,y1,z1)

	-- local particle=ParticleManager:CreateParticle("particles/a16t/a16t.vpcf",PATTACH_POINT,caster)
	-- ParticleManager:SetParticleControl(particle,0,point)
	-- ParticleManager:SetParticleControl(particle,1,point2)
	-- ParticleManager:SetParticleControl(particle,3,Vector(0,time,0))
	local num = 0
	Timers:CreateTimer(0,function()
		num = num + 1


		if num > 7 then
			point = point + vec * 300

			NobuDummyCreateSound (caster,point,"Hero_Leshrac.Split_Earth.Tormented")


			--effect
			--獲取攻擊範圍
	    local group = {}
	    local radius = 300

	    -- Register units around caster
	    group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, 300, ability:GetAbilityTargetTeam(), 63, 80, 0, false)
	    for i,v in ipairs(group) do
	    	if (not v:IsBuilding()) then
				ability:ApplyDataDrivenModifier(caster,v,"modifier_A16T",nil)
			end
	    end
			--
	    -- print(point)
		else
			distance = 300
			x1 = point3.x
			y1 = point3.y
			z1 = point3.z
			x1 = x1 + distance * math.cos(rad)
			y1 = y1 + distance * math.sin(rad)
			point2 = Vector(x1,y1,z1)
			point3 = point3 + vec * 300
			local particle=ParticleManager:CreateParticle("particles/a16t/a16t.vpcf",PATTACH_POINT,caster)
			ParticleManager:SetParticleControl(particle,0,point3)
			ParticleManager:SetParticleControl(particle,1,point2)
			ParticleManager:SetParticleControl(particle,3,Vector(0,0.18*8,0))

			print(point3)
		end

		if num <= 13 then
			return .18
		else
			return nil
		end
	end)

	-- for i=1,7 do
	-- 	distance = 7200
	-- 	x1 = point.x
	-- 	y1 = point.y
	-- 	z1 = point.z
	-- 	x1 = x1 + distance * math.cos(rad)
	-- 	y1 = y1 + distance * math.sin(rad)
	-- 	point2 = Vector(x1,y1,z1)
	-- 	local particle=ParticleManager:CreateParticle("particles/a16t/a16t.vpcf",PATTACH_POINT,caster)
	-- 	ParticleManager:SetParticleControl(particle,0,point)
	-- 	ParticleManager:SetParticleControl(particle,1,point2)
	-- 	ParticleManager:SetParticleControl(particle,3,Vector(0,i,0))
	-- end

	--A16T2( keys )
	--     7200      1000 2000 3000 4000
end

function A16E( keys )
	--[[
	O在這邊放計時器是因為節省particle的使用
	O魔免的時候，不能在KV裡面傷害單位
		要在lua裡面
	]]
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_percent = ability:GetLevelSpecialValueFor("heal_percent",ability:GetLevel()-1)
	local dmg = keys.dmg * damage_percent
	--print(dmg) --%attack_damage * %damage_percent
	--test
	-- target:Kill(nil,nil)
	caster:Heal(dmg,caster)
end


function A16R( keys )
	--[[
	O在這邊放計時器是因為節省particle的使用
	O魔免的時候，不能在KV裡面傷害單位
		要在lua裡面
	]]
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_percent = ability:GetLevelSpecialValueFor("damage_percent",ability:GetLevel()-1)
	local dmg = keys.dmg * damage_percent
	--print(dmg) --%attack_damage * %damage_percent
	--test
	-- target:Kill(nil,nil)
	AMHC:Damage( caster,target,dmg,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )

	if target.A16R == nil then
		target.A16R = true
	end

	if target.A16R == true then
		target.A16R = false
		Timers:CreateTimer(0.8,function ()
			if IsValidEntity(target) then
				target.A16R = true
			end
		end)

		local particle=ParticleManager:CreateParticle("particles/a16r3/a16r3.vpcf",PATTACH_POINT,target)
		ParticleManager:SetParticleControl(particle,0,target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle,1,Vector(1,0,0))
		ParticleManager:SetParticleControl(particle,2,target:GetAbsOrigin())

		NobuDestoryParticle (particle,1)
	end
end
