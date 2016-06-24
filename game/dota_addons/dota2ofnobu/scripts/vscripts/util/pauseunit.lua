
	function UnitPauseTarget( caster,target,pausetime)
		local dummy = CreateUnitByName("npc_dummy_unit", 
	    	                target:GetAbsOrigin(), 
							false, 
							caster, 
							caster, 
							caster:GetTeamNumber()
						)
		dummy:SetOwner(caster)
		dummy:AddAbility("ability_stunsystem_pause") 
		local ability = dummy:FindAbilityByName("ability_stunsystem_pause")
			
		ability:ApplyDataDrivenModifier( caster, target, "modifier_stunsystem_pause", {Duration=pausetime} )
		dummy:SetContextThink(DoUniqueString('ability_stunsystem_pause_timer'),
	    	function ()
	    			if GameRules:IsGamePaused() then return 0.03 end
	    			target:RemoveModifierByName("modifier_stunsystem_pause")
	                dummy:RemoveSelf()
		    	    return nil
		end,pausetime)
   	end