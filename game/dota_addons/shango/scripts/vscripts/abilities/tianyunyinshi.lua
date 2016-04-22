
function tianyunyinshi_jiasuqiang_01(keys)
	print("enter jiasuqiang")
-------------------------------------------------------------------
--墙体开始
-------------------------------------------------------------------	
	local point = keys.target_points[1]   --技能释放位置
	local qiang_width = 50   --加速墙宽度
	local qiang_length =400   --加速墙长度
	local caster=keys.caster  --施法者
	local dummy_name = "npc_dummy_qiang"
	local dummy_mid_name ="npc_dummy_qiang1"
	local caster_point =caster:GetOrigin()
    local dir1=(point-caster_point):Normalized()  --目标点到施法者的方向向量
    local point1=point+dir1*(1/2 * qiang_length)   --墙边缘位置
          point1 = RotatePosition(point,QAngle(0, -90, 0),point1)  --旋转至与英雄平行
    local point2=point+dir1*(1/2 * (-qiang_length))  --墙边缘位置
          point2 = RotatePosition(point,QAngle(0, -90, 0),point2)   --旋转至与英雄平行
    local point_1=point   --1  
    local point_2=point+dir1*80  --2
          point_2 = RotatePosition(point,QAngle(0, -90, 0),point_2)   
    local point_3=point+dir1*(-80)  --3
          point_3 = RotatePosition(point,QAngle(0, -90, 0),point_3)   
    local point_4=point+dir1*160    --4
          point_4 = RotatePosition(point,QAngle(0, -90, 0),point_4)   
    local point_5=point+dir1*(-160)  --5
          point_5 = RotatePosition(point,QAngle(0, -90, 0),point_5)   
    

    --创建马甲
    local dummy1 = CreateUnitByName(dummy_name,point1, false,nil,nil,caster:GetTeam())
    local dummy2 = CreateUnitByName(dummy_name,point2, false,nil,nil,caster:GetTeam())
    local p_mid = 'particles/neutral_fx/harpy_chain_lightning_head.vpcf'
    local p_point ='particles/units/heroes/hero_shredder/shredder_whirling_death_spin.vpcf'
    local p_dummy ='particles/units/heroes/hero_morphling/morphling_ambient_new_d.vpcf'
 -----------------------------------------------------------------------------------   
   local dummy_1 = CreateUnitByName("npc_dummy_qiang1",point_1, false,nil,nil,caster:GetTeam())
    dummy_1:AddAbility("tianyunyinshi_jiasuqiang_buff")
          dummy_1_ability=dummy_1:FindAbilityByName("tianyunyinshi_jiasuqiang_buff")
          dummy_1_ability:SetLevel(1)
   local dummy_2 = CreateUnitByName("npc_dummy_qiang1",point_2, false,nil,nil,caster:GetTeam())
    dummy_2:AddAbility("tianyunyinshi_jiasuqiang_buff")
          dummy_2_ability=dummy_1:FindAbilityByName("tianyunyinshi_jiasuqiang_buff")
          dummy_2_ability:SetLevel(1)
   local dummy_3 = CreateUnitByName("npc_dummy_qiang1",point_3,false,nil,nil,caster:GetTeam())
    dummy_3:AddAbility("tianyunyinshi_jiasuqiang_buff")
          dummy_3_ability=dummy_1:FindAbilityByName("tianyunyinshi_jiasuqiang_buff")
          dummy_3_ability:SetLevel(1)
   local dummy_4 = CreateUnitByName("npc_dummy_qiang1",point_4, false,nil,nil,caster:GetTeam())
    dummy_4:AddAbility("tianyunyinshi_jiasuqiang_buff")
          dummy_4_ability=dummy_1:FindAbilityByName("tianyunyinshi_jiasuqiang_buff")
          dummy_4_ability:SetLevel(1)
   local dummy_5 = CreateUnitByName("npc_dummy_qiang1",point_5, false,nil,nil,caster:GetTeam())
    dummy_5:AddAbility("tianyunyinshi_jiasuqiang_buff")
          dummy_5_ability=dummy_1:FindAbilityByName("tianyunyinshi_jiasuqiang_buff")
          dummy_5_ability:SetLevel(1)
-------------------------------------------------------------------------------------
    local p_index1 = ParticleManager:CreateParticle(p_point, PATTACH_CUSTOMORIGIN, dummy1)
    local p_index2 = ParticleManager:CreateParticle(p_dummy, PATTACH_CUSTOMORIGIN, dummy1)
    local p_index3 = ParticleManager:CreateParticle(p_dummy, PATTACH_CUSTOMORIGIN, dummy2)
          ParticleManager:SetParticleControl(p_index1, 0,point)
          ParticleManager:SetParticleControl(p_index2, 0,dummy1:GetOrigin())
          ParticleManager:SetParticleControl(p_index3, 0,dummy2:GetOrigin())
    dummy1:SetContextThink(DoUniqueString("___"),
    function()
          local p_index = ParticleManager:CreateParticle(p_mid, PATTACH_CUSTOMORIGIN, dummy1)
          ParticleManager:SetParticleControl(p_index, 0, dummy1:GetOrigin())
          ParticleManager:SetParticleControl(p_index, 1, dummy2:GetOrigin())
          return 0.5
    end,0)

-------------------------------------------------------------------
--墙体结束
-------------------------------------------------------------------
   GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("____002"),function()
   	  dummy1:RemoveSelf()
   	  dummy2:RemoveSelf()
   	  dummy_1:RemoveSelf()
   	  dummy_2:RemoveSelf()
   	  dummy_3:RemoveSelf()
   	  dummy_4:RemoveSelf()
   	  dummy_5:RemoveSelf()
   	  return nil 
   	end,3.5)
