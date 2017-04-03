--神隱

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
	for _,unit in ipairs(units) do
		unit:AddNewModifier(caster,ability,"modifier_invisible",{duration = 10})
		if not unit:IsBuilding() then
			unit:Heal(1000,caster)
		end
	end
end
