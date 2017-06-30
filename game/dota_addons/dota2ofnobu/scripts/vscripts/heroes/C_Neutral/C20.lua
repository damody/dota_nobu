--長宗我部元親
function C20W_OnTakeDamage( event )
	-- Variables
	if IsServer() then
		local ability = event.ability
		local damage = ability:GetSpecialValueFor("damage")
		if ability then
			local caster =ability:GetCaster()
			if event.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
				if not caster.c20w_lock then
					caster:EmitSound( "Hero_Nevermore.Raze_Flames")
					caster.c20w_lock=true
					local ifx = ParticleManager:CreateParticle( "particles/c20w_real/c20w2.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
					local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 300, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
					for _,unit in ipairs(units) do
						damageTable = {
							victim = unit,
							attacker = caster,
							ability = ability,
							damage = damage,
							damage_type = ability:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
						}
						if not unit:IsBuilding() then
							ApplyDamage(damageTable)
						end
					end
					GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("C20W_timer"), 
					function( )
						caster.c20w_lock=nil
						return nil
					end, 0.3)
				end
			end
		end
	end
end


function C20R_OnSpellStart( event )
	-- Variables
	local ability = event.ability
	local damage = ability:GetSpecialValueFor("damage")
	local duration = ability:GetSpecialValueFor("stun")
	local caster = event.caster
	caster:EmitSound( "Hero_Nevermore.ROS_Flames")
	local ifx = ParticleManager:CreateParticle( "particles/c20r_real/c20r.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 550, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
	for _,unit in ipairs(units) do
		damageTable = {
		victim = unit,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		}
		if not unit:IsBuilding() then
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_C20R", {duration=duration})
			ApplyDamage(damageTable)
		end
	end
end

LinkLuaModifier( "modifier_C20T_model", "scripts/vscripts/heroes/C_Neutral/C20.lua",LUA_MODIFIER_MOTION_NONE )

modifier_C20T_model = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_C20T_model:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_C20T_model:GetModifierModelChange()
	return "models/heroes/terrorblade/demon.vmdl"
end


function modifier_C20T_model:IsHidden() 
	return false
end

function modifier_C20T_model:IsDebuff()
	return false
end


function modifier_C20T_model:IsPurgable()
	return false
end




function C20T_OnSpellStart( event )
	-- Variables
	local ability = event.ability
	local caster = event.caster
	local duration = ability:GetSpecialValueFor("During")
	caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
	caster:EmitSound( "Hero_Nevermore.ROS_Flames")
	--local ifx = ParticleManager:CreateParticle( "particles/c20r_real/c20r.vpcf", PATTACH_CUSTOMORIGIN, caster)
	--ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C20T_model", {duration=duration})
	local ifx = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
	--local ifx = ParticleManager:CreateParticle( "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf", PATTACH_CUSTOMORIGIN, caster)
	--ParticleManager:SetParticleControlEnt(ifx, 0, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControlEnt(ifx, 3, caster, PATTACH_POINT_FOLLOW, "attach_wind_r1", caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControlEnt(ifx, 4, caster, PATTACH_POINT_FOLLOW, "attach_wind_r2", caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControlEnt(ifx, 5, caster, PATTACH_POINT_FOLLOW, "attach_wind_r3", caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControlEnt(ifx, 6, caster, PATTACH_POINT_FOLLOW, "attach_wind_l1", caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControlEnt(ifx, 7, caster, PATTACH_POINT_FOLLOW, "attach_wind_l2", caster:GetAbsOrigin(), true)
	--ParticleManager:SetParticleControlEnt(ifx, 8, caster, PATTACH_POINT_FOLLOW, "attach_wind_l3", caster:GetAbsOrigin(), true)
end

function C20T_OnDestroy( event )
	local caster = event.caster
	caster:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
end

function modifier_C20W_old_OnTakeDamage( event )
	-- Variables

	if IsServer() then
		local ability = event.ability
		local damage = ability:GetSpecialValueFor("damage")
		if ability then
			local caster =ability:GetCaster()
			if not caster.c20w_lock then
				if event.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
					caster:EmitSound( "Hero_Nevermore.Raze_Flames")
					caster.c20w_lock=true
					local ifx = ParticleManager:CreateParticle( "particles/c20w_real/c20w2.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin())
					local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 300, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false )
					for _,unit in ipairs(units) do
							damageTable = {
							victim = unit,
							attacker = caster,
							ability = ability,
							damage = damage,
							damage_type = ability:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
						}
						if not unit:IsBuilding() then
							ApplyDamage(damageTable)
						end
					end
				end
				Timers:CreateTimer(0.3, function ()
					caster.c20w_lock=nil
					return nil
				end)
			end
		end
	end
end