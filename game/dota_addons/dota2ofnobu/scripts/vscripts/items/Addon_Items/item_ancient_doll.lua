--久棄邪物
function OnEquip( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_ancient_doll",nil)
end

function OnUnequip( keys )
	local caster = keys.caster
	caster:RemoveAbility("modifier_ancient_doll")
end

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local hModifier = caster:FindModifierByNameAndCaster("modifier_ancient_doll", hCaster)
	local scount = hModifier:GetStackCount()
	hModifier:SetStackCount(0)
	AMHC:Damage(caster,target,scount*50,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	caster:Heal(scount*25, caster)
	local flame = ParticleManager:CreateParticle("particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_model.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(flame,0,target:GetAbsOrigin()+Vector(0, 0, 100))
	Timers:CreateTimer(0.5, function ()
		ParticleManager:DestroyParticle(flame, false)
	end)
end

function AbilityExecuted(keys)
	local caster = keys.caster
	local id  = caster:GetPlayerID()
	local skill = keys.ability
	local level = keys.ability:GetLevel()
	if caster:HasModifier("modifier_ancient_doll") == false then
		skill:ApplyDataDrivenModifier(caster,caster,"modifier_ancient_doll",nil)
		local hModifier = caster:FindModifierByNameAndCaster("modifier_ancient_doll", hCaster)
		hModifier:SetStackCount(1)
	else
		local hModifier = caster:FindModifierByNameAndCaster("modifier_ancient_doll", hCaster)
		local scount = hModifier:GetStackCount()
		scount = scount + 1
		if (scount <= 6) then
			hModifier:SetStackCount(scount)
		end
	end
end

function Shock2( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local hModifier = caster:FindModifierByNameAndCaster("modifier_ancient_doll", hCaster)
	local scount = hModifier:GetStackCount()
	hModifier:SetStackCount(0)
	AMHC:Damage(caster,target,scount*90,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	caster:Heal(scount*45, caster)
	local flame = ParticleManager:CreateParticle("particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_model.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(flame,0,target:GetAbsOrigin()+Vector(0, 0, 100))
	Timers:CreateTimer(0.5, function ()
		ParticleManager:DestroyParticle(flame, false)
	end)
end
