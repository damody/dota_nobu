require( "ai/ai_core" )
function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
end
function AIThink()
	-- body
	    local maxdistance = 2000
	    local maxleavetime = 8
	    local goback = false
	    local wild_origin_name = thisEntity:GetContext("spwaner_name")
        local wild_origin = Entities:FindByName(nil, wild_origin_name)
        local leavetime 
        local isleave = false
		thisEntity:SetContextThink( "wild_maxaway", function()
			--如果单位死亡，则退出循环
			if not thisEntity:IsAlive() then 
			    return nil
			end 
            local caster_vec = thisEntity:GetAbsOrigin()
            local wild_spwaner = wild_origin:GetAbsOrigin()
            local distance = (wild_spwaner-caster_vec):Length()
            if distance > maxdistance then  --如果距离大于最大离开距离，则goback为true          	
                goback = true
            end
            if distance > 50 and isleave == false then 
                leavetime = GameRules:GetGameTime()
                isleave = true
            end
            if isleave == true then 
            	if GameRules:GetGameTime()-leavetime >= maxleavetime then 
            		goback = true 
                end
            end 

            if goback == true then   --如果返回，则返回产生点，不回头，直到回去     
                if not thisEntity:HasAbility("ability_yeguai_buff") then     
                    thisEntity:AddAbility("ability_yeguai_buff")
                end
                local abi=thisEntity:FindAbilityByName("ability_yeguai_buff")
                abi:SetLevel(1)
                thisEntity:MoveToPositionAggressive(wild_spwaner)

                if (thisEntity:GetAbsOrigin()-wild_spwaner):Length() <=50 then 
                     print("###### 2") 
                	goback = false
                	isleave =false
                	if thisEntity:HasAbility("ability_yeguai_buff") then
                        thisEntity:RemoveAbility("ability_yeguai_buff")               
                    end
                    if thisEntity:HasModifier("yeguai_buff_001") then 
                        thisEntity:RemoveModifierByName("yeguai_buff_001")                 
                    end
                end
            end
            if distance > 5 then 
            	return 0.25
            else 
			    return 1
			end
		end,0)
	
	
end