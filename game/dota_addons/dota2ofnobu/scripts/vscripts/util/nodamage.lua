
	function UnitNoDamageTarget( caster,target,nodamagetime)
		if (target:GetContext("ability_system_nodamagetime_duration")==nil) then
			target:SetContextNum("ability_system_nodamagetime_duration",0,0)
		end
		local old_stun_duration = target:GetContext("ability_system_nodamagetime_duration")
		local stun_duration = old_stun_duration + nodamagetime
		target:SetContextNum("ability_system_nodamagetime_duration",stun_duration,0)
		if(old_stun_duration==0)then
			--创建马甲单位
			local dummy = CreateUnitByName("npc_dummy_unit", 
	    	                            target:GetAbsOrigin(), 
										false, 
									    caster, 
										caster, 
										caster:GetTeamNumber()
										)
			dummy:SetOwner(caster)
			dummy:AddAbility("ability_system_nodamage") 
			--寻找单位释放技能
			local STUN_TARGET = dummy:FindAbilityByName("ability_system_nodamage")
			
			dummy:CastAbilityOnTarget(target, STUN_TARGET, 0 )
			target:SetContextThink('ability_system_nodamage',
				function ()
					if GameRules:IsGamePaused() then return 0.03 end
					local systemStunDuration = target:GetContext("ability_system_nodamagetime_duration")
					if(systemStunDuration>0)then
						systemStunDuration = systemStunDuration - 0.1
						target:SetContextNum("ability_system_nodamagetime_duration",systemStunDuration,0)
						return 0.1
					end
					target:SetContextNum("ability_system_nodamagetime_duration",0,0)
					target:RemoveModifierByName("modifier_system_nodamage")
					dummy:RemoveSelf()
					return nil
				end,0.1)
		end
    end