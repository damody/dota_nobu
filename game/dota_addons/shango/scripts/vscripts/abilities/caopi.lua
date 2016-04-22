require("utils/utils_print")
function caopi_touxi_01(keys)
	local caster=keys.caster 
	local ability=keys.ability 
	caster_ori=caster:GetOrigin()
	local target=FindUnitsInRadius(caster:GetTeam(), caster_ori, nil, 500, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)	
	local minlength=0
    ---------------------
    local p_end = 'particles/chezi/rattletrap_rocket_flare_launch.vpcf'
    local p_index = ParticleManager:CreateParticle(p_end, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(p_index, 0, caster:GetOrigin())
    ParticleManager:ReleaseParticleIndex(p_index)
    ---------------------
	local near_target=target[1]
	if target[1]  then
	  for _,_target in pairs(target) do
		_target_ori=_target:GetOrigin()        
        	if minlength == 0 then 
        	    minlength=(_target_ori-caster_ori):Length2D()
        	    near_target=_target
        	else 
                if (_target_ori-caster_ori):Length()<minlength then
                    minlength=(_target_ori-caster_ori):Length2D()
        	        near_target=_target
        	    end
            end
	  end
	_target_ori=(-near_target:GetForwardVector()):Normalized()
    target_ori=near_target:GetOrigin()+_target_ori*50
    caster:SetOrigin(target_ori)
    FindClearSpaceForUnit(caster, target_ori, false)
     ---------------------
    local p_end1 = 'particles/units/heroes/hero_axe/axe_counterhelix_unused2.vpcf'
    local p_index1 = ParticleManager:CreateParticle(p_end1, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(p_index1, 0, caster:GetOrigin())
    ParticleManager:ReleaseParticleIndex(p_index1)
    ---------------------
    ability:ApplyDataDrivenModifier(caster, near_target, "caopi_touxi_debuff", nil)
    local order =
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = near_target:entindex() 
	}
	ExecuteOrderFromTable( order )
  end
end
function caopi_mingxiang_01(keys)
    local caster=keys.caster
    local ability=keys.ability
    local caster_origin =caster:GetAbsOrigin()
    local order =
    {
        UnitIndex = caster:entindex(),
        OrderType = DOTA_UNIT_ORDER_STOP 
    }
    ExecuteOrderFromTable( order )

    caster:SetContextThink(DoUniqueString("caopi_01"),function()
        if caster:GetIdealSpeed() >= 500 then 
            caster:RemoveModifierByName("caopi_mingxiang_thinker")
        end
        if caster:GetAbsOrigin() ~= caster_origin then 
            if caster:HasModifier("caopi_mingxiang_thinker") then
                caster:RemoveModifierByName("caopi_mingxiang_thinker")
            end
        else 
            return 0.5
        end
    end,0.5)	
end
function caopi_beicixinde_01(keys)
	local target=keys.target 
	local caster=keys.caster
	local caster_origin=caster:GetAbsOrigin()
	local ability=keys.ability
	local target_origin=target:GetAbsOrigin()
    local point_right = target:GetAbsOrigin()+target:GetRightVector():Normalized()*200 
    local k_right     = (point_right.y-target_origin.y)/(point_right.x-target_origin.x)
    local point_forword =target:GetAbsOrigin()+target:GetForwardVector():Normalized()*200
    local k_forword   =(point_forword.y-target_origin.y)/(point_forword.x-target_origin.x)
    if (point_forword.y-target_origin.y)<(point_forword.x-target_origin.x)*k_right and (caster_origin.y-target_origin.y)>(caster_origin.x-target_origin.x)*k_right then 
       ability:ApplyDataDrivenModifier(caster, caster, "beicixinde_buff", nil)
    elseif (point_forword.y-target_origin.y)>(point_forword.x-target_origin.x)*k_right and (caster_origin.y-target_origin.y)<(caster_origin.x-target_origin.x)*k_right then
       ability:ApplyDataDrivenModifier(caster, caster, "beicixinde_buff", nil)
    end
end
caopi={}
caopi.aoyi_time=0
caopi.base_damage=0
function zhongjiaoyi_01(keys)
    caopi.aoyi_time=caopi.aoyi_time+1
end
function zhongjiaoyi_02(keys)
     local caster=keys.caster
    local ability2=caster:FindAbilityByName("caopi_zhongjiaoyi")
    local k=ability2:GetLevel()
    local base_damage=ability2:GetLevelSpecialValueFor("base_damage",k-1)
    caopi.base_damage=base_damage
    keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
   
    local origin_point = caster:GetOrigin()
    local target_point = keys.target_points[1]
    local difference_vector = target_point - origin_point 
    if difference_vector:Length() > 800 then 
        target_point = origin_point + (target_point - origin_point):Normalized() * 1000
    end
   caster:SetOrigin(target_point)
   FindClearSpaceForUnit(caster, target_point, false)
 -----------------------------
    local p_end1 = 'particles/caopi/sf_fire_arcana_shadowraze.vpcf'
    local p_index1 = ParticleManager:CreateParticle(p_end1, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(p_index1, 0, target_point)
    ParticleManager:ReleaseParticleIndex(p_index1)
  -------------------------------
      local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
      local types =DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC
      local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
     -- local group=FindUnitsInRadius(caster:GetTeam(),caster:GetOrigin(), nil, 300,teams, types,flags, 0, false)
      local group = FindUnitsInRadius(caster:GetTeam(),caster:GetOrigin(),nil, 350, teams, types, flags, FIND_CLOSEST, true)

        local _damage = base_damage+100*(caopi.aoyi_time+1)

        for i,_target in pairs(group) do                        
            ApplyDamage({ victim = _target, attacker = caster, damage = _damage, damage_type = DAMAGE_TYPE_MAGICAL})        
        end
    caopi.aoyi_time=0
    keys.caster:SwapAbilities("caopi_zhongjiaoyi_02","caopi_zhongjiaoyi", false, true)
    keys.caster:RemoveAbility("caopi_zhongjiaoyi_02") 
    caster:RemoveModifierByName("aoyi_thinker") 
end
function zhongjiaoyi_03(keys)
    -- body
    local k=keys.ability:GetLevel()
    local base_damge=keys.ability:GetLevelSpecialValueFor("base_damage",k-1)
    caopi.base_damge=base_damge
    local caster=keys.caster
    local caster_origin =caster:GetAbsOrigin()
    caster:AddAbility("caopi_zhongjiaoyi_02")
    local ability1=caster:FindAbilityByName("caopi_zhongjiaoyi_02")
    if ability1:GetLevel() ~= 1 then 
        ability1:SetLevel(1)
    end 
    caster:SwapAbilities("caopi_zhongjiaoyi","caopi_zhongjiaoyi_02", false, true)
    local order =
    {
        UnitIndex = caster:entindex(),
        OrderType = DOTA_UNIT_ORDER_STOP 
    }
    ExecuteOrderFromTable( order )
    caster:SetContextThink(DoUniqueString("caopi_05"),function()
        if caster:GetAbsOrigin() ~= caster_origin then 
            if caster:HasModifier("aoyi_thinker") then
                caopi.aoyi_time=0
               keys.caster:SwapAbilities("caopi_zhongjiaoyi_02","caopi_zhongjiaoyi", false, true)
               keys.caster:RemoveAbility("caopi_zhongjiaoyi_02")
               caster:RemoveModifierByName("aoyi_thinker") 
            end
        else 
            return 0.5
        end
    end,0.5)
end
function zhongjiaoyi_04(keys)
    -- body
    caopi.aoyi_time=0
    keys.caster:SwapAbilities("caopi_zhongjiaoyi_02","caopi_zhongjiaoyi", false, true)
    keys.caster:RemoveAbility("caopi_zhongjiaoyi_02") 
   
end
