-- 葵紋越前康繼．禦神刀

LinkLuaModifier("modifier_item_the_great_sword_of_sunflower_pattern_echizen_kang_following_lua","items/Addon_Items/item_the_great_sword_of_sunflower_pattern_echizen_kang_following.lua",LUA_MODIFIER_MOTION_NONE)

modifier_item_the_great_sword_of_sunflower_pattern_echizen_kang_following_lua = class({})

function modifier_item_the_great_sword_of_sunflower_pattern_echizen_kang_following_lua:IsHidden() return true end

function modifier_item_the_great_sword_of_sunflower_pattern_echizen_kang_following_lua:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE -- OnTakeDamage
	}
end

-- 這個function會收到全場的傷害事件，無論目標是誰...
function modifier_item_the_great_sword_of_sunflower_pattern_echizen_kang_following_lua:OnTakeDamage( keys )
	if IsServer() and keys.unit == self:GetParent() then
		local inspect = require('inspect')
		print(inspect(keys,
			{depth=1} 
		))
		local ability = self:GetAbility()
		local link_table = ability.link_table
		local link_count = #link_table

		-- 沒有連結任何目標則什麼都不做
		if link_count == 0 then return end

		-- 不能反彈反彈傷害
		if keys.damage_flags == DOTA_DAMAGE_FLAG_REFLECTION then return end

		local caster = self:GetParent()
		local ifx_table = {}
		local half_damage = keys.damage * 0.5
		local share_damage = half_damage / link_count

		caster:SetHealth(caster:GetHealth()+half_damage)

		local damage_table = {
			victim = nil,
			attacker = keys.attacker,
			ability = keys.ability,
			damage = share_damage,
			damage_type = keys.damage_type,
			damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
		}

		for i,unit in ipairs(link_table) do
			if IsValidEntity(unit) then
				damage_table.victim = unit
				ApplyDamage(damage_table)
				local ifx = ParticleManager:CreateParticle("particles/item/item_the_great_sword_of_sunflower_pattern_echizen_kang_following/item_the_great_sword_of_sunflower_pattern_echizen_kang_following_damage.vpcf",PATTACH_POINT_FOLLOW,caster)
				ParticleManager:SetParticleControlEnt(ifx,0,caster,PATTACH_POINT_FOLLOW,"attach_hitloc",caster:GetAbsOrigin(),true)
				ParticleManager:SetParticleControlEnt(ifx,1,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit:GetAbsOrigin(),true)
				ifx_table[i] = ifx
			end
		end

		Timers:CreateTimer(0.5, function()
			for _,ifx in ipairs(ifx_table) do
				ParticleManager:DestroyParticle(ifx, false)
			end
		end)
	end
end

function Init( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- 用來儲存被連結的目標
	if ability.link_table == nil then
		ability.link_table = {}
	end

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_item_the_great_sword_of_sunflower_pattern_echizen_kang_following_lua",{})
end

function End( keys )
	local caster = keys.caster
	caster.half_damage = false
	caster:RemoveModifierByName("modifier_item_the_great_sword_of_sunflower_pattern_echizen_kang_following_lua")
end

function LinkTarget( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local link_table = ability.link_table
	local link_count = #link_table
	caster.half_damage = true
	table.insert(link_table, target)
end

function UnlinkTarget( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local link_table = ability.link_table
	for i,v in ipairs(link_table) do
		if v == target then
			table.remove(link_table, i)
			break
		end
	end
	local link_count = #link_table
	if link_count == 0 then caster.half_damage = false end
end