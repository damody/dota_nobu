--[[
    典韦 野性战魂
    设置基础生命恢复速度提升（具体的数值需要再调整一下，我按原来的公式了）
    -- TODO，提升基础生命恢复速度百分比，应该用 MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE 即可？
    Author: XavierCHN@2015.3.18
]]
function OnDianweiUpdateYexingzhanhun(keys)
    -- 获取施法者和技能
    local caster = keys.caster
    local ability = keys.ability
    -- 计算升级之后的基础生命恢复速度
    local health_bonus = ability:GetLevelSpecialValueFor("health_bonus", ability:GetLevel() - 1)
    local health_regen_base = caster:GetBaseHealthRegen()
    local health_regen_new = health_regen_base + 0.25 * (health_bonus / 100)
    -- 赋予英雄新的基础生命恢复速度
    caster:SetBaseHealthRegen(health_regen_new)
end

function AmplifyDamageParticle( event )--典韦的特效
    local target = event.target
    local location = target:GetAbsOrigin()
    local particleName = "particles/dianweiyaohuo.vpcf"

    -- Particle. Need to wait one frame for the older particle to be destroyed
    Timers:CreateTimer(0.01, function() 
        target.AmpDamageParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(target.AmpDamageParticle, 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin(), true)
  end)
end

-- Destroys the particle when the modifier is destroyed
function EndAmplifyDamageParticle( event )
    local target = event.target
    ParticleManager:DestroyParticle(target.AmpDamageParticle,false)
end
