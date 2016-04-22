
--斯温，残影
function Ability2( keys )
	local caster = keys.caster
	local target = keys.target

	--获取技能等级
	local i = keys.ability:GetLevel() - 1

	--获取持续时间
	local dura = keys.ability:GetLevelSpecialValueFor("duration", i)

	--创建残影
	local unit = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
	
	--设置残影所属玩家
	unit:SetPlayerID(caster:GetPlayerID())
	unit:SetControllableByPlayer(caster:GetPlayerID(), true)

	--给残影添加隐形的modifier
	unit:AddNewModifier(caster, keys.ability, "modifier_illusion", {duration=dura})

	--添加技能里面的modifier
	keys.ability:ApplyDataDrivenModifier(caster, unit, "modifier_sven_ability2_buff", nil)

	--命令残影攻击被攻击的目标
	local order = {UnitIndex = unit:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = target:entindex()}

	ExecuteOrderFromTable(order)
end