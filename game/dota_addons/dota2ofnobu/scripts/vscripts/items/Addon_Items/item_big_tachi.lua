LinkLuaModifier( "big_tachi", "items/Addon_Items/item_big_tachi.lua",LUA_MODIFIER_MOTION_NONE )
--野太刀


big_tachi = class({})

function big_tachi:IsHidden()
	return true
end

function big_tachi:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function big_tachi:GetModifierPreAttack_CriticalStrike()
	return 200
end

function big_tachi:CheckState()
	local state = {
	}
	return state
end



function Shock( keys )
	local caster = keys.caster
	local skill = keys.ability
	local ran =  RandomInt(0, 100)
	caster:RemoveModifierByName("big_tachi")

	if (caster.big_tachi_count == nil) then
		caster.big_tachi_count = 0
	end
	if (ran > 20) then
		caster.big_tachi_count = caster.big_tachi_count + 1
	end
	if (caster.big_tachi_count > 5 or ran <= 20) then
		caster.big_tachi_count = 0
		StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
		local rate = caster:GetAttackSpeed()
		caster:AddNewModifier(caster, skill, "big_tachi", { duration = rate+0.1 } )
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