end
function tianyunyinshi_yinshenqiang_01(keys)
	print("enter yinshenqiang")
-------------------------------------------------------------------
--墙体开始
-------------------------------------------------------------------	
	local point = keys.target_points[1]   --技能释放位置
	local qiang_width = 50   --加速墙宽度
	local qiang_length =400   --加速墙长度
	local caster=keys.caster  --施法者
	local dummy_name = "npc_dummy_qiang"
	local dummy_mid_name ="npc_dummy_qiang1"
	local caster_point =caster:GetOrigin()
    local dir1=(point-caster_point):Normalized()  --目标点到施法者的方向向量
    local point1=point+dir1*(1/2 * qiang_length)   --墙边缘位置
          point1 = RotatePosition(point,QAngle(0, -90, 0),point1)  --旋转至与英雄平行
    local point2=point+dir1*(1/2 * (-qiang_length))  --墙边缘位置
          point2 = RotatePosition(point,QAngle(0, -90, 0),point2)   --旋转至与英雄平行
    local point_1=point   --1  
    local point_2=point+dir1*80  --2
          point_2 = RotatePosition(point,QAngle(0, -90, 0),point_2)   
    local point_3=point+dir1*(-80)  --3
          point_3 = RotatePosition(point,QAngle(0, -90, 0),point_3)   
    local point_4=point+dir1*160    --4
          point_4 = RotatePosition(point,QAngle(0, -90, 0),point_4)   
    local point_5=point+dir1*(-160)  --5
          point_5 = RotatePosition(point,QAngle(0, -90, 0),point_5)   
    

    --创建马甲
    local dummy1 = CreateUnitByName(dummy_name,point1, false,nil,nil,caster:GetTeam())
    local dummy2 = CreateUnitByName(dummy_name,point2, false,nil,nil,caster:GetTeam())
    local p_mid = 'particles/neutral_fx/harpy_chain_lightning_head.vpcf'
    local p_point ='particles/units/heroes/hero_shredder/shredder_whirling_death_spin.vpcf'
    local p_dummy ='particles/units/heroes/hero_templar_assassin/templar_assassin_meld_attack.vpcf'
 -----------------------------------------------------------------------------------   
   local dummy_1 = CreateUnitByName("npc_dummy_qiang1",point_1, false,nil,nil,caster:GetTeam())
    dummy_1:AddAbility("tianyunyinshi_yinshenqiang_buff")
          dummy_1_ability=dummy_1:FindAbilityByName("tianyunyinshi_yinshenqiang_buff")
          dummy_1_ability:SetLevel(1)
  local  dummy_2 = CreateUnitByName("npc_dummy_qiang1",point_2, false,nil,nil,caster:GetTeam())
    dummy_2:AddAbility("tianyunyinshi_yinshenqiang_buff")
          dummy_2_ability=dummy_1:FindAbilityByName("tianyunyinshi_yinshenqiang_buff")
          dummy_2_ability:SetLevel(1)
   local dummy_3 = CreateUnitByName("npc_dummy_qiang1",point_3,false,nil,nil,caster:GetTeam())
    dummy_3:AddAbility("tianyunyinshi_yinshenqiang_buff")
          dummy_3_ability=dummy_1:FindAbilityByName("tianyunyinshi_yinshenqiang_buff")
          dummy_3_ability:SetLevel(1)
   local dummy_4 = CreateUnitByName("npc_dummy_qiang1",point_4, false,nil,nil,caster:GetTeam())
    dummy_4:AddAbility("tianyunyinshi_yinshenqiang_buff")
          dummy_4_ability=dummy_1:FindAbilityByName("tianyunyinshi_yinshenqiang_buff")
          dummy_4_ability:SetLevel(1)
   local dummy_5 = CreateUnitByName("npc_dummy_qiang1",point_5, false,nil,nil,caster:GetTeam())
    dummy_5:AddAbility("tianyunyinshi_yinshenqiang_buff")
          dummy_5_ability=dummy_1:FindAbilityByName("tianyunyinshi_yinshenqiang_buff")
          dummy_5_ability:SetLevel(1)
-------------------------------------------------------------------------------------
    local p_index1 = ParticleManager:CreateParticle(p_point, PATTACH_CUSTOMORIGIN, dummy1)
    local p_index2 = ParticleManager:CreateParticle(p_dummy, PATTACH_CUSTOMORIGIN, dummy1)
    local p_index3 = ParticleManager:CreateParticle(p_dummy, PATTACH_CUSTOMORIGIN, dummy2)
          ParticleManager:SetParticleControl(p_index1, 0,point)
          ParticleManager:SetParticleControl(p_index2, 0,dummy1:GetOrigin())
          ParticleManager:SetParticleControl(p_index3, 0,dummy2:GetOrigin())
    dummy1:SetContextThink(DoUniqueString("___"),
    function()
          local p_index = ParticleManager:CreateParticle(p_mid, PATTACH_CUSTOMORIGIN, dummy1)
          ParticleManager:SetParticleControl(p_index, 0, dummy1:GetOrigin())
          ParticleManager:SetParticleControl(p_index, 1, dummy2:GetOrigin())
          return 0.5
    end,0)
-------------------------------------------------------------------
--墙体结束
-------------------------------------------------------------------
   GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("____001"),function()
   	  dummy1:RemoveSelf()
   	  dummy2:RemoveSelf()
   	  dummy_1:RemoveSelf()
   	  dummy_2:RemoveSelf()
   	  dummy_3:RemoveSelf()
   	  dummy_4:RemoveSelf()
   	  dummy_5:RemoveSelf()
   	  return nil 
   	end,4.5)
end
