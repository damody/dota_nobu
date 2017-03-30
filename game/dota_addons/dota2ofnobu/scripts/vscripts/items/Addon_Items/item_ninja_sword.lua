--忍者刀

function Shock( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:AddNewModifier(caster,ability,"modifier_invisible",{duration=6})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_ninja_sword", {duration = 6})
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
		keys.caster:RemoveModifierByName( "modifier_invisible" )
	end
end