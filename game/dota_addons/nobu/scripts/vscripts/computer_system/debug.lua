function Debug_UnitAttackAnimation( keys )
	local caster = keys.caster
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