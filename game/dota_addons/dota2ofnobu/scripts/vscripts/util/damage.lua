
    DAMAGE_INCREASE_TYPE_STR = 1
    DAMAGE_INCREASE_TYPE_AGI = 2
    DAMAGE_INCREASE_TYPE_INT = 3

	--接口
	--[[

		"RunScript"
		{
			"ScriptFile"		"scripts/vscripts/abilities/xxx.lua"
			"Function"			"xxx"
			"damage_base"		"0"									//固定的基础伤害(默认0)
			"damage_increase"	"1"									//伤害系数(默认1)
			"damage_increase_type" "1"                              //加成类型,默认为0（无） 1=力量 2=敏捷 3=智力
			"damage_type"		"DAMAGE_TYPE_PURE"					//伤害类型(默认纯粹)
		}
		
        function XXX(keys)		
		
		    UnitDamageTarget(keys)
			
		end
		
	]]
		



	--全局Damage表
	Damage = {}

	local Damage = Damage

	setmetatable(Damage, Damage)

	--伤害表的默认值
	Damage.damage_meta = {
		__index = {
			attacker 			= nil, 						--伤害来源
			victim 				= nil, 						--伤害目标
			damage				= 0,						--伤害
			damage_type			= DAMAGE_TYPE_PURE,			--伤害类型,不写的话是纯粹伤害
			damage_flags 		= 1, 						--伤害标记
		},
	}
	
	function UnitDamageTargetTemplate(keys)
		local targets	= keys.target_entities	--技能施放目标(数组)

		if not targets then
			print(debug.traceback '无伤害目标！')
		end
		
		--添加默认值
		setmetatable(damage, Damage.damage_meta)
		
		
		--获取技能传参,构建伤害table
		damage.attacker				= EntIndexToHScript(keys.caster_entindex)						--伤害来源(施法者)
		
		if not attacker then
			print(debug.traceback '找不到施法者！')
		end
		
		--获取伤害类型
		damage.damage_type          = keys.damage_type
		
		--判断属性类型，获取单位身上加成的属性
		local attribute             = 0
		
		if (keys.damage_increase_type == DAMAGE_INCREASE_TYPE_STR) then
			--力量增量
			attribute = keys.attacker:GetStrength()
			
		elseif (keys.damage_increase_type == DAMAGE_INCREASE_TYPE_AGI) then
		    --敏捷增量
		    attribute = keys.attacker:GetAgility()
			
		elseif (keys.damage_increase_type == DAMAGE_INCREASE_TYPE_INT) then
		    --智力增量
		    attribute = keys.attacker:GetIntellect()
			
		end
		          
		
		--根据公式计算出伤害
		--伤害系数 * (力量 * 力量系数 + 敏捷 * 敏捷系数 + 智力 * 智力系数)
		local damageResult     		=  attribute * keys.damage_increase + keys.damage_base
		
		--遍历数组进行伤害
		for i, victim in ipairs(targets) do
	        damage.victim 		= victim
			damage.damage 		= damageResult
			
			ApplyDamage(damage)
		end
		
    end
	
	function UnitDamageTarget(DamageTable)
		if(DamageTable.victim:IsNightmared())then
			DamageTable.victim:RemoveModifierByName("modifier_bane_nightmare")
		end
		ApplyDamage(DamageTable)
	end