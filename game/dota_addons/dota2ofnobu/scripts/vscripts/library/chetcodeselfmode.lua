print("@@@ : Cheats.lua Init ")

--------------------------------------------------------------------------------
--                                    global                                  --
--------------------------------------------------------------------------------
--model_lookup["npc_dota_hero_brewmaster"] = "models/heroes/brewmaster/brewmaster.vmdl"
--------------------------------------------------------------------------------
--                                    測試                                    --
--------------------------------------------------------------------------------
if Ctest == nil then
    Ctest = class({})
    GameMode = class({})
end



function Ctest:OnHeroIngame(unit)
  local spawnedUnit = EntIndexToHScript( unit.entindex )

  RemoveWearables( spawnedUnit )
end

function Chat(keys)
  --print("@@@@ : Chat Init")
  --DeepPrintTable(keys)    --详细打印传递进来的表

--測試創造單位
--local id    = keys.player --BUG:在講話事件裡，讀取不到玩家，是整數。
local s   	   = keys.text	
local id  	   = 1 --keys.userid --BUG:會1.2的調換，不知道為甚麼
local p 	     = PlayerResource:GetPlayer(id-1)--可以用索引轉換玩家方式，來捕捉玩家
local hero 	   = p: GetAssignedHero() --获取该玩家的英雄
local point    = hero:GetAbsOrigin()

  -- if s == "error" then
  --   error("class definition missing or not a table")    
  -- end

  if s == "test" then
    local table = {}
    table["ssssssssss"] = "5"
    print(  table["ssssssssss"])
  end


  if s == "Create1" then
    for i=1,10 do
     local  u = CreateUnitByName("test",hero:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
     --u:SetOwner(p)                                         --設置u的擁有者
     u:SetControllableByPlayer(0,true)               --設置u可以被玩家0操控
     u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
    end
  end

  if s == "Create2" then
    for i=1,10 do
     local  u = CreateUnitByName("com_archer",hero:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
     --u:SetOwner(p)                                         --設置u的擁有者
     u:SetControllableByPlayer(0,true)               --設置u可以被玩家0操控
     u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
    end
  end

  if s == "mana2" then
    hero:SetMana(10)
  end

  if s == "hp100" then
    hero:SetHealth(100)
  end  

  if s == "fog" then
    AddFOWViewer( 1, Vector(0,0,0), 99999, 99999 , 99999)
  end
  if s == "add ability" then
    --
    hero:AddAbility("tinker_rearm")

    --
    local spell = hero: FindAbilityByName("tinker_rearm")
    spell:SetLevel(3)
    spell:SetActivated(true)
    hero: CastAbilityImmediately(spell,0)

  end

  if s == "GOLD" then
    PlayerResource:SetGold(id-1,99999,false)--玩家ID需要減一 
  end

  if s == "playanislam" then

      --播放動畫
    --hero:StartGesture( ACT_DOTA_ECHO_SLAM )

    hero:StartGestureWithPlaybackRate( ACT_DOTA_ECHO_SLAM, 17 )

  end  

  -- if s == "test" then

  --   -- local  u = CreateUnitByName("npc_dota_hero_magnataur",hero:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
  --   -- --u:SetOwner(p)                                         --設置u的擁有者
  --   -- u:SetControllableByPlayer(0,true)               --設置u可以被玩家0操控
  --   -- u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
  --   --等級
  --   for i=1,30 do
  --     hero.HeroLevelUp(hero,true)
  --   end

  --   -- u = CreateUnitByName("npc_dota_hero_centaur",hero:GetAbsOrigin(),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
  --   -- --u:SetOwner(p)                                         --設置u的擁有者
  --   -- u:SetControllableByPlayer(0,true)               --設置u可以被玩家0操控
  --   -- u:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
  --   -- --等級
  --   -- for i=1,30 do
  --   --   u.HeroLevelUp(u,true)
  --   -- end

  -- end
  if s == "CreatOOXX" then
     local  u = CreateUnitByName("npc_dota_hero_magnataur",Vector(0,0),true,nil,nil,DOTA_TEAM_BADGUYS)    --創建一個斧王
     --u:SetOwner(p)                                         --設置u的擁有者
     u:SetControllableByPlayer(0,true)               --設置u可以被玩家0操控

    --等級
    for i=1,25 do
      u.HeroLevelUp(u,true)
    end

  --注意：DOTA2引擎與魔獸爭霸不同，單位被創建後並不能被玩家操控，必須分配操控玩家。
  end

  if s == "SetForwardVector" then
    hero:SetForwardVector(Vector(0,0,128))
  end


  if s == "SetStashPurchasingDisabled" then
    GameRules: GetGameModeEntity():SetStashPurchasingDisabled(true)
  end

  if s == "createc19" then
    CreateUnitByName("A11_SE",hero:GetAbsOrigin(),true,nil,nil,hero:GetTeamNumber())
  end

	if s == "create2222222222" then
		u2 = CreateUnitByName("npc_jidi",Vector(0,-1200),true,nil,nil,0)
	end	

  if s == "createEnemy" then
    u2 = CreateUnitByName("A23",Vector(0,0,128),true,nil,nil,DOTA_TEAM_BADGUYS )
  end 

	if s == "change" then
	end

	if s == "show player" then
		UTIL_MessageTextAll(PlayerResource:GetPlayerName(1),255,0,0,255)
		UTIL_MessageTextAll(tostring(id),255,0,0,255)

			if p == nil then
				UTIL_MessageTextAll("nil",255,0,0,255)--BUG點:不能發nil，要"nil"要不然會崩潰
			end
	end

	if s == "create lina" then--實驗句柄獲取
	    local lina = {}
 		for n=1,5 do
        	lina[n] = CreateUnitByName("npc_dota_hero_lina",Vector(0,0),true,nil,nil,2)
        	UTIL_MessageTextAll(tostring(lina[n]:entindex()),255,0,0,255)
     	end
	end

	if s == "show class name" then--顯示句柄名子
       local name = hero: GetClassname()
       UTIL_MessageTextAll(name,0,255,0,255)--具有自動調節語言能力
	end


	if s == "create item" then
		item = CreateItem("跳戒-Test",nil,nil)
		CreateItemOnPositionSync(Vector(5,5), item)
	end

	if s == "remove item" then
		hero:RemoveItem(item)
		--item: Destroy() --無法刪除地面上的道具
	end

	if s == "spell ability" then
		-- local spell = hero: FindAbilityByName("sven_warcry_datadriven")
		-- UTIL_MessageTextAll(tostring(spell),0,255,0,255)
		-- hero: CastAbilityImmediately(spell,0)

		--another test
		local u3 = CreateUnitByName("npc_dota_hero_lion",Vector(0,0),true,nil,nil,2)
		--u3:AddAbility("sven_ability3")w
		local spell = u3: FindAbilityByName("sven_ability3")
		UTIL_MessageTextAll(tostring(spell),0,255,0,255)
		u3: CastAbilityImmediately(spell,0)--可以無視有沒有學習，直接使用技能

	end

	if s == "spell to position" then
		local spell = hero: FindAbilityByName("earthshaker_fissure")--必須要技能等級>0
		UTIL_MessageTextAll(tostring(spell),0,255,0,255)
		hero: CastAbilityOnPosition(Vector(0,0),spell,0)
	end

	if s == "spell to target" then
		local spell = hero: FindAbilityByName("lina_ability2")--必須要技能等級>0
		UTIL_MessageTextAll(tostring(spell),0,255,0,255)
		hero:CastAbilityOnTarget(u2,spell,0)
	end

	if s == "ability toggle" then
		local spell = hero: FindAbilityByName("pudge_rot")--必須要技能等級>0
		UTIL_MessageTextAll(tostring(spell),0,255,0,255)
		hero: CastAbilityToggle(spell,0)
	end

	if (s == "level up" or s == "lp") then
		for i=1,25 do
			hero.HeroLevelUp(hero,true)
		end
    UTIL_MessageTextAll(tostring(hero),0,255,0,255)
	end

  if s ==  "disassemble" then
    local item = hero: AddItemByName("item_arcane_boots")
    hero: DisassembleItem(item)
    UTIL_MessageTextAll(tostring(item),0,255,0,255)  
  end

  if s == "drop item" then
    local item = hero: AddItemByName("item_heart")
    local pos = hero: GetOrigin() + RandomVector(300)
    hero: DropItemAtPosition(pos,item)
  end

  if s == "drop item immediate" then
    local item = hero: AddItemByName("item_heart")
    local pos = hero: GetOrigin() + RandomVector(300)
    hero: DropItemAtPositionImmediate(item,pos)
  end

  if s == "force kill unit" then
    hero:ForceKill(true)
    hero: SetThink(
    function ()    --2秒后复活
      hero: RespawnUnit()--BUG:DOTA內建復活時間倒數完，還是會調換回去。
    end,2.0)
  end

  if s == "get ability count" then
    local count = hero: GetAbilityCount()
    UTIL_MessageTextAll(tostring(count),0,255,0,255)--為甚麼有17個技能...
  end

  if s == "acquisitionRange" then
    local range = hero: GetAcquisitionRange()
    print("rang1: "..range)
    hero: SetAcquisitionRange(200)
    range = hero: GetAcquisitionRange()
    print("rang2: "..range)
  end

  if s == "GetAttackAnimationPoint" then
  	local point = hero: GetAttackAnimationPoint()
  	UTIL_MessageTextAll(tostring(point),0,255,0,255)
  end

  if s == "left" or s == "right" then --研究path.carner
    local ent = Entities:FindByName(nil,s)
    UTIL_MessageTextAll("@@@@ "..tostring(ent),0,255,255,255)  
    print("@@@@ "..tostring(ent))

    u2 = CreateUnitByName("npc_jidi",ent:GetAbsOrigin(),true,nil,nil,0)
    print("@@@@ "..tostring(u2))
  end

  if s == "Create Unit to attack1" then
    ShuaGuai2 = CreateUnitByName("npc_dota_neutral_alpha_wolf",Vector(0,0),false,nil,nil,DOTA_TEAM_GOODGUYS)
  end

  if s == "Create Unit to attack2" then
    ShuaGuai()
  end

  if s == "Create Unit to attack3" then
  	Timers:CreateTimer( 3.0, function()

  		ShuaGuai()

      return 3.0
    end
  )
  end

  if s == "MapAllView" then
    AddFOWViewer(2,Vector(-2668.3,1611.42),1.0,500.0,false)--天辉方单位在以坐标(0,0)半径1000.0范围内拥有全部视野，持续5秒
  end

  --if string.sub(s,0,0) == "" then
  if s == "SendCustomMessage" then
    print(s)
    GameRules: SendCustomMessage("Hello World",DOTA_TEAM_GOODGUYS,0)
  end

  if s == "lina" then
    Tutorial: AddBot("npc_dota_hero_lina","","",true) -- 添加电脑控制的英雄string_1
  end

  if s == "addquest" then
    local s2 = "#Nobu_TowerKill_Hero_A \n"
    Tutorial: AddQuest("quest_1",1,s2.."22222","ssssssssss")
  end

  if s == "AddShopWhitelistItem" then
    Tutorial: AddShopWhitelistItem("item_boots")
  end  

  if s == "CompleteQuest" then
    Tutorial: CompleteQuest("quest_1")
  end 

  --[[原型：void CompleteQuest(string string_1) 
  功能：标记教程任务string_1完成
  举例：Tutorial: CompleteQuest("quest_1")
  说明：标记教程任务quest_1完成]]

  if s == "CreateLocationTask" then
    Tutorial: CreateLocationTask(Vector(0,0))
  end
  --[[05、CreateLocationTask

  原型：void CreateLocationTask(Vector Vector_1)
  功能：创建一个移动到点Vector_1的任务
  举例：Tutorial: CreateLocationTask(Vector(0,0))
  说明：创建一个移动到点(0,0)的任务]]

  if s == "hide_unit" then
    CreateUnitByName("hide_unit",Vector(0,0),true,nil,nil,0)
  end

  if s == "EnableCreepAggroViz" then
    Tutorial: EnableCreepAggroViz(true)
  end
  --[[06、EnableCreepAggroViz

  原型：void EnableCreepAggroViz(bool bool_1) 
  功能：开启/关闭玩家被野怪攻击提示
  举例：Tutorial: EnableCreepAggroViz(true)
  说明：]]

  --[[13、RemoveShopWhitelistItem

  原型：void RemoveShopWhitelistItem(string string_1) 
  功能：从商店白名单中移除物品string_1
  举例：Tutorial: RemoveShopWhitelistItem("item_boots")
  说明：从商店白名单中移除速度之靴]]

  --[[14、SelectHero

  原型：void SelectHero(string string_1) 
  功能：为玩家选择英雄string_1
  举例：Tutorial: SelectHero("npc_dota_hero_luna")
  说明：为玩家选择英雄露娜]]

  --[[15、SelectPlayerTeam

  原型：void SelectPlayerTeam(string string_1) 
  功能：为玩家选择队伍string_1
  举例：Tutorial: SelectPlayerTeam("#DOTA_TEAM_BADGUYS")
  说明：为玩家选择夜魇方]]

  --[[16、SetItemGuide

  原型：void SetItemGuide(string string_1)
  功能：打开物品string_1合成指导
  举例：Tutorial: SetItemGuide("item_heart")
  说明：打开龙心合成指导]]

  --[[17、SetOrModifyPlayerGold

  原型：void SetOrModifyPlayerGold(int int_1, bool bool_2)
  功能：设置或调整玩家金币数量为int_1
  举例：Tutorial: SetOrModifyPlayerGold(1000,true)
  说明：设置玩家金钱数量为1000]]

  --[[18、SetQuickBuy

  原型：void SetQuickBuy(string string_1) 
  功能：设置快速购买物品string_1
  举例：Tutorial: SetQuickBuy("item_boots")
  说明：]]

    --[[19、SetShopOpen

  原型：void SetShopOpen(bool bool_1)
  功能：开放/关闭商店
  举例：Tutorial: SetShopOpen(false)
  说明：关闭商店 ]]

  --[[20、SetTimeFrozen

  原型：void SetTimeFrozen(bool bool_1)
  功能：冻结/解冻游戏时间
  举例：Tutorial: SetTimeFrozen(true)
  说明：]]

  --[[21、SetTutorialConvar

  原型：void SetTutorialConvar(string string_1, string string_2) 
  功能：设置教程的控制台变量string_1值为string_2
  举例：Tutorial: SetTutorialConvar("","")
  说明：]]

  --[[22、SetTutorialUI

  原型：void SetTutorialUI(int int_1) 
  功能：设置教程UI界面类型为int_1
  举例：Tutorial: SetTutorialUI(1)
  说明：设置教程界面UI类型为1


  仅测试部分，1~6，其余大家自己测试！]]

  --[[24、StartTutorialMode

  原型：void StartTutorialMode()
  功能：进入教程模式
  举例：Tutorial: StartTutorialMode()



  function Activate()
      Tutorial: StartTutorialMode()
  end]]


  --[[01、SetLightGroup 
  void SetLightGroup(string pLightGroup) ]]

  --[[02、SetModel 

  原型：void SetModel(string pModelName)
  功能：设置实体的模型文件为pModelName
  举例：ent: SetModel("models/heroes/sven/sven.vmdl")
  说明：设置实体ent的模型文件为models/heroes/sven/sven.vmdl

  我们可以在资源管理器中预览和选取合适的模型！

  验证：假设玩家所控制的英雄可以随意选择3种模型，其所控制玩家输入-morph 1/2/3可以选择对应的模型。

  斯文：models/heroes/sven/sven.vmdl
  剑圣：models/heroes/juggernaut/juggernaut.vmdl
  敌法：models/heroes/antimage/antimage.vmdl

  function Morph(keys)
         local model = {"models/heroes/sven/sven.vmdl","models/heroes/juggernaut/juggernaut.vmdl","models/heroes/antimage/antimage.vmdl"}
         local type = string.sub(keys.txt,0,6)
         if type == "-morph" then
               local index = tonumber(string.sub(keys.txt,8,9))
               local id = keys.userid
               local p = PlayerResource: GetPlayer(id)
               local hero = p: GetAssignedHero()
               if hero ~= nil then
                       hero: SetModel(model[index])
               end
  end

  function activate()
       ListenToGameEvent("player_chat",Morph,nil)
  end

  注意: DOTA2模型分为主体模型和附加可穿戴模型（饰品）。SetModel只能修改主体模型，而且修改后大部分主体模型与可穿戴模型不搭配！
  斯文主体模型没有脑袋；剑圣没有下肢；敌法四肢健全但是裸体！]]

  --[[03、SetRenderColor

  原型：void SetRenderColor(int r, int g, int b) 
  功能：设置实体模型的渲染颜色为(r,g,b)
  举例：ent: SetRenderColor(255,0,0)
  说明：设置实体ent的模型渲染颜色为红色


  验证：玩家输入-render+r+g+b 三组数值，将所控制英雄模型渲染成对应颜色。

  function Morph(keys)
  local r = 255
  local g = 255
  local b = 255
  if keys.text == "-red" then
    g=0
    b=0
  elseif keys.text == "-green" then
    r=0
    b=0
  elseif keys.text == "-blue" then
    r=0
    g=0
  end
  local id = keys.userid-1
  local p = PlayerResource: GetPlayer(id)
  local hero = p: GetAssignedHero()
  if hero ~= nil then
    hero: SetRenderColor(r,g,b)
    hero: SetRenderMode(1)
  end
  GameRules: SendCustomMessage("Render",0,0)
  end

  function Activate()
       ListenToGameEvent("player_chat",Morph,nil)
  end]]

  --[[05、SetSize 
  void SetSize(Vector mins, Vector maxs)]]
 
  if s == "Quest" then
    --首先在你需要的时候(走上trigger box时、杀死指定单位时等)，初始化任务实体(Quest Entity)
    Quest = SpawnEntityFromTableSynchronous( "quest", { name = "QuestName", title = "#QuestTimer" } )

    --设置完成任务的时间，这个例子里是30秒
    Quest.EndTime = 30

    --初始化带有进度条的子任务
    subQuest = SpawnEntityFromTableSynchronous( "subquest_base", { 
               show_progress_bar = true, 
               progress_bar_hue_shift = -119 
             } )

    --绑定子任务到任务实体
    Quest:AddSubquest( subQuest )

    --设置文本
    -- 计时器启动时的文本
    Quest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 30 )
    Quest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, 30 )

    -- 进度条上的文本
    subQuest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 30 )
    subQuest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, 30 )

    --随着时间减少进度条，刷新文本和进度条
    Timers:CreateTimer(1, function()
        Quest.EndTime = Quest.EndTime - 1
        Quest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Quest.EndTime )
        subQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, Quest.EndTime )

        -- 时间到时完成任务 
        if Quest.EndTime == 0 then 
            EmitGlobalSound("Tutorial.Quest.complete_01") -- game_sounds_music_tutorial中的音乐
            Quest:CompleteQuest()
            return
        else
            return 1 -- 每秒再次调用
        end
    end)
  end

  if s == "killquest" then

    --任务初始化设置，使用GameRules句柄(或者self)来保持可见
    GameRules.Quest = SpawnEntityFromTableSynchronous( "quest", {
            name = "QuestName",
            title = "#QuestKill"
        })
    GameRules.subQuest = SpawnEntityFromTableSynchronous( "subquest_base", {
        show_progress_bar = true,
        progress_bar_hue_shift = -119
    } )
    GameRules.Quest.UnitsKilled = 0
    GameRules.Quest.KillLimit = 10
    GameRules.Quest:AddSubquest( GameRules.subQuest )

    -- 启动时文本
    GameRules.Quest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 0 )
    GameRules.Quest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, GameRules.Quest.KillLimit )

    -- 进度条上的值
    GameRules.subQuest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 0 )
    GameRules.subQuest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, GameRules.Quest.KillLimit )

    --addon_english.txt中的文本
    --"QuestKill" "Kill dem Kobolds. (%quest_current_value%/%quest_target_value%)"
  end


  --[[function MyAbility_null_2( keys )
          local caster = keys.caster       --获取施法者
          local al = keys.ability:GetLevel() - 1   --获取技能等级，并且减1

          local c_team = caster:GetTeam()         --获取施法者所在的队伍
          local vec = caster:GetOrigin()                --获取施法者的位置，就是三维坐标
          local radius = keys.ability:GetLevelSpecialValueFor("radius", al)        --获取范围

          local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
          local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
          local flags = DOTA_UNIT_TARGET_FLAG_NONE

          --获取范围内的单位，效率不是很高，在计时器里面注意使用
          local targets = FindUnitsInRadius(c_team, vec, nil, radius, teams, types, flags, FIND_CLOSEST, true)

          --利用Lua的循环迭代，循环遍历每一个单位组内的单位
          for i,unit in pairs(targets) do
                  local damageTable = {victim=unit,    --受到伤害的单位
                          attacker=caster,          --造成伤害的单位
                          damage=keys.ability:GetLevelSpecialValueFor("damage", al),        --在GetLevelSpecialValueFor里面必须技能等级减1
                          damage_type=keys.ability:GetAbilityDamageType()}    --获取技能伤害类型，就是AbilityUnitDamageType的值
                  ApplyDamage(damageTable)    --造成伤害
          end
  end]]
  if s == "killself" then
      print(s)
      AMHC:Damage( hero,hero,9999.0,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
  end


end

--每当单位死亡，检查其是否符合条件，如果符合就刷新任务
function Ctest:OnEntityKilled( event )
  ------------------------------------------------------------------
   --  local killedUnit = EntIndexToHScript( event.entindex_killed )

   --  if killedUnit and string.find(killedUnit:GetUnitName(), "kobold") then
   --      -- 填充进度条并修改标题
   --      GameRules.Quest.UnitsKilled = GameRules.Quest.UnitsKilled + 1
   --      GameRules.Quest:SetTextReplaceValue(QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, GameRules.Quest.UnitsKilled)
   --      GameRules.subQuest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, GameRules.Quest.UnitsKilled )

   --      -- 检查任务是否完成
   --      if GameRules.Quest.UnitsKilled >= GameRules.Quest.KillLimit then
   --          GameRules.Quest:CompleteQuest()
   --      end
   -- end
   ------------------------------------------------------------------

  --[解决] 请问怎么修改英雄复活时间呢？
    -- local killedUnit = EntIndexToHScript( event.entindex_killed )
    -- --print(event.entindex_killed, " killed")
    -- if killedUnit:IsRealHero() then
    --         --print("Hero has been killed")
    --         if killedUnit:IsReincarnating() == false then
    --                 --print("Setting time for respawn")
    --                 killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*200)
    --         end
    -- end

    ------------------------------------------------------------------
    local killedUnit = EntIndexToHScript( event.entindex_killed )
    if killedUnit:IsRealHero() then
      for i=1,10 do
        GameRules: SendCustomMessage("   ",DOTA_TEAM_GOODGUYS,0)
      end
      Tutorial: AddQuest("quest_1",1,"破塔成功","ssssssssss")     
    end  
