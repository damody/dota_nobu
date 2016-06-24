
function UnitMagicImmune( caster,target,duration)
	if (target == nil) then
		return
	end
	target:AddNewModifier(caster,nil,"modifier_magic_immune",{duration=duration})
	-- --创建马甲单位
 --    local dummy = CreateUnitByName("npc_dummy_unit", 
 --    	                            target:GetAbsOrigin(), 
	-- 								false, 
	-- 								caster, 
	-- 								caster, 
	-- 								caster:GetTeamNumber()
	-- 								)
 -- 	dummy:SetOwner(caster)
	-- dummy:AddAbility("ability_system_magicImmune") 
	-- --寻找单位释放技能
	-- local BUFF_TARGET = dummy:FindAbilityByName("ability_system_magicImmune")
	
 --    dummy:CastAbilityOnTarget(target, BUFF_TARGET, 0 )
	-- target:SetContextThink(DoUniqueString('ability_system_magicImmune'),
	-- function ()
	-- 		if GameRules:IsGamePaused() then return 0.03 end
	--         target:RemoveModifierByName("modifier_system_magicImmune")
 --    	    return nil
	-- end,duration)
	-- dummy:SetContextThink(DoUniqueString('ability_system_magicImmune_dummy'),
	-- function ()
	-- 		if GameRules:IsGamePaused() then return 0.03 end
	--         dummy:RemoveSelf()
 --    	    return nil
	-- end,duration)
end