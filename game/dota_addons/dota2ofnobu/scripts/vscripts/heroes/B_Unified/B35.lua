function B35E_old_OnSpellStart( keys )
	local caster = keys.caster
	local center = caster:GetAbsOrigin()
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local speed = ability:GetSpecialValueFor("B35E_speed")
	local dir = (point-center):Normalized()
	-- 防呆
	if dir == Vector(0,0,0) then 
		dir = caster:GetForwardVector() 
		point = center + dir
	end
	local fake_center = center - dir
	local distance = ability:GetSpecialValueFor("B35E_distance")
	local duration = distance/speed
	-- 把自己踢過去
	local knockbackProperties = {
	    center_x = fake_center.x,
	    center_y = fake_center.y,
	    center_z = fake_center.z,
	    duration = duration,
	    knockback_duration = duration,
	    knockback_distance = distance,
	    knockback_height = 0,
	    should_stun = 0,
	}
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_knockback",knockbackProperties)

	EmitSoundOn("Hero_Clinkz.WindWalk",caster)
end


function B35E_old_OnAttackLanded( keys )
		local caster = keys.caster
		local ability = keys.ability
		local handle = caster:FindAbilityByName("B35E_old")
		if handle then
			if not handle:IsCooldownReady() then
				local t = handle:GetCooldownTimeRemaining()
				handle:EndCooldown()
				handle:StartCooldown(t-ability:GetLevel()*0.5)
			end
		end
end

function B35R_old_OnAttackStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local crit_chance = ability:GetLevelSpecialValueFor("crit_chance",ability:GetLevel()-1)
	caster:RemoveModifierByName("modifier_B35R2")
	if caster.C21R == nil then
		caster.C21R = 0
	end
	caster.C21R = caster.C21R + 1
	print("caster.C21R", caster.C21R)
	if RandomInt(1,100)<=crit_chance or caster.C21R > 9 then
		local rate = caster:GetAttackSpeed()+0.1
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_B35R2",{duration=rate})
		caster.C21R = 0
	end
end
