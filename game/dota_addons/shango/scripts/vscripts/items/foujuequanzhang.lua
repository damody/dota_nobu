function foujuequanzhang_01(keys)   --测试无效，需要修改。最终效果为：去掉目标身上可净化buff、debuff
	-- body
	--获取AOE范围的目标
	local group = keys.target_entities
    --对所有目标使用净化
	for i,unit in pairs(group) do
		if unit:IsAlive() then
			unit:Purge(true,true,true,false,true)
		end
	end
end