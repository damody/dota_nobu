leidun={}
function leidun_01(keys)
    local caster=EntIndexToHScript(keys.caster_entindex)
    local k=keys.ability:GetLevel()
    leidun.abilutylvevl=k
    local per_mana =keys.ability:GetLevelSpecialValueFor("per_manaregen",k-1)
    if caster:IsAlive() then 
    	local mana=caster:GetMana()
        if mana<caster:GetMaxMana() then
    	   caster:SetMana(mana+per_mana)
    	end
	end   
end
function shandianqiu_01(keys)
	local caster=EntIndexToHScript(keys.caster_entindex)
	local k=keys.ability:GetLevel()
    leidun.abilutylvevl=k
	local point=caster:GetAbsOrigin()
	local high = Vector(0,0,320)
    point=point+high
	local unit_name ="npc_zhangbao_shandianqiu"
	local creep = CreateUnitByName(unit_name,point,false,caster,caster,caster:GetTeam())
    creep:SetAbsOrigin(point)
    FindClearSpaceForUnit(caster,point, false)
    local creepability=creep:FindAbilityByName("zhangbao_shandianqiu_dummy_01")
    if creepability then  
        creepability:SetLevel(leidun.abilutylvevl)
    end
    local p_end = 'particles/econ/items/storm_spirit/storm_spirit_orchid_hat/stormspirit_orchid_ball_sphere.vpcf'
    local p_index = ParticleManager:CreateParticle(p_end, PATTACH_CUSTOMORIGIN, creep)
    ParticleManager:SetParticleControl(p_index, 0, creep:GetOrigin())
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("shandianqiu_01"),function()
    	creep:RemoveSelf()
    end,20)
end
function shandianqiu_02(keys)
    local caster=EntIndexToHScript(keys.caster_entindex)
    local target=keys.target
    local k=keys.ability:GetLevel()
    local damage=keys.ability:GetLevelSpecialValueFor("damage",k-1)
    if target:IsMagicImmune() then 
            ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
    end
end