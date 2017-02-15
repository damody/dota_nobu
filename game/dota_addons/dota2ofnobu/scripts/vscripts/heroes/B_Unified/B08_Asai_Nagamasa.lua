	B08W = class({})
local mover = require('amhc_library/mover')
--global
	B08R_INT={}
--ednglobal

function B08D_Copy(u, u2)
	local  team  = u:GetTeamNumber()
	local  point = u:GetAbsOrigin()
	local  tu   = CreateUnitByName("B08D_SE",point,true,nil,nil,team)

	-- --播放動畫(透明度50%,顏色要改金),隨機播放攻擊動作	
	--tu: SetRenderColor(255,255,122)
	-- call SetUnitTimeScale(u,3)
	-- call SetUnitAnimation(u,"Attack Slam")
	-- --紀錄特效單位在群組
	tu:SetForwardVector((u2:GetAbsOrigin()-point):Normalized())
	--tu:SetPlaybackRate(3)
    --播放動畫
    local count = 0
    Timers:CreateTimer(
    	function()
    		count = count + 1
    		if (tu:IsAlive()) then
    			tu:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_1, 2 )	
    		end
    		if (count > 4) then
    			tu:ForceKill(false)
                tu:Destroy()
    			return nil
    		else
    			return 0.2
    		end
    	end)
end

function B08D_old( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level  = keys.ability:GetLevel()
	local opoint = target:GetAbsOrigin()
	local pointx = opoint.x
	local pointy = opoint.y
	local pointz = opoint.z
	local pointx2
	local pointy2
	local a	
	local maxrock = 18
	local pos={}
	local dir={}
	AddFOWViewer(DOTA_TEAM_GOODGUYS, opoint, 1000, 3.0, false)
	AddFOWViewer(DOTA_TEAM_BADGUYS, opoint, 1000, 3.0, false)
	ability:ApplyDataDrivenModifier(caster,target,"modifier_stun",{duration = 2.2})
	for i=1,maxrock do
		a	=	(	(360.0/maxrock)	*	i	)* bj_DEGTORAD
		pointx2 	=  	pointx 	+ 	700 	* 	math.cos(a)
		pointy2 	=  	pointy 	+ 	700 	*	math.sin(a)
		point = Vector(pointx2 ,pointy2 , pointz)
		local direction = (opoint - point):Normalized()
		pos[i] = point
		dir[i] = direction
		Timers:CreateTimer(0.1*i, function()
			caster:SetAbsOrigin(pos[i])
			B08D_Copy(caster, target)
			end)
		Timers:CreateTimer(0.1+0.1*i, function()
			local projectileTable =
			{
				EffectName = "particles/b08t/b08t.vpcf",
				Ability = ability,
				vSpawnOrigin = pos[i],
				vVelocity = dir[i] * 2000,
				fDistance = 1100,
				fStartRadius = 175,
				fEndRadius = 175,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = caster:GetTeamNumber(),
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				bProvidesVision = true,
				iVisionRadius = vision_radius,
				iVisionTeamNumber = caster:GetTeamNumber()
			}
			ProjectileManager:CreateLinearProjectile(projectileTable)
			end)

		--dummy:EmitSound("Creep_Siege_Dire.Destruction") 
	end
	Timers:CreateTimer(1.9, function()
			caster:SetAbsOrigin(target:GetAbsOrigin())
			caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
			end)
end

function B08E_Action( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level  = keys.ability:GetLevel()
	
	--move
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())
	if not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stun",{duration = 1.1})
	end
	if target:IsMagicImmune() then return end
	local dmg = keys.ability:GetLevelSpecialValueFor("B08E_Damage", keys.ability:GetLevel() - 1 )
	AMHC:Damage( caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )

	local current_mana = target:GetMana()
	local burn_amount = keys.ability:GetLevelSpecialValueFor( "B08E_mana", keys.ability:GetLevel() - 1 )
	local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
	local burn_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"
	local damageType = keys.ability:GetAbilityDamageType()
	
	-- Calculation
	local mana_to_burn = math.min( current_mana,  burn_amount)
	local life_time = 2.0
	local digits = string.len( math.floor( mana_to_burn ) ) + 1
	
	-- Fail check
	if target:IsMagicImmune() then
		mana_to_burn = 0
	end
	
	-- Apply effect of ability
	target:ReduceMana( mana_to_burn )
	local damageTable = {
		victim = target,
		attacker = caster,
		damage = mana_to_burn,
		damage_type = damageType
	}
	ApplyDamage( damageTable )
	
	-- Show VFX
	if mana_to_burn ~= 0 then
		local numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
		ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
	    ParticleManager:SetParticleControl( numberIndex, 2, Vector( life_time, digits, 0 ) )
		local burnIndex = ParticleManager:CreateParticle( burn_particle_name, PATTACH_ABSORIGIN, target )
		
		-- Create timer to properly destroy particles
		Timers:CreateTimer( life_time, function()
				ParticleManager:DestroyParticle( numberIndex, false )
				ParticleManager:DestroyParticle( burnIndex, false)
				return nil
			end
		)
	end
end

function B08E_Action2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level  = keys.ability:GetLevel()
	
	--move
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())
	if not target:IsMagicImmune() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stun",{duration = 0.5})
		local dmg = keys.ability:GetLevelSpecialValueFor("B08E_Damage", keys.ability:GetLevel() - 1 )
		AMHC:Damage( caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
end


function B08R_SE( event )

	-- Variables
	local target = event.caster
	local max_damage_absorb = event.ability:GetLevelSpecialValueFor("damage_absorb", event.ability:GetLevel() - 1 )
	local shield_size = 20 -- could be adjusted to model scale

	-- Reset the shield
	target.AphoticShieldRemaining = max_damage_absorb

	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.ShieldParticle = ParticleManager:CreateParticle("particles/b08r3/b08r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(target.ShieldParticle, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 5, Vector(shield_size,0,0))

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "se_1", target:GetAbsOrigin(), true)--attach_attack1
	end)

		-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.ShieldParticle1 = ParticleManager:CreateParticle("particles/b08r3/b08r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(target.ShieldParticle1, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle1, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle1, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle1, 5, Vector(shield_size,0,0))

	-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(target.ShieldParticle1, 0, target, PATTACH_POINT_FOLLOW, "se_2", target:GetAbsOrigin(), true)--attach_attack1
	end)

	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.ShieldParticle2 = ParticleManager:CreateParticle("particles/b08r3/b08r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(target.ShieldParticle2, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle2, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle2, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle2, 5, Vector(shield_size,0,0))

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(target.ShieldParticle2, 0, target, PATTACH_POINT_FOLLOW, "se_3", target:GetAbsOrigin(), true)--attach_attack1
	end)