end

function unitspell( keys )
  -- body
end

function Ctest:FilterExecuteOrder( filterTable )
--DeepPrintTable(filterTable)  --多用这个来print各种表，能学会挺多，下面比如什么position_x 都在这个filterTable里，print一下就知道这里面有什么了
print("@@@@@")
        local f = filterTable
        --对lua不熟悉的人注意一下，“=”并不是“复制粘贴”，这里我们更改了f这个table的值，其实也就更改了filterTable，在c语言里面来说大概就是复制了一个指针，而不是复制了一个数组，这里这样写只是为了少打几个字 -_-||
        local unit = EntIndexToHScript(f.units["0"]) --单位
 
        if f.order_type ==  DOTA_UNIT_ORDER_MOVE_TO_POSITION then --如果下达的指令类型是移动到某个地点（这个常量表也在一楼的wiki上能查到，网页按Ctrl + F是搜索）
                if unit:FindModifierByName("raoluan") then --在这种情况下这个单位就是移动的单位，查找他是否有上面那个技能的debuff
                        local v = Vector(f.position_x,f.position_y,f.position_z)
                        local r_v = RotatePosition(unit:GetAbsOrigin(),QAngle(0,180,0),v) --把v这个坐标围绕unit的位置坐标在水平面上旋转180°
                        --以下这些是防止新生成的坐标超出了地图的界限
                        if r_v.x > GetWorldMaxX() then
                                r_v.x = GetWorldMaxX()
                        end
                        if r_v.x < GetWorldMinX() then
                                r_v.x = GetWorldMinX()
                        end
                        if r_v.y > GetWorldMaxY() then
                                r_v.y = GetWorldMaxY()
                        end
                        if r_v.y < GetWorldMinY() then
                                r_v.y = GetWorldMinY()
                        end
