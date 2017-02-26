
LinkLuaModifier( "modifier_A07W", "scripts/vscripts/heroes/A_Oda/A07_Honda_Tadakatsu.lua",LUA_MODIFIER_MOTION_NONE )
modifier_A07W = class({})

--------------------------------------------------------------------------------

function modifier_A07W:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_A07W:OnCreated( event )
	self:StartIntervalThink(0.1)
end

function modifier_A07W:OnIntervalThink()
	if self.caster ~= nil then
		self.hp = self.caster:GetHealth()
	end
end

function modifier_A07W:OnTakeDamage(event)
	if IsServer() then
	    local attacker = event.unit
	    local victim = event.attacker
	    local return_damage = event.original_damage
	    local damage_type = event.damage_type
	    local damage_flags = event.damage_flags
	    local ability = self:GetAbility()
	    if (self.caster ~= nil) and IsValidEntity(self.caster) then
	    	if victim:GetTeam() ~= attacker:GetTeam() and attacker == self.caster then
	    		if (damage_type ~= DAMAGE_TYPE_PHYSICAL) then
					self.caster:SetHealth(self.hp + event.original_damage)
					self.hp = self.hp + event.original_damage
				else
					self.caster:SetHealth(self.hp)
				end
			end
		end
	end
end


LinkLuaModifier( "A07R_critical", "scripts/vscripts/heroes/A_Oda/A07_Honda_Tadakatsu.lua",LUA_MODIFIER_MOTION_NONE )


--RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR

A07R_critical = class({})

function A07R_critical:IsHidden()
	return true
end

function A07R_critical:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function A07R_critical:GetModifierPreAttack_CriticalStrike()
	return self.A07R_level
end

function A07R_critical:CheckState()
	local state = {
	}
	return state
end


function A07R_Levelup( keys )
	local caster = keys.caster
	caster.A07R_noncrit_count = 0
	
end

function A07R_old( keys )
	local caster = keys.caster
	local skill = keys.ability
	local ability = keys.ability
	local ran =  RandomInt(0, 100)
	caster:RemoveModifierByName("A07R_critical")
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > 36) then
			caster.A07R_noncrit_count = caster.A07R_noncrit_count + 1
		end
		if (caster.A07R_noncrit_count > 3 or ran <= 36) then
			caster.A07R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			local rate = caster:GetAttackSpeed()
			caster:AddNewModifier(caster, skill, "A07R_critical", { duration = rate+0.1 } )
			local hModifier = caster:FindModifierByNameAndCaster("A07R_critical", caster)
			--SE
			-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/jugg_crit_blur_impact.vpcf", PATTACH_POINT, keys.target)
			-- ParticleManager:SetParticleControlEnt(particle, 0, keys.target, PATTACH_POINT, "attach_hitloc", Vector(0,0,0), true)
			--動作
			local rate = caster:GetAttackSpeed()

			--播放動畫
		    --caster:StartGesture( ACT_SLAM_TRIPMINE_ATTACH )
			if rate < 1 then
			    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,1)
			else
			    caster:StartGestureWithPlaybackRate(ACT_DOTA_ECHO_SLAM,rate)
			end

			if (hModifier ~= nil) then
				hModifier.A07R_level = ability:GetLevelSpecialValueFor("crit_persent",ability:GetLevel() - 1) 
			end
		end
	end
end

function A07W_SE( event )
	-- Variables
	local target = event.caster
	local caster = event.caster
	local ability = event.ability
	local shield_size = 30 -- could be adjusted to model scale

	ability:ApplyDataDrivenModifier(caster,caster,"modifier_A07W",{duration=event.Time})
	caster:FindModifierByName("modifier_A07W").caster = caster
	caster:FindModifierByName("modifier_A07W").hp = caster:GetHealth()
	-- -- Strong Dispel 刪除負面效果
	-- local RemovePositiveBuffs = false
	-- local RemoveDebuffs = true
	-- local BuffsCreatedThisFrameOnly = false
	-- local RemoveStuns = true
	-- local RemoveExceptions = false
	-- target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)

	-- Particle. Need to wait one frame for the older particle to be destroyed
	Timers:CreateTimer(0.01, function() 
		target.ShieldParticle = ParticleManager:CreateParticle("particles/a07w5/a07w5.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(target.ShieldParticle, 1, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 2, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 4, Vector(shield_size,0,shield_size))
		ParticleManager:SetParticleControl(target.ShieldParticle, 5, Vector(shield_size,0,0))

		-- Proper Particle attachment courtesy of BMD. Only PATTACH_POINT_FOLLOW will give the proper shield position
		ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)--attach_attack1
	end)
