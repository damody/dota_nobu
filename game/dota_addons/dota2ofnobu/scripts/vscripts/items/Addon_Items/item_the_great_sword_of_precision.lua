LinkLuaModifier( "great_sword_of_precision", "items/Addon_Items/item_the_great_sword_of_precision.lua",LUA_MODIFIER_MOTION_NONE )
--長船


great_sword_of_precision = class({})

function great_sword_of_precision:IsHidden()
	return true
end

function great_sword_of_precision:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function great_sword_of_precision:GetModifierPreAttack_CriticalStrike()
	return 300
end

function great_sword_of_precision:CheckState()
	local state = {
	}
	return state
end



function Shock( keys )
	local caster = keys.caster
	local skill = keys.ability
	local ran =  RandomInt(0, 100)
	--caster:RemoveModifierByName("great_sword_of_precision")
	if (caster.great_sword_of_precision_count == nil) then
		caster.great_sword_of_precision_count = 0
	end
	if (ran > 25) then
		caster.great_sword_of_precision_count = caster.great_sword_of_precision_count + 1
	end
	if (caster.great_sword_of_precision_count > 4 or ran <= 25) then
		caster.great_sword_of_precision_count = 0
		StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
		local rate = caster:GetAttackSpeed()
		caster:AddNewModifier(caster, skill, "great_sword_of_precision", { duration = 0.1 } )
		--SE
		-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur_impact.vpcf", PATTACH_POINT, keys.target)
		-- ParticleManager:SetParticleControlEnt(particle, 0, keys.target, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
		--動作
		local rate = caster:GetAttackSpeed()
		--print(tostring(rate))

		--播放動畫
	    --caster:StartGesture( ACT_SLAM_TRIPMINE_ATTACH )
		if rate < 1 then
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
		else
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end

	end

end


