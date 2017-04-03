--池田鬼神丸國重．銘刀
function OnEquip(keys)
    local caster = keys.caster
    caster.great_sword_of_disease = 1
    Timers:CreateTimer(0, function ()
            local group = FindUnitsInRadius(caster:GetTeamNumber(),
                              caster:GetAbsOrigin(),
                              nil,
                              800,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_BASIC,
                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                              FIND_ANY_ORDER,
                              false)
            for _,it in pairs(group) do
                keys.ability:ApplyDataDrivenModifier(it, it,"modifier_great_sword_of_disease", {duration=3})
            end
            if caster.great_sword_of_disease == 1 then
                return 1
            else
                return nil
            end
        end)
end

function OnUnequip(keys)
    keys.caster.great_sword_of_disease = nil
end

function Death(keys)
    keys.caster:ForceKill(false)
end

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
  local monster = CreateUnitByName("great_sword_of_disease_unit",caster:GetAbsOrigin() ,false,caster,caster,caster:GetTeamNumber())
  monster:SetControllableByPlayer(caster:GetPlayerID(),false)
  monster:AddNewModifier(monster,ability,"modifier_phased",{duration=0.1})
  ability:ApplyDataDrivenModifier(monster, monster,"modifier_dead", {duration=60})
  caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
end

function getmana( keys )
    --【Basic】
    local caster = keys.caster
    local ability = keys.ability
    local level = ability:GetLevel() - 1
    local spe_value = 17
    local target = keys.target
    --【扣魔】
    chaos_effect = ParticleManager:CreateParticle("particles/econ/items/phantom_lancer/phantom_lancer_immortal_ti6/phantom_lancer_immortal_ti6_spiritlance_cast_flash.vpcf", PATTACH_ABSORIGIN, keys.caster)
    Timers:CreateTimer(1, function ()
            ParticleManager:DestroyParticle(chaos_effect, true)
        end)
    target:SetMana(target:GetMana()-150)
    AMHC:Damage(caster, target, 200, AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
    caster:SetMana(caster:GetMana()+150)
end


function attackgo( keys )
    --【Basic】
    local caster = keys.caster
    local ability = keys.ability
    local level = ability:GetLevel() - 1
    local spe_value = 17
    local target = keys.target
    --【扣魔】
    if caster:GetMana() < spe_value then

    else
        caster:SetMana(caster:GetMana() - spe_value)
        local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                                  target:GetAbsOrigin(),
                                  nil,
                                  300,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)

        for _,it in pairs(direUnits) do
          AMHC:Damage(caster,it,320,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
        end
    end
end

function Sick(keys)
    local target = keys.target
    local dmg = 50
    if target:GetHealth() > dmg then
        target:SetHealth(target:GetHealth()-dmg)
    else
        target:SetHealth(1)
    end
end

function ToSick(keys)
    local caster = keys.caster
    local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  500,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                  FIND_ANY_ORDER,
                                  false)

    --effect:傷害+暈眩
    for _,it in pairs(direUnits) do
        if (not(it:IsBuilding())) then
            keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_great_sword_of_disease_R2", {duration=20})
        end
    end
end

function make_line(keys)
    local caster = keys.caster
    local target = keys.target
    local chaos_effect1 = ParticleManager:CreateParticle("particles/radiant_fx/tower_good3_powerline.vpcf", PATTACH_ABSORIGIN, keys.caster)
    ParticleManager:SetParticleControl(chaos_effect1,0, caster:GetAbsOrigin()+Vector(0, 0, 100))
    ParticleManager:SetParticleControl(chaos_effect1,4, target:GetAbsOrigin()+Vector(0, 0, 100))
    local chaos_effect2 = ParticleManager:CreateParticle("particles/radiant_fx/tower_good3_powerline.vpcf", PATTACH_ABSORIGIN, keys.caster)
    ParticleManager:SetParticleControl(chaos_effect2,0, caster:GetAbsOrigin()+Vector(0, 0, 100))
    ParticleManager:SetParticleControl(chaos_effect2,4, target:GetAbsOrigin()+Vector(0, 0, 100))
    caster.chaos_effect1 = chaos_effect1
    caster.chaos_effect2 = chaos_effect2
