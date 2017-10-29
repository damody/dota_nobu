LinkLuaModifier( "modifier_soul", "scripts/vscripts/library/common/dummy.lua",LUA_MODIFIER_MOTION_NONE )
modifier_soul = class({})

--------------------------------------------------------------------------------

function modifier_soul:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_soul:OnCreated( event )
  self:StartIntervalThink(0.2)
end

function modifier_soul:OnIntervalThink()
  if (self.caster ~= nil) and IsValidEntity(self.caster) then
    self.hp = self.caster:GetHealth()
  end
end

function modifier_soul:OnTakeDamage(event)
  if IsServer() then
    local attacker = event.unit
    local victim = event.attacker
    local caster = self.caster
    local return_damage = event.original_damage
    local damage_type = event.damage_type
    local damage_flags = event.damage_flags
    local ability = self:GetAbility()
    
    if (caster ~= nil) and IsValidEntity(caster) then
      if attacker == self.caster then
        if damage_type == DAMAGE_TYPE_PURE and caster:GetHealth() < 15000 then
          caster:Heal(event.damage, caster)
        end
        if damage_type == DAMAGE_TYPE_PHYSICAL and caster:GetHealth() < 5000 then
          if caster.big == nil then
            caster.big = 1
            caster:EmitSound("berserkercaster")
            Timers:CreateTimer(30, function()
              caster.big = nil
            end)
            local enemies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 2000, 
              DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
            for _,it in pairs(enemies) do
              ability:ApplyDataDrivenModifier(caster,it,"modifier_stunned",{duration = 3})
              if it:IsIllusion() then 
                it:ForceKill(true)
              end
            end
          end
          caster:Heal(event.damage, caster)
        end
      end
    end
  end
end


function top_broken( keys )
  local caster = keys.caster
  local team = caster:GetTeamNumber()
  _G.team_broken[team]["top"] = _G.team_broken[team]["top"] + 1
  if team == 2 then
    if _G.team_broken[team]["top"] == 1 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">織田軍上路騎兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    elseif _G.team_broken[team]["top"] == 2 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">織田軍上路鐵炮兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    end
  elseif team == 3 then
    if _G.team_broken[team]["top"] == 1 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">聯合軍上路騎兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    elseif _G.team_broken[team]["top"] == 2 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">聯合軍上路鐵炮兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    end
  end
end

function mid_broken( keys )
  local caster = keys.caster
  local team = caster:GetTeamNumber()
  _G.team_broken[team]["mid"] = _G.team_broken[team]["mid"] + 1
  if team == 2 then
    if _G.team_broken[team]["mid"] == 1 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">織田軍中路騎兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    elseif _G.team_broken[team]["mid"] == 2 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">織田軍中路鐵炮兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    end
  elseif team == 3 then
    if _G.team_broken[team]["mid"] == 1 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">聯合軍中路騎兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    elseif _G.team_broken[team]["mid"] == 2 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">聯合軍中路鐵炮兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    end
  end
end

function down_broken( keys )
  local caster = keys.caster
  local team = caster:GetTeamNumber()
  _G.team_broken[team]["down"] = _G.team_broken[team]["down"] + 1
  if team == 2 then
    if _G.team_broken[team]["down"] == 1 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">織田軍下路騎兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    elseif _G.team_broken[team]["down"] == 2 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">織田軍下路鐵炮兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    end
  elseif team == 3 then
    if _G.team_broken[team]["down"] == 1 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">聯合軍下路騎兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    elseif _G.team_broken[team]["down"] == 2 then
      GameRules: SendCustomMessage("<font color=\"#33cc33\">聯合軍下路鐵炮兵停止生產</font>", DOTA_TEAM_GOODGUYS + DOTA_TEAM_BADGUYS, 0)
    end
  end
end

function nodmg_courier( keys )
  local caster = keys.caster
  local ability = keys.ability
  --print(dummy:GetUnitName())

  local units = FindUnitsInRadius(caster:GetTeamNumber(),  
        caster:GetAbsOrigin(),nil,1400,DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
          DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
          FIND_ANY_ORDER, 
        false)
  for _,it in pairs(units) do
    if it:GetUnitName() == "npc_dota_courier2" then
      it:AddNewModifier(it, nil, "modifier_invulnerable", {duration = 5})
    end
  end
