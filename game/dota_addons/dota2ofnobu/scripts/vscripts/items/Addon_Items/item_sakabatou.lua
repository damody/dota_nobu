
function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not caster:IsIllusion() then
		local ran =  RandomInt(0, 100)
		if (caster.sakabatou_count == nil) then
			caster.sakabatou_count = 0
		end
		if (caster.sakabatou == nil) then
				caster.sakabatou = 1
					Timers:CreateTimer(0.1, function() 
						caster.sakabatou = nil
					end)
			if (ran > 11) then
				caster.sakabatou_count = caster.sakabatou_count + 1
			end
			if (caster.sakabatou_count > 10 or ran <= 11) then
				caster.sakabatou_count = 0
				StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )

				if (not(target:IsBuilding())) then
					if target:IsMagicImmune() then
						ability:ApplyDataDrivenModifier(caster,target,"modifier_sakabatou",{duration = 0.2})
					else
						ability:ApplyDataDrivenModifier(caster,target,"modifier_sakabatou",{duration = 0.8})
					end
				end
				
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
	end
end