end


-- Destroys the particle when the modifier is destroyed. Also plays the sound
function EndB08R_SEParticle( event )
	local target = event.target
	target:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
	ParticleManager:DestroyParticle(target.ShieldParticle,false)
	ParticleManager:DestroyParticle(target.ShieldParticle1,false)
	ParticleManager:DestroyParticle(target.ShieldParticle2,false)
end


function B08R_Action( keys )
	local caster = keys.caster
	local target = keys.target
	local skill  = keys.ability	
	local level  = skill:GetLevel()
	local limit_int = 3 + level

	if caster:HasModifier("modifier_B08R_buff") == false then
		skill:ApplyDataDrivenModifier(caster,caster,"modifier_B08R_buff",nil)
		local hModifier = caster:FindModifierByNameAndCaster("modifier_B08R_buff", hCaster)
		hModifier:SetStackCount(1)
		B08R_SE(keys)
	else
		local hModifier = caster:FindModifierByNameAndCaster("modifier_B08R_buff", hCaster)
		local scount = hModifier:GetStackCount()
		scount = scount + 1
		if (scount <= limit_int) then
			hModifier:SetStackCount(scount)
		end

		--可以用來更新buff
		skill:ApplyDataDrivenModifier(caster,caster,"modifier_B08R_buff",nil)
	end
end


