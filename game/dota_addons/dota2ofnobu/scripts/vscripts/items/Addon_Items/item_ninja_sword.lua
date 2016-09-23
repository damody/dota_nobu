--忍者刀

LinkLuaModifier( "modifier_transparency", "scripts/vscripts/items/Addon_Items/item_ninja_sword.lua",LUA_MODIFIER_MOTION_NONE )

modifier_transparency = class({})

function modifier_transparency:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
	--MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end

function modifier_transparency:OnAbilityExecuted(params)
	if IsServer() then
		self:Destroy()
	end
end

function modifier_transparency:AttackProc(params)
	local hAbility = self:GetAbility()
	local hTarget = params.target
	--local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), hTarget:GetOrigin(), nil, hAbility:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
end

function modifier_transparency:GetModifierInvisibilityLevel()
	return 50
end

function modifier_transparency:IsHidden()
	return true
end

function modifier_transparency:CheckState()
	local state = {
	[MODIFIER_STATE_INVISIBLE] = true
	}
	return state
end

function modifier_transparency:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
		EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Nevermore.Pick", self:GetCaster() )
		self:AttackProc(params)
		self:Destroy()
		end
	end
end

function modifier_transparency:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function modifier_transparency:GetEffectName()
	return "particles/items_fx/ghost.vpcf"
end


function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_transparency", {duration = 10} )
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ninja_sword", {duration = 10})
end


function Shock2( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local modifierName = "modifier_ninja_sword"
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			PopupCriticalDamage(target, 350)
			AMHC:Damage( caster,target,350,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end	
		keys.caster:RemoveModifierByName( modifierName )
	end
end