--更改原来的指令指向的坐标
                        f.position_x = r_v.x
                        f.position_y = r_v.y
                end
        end
        return true--对于return有三种情况，一种false，就等于指令被过滤不生效（本例子情况下就是点击了移动但是不移动），一种是true，并且不做更改，等于没有过滤器一样，还有一种就是上面那样更改了表中的几个值再返回true，那么生效的就是更改后的指令（本例子情况下就是移动了，但是移动的目的地变了）
end

function Ctest:InitGameMode()

  --设置游戏准备时间
  GameRules:SetPreGameTime( 3.0)

  --监听游戏进度
  --ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(Ctest,"OnGameRulesStateChange"), self)

  ListenToGameEvent( "entity_killed", Dynamic_Wrap( Ctest, 'OnEntityKilled' ), self )

  --確認一下是不是成功賭取
  UTIL_MessageTextAll("Init Success",255,0,0,255)--BUG點:不能發nil，要"nil"要不然會崩潰

  --玩家死亡事件
  --ListenToGameEvent("dota_player_killed",Death,nil)
  --监听器(Listener)
  ListenToGameEvent( "entity_killed", Dynamic_Wrap( Ctest, "OnEntityKilled" ), self )

  --玩家對話事件
  ListenToGameEvent("player_chat",Chat,nil)

  --玩家施法事件
  --ListenToGameEvent("dota_player_used_ability",unitspell,nil)