end

function for_move300( keys )
  local caster = keys.caster
  local ability = keys.ability
  --print(dummy:GetUnitName())

  local units = FindUnitsInRadius(caster:GetTeamNumber(),  
        caster:GetAbsOrigin(),nil,1400,DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
          DOTA_UNIT_TARGET_HERO,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
          FIND_ANY_ORDER, 
        false)
  for _,it in pairs(units) do
    ability:ApplyDataDrivenModifier( caster , it , "modifier_for_move300" , { duration = 6 } )
  end
end

function killdummy( keys )
	local dummy = keys.target
	--print(dummy:GetUnitName())
	if dummy ~= nil then
    if IsValidEntity(dummy) then
		  dummy:ForceKill(true)
    end
	end
end

_G.EXCLUDE_TARGET_NAME = {
  --npc_dota_cursed_warrior_souls = true,
  npc_dota_the_king_of_robbers  = true,
  com_general = true,
  com_general2 = true,
  com_general3 = true,
  EARTH_WALL = true,
  com_soldiercamp_Unified = true,
  com_soldiercamp_Oda = true,
  com_general_Unified2 = true,
  com_general_Nobu2 = true,
  com_general_Unified2_1 = true,
  com_general_Nobu2_1 = true,
  com_general_oda = true,
  com_general_unified = true,
  com_general2_oda = true,
  com_general2_unified = true,
  com_general3_oda = true,
  com_general3_unified = true,
  com_general2_unified = true,
  C17R_old_SUMMEND_UNIT_bag_hero = true,
  C17R_old_SUMMEND_UNIT_hero = true,
  B13_MINE_hero = true,
  A26_MINE_hero = true,
  A26_MINE_school_hero = true,
  B17W_deathGuard_hero = true,
  npc_dummy_unit = true,
  npc_dummy_unit_Ver2 = true,
  Dummy_Ver1 = true,
  Dummy_B34E = true,
  B24T_HIDE_hero = true,
  EARTH_WALL_hero = true,
  B33T_UNIT = true,
  B24W_dummy_hero = true,
  C03T_UNIT = true,
  npc_dummy_unit_new = true,
  npc_dummy = true,
  npc_dummy = true,
  hide_unit = true,
}

_G.EXCLUDE_MODIFIER_NAME = {
  modifier_C04T = true,
  modifier_C04T2 = true,
  modifier_A11E = true,
  modifier_A11E2 = true,
  modifier_C07E = true,
  modifier_C07E2 = true,
  modifier_B28E = true,
  modifier_B28E2 = true,
  modifier_voodoo_lua = true,
  modifier_B36R = true,
  modifier_A28W = true,
  modifier_A09E = true,
  modifier_weakness = true,
  modifier_C08T_bleeding = true,
  modifier_soul_adder = true,
}


function CP_Posistion( keys )
	local caster = keys.caster
	caster.origin_pos = caster:GetAbsOrigin()
	Timers:CreateTimer(1, function ()
    if not _G.mo then
      if IsValidEntity(caster) and not caster:IsIllusion() then
        local donkey = CreateUnitByName("cp_soldiercamp", caster.origin_pos, true, caster, caster, caster:GetTeamNumber())
        donkey:SetAbsOrigin(caster.origin_pos)
        donkey:AddAbility("majia_cp"):SetLevel(1)
        donkey:AddAbility("for_no_damage"):SetLevel(1)
        Timers:CreateTimer(1, function ()
        	if caster~= nil and IsValidEntity(caster) and caster:IsAlive() then
        		return 1
        	else
            Timers:CreateTimer(10, function ()
        		  donkey:ForceKill(true)
              end)
        	end
      	end)  	
        return nil
      end
    else
      if _G.EXCLUDE_TARGET_NAME[caster:GetUnitName()] == nil then
        caster:ForceKill(true)
      end
    end
  end)
	--donkey:AddAbility("majia_cp"):SetLevel(1)
end

