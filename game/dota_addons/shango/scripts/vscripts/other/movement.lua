--//////////////////////////////////////////////////
--无叠加速度控制系统
--//////////////////////////////////////////////////
--多种物品速度不叠加，选取最大速度加成生效
--//////////////////////////////////////////////////
--在KV中添加以下Modifier和AbilitySpecial：
--[[
      "Modifiers"
      {
            "speed_thinker"
           {
                "Passive"  "1"
                "IsHidden"   "1"
                "OnCreated"
                {
                    "RunScript"
                    {
                        "ScriptFile"    "scripts/vscripts/other/movement.lua"
                        "Target"        "TARGET"
                        "action"        "create"
                        "itemname"      "item_xiangxue"  
                        "Function"      "cast"
                    }
                }
                "OnDestroy"
                {
                     "RunScript"
                    {
                        "ScriptFile"    "scripts/vscripts/other/movement.lua"
                        "Target"        "TARGET"
                        "action"        "destroy"
                        "itemname"      "item_xiangxue"
                        "Function"      "cast"
                    }
                }
            }
            "independent_speed_bonus"
            {
                "IsHidden"      "1"
                "Attributes"  "MODIFIER_ATTRIBUTE_MULTIPLE"
                "Properties"
                {
                    "MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT"    "1"   //不叠加速度
                   // "MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE"  "1"     //不叠加攻击
                }               
            }
        }
        "AbilitySpecial"
        {
            "01"
            {
                "var_type"                      "FIELD_INTEGER"
                "independent_movement"              "50"  
            }
        }

]]
--//////////////////////////////////////////////////
if move == nil then move = class( { } )  end
MOVEMENT_BASE=300
if move._movedata == nil then move._movedata={} end
function cast(keys)  --入口
 	local independent_movement=keys.ability:GetLevelSpecialValueFor("independent_movement",0)
 	move:think(keys,independent_movement)  --进入速度处理
end 
function move:think(keys,independent_movement)  
    local caster=EntIndexToHScript(keys.caster_entindex)   --物品携带者
    --当物品得到物品时
    if keys.action =="create" then   
    	if self._movedata[keys.caster_entindex] == nil then self._movedata[keys.caster_entindex]={} end 
        self._movedata[keys.caster_entindex][keys.itemname] = independent_movement
        local max = 0
        for _item,value in pairs(self._movedata[keys.caster_entindex]) do
           if  value > max then max = value end 	
        end 
        if caster:HasModifier("independent_speed_bonus") then caster:RemoveModifierByName("independent_speed_bonus") end
        if caster:GetContext("independent_speed_bonus") == nil then 
           caster:SetContextNum("independent_speed_bonus",max,0)
           keys.ability:ApplyDataDrivenModifier(caster,caster,"independent_speed_bonus",nil)
           caster:SetModifierStackCount("independent_speed_bonus",caster,max)
        else 
        	if max >= caster:GetContext("independent_speed_bonus") then
        		caster:SetContextNum("independent_speed_bonus",max,0)
                keys.ability:ApplyDataDrivenModifier(caster,caster,"independent_speed_bonus",nil)
        		caster:SetModifierStackCount("independent_speed_bonus",caster,max)
        	end
        end
    --移除物品时
    elseif keys.action == "destroy" then 
    	self._movedata[keys.caster_entindex][keys.itemname]= nil
        if  caster:HasModifier("independent_speed_bonus") and not self:FindItem(caster,keys.itemname) then 
            caster:RemoveModifierByName("independent_speed_bonus")
            local max =0 
            for _item,value in pairs(self._movedata[keys.caster_entindex]) do
                if  value > max then max = value end     
            end 
            if max > 0 then
                keys.ability:ApplyDataDrivenModifier(caster,caster,"independent_speed_bonus",nil)
                caster:SetModifierStackCount("independent_speed_bonus",keys.caster,max)
            end 
            caster:SetContextNum("independent_speed_bonus",max,0)
        end      
    end
end
function move:FindItem(hero, item_name)  --遍历物品
    for i = 0, 11 do
        local item = hero:GetItemInSlot(i)
        if item then
            if item:GetAbilityName() == item_name then
                return item
            end
        end
    end
end