end

-- function Ctest:OnEntityKilled( event )
--   DeepPrintTable(event)    --详细打印传递进来的表
--   print("@@@@ : Death Event Run")

--   local killedUnit = EntIndexToHScript( event.entindex_killed )
--   print("@@@  killed Unit = "..killedUnit:GetUnitName() )

--   --print(event.entindex_killed, " killed")
--   if killedUnit:IsRealHero() then
--     print("@@@@ : YES , i am dead hero")

--     --print("Hero has been killed")
--     if killedUnit:IsReincarnating() == false then --是否處於重生狀態 (不懂? 是說死過一次還是單位還活著) END:效果為單位是否還活著
--       print("@@@@ : Setting time for respawn")
--       killedUnit:SetTimeUntilRespawn(killedUnit:GetLevel()*0.5)--設定復活時間
--     end

--   end
-- end


function Death(keys)
  print("@@@@ : Death Event Run")
  DeepPrintTable(keys)    --详细打印传递进来的表

  -- 储存被击杀的单位
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  
  -- 储存杀手单位
  local killerEntity = EntIndexToHScript( keys.entindex_attacker )

  --EntIndexToHScript handle EntIndexToHScript(int a) 把一个实体的整数索引转化为表达该实体脚本实例的HScript

  print("@@@  killed Unit = "..killedUnit:GetUnitName() )
  print("@@@  killer Unit = "..killerEntity:GetUnitName() )

end


function Activate()--此函數=初始化
end	

-- 在执行完这个文件，和我们上面所LoadModule之后，
-- dota2的build_slave的vlua.cpp就会开始执行addon_game_mode.lua

-- 这里我们只写一个内容，DOTA2XGameMode:初始化
Ctest:InitGameMode()

