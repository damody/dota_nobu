--御魂

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
        AMHC:Damage(caster,keys.target, 1,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
        if target:IsMagicImmune() then
            ability:ApplyDataDrivenModifier(caster,target,"modifier_soul_adder",{duration = 1.5})
        else
            ability:ApplyDataDrivenModifier(caster,target,"modifier_soul_adder",{duration = 3})
            Timers:CreateTimer(2.9, function() 
                if (target:HasModifier("modifier_soul_adder")) then
                    Timers:CreateTimer(0.11, function()
                        ability:ApplyDataDrivenModifier(target,target,"modifier_soul_adder2",{duration = 8})
                    end)
                end
            end)
        end
    else
        target:Stop()
        ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = 1})
        ability:ApplyDataDrivenModifier(caster,target,"modifier_soul_adderx",{duration = 4})
    end
    target:EmitSound("SleepBirth1")
end

function over( keys )
    local caster = keys.caster
    local target = keys.target
    local attacker = keys.attacker
    local unit = keys.unit
    if target then
        target:RemoveModifierByName("modifier_soul_adderx")
    end
    if unit then
        unit:RemoveModifierByName("modifier_soul_adderx")
    end
    if attacker then
        attacker:RemoveModifierByName("modifier_soul_adderx")
    end
end

function sound( keys )
    local caster = keys.caster
    local unit = keys.unit
    if keys.time then
        Timers:CreateTimer(keys.time,function()
                caster:StopSound(keys.sound)
            end)
    end
    if unit then
        unit:EmitSound(keys.sound)
    else
        caster:EmitSound(keys.sound)
    end
end

function sound_unit( keys )
    local unit = keys.unit
    if keys.time then
        Timers:CreateTimer(keys.time,function()
                unit:StopSound(keys.sound)
            end)
    end
    unit:EmitSound(keys.sound)
end
