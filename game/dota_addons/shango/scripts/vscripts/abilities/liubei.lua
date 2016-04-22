require('Utils/Utils')
function liubei_shengguangshu_01(keys)
    local target=keys.target 
    local caster=keys.caster
    local team = target:GetTeam()
    local team_caster=caster:GetTeam()
    local k=keys.ability:GetLevel()
    local _damage=keys.ability:GetLevelSpecialValueFor("damage",k-1)

    if team == team_caster then 
    	target:Heal(_damage,target)
	else 
		ApplyDamage({victim = target, attacker = caster, damage = _damage/2, damage_type = DAMAGE_TYPE_PURE})
    end
     local p_end = 'particles/units/heroes/hero_abaddon/abaddon_death_coil_explosion.vpcf'
    local p_inde = ParticleManager:CreateParticle(p_end, PATTACH_CUSTOMORIGIN, target)
    ParticleManager:SetParticleControl(p_inde, 0, target:GetOrigin())
end
function liubei_zhandoumingling_01(keys)
	local caster=keys.caster 
    local caster_abs=caster:GetOrigin()
    local face=caster:GetForwardVector() 
    local distance = 600
    Knockback( caster,caster_abs-face*300,0.15,distance,0,true,function()       
        caster:Stop()
    end )
    CustomCreateParticle("particles/jugg_ghost.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0.15,false,nil)
            local particle = CustomCreateParticle("particles/jugg_chop.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster,0.7,false,nil)
            ParticleManager:SetParticleControl(particle,2,caster_abs)
            ParticleManager:SetParticleControl(particle,3,caster_abs+face*300)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("erettttweee"),
        function( )
           if caster:HasModifier("liubei_zhandoumingling_state") then 
               caster:RemoveModifierByName("liubei_zhandoumingling_state")
           end 
           if caster:HasModifier("liubei_zhandoumingling_aura") then 
               caster:RemoveModifierByName("liubei_zhandoumingling_aura")
           end
        end,0.3)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("123_132"),
        function( )
            if caster:HasModifier("liubei_zhandoumingling_effect") then 
               caster:RemoveModifierByName("liubei_zhandoumingling_effect")
            end
        end,3)

end
function liubei_hujia_01(keys)
    local caster=keys.caster 
    local target=keys.target 
    local caster_origin=caster:GetOrigin()
    if caster ~= target then 
        FindClearSpaceForUnit(target, caster_origin, false)
        target:Stop()
    end     
end
function liubei_zhanyi_01(keys)
    -- body
    local caster=keys.caster 
    local p_end = 'particles/units/heroes/hero_dazzle/dazzle_weave.vpcf'
    local p_inde = ParticleManager:CreateParticle(p_end, PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(p_inde, 0, caster:GetOrigin())
                    
end

