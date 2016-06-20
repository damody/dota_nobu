	B08W = class({})
local mover = require('amhc_library/mover')





--global
	B08R_INT={}
--ednglobal







function B08W_Action( keys )
	-- local  caster 	 = keys.caster

	-- --劍刃風暴定義
	-- local modifierData = {
	-- 	duration = 40,
	-- 	damage = 400
	-- }
	-- caster:AddNewModifier( caster, B08W, "modifier_juggernaut_blade_fury", modifierData )
end


function B08E_Action( keys )
	local caster = keys.caster
	local target = keys.target
	local level  = keys.ability:GetLevel()

	--move
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())

	-- 	--移动到目标
	-- local m = mover:create
	-- {
	--         type = 'target',
	--         unit = caster,        dest = target,
	--         speed = 999999,
	--         max_height = target:GetAbsOrigin().z,
	-- }
	-- m:run()
end


function B08R_SE( event )

	-- -- Variables
	-- local target = event.caster
	-- local max_damage_absorb = event.ability:GetLevelSpecialValueFor("damage_absorb", event.ability:GetLevel() - 1 )
	-- local shield_size = 20 -- could be adjusted to model scale

	-- -- Reset the shield
	-- target.AphoticShieldRemaining = max_damage_absorb

	-- -- Particle. Need to wait one frame for the older particle to be destroyed
	-- Timers:CreateTimer(0.01, function() 
	-- 	target.ShieldParticle = ParticleManager:CreateParticle("particles/b08r3/b08r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle, 1, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle, 2, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle, 4, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle, 5, Vector(shield_size,0,0))

	-- 	-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
	-- 	ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "se_1", target:GetAbsOrigin(), true)--attach_attack1
	-- end)

	-- 	-- Particle. Need to wait one frame for the older particle to be destroyed
	-- Timers:CreateTimer(0.01, function() 
	-- 	target.ShieldParticle1 = ParticleManager:CreateParticle("particles/b08r3/b08r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle1, 1, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle1, 2, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle1, 4, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle1, 5, Vector(shield_size,0,0))

	-- -- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
	-- 	ParticleManager:SetParticleControlEnt(target.ShieldParticle1, 0, target, PATTACH_POINT_FOLLOW, "se_2", target:GetAbsOrigin(), true)--attach_attack1
	-- end)

	-- -- Particle. Need to wait one frame for the older particle to be destroyed
	-- Timers:CreateTimer(0.01, function() 
	-- 	target.ShieldParticle2 = ParticleManager:CreateParticle("particles/b08r3/b08r3.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle2, 1, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle2, 2, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle2, 4, Vector(shield_size,0,shield_size))
	-- 	ParticleManager:SetParticleControl(target.ShieldParticle2, 5, Vector(shield_size,0,0))

	-- 	-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
	-- 	ParticleManager:SetParticleControlEnt(target.ShieldParticle2, 0, target, PATTACH_POINT_FOLLOW, "se_3", target:GetAbsOrigin(), true)--attach_attack1
	-- end)
end


-- Destroys the particle when the modifier is destroyed. Also plays the sound
function EndB08R_SEParticle( event )
	-- local target = event.target
	-- target:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
	-- ParticleManager:DestroyParticle(target.ShieldParticle,false)
	-- ParticleManager:DestroyParticle(target.ShieldParticle1,false)
	-- ParticleManager:DestroyParticle(target.ShieldParticle2,false)
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