end

function line_end(keys)
    local caster = keys.caster
    ParticleManager:DestroyParticle(caster.chaos_effect1, false)
    ParticleManager:DestroyParticle(caster.chaos_effect2, false)
end


function Real_OnSpellStart( keys )
  local caster = keys.caster
  local ability = keys.ability
  local point = ability:GetCursorPosition()
  local duration = ability:GetSpecialValueFor("duration")
  local radius = ability:GetSpecialValueFor("radius")
  local A11W_damage = ability:GetSpecialValueFor("damage")
  local A11W_adjustOnBuilding = ability:GetSpecialValueFor("adjustOnBuilding")

  local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
  dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=duration} )
  dummy:SetOwner( caster)
  dummy:AddAbility( "majia"):SetLevel(1)

  local time = 0.1 + duration
  local count = 0

  Timers:CreateTimer(0,function()
    count = count + 1
    if count > time then
      return nil
    end

    local ifx = ParticleManager:CreateParticle( "particles/item/diseaseonkey_king_spring_water_base.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,50))
    ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,50))
    Timers:CreateTimer(duration, function ()
      ParticleManager:DestroyParticle(ifx,true)
    end)

    StartSoundEvent("Hero_Slark.Pounce.Impact",dummy)

    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
    for _,unit in ipairs(units) do
      damageTable = {
        victim = unit,
        attacker = caster,
        ability = ability,
        damage = A11W_damage,
        damage_type = ability:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
      }
      if not caster:IsAlive() then
        damageTable.attacker = dummy
      end
      if unit:IsBuilding() then
        damageTable.damage = damageTable.damage * A11W_adjustOnBuilding
      end
      ApplyDamage(damageTable)
    end
    return 1
  end)
end


function Water_OnSpellStart( keys )
  local caster = keys.caster
  local ability = keys.ability
  local point = ability:GetCursorPosition()
  local duration = ability:GetSpecialValueFor("duration")
  local radius = ability:GetSpecialValueFor("radius")
  local A11W_damage = ability:GetSpecialValueFor("damage")
  local A11W_adjustOnBuilding = ability:GetSpecialValueFor("adjustOnBuilding")

  local dummy = CreateUnitByName( "npc_dummy_unit", point, false, nil, nil, caster:GetTeamNumber())
  dummy:AddNewModifier( dummy, nil, "modifier_kill", {duration=duration} )
  dummy:SetOwner( caster)
  dummy:AddAbility( "majia"):SetLevel(1)

  local time = 0.1 + duration
  local count = 0

  Timers:CreateTimer(0,function()
    count = count + 1
    if count > time then
      return nil
    end

    local ifx = ParticleManager:CreateParticle( "particles/a11w/a11wonkey_king_spring_water_base.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl( ifx, 0, point + Vector(0,0,50))
    ParticleManager:SetParticleControl( ifx, 3, point + Vector(0,0,50))
    Timers:CreateTimer(duration, function ()
      ParticleManager:DestroyParticle(ifx,true)
    end)

    StartSoundEvent("Hero_Slark.Pounce.Impact",dummy)

    local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
    for _,unit in ipairs(units) do
      damageTable = {
        victim = unit,
        attacker = caster,
        ability = ability,
        damage = A11W_damage,
        damage_type = ability:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
      }
      if not caster:IsAlive() then
        damageTable.attacker = dummy
      end
      if unit:IsBuilding() then
        damageTable.damage = damageTable.damage * A11W_adjustOnBuilding
      end
      ApplyDamage(damageTable)
    end
    return 1
  end)
end
