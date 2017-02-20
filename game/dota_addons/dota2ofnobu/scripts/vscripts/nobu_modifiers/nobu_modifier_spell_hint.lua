
--[[

local dummy = CreateUnitByName("npc_dummy_unit_new",caster:GetAbsOrigin(),false,nil,nil,caster:GetTeamNumber())
local spell_hint_table = {
	duration   = 1000,				-- 持續時間
	radius     = 300,				-- 半徑
	thinkness  = 10,				-- 線的粗細
	teamonly   = false, 			-- 只顯示給夥伴
	ignore_fog = false,  			-- 無視戰爭迷霧
	color_self = Vector(0,255,0),	-- 己方顏色
	color_enemy= Vector(255,0,0),	-- 敵方顏色
}
dummy:AddNewModifier(dummy,nil,"nobu_modifier_spell_hint",spell_hint_table)

--]]

if nobu_modifier_spell_hint == nil then
	nobu_modifier_spell_hint = class({})
end

function nobu_modifier_spell_hint:IsHidden()
	return true
end

function nobu_modifier_spell_hint:OnCreated( keys )
	if IsServer() then
		local duration 		= keys.duration or 1000
		local radius 		= keys.radius or 300
		local thinkness 	= keys.thinkness or 10
		local teamonly 		= keys.teamonly
		local ignore_fog 	= keys.ignore_fog
		local color_self 	= keys.color_self or Vector(0,255,0)  -- green
		local color_enemy 	= keys.color_enemy or Vector(255,0,0) -- red

		local particle_name = nil
		if ignore_fog == true then
			particle_name = "particles/spell_hint/spell_hint_circle_fog.vpcf"
		else
			particle_name = "particles/spell_hint/spell_hint_circle.vpcf"
		end

		local caster = self:GetParent()
		local team_self = DOTA_TEAM_GOODGUYS
		local team_enemy = DOTA_TEAM_BADGUYS
		if team_enemy == caster:GetTeamNumber() then
			team_self, team_enemy = team_enemy, team_self
		end
		local ifx_self = ParticleManager:CreateParticleForTeam(particle_name,PATTACH_WORLDORIGIN,nil,team_self)
		ParticleManager:SetParticleControl(ifx_self,0,caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(ifx_self,1,Vector(radius, thinkness, duration))
		ParticleManager:SetParticleControl(ifx_self,2,color_self)
		self.ifx_self = ifx_self
		
		if teamonly ~= true then
			local ifx_enemy = ParticleManager:CreateParticleForTeam(particle_name,PATTACH_WORLDORIGIN,nil,team_enemy)
			ParticleManager:SetParticleControl(ifx_enemy,0,caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(ifx_enemy,1,Vector(radius, thinkness, duration))
			ParticleManager:SetParticleControl(ifx_enemy,2,color_enemy)
			self.ifx_enemy = ifx_enemy
		end
	end
end

function nobu_modifier_spell_hint:OnDestroy()
	if self.ifx_self then ParticleManager:DestroyParticle(self.ifx_self, true) end
	if self.ifx_enemy then ParticleManager:DestroyParticle(self.ifx_enemy, true) end
end

LinkLuaModifier("nobu_modifier_spell_hint","nobu_modifiers/nobu_modifier_spell_hint.lua",LUA_MODIFIER_MOTION_NONE)