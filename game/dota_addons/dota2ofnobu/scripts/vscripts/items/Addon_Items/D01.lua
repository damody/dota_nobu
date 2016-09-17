-- 風之卷

function item_D01( keys )
	--【Basic】
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	--local player = caster:GetPlayerID()
	local point = caster:GetAbsOrigin()
	local point2 = target:GetAbsOrigin() 
	--local point2 = ability:GetCursorPosition()
	local level = ability:GetLevel() - 1
	local height = 400
	target:SetAbsOrigin(point2+Vector(0,0,height))
	local particle2 = ParticleManager:CreateParticle("particles/item_d01_3/d01_3.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle2,0, point+Vector(0,0,0))
	local particle3 = ParticleManager:CreateParticle("particles/item/d01_2/d01_2.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle3,0, point+Vector(0,0,400))


	local particle = ParticleManager:CreateParticle("particles/item_d01_3/d01_3_c.vpcf",PATTACH_POINT,target)
	ParticleManager:SetParticleControl(particle,0, point+Vector(0,0,0))
	local num = 0
	local tem_p1 = point2+Vector(0,0,height)
	local tem_p2 = nil
	Timers:CreateTimer(0, function ()
		num = num + 1
		if num == 10 then
			ParticleManager:DestroyParticle(particle,false)
			ParticleManager:DestroyParticle(particle2,true)
			ParticleManager:DestroyParticle(particle3,true)
			return nil
		else
			tem_p2 = tem_p1
 			ParticleManager:DestroyParticle(particle,false)
			particle = ParticleManager:CreateParticle("particles/item_d01_3/d01_3_c.vpcf",PATTACH_POINT,target)
			ParticleManager:SetParticleControl(particle,0, tem_p2)
			return 2	
		end
	end)

	--【SOUND】
	caster:StopSound("ITEM_D01_SOUND")
	caster:EmitSound("ITEM_D01_SOUND")
end

function item_D01_END( keys )
	print("DEAD")
	local target = keys.target
	target:ForceKill(true)
	target:Destroy()
end