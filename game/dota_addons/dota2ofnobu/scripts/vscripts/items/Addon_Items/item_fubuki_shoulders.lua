--吹雪護肩
function Start( keys )
	print("modifier_fubuki_shoulders")
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster,"modifier_fubuki_shoulders",{duration=7})
	local particle = ParticleManager:CreateParticle("particles/a04r3/a04r3.vpcf", PATTACH_ROOTBONE_FOLLOW, caster)
	ParticleManager:SetParticleControl( particle, 0, Vector( 0, 0, 200 ) )
	ParticleManager:SetParticleControl( particle, 1, Vector( 7, 0, 0 ) )
	Timers:CreateTimer(7, function ()
		ParticleManager:DestroyParticle(particle, true)
		end)
	
end


function Shock( keys )
	local caster = keys.caster
	--local target = keys.target
	local ability = keys.ability
	local dmg = keys.dmg
	local healmax = dmg*0.45
	local mana = healmax / 2.5

	if (caster:GetMana() >= mana and caster:GetHealth() > healmax) then
		caster:SpendMana(mana,ability)
		caster:SetHealth(caster:GetHealth() + healmax)
	end
end


