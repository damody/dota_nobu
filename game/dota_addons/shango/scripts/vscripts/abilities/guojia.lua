require('abilities/ability_generic')
function guojia_binhebaoliepo_01(keys) --国家特效，无其他内容
    local caster = keys.caster
    local point = keys.target_points[1]
    local caster_origin = caster:GetAbsOrigin()
    local direction =(point - caster_origin):Normalized()
    local particle ={}
    local particle1 ={}
    local effect_count = 1
    local p_time = 0
    local p_index = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf", PATTACH_CUSTOMORIGIN, caster)
    local vec = caster_origin + direction *1400
   
    ParticleManager:SetParticleControl( p_index, 0, caster_origin )
    ParticleManager:SetParticleControl( p_index, 1, vec )
    ParticleManager:SetParticleControl( p_index, 2, Vector( 3, 0, 0 ) )
    ParticleManager:SetParticleControl( p_index, 9, caster_origin )
    

    --[[caster:SetContextThink(DoUniqueString("fireeffect"),
    function()
        local p_index = ParticleManager:CreateParticle("particles/heroes/zhuge/jakiro_ice_path_shards.vpcf", PATTACH_CUSTOMORIGIN, caster)
        local vec = caster_origin + direction *(100 + 200 * effect_count)
        ParticleManager:SetParticleControl(p_index, 0, vec)

        local p_index1 = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_ice_shards_projectile_crystal.vpcf", PATTACH_CUSTOMORIGIN, caster)
        local vec1 = caster_origin + direction *(100 + 200 * effect_count)
        ParticleManager:SetParticleControl(p_index1, 3, vec1)

        particle[effect_count] = p_index
       
        
        particle1[effect_count] = p_index1
        effect_count = effect_count + 1
        
        -- 总共创建五个
        if effect_count >= 6 then 
            
            if p_time >= 1.5 then
                for i=1,6 do
                    local k = particle[i]
                    local j = particle1[i]
                    ParticleManager:DestroyParticle(k,true)  
                    ParticleManager:DestroyParticle(j,true) 
                end
               return nil 
            else 
               
                p_time=p_time+1.5
                return 1.5
            end
        else  
            return 0.05 
        end
    end ,0.1)]]
end
function guojia_binhebaoliepo_02(keys)
    local caster=keys.caster 
    local target=keys.target
    --for k,_target in pairs(target) do
        if target:IsMagicImmune() then 
            keys.ability:ApplyDataDrivenModifier(caster,target, "modifier_jidongningjie_1",nil)
        end
   -- end
end