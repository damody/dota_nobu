require("utils/utils_print")
function guanyu_liuyuefeizhan_01( keys) --六月飞斩，原名：五月雨斩，我也不知道怎么写成了六月，勿怪
    local caster=EntIndexToHScript(keys.caster_entindex)
    local ability=keys.ability
    local caster_ori = caster:GetAbsOrigin()
    local point =keys.target_points[1]                 --AOE中心坐标
    local distance = (caster_ori-point):Length()       --AOE中心离关羽的距离                       
    local dir=(caster_ori-point):Normalized()          --水平移动方向的单位向量
    caster:SetForwardVector(-dir)
    local k=keys.ability:GetLevel()
    local damage=keys.ability:GetLevelSpecialValueFor("damage",k-1)
    guanyu_liuyuefeizhan_move(caster,point,distance,dir,damage,ability)   --调用关羽技能动画函数
end 
function guanyu_liuyuefeizhan_move(caster,point,distance,dir,damage,ability)   --耗时0.5秒  关羽动画函数
    -- body
    --s = vt + 1/2 * a * t ^ 2
    local caster_ori = caster:GetAbsOrigin()  --关羽现在位置
    local perdistance_h = distance/30    --每次移动竖直位移
    local cont = 0                          --移动次数
    local perdistance_v   = 0               --每次水平移动位移
    local t = 0 
    local v =1500
                  --[[local p_endx = 'particles/neutral_fx/roshan_spawn.vpcf'
                  local p_indexx = ParticleManager:CreateParticle(p_endx, PATTACH_ABSORIGIN_FOLLOW, caster)
                  ParticleManager:SetParticleControl(p_indexx, 0, caster:GetOrigin())]]
  GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("fengbaozhizhang_02"),function()              
          local caster_ori = caster:GetAbsOrigin()
          
          --caster:SetAbsOrigin(caster_ori-dir*perdistance_h)
        if t <= 0.3 then 
          perdistance_v=v*0.02-1/2*3750*0.02*0.02
          v=v-3750*0.02
          caster:SetAbsOrigin(caster_ori+Vector(0,0,perdistance_v)-dir*perdistance_h)
        elseif t >= 0.53 and t < 0.55 then
                  local p_endx1 = 'particles/neutral_fx/roshan_spawn.vpcf'
                  local p_indexx1 = ParticleManager:CreateParticle(p_endx1, PATTACH_ABSORIGIN_FOLLOW, caster)
                  ParticleManager:SetParticleControl(p_indexx1, 0, caster:GetOrigin())
        elseif t>= 0.6 then
           --在落地之时添加特效，且调用伤害函数

           local p_end = 'particles/units/heroes/hero_ursa/ursa_earthshock.vpcf'
                  local p_index = ParticleManager:CreateParticle(p_end, PATTACH_CUSTOMORIGIN, caster)
                  ParticleManager:SetParticleControl(p_index, 0, caster:GetOrigin())
                  
             guanyu_liuyuefeizhan_damage(caster,damage,point,ability)
             FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
             ParticleManager:ReleaseParticleIndex(p_index)
             return nil
        else
          perdistance_v=v*0.02+1/2*3750*0.02*0.02
          v=v+3750*0.02
          caster:SetAbsOrigin(caster_ori-Vector(0,0,perdistance_v)-dir*perdistance_h)
        end
          t=t+0.02
          return 0.02
      end,0)
end
function guanyu_liuyuefeizhan_damage(caster,damage,point,ability) --关羽五月雨斩伤害函数
    -- body
    local target=FindUnitsInRadius(caster:GetTeam(), point, nil, 300, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    local caster_now=caster:GetAbsOrigin()     
    if target[1] then 
      for _,_target in pairs(target) do
     local target_now =_target:GetAbsOrigin()
     local _distance = (caster_now-target_now):Length() 
     local _damage = damage*(1-_distance/300)   --距离AOE中心距离越近伤害越高
           ApplyDamage(
                                                { victim = _target, 
                                                    attacker = caster, 
                                                    damage = _damage, 
                                                    damage_type = DAMAGE_TYPE_PHYSICAL 
                                                }
                         )

           
      end
     end
      if caster:HasModifier("guanyu_liuyuefeizhan_wudi")  then 
          caster:RemoveModifierByName("guanyu_liuyuefeizhan_wudi")   --移除关羽移动过程中的无敌、不可控状态
      end
end
function guanyu_liuyuefeizhan_02(keys)
    local caster=keys.caster
    local target=keys.target 
    local ability = caster:FindAbilityByName("guanyu_jianshengfengbao")
    local k=ability:GetLevel()
    local damage=ability:GetLevelSpecialValueFor("damage",k-1)
      local per_damage=damage*0.3
      local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
      local types = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_MECHANICAL+DOTA_UNIT_TARGET_OTHER
      local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
      local rad   = 250 
      local group = FindUnitsInRadius(caster:GetTeam(),caster:GetOrigin(),nil, rad, teams, types, flags, FIND_CLOSEST, true)
      if group ~= nil then 
        for i,unit in pairs(group) do
          if unit ~= nil then 
            if unit:IsMagicImmune() and unit:IsHero() then 
                ApplyDamage({ victim = unit, attacker = caster, damage = per_damage, damage_type = DAMAGE_TYPE_PHYSICAL})
            end 
          end
        end
      end    
end

