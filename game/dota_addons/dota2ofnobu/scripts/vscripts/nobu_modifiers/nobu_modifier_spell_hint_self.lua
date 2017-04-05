
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
dummy:AddNewModifier(dummy,nil,"nobu_modifier_spell_hint_self",spell_hint_table)

--]]

if nobu_modifier_spell_hint_self == nil then
	nobu_modifier_spell_hint_self = class({})
end

function nobu_modifier_spell_hint_self:IsHidden()
	return true
end

function nobu_modifier_spell_hint_self:OnCreated( keys )
	if IsServer() then
		self:StartIntervalThink(0.1) 
		local duration 		= keys.duration or 1000
		local radius 		= keys.radius or 300
		local thinkness 	= keys.thinkness or 10
		local teamonly 		= keys.teamonly
		local ignore_fog 	= keys.ignore_fog
		local color_self 	= keys.color_self or Vector(1,0.3,0.3)  -- green
		
		local particle_name = nil
		particle_name = "particles/spell_hint/spell_hint_circle_self.vpcf"

		local caster = self:GetParent()
		local team_self = DOTA_TEAM_GOODGUYS
		local team_enemy = DOTA_TEAM_BADGUYS
		if team_enemy == caster:GetTeamNumber() then
			team_self, team_enemy = team_enemy, team_self
		end
		local player = PlayerResource:GetPlayer( caster:GetPlayerID() )
		local ifx_self = ParticleManager:CreateParticleForPlayer(particle_name,PATTACH_ABSORIGIN_FOLLOW,caster,player)

		ParticleManager:SetParticleControl(ifx_self,0,caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(ifx_self,1,Vector(radius, thinkness, duration))
		ParticleManager:SetParticleControl(ifx_self,2,color_self)
		ParticleManager:SetParticleControlEnt(ifx_self, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self.ifx_self = ifx_self
	end
end

function nobu_modifier_spell_hint_self:OnIntervalThink()
	if self.ifx_self then
		local caster = self:GetParent()
		ParticleManager:SetParticleControl(self.ifx_self,0,caster:GetAbsOrigin())
	end
end

function nobu_modifier_spell_hint_self:OnDestroy()
	if self.ifx_self then ParticleManager:DestroyParticle(self.ifx_self, true) end
end

LinkLuaModifier("nobu_modifier_spell_hint_self","nobu_modifiers/nobu_modifier_spell_hint_self.lua",LUA_MODIFIER_MOTION_NONE)