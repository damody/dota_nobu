
function TrueFormStart( event ) --鬼神开始变形调用
	local caster = event.caster   
	local model = event.model   --要变成的模型
	local ability = event.ability   --变现技能
	local point = event.caster.point   --对比point和caster的位置
	local k=ability:GetLevel()
    local duration=ability:GetLevelSpecialValueFor("duration",k-1)
	local ability_all ={"caoren_cuimianshu",   --记录曹仁所有
                        "caoren_shifuqun",
                        "caoren_siyao",
                        "caoren_guishen"
                        }
    local ability_all_lvl={}  --记录技能等级
    local ability_all_has={}  --记录是否学习相关技能
    if caster:FindAbilityByName("caoren_cuimianshu") then 
        ability_all_lvl["caoren_cuimianshu"]=caster:FindAbilityByName("caoren_cuimianshu"):GetLevel()
	end 
    if caster:FindAbilityByName("caoren_shifuqun") then 
        ability_all_lvl["caoren_shifuqun"]=caster:FindAbilityByName("caoren_shifuqun"):GetLevel()
    end
    if caster:FindAbilityByName("caoren_siyao") then 
        ability_all_lvl["caoren_siyao"]=caster:FindAbilityByName("caoren_siyao"):GetLevel()
    end
    if caster:FindAbilityByName("caoren_guishen") then 
        ability_all_lvl["caoren_guishen"]=caster:FindAbilityByName("caoren_guishen"):GetLevel()
    end
    --所有物品不可用
    for i = 0, 11 do
        local _item= caster:GetItemInSlot(i)
        if _item then
            _item:SetActivated(false)
        end
    end
    --设置为满血
    caster:SetHealth(caster:GetMaxHealth())
    caster:SetHullRadius(48)
    if caster.caster_model == nil then 
		caster.caster_model = caster:GetModelName()
	end
	caster.caster_attack = caster:GetAttackCapability() 
	caster:SetAbsOrigin(point+Vector(0,0,300))  --移动曹仁到AOE中心   
    local p_end3 = 'particles/units/heroes/hero_warlock/warlock_rain_of_chaos_start.vpcf'
            local p_index3 = ParticleManager:CreateParticle(p_end3, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControl(p_index3, 0,point)
   	--变身，改变模型，同时变大,从高处掉落。
	caster:SetOriginalModel(model)
	local model_size = 0.5  --初始鬼神模型大小
	local per_down = 20
    local count = 0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("caoren_02"),function()        	          
        if count >= 6 then
            --释放落地特效特效
            local p_end = 'particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf'
            local p_index = ParticleManager:CreateParticle(p_end, PATTACH_CUSTOMORIGIN, caster)
            ParticleManager:SetParticleControl(p_index, 0, caster:GetOrigin())
            --移除不可控、无敌效果
            if caster:HasModifier("caoren_down_state")  then 
                caster:RemoveModifierByName("caoren_down_state")   --移除关羽移动过程中的无敌、不可控状态
            end
            --移除现有技能
            for _,v in pairs(ability_all) do
                if caster:HasAbility(v) then 
                    ability_all_has[v]=1
                    caster:RemoveAbility(v)
                end 
            end
            --添加地动跺技能并释放
            caster:AddAbility("caoren_t")
            local spell = caster:FindAbilityByName("caoren_t")  --为陷阱添加隐形技能
            if spell then  
                spell:SetLevel(1)
                caster:CastAbilityImmediately(spell, caster:GetPlayerOwnerID())   --释放
            end
            --防卡地形
            FindClearSpaceForUnit(caster, caster:GetOrigin(), false)  
            return nil 
        else 
            caster:SetModelScale(model_size)
            local now_point = caster:GetAbsOrigin()
            caster:SetAbsOrigin(now_point-Vector(0,0,per_down))
            model_size=model_size+0.18
            count = count + 1 
            return 0.02
        end 
    end,0)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("caoren_03"),function()  --变身持续时间到时，变回原模型
        --设置为原有模型
        caster:SetModel(caster.caster_model)
        caster:SetHullRadius(24)
	    caster:SetOriginalModel(caster.caster_model)
        caster:SetModelScale(1)  
        --移除变身中的modifier  
        if caster:HasModifier("caoren_damage_per")  then 
           caster:RemoveModifierByName("caoren_damage_per")   
        end
        if caster:HasModifier("modifier_true_form")  then 
           caster:RemoveModifierByName("modifier_true_form")   
        end
        if caster:HasModifier("caoren_guishen_fire")  then 
           caster:RemoveModifierByName("caoren_guishen_fire")   
        end
        if caster:HasAbility("caoren_t") then 
                    caster:RemoveAbility("caoren_t")
                end 
        --恢复原有技能
        for _,v in pairs(ability_all) do
            	if not caster:HasAbility(v) and ability_all_has[v] then 
            		caster:AddAbility(v)
                    if ability_all_lvl[v] then 
                        caster:FindAbilityByName(v):SetLevel(ability_all_lvl[v])
                    end
                end 
        end
       --恢复物品可用
        for i = 0, 11 do
            local _item= caster:GetItemInSlot(i)
            if _item then
                _item:SetActivated(true)
            end
         end
        --恢复饰品
        ShowWearables( event )

    end,duration+0.5)
    
end
function HideWearables( event )   --隐藏饰品
	local hero = event.caster
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
    hero.wearableNames = {} -- In here we'll store the wearable names to revert the change
	hero.hiddenWearables = {} -- Keep every wearable handle in a table, as its way better to iterate than in the MovePeer system
    local model = hero:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() ~= "" and model:GetClassname() == "dota_item_wearable" then
            local modelName = model:GetModelName()
            print("modelName:"..model:GetModelName())
            if string.find(modelName, "invisiblebox") == nil then
            	-- Add the original model name to revert later
            	table.insert(hero.wearableNames,modelName)
            	model:SetModel("models/development/invisiblebox.vmdl")
            	table.insert(hero.hiddenWearables,model)
            end
        end
        model = model:NextMovePeer()
    end
end
function ShowWearables( event )  --显示饰品
	local hero = event.caster
	for i,v in ipairs(hero.hiddenWearables) do
		for index,modelName in ipairs(hero.wearableNames) do
			if i==index then
				v:SetModel(modelName)
			end
		end
	end
end
function point_01(keys)--直接传参不行，就间接传
    -- body
    local point = keys.target_points[1]   --对比point和caster的位置
    keys.caster.point=point
end
function cuimianshu(keys)
    -- body
    print("enter caoren!!!")
    local target = keys.target
    local ability = keys.ability   --变现技能
    local k=ability:GetLevel()
    local duration=ability:GetLevelSpecialValueFor("duration",k-1)
    local dru = 0
    local target_health = target:GetHealth()
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("cuimianshu01"),function()
        if target:GetHealth() < target_health then 
            if target:HasModifier("caoren_cuimianshu_debuff") then 
                    target:RemoveModifierByName("caoren_cuimianshu_debuff")
            else 
                return nil
            end 
        end
        dru =dru + 0.02
        if dru >= duration then 
            return nil
        end 
        return 0.02
    end,0)
end
