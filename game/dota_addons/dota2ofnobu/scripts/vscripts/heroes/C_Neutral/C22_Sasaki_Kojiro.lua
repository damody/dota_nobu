	bj_PI                            = 3.14159
	bj_RADTODEG                      = 180.0/bj_PI
	bj_DEGTORAD                      = bj_PI/180.0
--ednglobal


function C22W_Damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()

	-- Finds all the enemies in a radius around the target and then deals damage to each of them
    --獲取攻擊範圍
    local group = {}
    local radius = 435

    --獲取周圍的單位
    group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)

	for _,v in ipairs(group) do
		----print(v:GetUnitName())
		if v:IsMagicImmune() then --是否魔免(如果是加深傷害)
			AMHC:Damage( caster,v,damage,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
			----print("YES")
		else
			AMHC:Damage( caster,v,damage,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end

function C22E_Succes_Hit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--print(caster:GetUnitName())
	--print(target:GetUnitName())
	caster.C22E_Target = target
end

function C22E_Start( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--print(caster:GetUnitName())
	--print(target:GetUnitName())
	caster.C22E_Target = nil
end

function C22R_SE( keys )
	local caster = keys.caster
	local target = keys.target

	--AMHC:CreateParticle(particleName,PATTACH_CUSTOMORIGIN,false,caster,3,nil)
	local particle = ParticleManager:CreateParticle("particles/c20r2/c20r2.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_sword", Vector(0,0,0), true)
	--ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 1, target, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_sword", caster:GetAbsOrigin()+Vector(1000,1000), true)
end

function C22R__ATTACK_SE( keys )
	local caster = keys.caster
	local rate = caster:GetAttackSpeed()/2
	--print(tostring(rate))

	--播放動畫
    caster:StartGesture( ACT_DOTA_ECHO_SLAM )
    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
end

function C22D_GetAbility( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("C22R")
	if ability:GetLevel() >0 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_C22R", {duration = 4.0})
	end
	if caster.C22E_Target ~= nil then
		if caster.C22E_Target:FindModifierByName("modifier_C22E") ~= nil then
			local target = caster.C22E_Target
			point = caster:GetAbsOrigin()
			local  x = point.x
			local  y = point.y
			point2 = target:GetAbsOrigin()
			local  x2 	  = point2.x
			local  y2     = point2.y
			local  a      = caster:GetAngles().y --bj_RADTODEG *math.atan2(y2-y,x2-x) 
			point3 = Vector(x+100*math.cos(a*bj_DEGTORAD) ,  y+100*math.sin(a*bj_DEGTORAD), point.z)--需要Z軸 要不然會低於地圖
			target:SetOrigin(point3)			
			caster.C22E_Target:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})

			--debug
			caster.C22E_Target = nil
		end
	end

	--SE
	if caster.c20D_SE == nil then
		caster.c20D_SE = ParticleManager:CreateParticle("particles/c20d3/c20d3.vpcf", PATTACH_POINT_FOLLOW, caster)
		local particle = caster.c20D_SE
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hand", Vector(0,0,0), true)
	end
	--播放動畫
    caster:StartGesture( ACT_DOTA_ATTACK )
    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,2.5)
end

function C22D_SE_END( keys )
	local caster = keys.caster
	ParticleManager:DestroyParticle(caster.c20D_SE,false)
	caster.c20D_SE = nil
end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Hide caster's model.
]]
function HideCaster( event )
	event.caster:AddNoDraw()
end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Show caster's model.
]]
function ShowCaster( event )
	event.caster:RemoveNoDraw()
end

--[[
	Author: Ractidous
	Date: 13.02.2015.
	Stop a sound on the target unit.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.target )
end

function C22T_Damage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local abilitylevel = ability:GetLevel()

	-- Finds all the enemies in a radius around the target and then deals damage to each of them
    --獲取攻擊範圍
    local group = {}
    local radius = 750

    --獲取周圍的單位
    group = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), 0, false)

	for _,v in ipairs(group) do
		local damage = 500 + 0.28*v:GetHealth()
		AMHC:Damage( caster,v,damage,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		ability:ApplyDataDrivenModifier(caster,v,"modifier_C22T",nil)
	end

	local particle = ParticleManager:CreateParticle("particles/c20t2/c20t2.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
	local particle = ParticleManager:CreateParticle("particles/c20t2/c20t2.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
	local particle = ParticleManager:CreateParticle("particles/c20t2/c20t2.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
end