--忍者刀

LinkLuaModifier( "modifier_transparency", "scripts/vscripts/items/Addon_Items/item_ninja_sword.lua",LUA_MODIFIER_MOTION_NONE )

modifier_transparency = class({})

function modifier_transparency:DeclareFunctions()
	return {  }
end


function modifier_transparency:GetModifierInvisibilityLevel()
	return 70
end

function modifier_transparency:IsHidden()
	return false
end

function modifier_transparency:CheckState()
	local state = {
	[MODIFIER_STATE_INVISIBLE] = true,
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
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
	caster:AddNewModifier(caster,ability,"modifier_transparency",{duration=10})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ninja_sword", {duration = 10})
end


function Shock2( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			PopupCriticalDamage(target, 350)
			AMHC:Damage( caster,target,350,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end	
		keys.caster:RemoveModifierByName( "modifier_ninja_sword" )
		keys.caster:RemoveModifierByName( "modifier_transparency" )
	end
end