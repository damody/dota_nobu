
--[[
	Author: kritth
	Date: 7.1.2015.
	Refresh cooldown
]]
function rearm_refresh_cooldown( keys )
	local caster = keys.caster

	local particle = ParticleManager:CreateParticle( "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/cm_arcana_pup_lvlup_godray.vpcf", PATTACH_POINT, caster )
	ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 1, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 2, caster:GetAbsOrigin() )
	ParticleManager:SetParticleControl( particle, 3, caster:GetAbsOrigin() )
	-- Timers:CreateTimer( 0.5, function()
	-- 		ParticleManager:DestroyParticle(particle,false)
	-- 	end)
	
	-- Reset cooldown for abilities that is not rearm
	for i = 0, caster:GetAbilityCount() - 1 do
		local ability = caster:GetAbilityByIndex( i )
		if ability and ability ~= keys.ability then
			ability:EndCooldown()
		end
	end
	
	-- Put item exemption in here
	local exempt_table = {}
	
	-- Reset cooldown for items
	for i = 0, 5 do
		local item = caster:GetItemInSlot( i )
		if item and not exempt_table[ item:GetAbilityName() ] then
			item:EndCooldown()
		end
	end
end

function A34D_20_OnAbilityExecuted( keys )
	-- 開關型技能不能用
	if keys.event_ability:IsToggle() then return end
	local caster = keys.caster
	local ability = keys.ability
	local skill = "WERT"
	for si=1,#skill do
      local handle = caster:FindAbilityByName("A34"..skill:sub(si,si).."_20")
      if handle then
			if not handle:IsCooldownReady() then
				local t = handle:GetCooldownTimeRemaining()
				handle:EndCooldown()
				handle:StartCooldown(t-1)
			end
		end
    end
end


function A34W_20_OnProjectileHitUnit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local abilityLevel = ability:GetLevel()
	local duration = ability:GetSpecialValueFor("duration")
	if not target:IsHero() then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_frost_bite_root_datadriven", {duration = duration+1.5} )
	else
		ability:ApplyDataDrivenModifier( caster, target, "modifier_frost_bite_root_datadriven", {duration = duration} )
	end
end