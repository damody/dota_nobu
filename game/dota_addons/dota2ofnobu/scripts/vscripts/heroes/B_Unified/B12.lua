
--point = keys.target_points[1]
function B12W_OnSpellStart( keys )
	local point = keys.target_points[1]
	local ability=keys.ability
	local caster = keys.caster            
	local particle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_trigger_ground_symbol_add.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, point)
	Timers:CreateTimer(2, function()
		ParticleManager:DestroyParticle(particle,true)
		return nil
    	end)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1,1)
end



function B12W_DelayedAction( keys )
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local particle = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_manavoid_ti_5.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, point)
   	local group = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, 
   		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
   	keys.caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
	for i,v in ipairs(group) do
		if (keys.caster:GetAbsOrigin() - point):Length2D() < 5500 then
			if v:GetTeamNumber() ~= caster:GetTeamNumber() then
				AMHC:Damage( caster,v,ability:GetAbilityDamage(),AMHC:DamageType("DAMAGE_TYPE_MAGICAL") )
			end
			v:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
			if not string.match(v:GetUnitName(), "com_general") and v~= caster and v:GetTeamNumber()~=4 and not (v:GetTeamNumber()==caster:GetTeamNumber() and v:IsCreature()) then
				v:SetAbsOrigin(caster:GetAbsOrigin())
				local damageTable = {victim=v,   
					attacker=caster,         
					damage=ability:GetAbilityDamage(),
					damage_type=ability:GetAbilityDamageType()}
				if(v:GetTeamNumber()~=caster:GetTeamNumber()) then
					ApplyDamage(damageTable)   
				end
			end
		end
	end	
end

function B12E_OnSpellStart( keys )
	local target = keys.target
	local ability = keys.ability
	local caster = keys.caster
	local health_recover = ability:GetLevelSpecialValueFor("health_recover_and_damage",ability:GetLevel()-1)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start_fallback_mid.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())

	if(target:GetTeamNumber()==caster:GetTeamNumber()) then
		target:Heal(health_recover,caster)
	else
		if not target:IsMagicImmune() then
			AMHC:Damage(caster,target, health_recover,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end


function modifier_B12R_onattack_OnAttackLanded( event )
	local target = event.target
	--print(target:GetMagicalArmorValue())
	--print(event.caster:GetMagicalArmorValue())
	--print(100-target:GetMagicalArmorValue())
	if not target:IsBuilding() then
		local ability = event.ability
		local caster =ability:GetCaster()
		local damageTable = {victim=target,   
			attacker=caster,         
			damage=ability:GetSpecialValueFor("damage")/100*caster:GetIntellect(),
			damage_type=ability:GetAbilityDamageType()}
			if target:IsMagicImmune() then
				damageTable.damage=damageTable.damage*0.5
				ApplyDamage(damageTable)
			else
				ApplyDamage(damageTable)
			end
	end
end
