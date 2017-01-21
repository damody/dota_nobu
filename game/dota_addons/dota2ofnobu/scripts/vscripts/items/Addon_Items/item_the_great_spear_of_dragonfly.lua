
function Shock( keys )
	local caster = keys.caster
	if not caster:IsIllusion() then
		local target = keys.target
		local skill = keys.ability
		local ran =  RandomInt(0, 100)
		if (caster.great_spear_of_dragonfly_count == nil) then
			caster.great_spear_of_dragonfly_count = 0
		end
		
		if (ran > 20) then
			caster.great_spear_of_dragonfly_count = caster.great_spear_of_dragonfly_count + 1
		end
		if (caster.great_spear_of_dragonfly_count > 5 or ran <= 20) then
			caster.great_spear_of_dragonfly_count = 0
			if (caster.great_spear_of_dragonfly == nil) then
				caster.great_spear_of_dragonfly = 1
				Timers:CreateTimer(0.1, function() 
						caster.great_spear_of_dragonfly = nil
					end)
				StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
				local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		                              target:GetAbsOrigin(),
		                              nil,
		                              250,
		                              DOTA_UNIT_TARGET_TEAM_ENEMY,
		                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		                              DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		                              FIND_ANY_ORDER,
		                              false)

				--effect:傷害+暈眩
				for _,it in pairs(direUnits) do
					if (not(it:IsBuilding())) then
						local flame = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_flames.vpcf", PATTACH_OVERHEAD_FOLLOW, it)
						Timers:CreateTimer(0.3, function ()
							ParticleManager:DestroyParticle(flame, false)
						end)
						AMHC:Damage(caster,it,300,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
					end
				end
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
	end
end


