function B26W( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin()
	local level = ability:GetLevel() - 1
	caster:FindAbilityByName("B26D"):SetLevel(1)
end

function B26D( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin()
	local level = ability:GetLevel() - 1

	if caster:FindAbilityByName("B26D"):GetLevel() == 1 then
		StartSoundEvent( "Hero_Brewmaster.ThunderClap", caster )
		caster:FindAbilityByName("B26D"):SetLevel(0)
		caster:FindAbilityByName("B26W"):ApplyDataDrivenModifier(caster,caster,"modifier_B26W_2",nil)
		caster:RemoveModifierByName("modifier_B26W")
		local particle = ParticleManager:CreateParticle("particles/b26w2/b26w2.vpcf",PATTACH_POINT,caster)
		ParticleManager:SetParticleControl(particle,0,point)
	end
end

function B26R( keys )
	local caster = keys.caster
	--local target = keys.target
	--local ability = keys.ability
	--local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin()
	--local level = ability:GetLevel() - 1
	local dmg = keys.dmg
	if not (dmg > caster:GetHealth()) then
		local hp =  caster:GetHealth() + dmg
		caster:SetHealth(hp)
	end	
end

function B26T( keys )
	local caster = keys.caster
	--local target = keys.target
	--local ability = keys.ability
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin()
	--local level = ability:GetLevel() - 1
	local particle = ParticleManager:CreateParticle("particles/b26t/b26t.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0, point)
	ParticleManager:SetParticleControl(particle,1, point+Vector(0,0,299))

	local particle2 = ParticleManager:CreateParticle("particles/b26t4/b26t4.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle2,0, point+Vector(0,0,200))
	--ParticleManager:SetParticleControl(particle2,1, point+Vector(0,0,299))	
	Timers:CreateTimer(0.5,function()
		ParticleManager:DestroyParticle(particle2,false)
	end)	
end