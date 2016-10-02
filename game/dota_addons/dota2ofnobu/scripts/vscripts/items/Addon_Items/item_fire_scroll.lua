-- 火之卷
function Shock( keys )
	--【Basic】
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	--local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	--local vec = caster:GetForwardVector():Normalized()

	--【Particle】
	local particle = ParticleManager:CreateParticle("particles/d03/d03.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0, point+Vector(0,0,100))
	ParticleManager:SetParticleControl(particle,1, point)

	particle = ParticleManager:CreateParticle("particles/d03_2/d03_2.vpcf",PATTACH_POINT,caster)
	ParticleManager:SetParticleControl(particle,0, point+Vector(0,0,100))
	ParticleManager:SetParticleControl(particle,3, point)

	--【SOUND】
	caster:StopSound("ITEM_D03.sound")
	caster:EmitSound("ITEM_D03.sound")
end
