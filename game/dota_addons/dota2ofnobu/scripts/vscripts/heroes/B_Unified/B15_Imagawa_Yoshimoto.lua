--global
	C09E_B = {}
	C09R_B = {}
--ednglobal

function C09E_Mitsuhide_Akechi_Effect_first( keys, int,caster,level,point )
	local dmg = 0
	local SEARCH_RADIUS = 300
		--判斷是不是第一波火焰
		if int == 0 then
			dmg = 100 + 100 * level
		else
			dmg = 100 
		end

		direUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
	                              point,
	                              nil,
	                              SEARCH_RADIUS,
	                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)

		--effect:傷害+暈眩
		for _,it in pairs(direUnits) do
			AMHC:Damage(caster,it,dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			keys.ability:ApplyDataDrivenModifier(caster, it,"modifier_C09E",nil)

			--debug
			GameRules: SendCustomMessage("Hello World",DOTA_TEAM_GOODGUYS,0)
		end

		--particle
		local particle=ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf",PATTACH_WORLDORIGIN,caster)
		ParticleManager:SetParticleControl(particle,0,vec)
		ParticleManager:SetParticleControl(particle,1,Vector(5,5,5))
		ParticleManager:SetParticleControl(particle,3,vec)
		ParticleManager:ReleaseParticleIndex(particle)

end




-- 傳入單位盡量統一名稱用keys
function C09E_Mitsuhide_Akechi ( keys )
	local caster = keys.caster --unit
	local caster_abs = caster:GetAbsOrigin() -- vectorv
	local point = keys.target_points[1] 
	local time = 1.40
	local b = false --boolean
	local level = keys.ability:GetLevel()
	local int = 0

		--判斷有沒有R技的modifier
		if caster:HasModifier("modifier_C09R") == false then
			b = true
		else
			b = false
		end

		--timer : 第一次火焰
	    Timers:CreateTimer(time, function()
	    	C09E_Mitsuhide_Akechi_Effect_first(int,caster,level,point)
	        return nil -- 每秒再次调用
	    end)

		--timer : 第二次火焰
	    Timers:CreateTimer(time, function()

	    	if int >= 3 then
	        	return nil -- 每秒再次调用
	        else

	        	--效果
	        	C09E_Mitsuhide_Akechi_Effect_first(keys, int,caster,level,point)

	        	--判斷是否通過機率
	        	if RandomInt( 1 , 100 ) <= 15 + 10 * level then
	        		int = int + 1
	        	else
	        		return nil
	    		end
	        end

	    end)

end


function C09R( keys )
	local caster = keys.caster
	local skill = keys.ability
	local time = 10.00
	local id  = caster:GetPlayerID()

	--debug
	GameRules: SendCustomMessage(tostring(C09R_B[22]),DOTA_TEAM_GOODGUYS,0)

	--debug
	if C09R_B[id] == nil then

		--timer
	    Timers:CreateTimer(time, function()

			--debug
			GameRules: SendCustomMessage("Hello",DOTA_TEAM_GOODGUYS,0)

			--如果沒有R技的modifier，就給予modifer
	    	if caster:HasModifier("modifier_C09R") == false then
	    		skill:ApplyDataDrivenModifier(caster,caster,"modifier_C09R",nil)
	    	end
	        return time -- 每秒再次调用
	    end)

	end

	--avoid
	--避免二次創造計時器
	C09R_B[id] = true

end


-- 可以在別的技能刪除另外一個技能的modifier
-- 問題可以洗 如何判斷每人一個計時器