function showTitle( keys )
  local caster = keys.caster
  local pos = caster:GetAbsOrigin()
  if keys.target_points then
    pos = keys.target_points[1]
  end
  if keys.target and keys.target ~= caster then
    pos = keys.target:GetAbsOrigin()
  end
  
  if keys.dummy then
    local dummy = CreateUnitByName("npc_dummy_unit_Ver2",caster:GetAbsOrigin() ,false,caster,caster,caster:GetTeam())
    dummy:FindAbilityByName("majia"):SetLevel(1)
    dummy:AddNewModifier(dummy,nil,"modifier_kill",{duration=5})
    local spike = ParticleManager:CreateParticle(keys.title, PATTACH_ABSORIGIN, dummy)
    ParticleManager:SetParticleControl(spike, 0, pos+Vector(0,0,300))
  else
    local spike = ParticleManager:CreateParticle(keys.title, PATTACH_OVERHEAD_FOLLOW, caster)
    ParticleManager:SetParticleControl(spike, 0, pos+Vector(0,0,300))
  end
end

function removeAbility( keys )
  local caster = keys.caster
  caster:RemoveAbility(keys.title)
end

local ok_modifier = {
  ["modifier_great_sword_of_hurricane_debuff"] = true,
  ["modifier_debuff_x"] = true,
  ["modifier_A17T"] = true,
  ["modifier_magical_1300_aura"] = true,
  ["modifier_tower_truesight_aura"] = true,
  ["modifier_tower_aura"] = true,
  ["modifier_tower_armor_bonus"] = true,
  ["modifier_great_sword_of_hurricane_debuff"] = true,
  ["modifier_1300"] = true,
  ["Passive_warrior_souls_skill"] = true,
  ["modifier_dead_give_item1"] = true,
  ["modifier_dead_give_item2"] = true,
  ["modifier_invulnerable_souls"] = true,
  ["modifier_soul"] = true,
  ["modifier_magic_immune"] = true,
  ["modifier_stunned"] = true,
  ["modifier_for_magic_immune"] = true,
}

function debuff_tower1( keys )
  local caster = keys.caster
  local ability = keys.ability
  local am = caster:FindAllModifiers()
  for _,v in pairs(am) do
    if ok_modifier[v:GetName()] == nil then
      caster:RemoveModifierByName(v:GetName())
    end
  end
end

function debuff_tower2( keys )
  local caster = keys.caster
  local ability = keys.ability
  local am = caster:FindAllModifiers()
  for _,v in pairs(am) do
    if ok_modifier[v:GetName()] == nil then
      caster:RemoveModifierByName(v:GetName())
    end
  end
  caster:AddNewModifier(caster,ability,"modifier_soul",{})
  local handle = caster:FindModifierByName("modifier_soul")
  if handle then
    handle.caster = caster
  end
end

function debuff_tower( keys )
  local caster = keys.caster
  local ability = keys.ability
  local team = caster:GetTeamNumber()
  local heros = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 1100, 
          DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 
          0, FIND_ANY_ORDER, false )
  local count = 0
  for i,v in pairs(heros) do
    if not v:IsIllusion() then
      count = count + 1
    end
  end
  if count > 2 then
    ability:ApplyDataDrivenModifier(caster,caster,"debuff_tower",{duration = 2})
    local handle = caster:FindModifierByName("debuff_tower")
    if handle then
      handle:SetStackCount(count)
    end
  end
end

local ok_unit = {
  ["B16D_SUMMEND_UNIT"] = true,
  ["B16W_old_SUMMEND_UNIT"] = true,
  ["A04W_SUMMEND_UNIT"] = true,
  ["B07W_old"] = true,
  ["A03T_old"] = true,
  ["A03W_old"] = true,
  ["B23D_ghost"] = true,
}

function buff_tower( keys )
  local caster = keys.caster
  local ability = keys.ability
  local team = caster:GetTeamNumber()
  local enemys = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 1500, 
          DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 
          0, FIND_ANY_ORDER, false )
  local counth = 0
  for i,v in pairs(enemys) do
    counth = counth + 1
  end
  local enemys = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 1000, 
          DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, 
          0, FIND_ANY_ORDER, false )
  local count = 0
  for i,v in pairs(enemys) do
    if ok_unit[v:GetUnitName()] then
      count = 1
      break
    end
    if not v:IsIllusion() and not v:GetOwner() then
      count = 1
      break
    end
  end
  if count == 0 and counth < 3 then
    ability:ApplyDataDrivenModifier(caster, caster, "buff_tower", {duration = 2})
  end
end

