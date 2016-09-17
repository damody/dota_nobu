LinkLuaModifier( "kousetsusamonnji", "items/Addon_Items/item_kousetsusamonnji.lua",LUA_MODIFIER_MOTION_NONE )
--長船


kousetsusamonnji = class({})

function kousetsusamonnji:IsHidden()
	return true
end

function kousetsusamonnji:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function kousetsusamonnji:GetModifierPreAttack_CriticalStrike()
	return 200
end

function kousetsusamonnji:CheckState()
	local state = {
	}
	return state
end



function Shock( keys )
	local caster = keys.caster
	local skill = keys.ability
	local ran =  RandomInt(0, 100)
	if (caster.kousetsusamonnji_count == nil) then
		caster.kousetsusamonnji_count = 0
	end
	if (ran > 36) then
		caster.kousetsusamonnji_count = caster.kousetsusamonnji_count + 1
	end
	if (caster.kousetsusamonnji_count > 3 or ran <= 36) then
		caster.kousetsusamonnji_count = 0
		StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
		caster:AddNewModifier(caster, skill, "kousetsusamonnji", { duration = 0.1 } )
		--SE
		-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur_impact.vpcf", PATTACH_POINT, keys.target)
		-- ParticleManager:SetParticleControlEnt(particle, 0, keys.target, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
		--動作
		local rate = caster:GetAttackSpeed()
		--print(tostring(rate))

		--播放動畫
	    --caster:StartGesture( ACT_SLAM_TRIPMINE_ATTACH )
		if rate < 1.00 then
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1.00)
		else
		    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
		end

	end

end


