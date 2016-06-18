
function GameRules.Nobu:PickHero( keys )
  local id       = keys.player  
  local p        = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家
  local hero     = p: GetAssignedHero() 
  local point    = hero:GetAbsOrigin()
  local owner = hero:GetPlayerOwner()

  --【英雄名稱判別】
  local name = hero:GetUnitName()
  if name == "npc_dota_hero_ancient_apparition"  then
    local ability = hero:FindAbilityByName("A04D")
    ability:SetLevel(1)
  elseif name == "npc_dota_hero_jakiro"  then
    hero:FindAbilityByName("C22D"):SetLevel(1)
  elseif name == "npc_dota_hero_templar_assassin"  then
    hero:FindAbilityByName("C19D"):SetLevel(1) 
  elseif name == "npc_dota_hero_storm_spirit"  then
    hero:FindAbilityByName("A12D_HIDE"):SetLevel(1)    
  elseif name ==  "npc_dota_hero_silencer"  then
    hero:FindAbilityByName("C07D"):SetLevel(1) 
  elseif name ==  "npc_dota_hero_windrunner"  then
    hero:FindAbilityByName("C17D"):SetLevel(1)     
  elseif name ==  "npc_dota_hero_faceless_void"  then--風魔
    hero:FindAbilityByName("B02D"):SetLevel(1)      
  end  
  --【英雄名稱判別】

  --【英雄系統】
    --<<事件:任一單位施放技能>>
    --hero:AddAbility("EventForUnitSpellAbility"):SetLevel(1)
    --<<事件:命令事件>>
    --hero:AddAbility("EventForOrder"):SetLevel(1)
    --<<全能力點數>>
    hero:AddAbility("attribute_bonus_Data")
    
  --【英雄系統】

  --【御守系統】
  hero.yushou = false 

  --【test】
    --物品
  item = CreateItem("item_blink_datadriven",nil,nil)
  CreateItemOnPositionSync(point, item)

  item = CreateItem("item_invis_sword",nil,nil)
  CreateItemOnPositionSync(point, item)

  CreateItemOnPositionSync(point, CreateItem("item_D09",nil,nil))
  CreateItemOnPositionSync(point, CreateItem("item_D0"..2,nil,nil))
  CreateItemOnPositionSync(point, CreateItem("item_S01",nil,nil))


  --print(bj_CELLWIDTH)



 -- CreateItemOnPositionSync(point, CreateItem("item_test",nil,nil))
  -- item = CreateItem("item_sphere",nil,nil)
  -- CreateItemOnPositionSync(point, item)

  -- item = CreateItem("item_manta_datadriven",nil,nil)
  -- CreateItemOnPositionSync(point, item)

  --debug
  --GameRules: SendCustomMessage("Hello World",DOTA_TEAM_GOODGUYS,0)

  --金錢
  PlayerResource:SetGold(id-1,99999,false)--玩家ID需要減一

  --等級
  for i=1,25 do
    hero.HeroLevelUp(hero,true)
  end

  --刪除建築物無敵
  local allBuildings = Entities:FindAllByClassname('npc_dota_building')
  for i = 1, #allBuildings, 1 do
     local building = allBuildings[i]
     if building:HasModifier('modifier_invulnerable') then
        building:RemoveModifierByName('modifier_invulnerable')
     end
  end





end
