--global
local A17R_noncrit_count = 0
local A17R_level = 0
--ednglobal

LinkLuaModifier( "A17R_critical", "scripts/vscripts/heroes/A_Oda/A17_Oda_Nobunaga.lua",LUA_MODIFIER_MOTION_NONE )

A17R_critical = class({})

--------------------------------------------------------------------------------

function A17R_critical:IsHidden()
	return true
end

function A17R_critical:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE }
end

function A17R_critical:GetModifierPreAttack_CriticalStrike()
	return A17R_level*50 + 150
end

function A17R_critical:CheckState()
	local state = {
	}
	return state
end


function A11R_Levelup( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("A11D")
	local level = keys.ability:GetLevel()
	A17R_level = level
end

function A17R( keys )
	local caster = keys.caster
	local skill = keys.ability
	local id  = caster:GetPlayerID()
	local ran =  RandomInt(0, 100)
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then
		if (ran > 20) then
			A17R_noncrit_count = A17R_noncrit_count + 1
		end
		if (A17R_noncrit_count > 5 or ran <= 20) then
			A17R_noncrit_count = 0
			StartSoundEvent( "Hero_SkeletonKing.CriticalStrike", keys.target )
			caster:AddNewModifier(caster, skill, "A17R_critical", { duration = 0.1 } )
		end
	end
end


-- 可以在別的技能刪除另外一個技能的modifier
-- 問題可以洗 如何判斷每人一個計時器