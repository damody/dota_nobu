-- 閃光輪
--[[ ============================================================================================================
	Author: Rook, with help from some of Pizzalol's SpellLibrary code
	Date: January 25, 2015
	Called when Blink Dagger is cast.  Blinks the caster in the targeted direction.
	Additional parameters: keys.MaxBlinkRange and keys.BlinkRangeClamp
================================================================================================================= ]]
function item_blink_datadriven_on_spell_start(keys)
	ProjectileManager:ProjectileDodge(keys.caster)  --Disjoints disjointable incoming projectiles.
	
	ParticleManager:CreateParticle("particles/item/c05/c05.vpcf", PATTACH_ABSORIGIN, keys.caster)
	--keys.caster:EmitSound("Greevil.Strike.Start")	
	keys.caster:EmitSound("DOTA_Item.BlinkDagger.Activate")
	--keys.caster:EmitSound("Hero_QueenOfPain.Pick")	
	local caster = keys.caster
	local origin_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local difference_vector = target_point - origin_point

	
	-- if difference_vector:Length2D() > keys.MaxBlinkRange then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
	-- 	target_point = origin_point + (target_point - origin_point):Normalized() * keys.BlinkRangeClamp
	-- end
	
	keys.caster:SetAbsOrigin(target_point)
	FindClearSpaceForUnit(keys.caster, target_point, false)
	
	--【Timer】
	Timers:CreateTimer(0.1,function()
		--【Particle】
		local particle = ParticleManager:CreateParticle("particles/item/c05/c05.vpcf",PATTACH_POINT,caster)
		ParticleManager:SetParticleControl(particle,0, target_point)
		ParticleManager:SetParticleControl(particle,1, target_point)		
	end)		

	print(target_point)
end