end

-- Destroys the particle when the modifier is destroyed. Also plays the sound
function A07W_EndShieldParticle( event )
	local target = event.target
	if target.ShieldParticle ~= nil then
		ParticleManager:DestroyParticle(target.ShieldParticle,false)
		target.ShieldParticle = nil
	end
	target:RemoveModifierByName("modifier_A07W")
end


function A07W_BorrowedTimeHeal( event )
	--[[
		【邏輯概念】:假如傷害大於0 就代表不是物理傷害
	]]

	-- -- Variables
	local damage = event.DamageTaken
	local caster = event.caster
	local ability = event.ability
	
	if damage > 0 then
		caster:Heal(damage, caster)
	end
	
end

function A07W_BorrowedTimePurge( event )
	local caster = event.caster

	-- Strong Dispel
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false
	caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)--驅散負面效果
end


----------------------------------------------------------------------------<<A07E>>------------------------------------------------------------------------------
function A07E_SE( keys )
	local caster = keys.caster
	if (keys.target ~= nil) then
		caster = keys.target
		local dummy = CreateUnitByName( "hide_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
		AMHC:CreateParticle("particles/a07e/a07e.vpcf",PATTACH_ABSORIGIN,false,dummy,2.0,nil)
		dummy:ForceKill( true )
	else
		local dummy = CreateUnitByName( "hide_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
		AMHC:CreateParticle("particles/a07e/a07e.vpcf",PATTACH_ABSORIGIN,false,dummy,2.0,nil)
		dummy:ForceKill( true )
	end
end



--[[Author: LinWeiHan
	Date: 03.05.2016.
	It Heal HP and attack's speed]]
function A07D_HealHP( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()
	local hModifier = caster:FindModifierByNameAndCaster("modifier_A07T", caster)--獲取modifier
	local float_healhp

	if hModifier ~= nil then
		float_healhp = ((caster:GetHealth()) + (0.06 * caster:GetMaxHealth()))
		caster:SetHealth(float_healhp)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_A07D", {duration = duration})
	else
		float_healhp = ((caster:GetHealth()) + (0.03 * caster:GetMaxHealth()))
		caster:SetHealth(float_healhp)	
	end
end

--[[
	Author: kritth
	Date: 9.1.2015.
	Bubbles seen only to ally as pre-effect
]]
function A07R_Learn_Skill( keys )
	local caster = keys.caster
	local skill = keys.ability
	local level = keys.ability:GetLevel()

	local ability = caster:FindAbilityByName("A07D")
	if ability ~= nil then
		ability:SetLevel(level+1)
		ability:SetActivated(true)
	end
end

--[[Author: LinWeiHan
	Date: 03.05.2016.]]
LinkLuaModifier("A07T", "heroes/A_Oda/A07/A07.lua", LUA_MODIFIER_MOTION_NONE)	
function A07T_Transform( keys )
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel()

	local duration = ability:GetLevelSpecialValueFor("duration",level - 1)
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
			caster:RemoveModifierByName(v:GetName())
		end
	end
	-- Deciding the transformation level
	local modifier = keys.modifier_one

	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
	caster:AddNewModifier(caster,ability,"A07T",{duration = duration})--變身
end

function A07T_SE( keys )
	local caster = keys.caster
	local target = keys.target
	AMHC:CreateParticle("particles/a07e/a07e.vpcf",PATTACH_ABSORIGIN,false,target,0.5,nil)
end