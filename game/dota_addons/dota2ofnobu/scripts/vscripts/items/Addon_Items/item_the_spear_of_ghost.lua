function OnEquip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == nil) then
		caster.nobuorb1 = "item_the_spear_of_ghost"
	end
end

function OnUnequip( keys )
	local caster = keys.caster
	if (caster.nobuorb1 == "item_the_spear_of_ghost") then
		caster.nobuorb1 = nil
	end
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if (string.match(itemName,"scream_of_spiders")) then
				caster.nobuorb1 = "item_the_spear_of_ghost"
				break
			end
		end
	end
end

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local skill = keys.ability

	if (caster.nobuorb1 == "item_the_spear_of_ghost" or caster.nobuorb1 == nil) and not target:IsBuilding() and caster.gospear_of_ghost == nil then
		caster.nobuorb1 = "item_the_spear_of_ghost"
		caster.gospear_of_ghost = 1
		print("item_the_spear_of_ghost")
		Timers:CreateTimer(0.1, function() 
				caster.gospear_of_ghost = nil
			end)
		local ran =  RandomInt(0, 100)
		if (caster.spear_of_ghost == nil) then
			caster.spear_of_ghost = 0
		end
		if (ran > keys.Chance) then
			caster.spear_of_ghost = caster.spear_of_ghost + 1
		end
		if (caster.spear_of_ghost > (100/keys.Chance)+1 or ran <= keys.Chance) then

			caster.spear_of_ghost = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			if (keys.target.spear_of_ghost == nil) then
				keys.target.spear_of_ghost = 1
				Timers:CreateTimer(0.1, function() 
						keys.target.spear_of_ghost = nil
					end)
				local dmg = keys.target:GetHealth() * keys.Percent / 100
				if dmg < keys.MinDmg then
					dmg = keys.MinDmg
				end
				if not keys.target:IsMagicImmune() then
					AMHC:Damage(caster,keys.target, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
					AMHC:CreateNumberEffect(keys.target,dmg,1,AMHC.MSG_DAMAGE,'blue')
				else
					AMHC:Damage(caster,keys.target, dmg*1.5,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
					AMHC:CreateNumberEffect(keys.target,dmg*1.5,1,AMHC.MSG_DAMAGE,{255,100,100})
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

