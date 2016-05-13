
--哇塞 lua也太方便了吧 X.y後面就可以設定一個變數
--還可以是table
--可以在KV那邊傳導設定 keys的子級

--<<global>>

--<<global>>


function b06e_Shot( keys )
	local ability = keys.ability
	local target = keys.target

	--debug
  	-- local caster   = keys.caster --获取该玩家的英雄
  	-- DeepPrintTable(keys)    --详细打印传递进来的表

	local id	 = keys.caster:GetPlayerOwnerID() --獲取玩家ID
	local p        = PlayerResource:GetPlayer(id)--可以用索引轉換玩家方式，來捕捉玩家
  	local caster   = p: GetAssignedHero() --获取该玩家的英雄
  	local point  = target:GetAbsOrigin()

  	--次數紀錄
  	caster.b06ecountofattacked = caster.b06ecountofattacked - 1

	--範圍尋找對象
	local radius = 500

    --獲取攻擊範圍
    local group = {}
    local radius = 400
    local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
    local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_MECHANICAL     --+DOTA_UNIT_TARGET_BUILDING
    local flags = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE

    --獲取周圍的單位
    group = FindUnitsInRadius(caster:GetTeamNumber(),point,nil,radius,teams,types,flags,FIND_ANY_ORDER,true)

    --如果元素大於0個單位才隨機抓取
    if #group > 1  and caster.b06ecountofattacked > 0 then

    	local newgroup = {}
    	for i,unit in ipairs(group) do
			if unit ~= target then
				table.insert(newgroup,unit)
			end
		end

    	local new_target = newgroup[RandomInt(1,#newgroup)]

  		-- local new_target = group[RandomInt(1,#group)]

    	--馬甲&技能(除非有單位才創造)
    	local dummy = AMHC:CreateUnit( "hide_unit",target:GetOrigin(),caster:GetForwardVector(),caster,caster:GetTeamNumber())
		local level  = keys.ability:GetLevel()--獲取技能等級
	    local spell = dummy:AddAbility("B06E_HIDE")  
	    spell:SetLevel(level)
	    spell:SetActivated(true) 

	    --添加馬甲技能
		dummy:AddAbility("majia"):SetLevel(1)

		--刪除馬甲
	    Timers:CreateTimer( 10.0, function()
			dummy:ForceKill( true )
			return nil
		end )

		--命令 
		local order = { 
	            UnitIndex = dummy:entindex(),
	            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
	            TargetIndex = new_target:entindex(),
	            AbilityIndex = spell:entindex(),
	            Queue = true
	        }
		ExecuteOrderFromTable(order)
    end

end

function b06e_start( keys )
	local caster = keys.caster
	local target = caster

	--保存次數:彈跳次數
	caster.b06ecountofattacked = 5

	local particleName = "particles/b06t/b06t.vpcf"
	Timers:CreateTimer(0.01, function() 
		target.AmpDamageParticle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 1, target, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
		--ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 2, target, PATTACH_CUSTOMORIGIN_FOLLOW, "attach_attack1", target:GetAbsOrigin(), true)
	end)

	Timers:CreateTimer(0.7, function() 
		ParticleManager:DestroyParticle(target.AmpDamageParticle,false)
	end)

end

--要注意魔法免疫
--ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags() 超好用

function B06R_Learn_Ability( keys )
	keys.caster.B06R_Buff = true
end


function B06R_BeSpelled( caster,ability )
	caster.B06R_Buff = false
	caster:FindAbilityByName("B06R"):ApplyDataDrivenModifier(caster, caster, "modifier_B06R", {duration = 3.0})

	local target  = caster
	local location = target:GetAbsOrigin()
	local particleName = "particles/b06r3/b06r3.vpcf"

	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.AmpDamageParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
		-- ParticleManager:SetParticleControl(target.AmpDamageParticle, 0, target:GetAbsOrigin())
		-- ParticleManager:SetParticleControl(target.AmpDamageParticle, 1, target:GetAbsOrigin())
		-- ParticleManager:SetParticleControl(target.AmpDamageParticle, 2, target:GetAbsOrigin())

		-- ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		-- ParticleManager:SetParticleControlEnt(target.AmpDamageParticle, 2, target, PATTACH_OVERHEAD_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
	end)

	local count = 0
	Timers:CreateTimer(1.0, function() 
		if count == 2 then
			return nil
		else
			particleName = "particles/b06r3/b06r4.vpcf"
			target.AmpDamageParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
			count = count + 1
			return 1.0
		end
	end)
end

function B06R_TimeUP( keys )
	keys.caster.B06R_Buff = true
end

function B06T_SE( keys )
	local caster = keys.caster
	local target = keys.target
	AMHC:CreateParticle("particles/b06e4/b06e4_b.vpcf",PATTACH_ABSORIGIN,false,target,0.5,nil)
end