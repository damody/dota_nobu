
function Shock( keys )
	local caster = keys.caster
	local point = keys.target_points[1] 
	local ability = keys.ability
	local particle = ParticleManager:CreateParticle("particles/item/item_flood_book.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(particle,0,point)
	local SEARCH_RADIUS = 400
	local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
          point,
          nil,
          SEARCH_RADIUS,
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
          0,
          false)
	for _,target in pairs(direUnits) do
		-- 不能推秋山的石頭跟建築物
		if not target:IsBuilding() and _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] == nil then
				
				local knockbackProperties =
				{
					center_x = point.x,
					center_y = point.y,
					center_z = point.z,
					duration = 0.3,
					knockback_duration = 0.3,
					knockback_distance = 500,
					knockback_height = 0,
					should_stun = 1
				}
				target:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
			if (target:IsMagicImmune()) then
				ability:ApplyDataDrivenModifier(caster, target, "modifier_flood_book", {duration = 0.6})
			else
				ability:ApplyDataDrivenModifier(caster, target, "modifier_flood_book", {duration = 1.2})
			end
			AMHC:Damage(caster,target,300,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
		end
	end
end


