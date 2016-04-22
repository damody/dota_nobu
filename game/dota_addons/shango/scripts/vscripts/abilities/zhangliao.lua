function zhangliao_chongjibo_point(keys)
    local caster = keys.caster
    local caster_fv = caster:GetForwardVector()
    local caster_origin = caster:GetOrigin()
    
    -- 计算正负30度的两个点，还有中间那个点
    ang_right = QAngle(0, -30, 0)
    ang_left = QAngle(0, 30, 0)
    point_mid = caster_origin + caster_fv * 1200
    point_left = RotatePosition(caster_origin, ang_left, point_mid)
    point_right = RotatePosition(caster_origin, ang_right, point_mid)

    local result = { }
    table.insert(result, point_mid)
    table.insert(result, point_left)
    table.insert(result, point_right)

    return result
end
zhangliao={}

function zhangliao_02(keys)
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    zhangliao.target_origin=target:GetOrigin()
    zhangliao.target=target

    local ability2=target:FindAbilityByName("zhangliao_unit")
    if ability2:GetLevel() ~= 1 then 
        ability2:SetLevel(1)
    end 
    caster:AddAbility("zhangliao_cizhenkuijia_01")
    local ability1=caster:FindAbilityByName("zhangliao_cizhenkuijia_01")
    if ability1:GetLevel() ~= 1 then 
        ability1:SetLevel(1)
    end 
    local p_end = 'particles/units/heroes/hero_legion_commander/legion_commander_odds_hero_arrow_group.vpcf'
    local p_index = ParticleManager:CreateParticle(p_end, PATTACH_CUSTOMORIGIN, target)
    ParticleManager:SetParticleControl(p_index, 0, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(p_index)
    caster:SwapAbilities("zhangliao_cizhenkuijia","zhangliao_cizhenkuijia_01", false, true)
    zhangliao.ischange=true
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("zhangliao_02"),function() 
        if zhangliao.ischange == true then
              caster:SwapAbilities("zhangliao_cizhenkuijia_01","zhangliao_cizhenkuijia", false, true)
              zhangliao.ischange = false
              zhangliao.target_origin=nil
              caster:RemoveAbility("zhangliao_cizhenkuijia_01")
              if zhangliao.target then 
                --target:RemoveSelf()
              end
        end
        end,20)
end
function zhangliao_03(keys)
    local caster = keys.caster
    local caster_ori=caster:GetOrigin()
    local ability = keys.ability
    if zhangliao.target_origin then
         caster:SetOrigin(zhangliao.target_origin)
         FindClearSpaceForUnit(caster, zhangliao.target_origin, false)
         local p_end = 'particles/units/heroes/hero_legion_commander/legion_commander_odds_hero_arrow_group.vpcf'
         local p_index = ParticleManager:CreateParticle(p_end, PATTACH_CUSTOMORIGIN, caser)
         ParticleManager:SetParticleControl(p_index, 0, caster:GetOrigin())
         ParticleManager:ReleaseParticleIndex(p_index)
         
         local p_end1 = 'particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf'
         local p_index1 = ParticleManager:CreateParticle(p_end1, PATTACH_CUSTOMORIGIN, caser)
         ParticleManager:SetParticleControl(p_index1, 0, caster:GetOrigin())
         ParticleManager:SetParticleControl(p_index1, 1, caster_ori)
         ParticleManager:ReleaseParticleIndex(p_index1)
         zhangliao.ischange = false
         caster:SwapAbilities("zhangliao_cizhenkuijia_01","zhangliao_cizhenkuijia", false, true)
         if zhangliao.target then 
                 zhangliao.target:RemoveSelf()
                 zhangliao.target=nil
                  caster:RemoveAbility("zhangliao_cizhenkuijia_01")
        end
    end
end