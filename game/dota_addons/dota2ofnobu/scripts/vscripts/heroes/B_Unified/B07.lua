
function B07W_OnSpellStart( keys )
	local ability = keys.ability
	local caster = keys.caster
	local casterLocation = keys.target_points[1]
	local radius =  ability:GetSpecialValueFor( "radius")
	local wave =  ability:GetSpecialValueFor( "wave")
	local dmg = ability:GetSpecialValueFor( "dmg")
	local targetTeam = ability:GetAbilityTargetTeam() -- DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = ability:GetAbilityTargetType() -- DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = ability:GetAbilityTargetFlags() -- DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	local damageType = ability:GetAbilityDamageType()
	local second = 0
	local count = 0
	for i=1,10 do
		B07W_2(keys)
	end
	caster:StartGesture( ACT_DOTA_OVERRIDE_ABILITY_2 )
	Timers:CreateTimer( 0.5, function()
			if caster:IsChanneling() then
				caster:EmitSound("starstorm_impact01")
				caster:StartGesture( ACT_DOTA_OVERRIDE_ABILITY_2 )
				second = second + 1
				local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
						casterLocation,							-- 搜尋的中心點
						nil,
						radius,					-- 搜尋半徑
						ability:GetAbilityTargetTeam(),	-- 目標隊伍
						ability:GetAbilityTargetType(),	-- 目標類型
						DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,-- 額外選擇或排除特定目標
						FIND_ANY_ORDER,					-- 結果的排列方式
						false) 
				for _, it in pairs( units ) do
					if (not(it:IsBuilding())) then
						AMHC:Damage(caster, it, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
					else
						AMHC:Damage(caster, it, dmg*0.3,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
					end
				end
				for i=1,10 do
					B07W_2(keys)
				end
			else
				return nil
			end
			if (second <= wave) then
				return 0.5
			else
				return nil
			end
		end)
end

function B07W_2( keys )
	local ability = keys.ability
	local caster = keys.caster
	local casterLocation = keys.target_points[1]
	local radius =  ability:GetSpecialValueFor("radius")
	local directionConstraint = keys.section
	local particleName = "particles/a31/a31w.vpcf"
	
	-- Get random point
	local attackPoint = casterLocation + RandomVector(RandomInt(10,radius))
	
	-- Fire effect
	local fxIndex = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, attackPoint )
	
end

function B07E_mana_max(keys)
	local caster = keys.caster
	if caster:GetMana()>caster.mana then
		caster:SetMana(caster.mana)
	end
end

function B07E_OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local hp = ability:GetSpecialValueFor("hp")
	local B07R = caster:FindAbilityByName("B07R"):GetLevel()
	if caster.B07E == nil then
		caster.B07E = {}
	end
	local lb07e = {}
	for i,v in pairs(caster.B07E) do
		if IsValidEntity(v) and v:IsAlive() then
			table.insert(lb07e, v)
		end
	end
	
 	local player = caster:GetPlayerID()
 	local wolf = CreateUnitByName("B07E_UNIT",target ,false,caster,caster,caster:GetTeam())
 	wolf.mana = 10
 	caster.B07E = {}
 	if #lb07e >= 2 then
		lb07e[1]:ForceKill(true)
		table.insert(caster.B07E, lb07e[2])
	else
		caster.B07E = lb07e
	end
 	table.insert(caster.B07E, wolf)
 	wolf:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
 	wolf.master = caster
 	wolf:SetBaseMaxHealth(hp)
 	wolf:SetHealth(wolf:GetHealth())
 	wolf:SetBaseDamageMax(100+caster:GetLevel()*5)
 	wolf:SetBaseDamageMin(80+caster:GetLevel()*5)
 	wolf:SetPhysicalArmorBaseValue(1.5+caster:GetLevel()*0.5)
	wolf:AddNewModifier(wolf,ability,"modifier_phased",{duration=0.1})
	ability:ApplyDataDrivenModifier(wolf,wolf,"Passive_mana_max",nil)
	wolf:AddAbility("B07W_old_soldiercamp"):SetLevel(1)
	if B07R >= 3 then
		ability:ApplyDataDrivenModifier(wolf,wolf,"Passive_insight_gem",nil)
		local particle = ParticleManager:CreateParticle("particles/b01w/b01w.vpcf",PATTACH_POINT_FOLLOW,caster)
		ParticleManager:SetParticleControlEnt(particle, 0, wolf, PATTACH_POINT_FOLLOW, "attach_hitloc", wolf:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 2, wolf, PATTACH_POINT_FOLLOW, "attach_hitloc", wolf:GetAbsOrigin(), true)
		--ParticleManager:SetParticleControl(particle,0, point)
		ParticleManager:SetParticleControl(particle,1, Vector(10,0,0))
		ParticleManager:SetParticleControl(particle,2, wolf:GetAbsOrigin())
		Timers:CreateTimer(1, function() 
			if not wolf:IsAlive() then
				ParticleManager:DestroyParticle(particle,true)
				return nil
			end
			return 1
			end)
	end
 	--ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_invulnerable",nil)
 	local items = 1
 	local lv = caster:FindAbilityByName("B07T"):GetLevel()

 	for itemSlot=0,1 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if "item_napalm_bomb" ~= itemName then
				local newItem = CreateItem(itemName, wolf, wolf)
				wolf:AddItem(newItem)
			end
		end
	end
end


function B07T_OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("radius")
	local dmg = ability:GetAbilityDamage()
	Timers:CreateTimer(0, function()
		if caster:IsChanneling() then
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				caster:GetAbsOrigin(),							-- 搜尋的中心點
				nil,
				radius,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 
			--if #units > 0 then
				--local unit = units[RandomInt(1,#units)]
			for _,unit in pairs(units) do
				local ifx = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5_gold/luna_eclipse_impact_moonfall_gold.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
				ParticleManager:SetParticleControlEnt(ifx,0,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
				ParticleManager:SetParticleControlEnt(ifx,1,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
				ParticleManager:SetParticleControlEnt(ifx,2,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
				ParticleManager:SetParticleControlEnt(ifx,5,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
				ParticleManager:ReleaseParticleIndex(ifx)
				if unit:IsBuilding() then
					AMHC:Damage(caster, unit, dmg*0.3, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				elseif unit:IsMagicImmune() then
					AMHC:Damage(caster, unit, dmg*0.5, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				else
					AMHC:Damage(caster, unit, dmg, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
				end
			end
			return 1
		else
			return nil
		end
			
		end)
end

function B07W_old_OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
 	local wolf = CreateUnitByName("B07_soldiercamp_hero",target ,false,caster,caster,caster:GetTeam())
 	wolf:RemoveModifierByName("modifier_invulnerable")
 	wolf:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
 	wolf.master = caster
 	wolf:SetHealth(wolf:GetHealth())
	wolf:AddNewModifier(wolf,ability,"modifier_phased",{duration=0.1})
	wolf:AddNewModifier(wolf,nil,"modifier_kill",{duration=41})
	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_B07W_old2",nil)

	local units = FindUnitsInRadius(caster:GetTeamNumber(),  
        target,nil,300,DOTA_UNIT_TARGET_TEAM_BOTH, 
          DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
          FIND_ANY_ORDER, 
        false)
	local knockbackProperties =
				{
					center_x = target.x,
					center_y = target.y,
					center_z = target.z,
					duration = 0.3,
					knockback_duration = 0.3,
					knockback_distance = 200,
					knockback_height = 0,
					should_stun = 1
				}
				
	for _,it in pairs(units) do
		it:AddNewModifier( caster, nil, "modifier_knockback", knockbackProperties )
	end
end

function B07W_old_OnIntervalThink(keys)
	local caster = keys.caster
	local master = caster.master
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
 	local wolf = CreateUnitByName("B07W_old",caster:GetAbsOrigin()+Vector(100,0,0) ,false,caster,caster,caster:GetTeam())
 	wolf:SetOwner(master)
 	wolf:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
 	wolf:SetHealth(wolf:GetHealth())
	wolf:AddNewModifier(wolf,ability,"modifier_phased",{duration=0.1})
	ability:ApplyDataDrivenModifier(wolf,wolf,"modifier_B07W_old",nil)
	local handle = wolf:FindModifierByName("modifier_B07W_old")
	if handle then
		handle:SetStackCount(master:GetLevel())
	end
end


function B07W_old_OnIntervalThink_self(keys)
	local caster = keys.caster
	local units = FindUnitsInRadius(caster:GetTeamNumber(),  
        caster:GetAbsOrigin() ,nil,1000,DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
          DOTA_UNIT_TARGET_BASIC,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
          FIND_ANY_ORDER, 
        false)
	for _,it in pairs(units) do
		if it:GetUnitName() == "B07W_old" then
			local handle = it:FindModifierByName("modifier_B07W_old")
			if handle then
				handle:SetStackCount(caster:GetLevel())
			end
		end
	end
end

function B07E_old_OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local regen = ability:GetSpecialValueFor("regen")
	local units = FindUnitsInRadius(caster:GetTeamNumber(),  
        caster:GetAbsOrigin() ,nil,radius,DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
          DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
          FIND_ANY_ORDER, 
        false)
	for _,it in pairs(units) do
		it:Heal(regen,ability)
	end
	local ifx = ParticleManager:CreateParticle("particles/b07/b07e_old.vpcf",PATTACH_CUSTOMORIGIN,nil)
	ParticleManager:SetParticleControl( ifx, 0, caster:GetAbsOrigin() )
end


function B07R_old_OnSpellStart( keys )
	local ability = keys.ability
	local caster = keys.caster
	local pos = keys.target_points[1]
	local radius = ability:GetSpecialValueFor("radius")
	local dmg = ability:GetAbilityDamage()
	for i=1,20 do
		B07W_2(keys)
	end
	Timers:CreateTimer(0.5, function()
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				pos,							-- 搜尋的中心點
				nil,
				radius,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				0,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 
		for _, it in pairs( units ) do
			if (not(it:IsBuilding())) then
				AMHC:Damage(caster, it, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			else
				AMHC:Damage(caster, it, dmg*0.5,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
			end
		end
		end)
end


function B07T_old_OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local level = keys.ability:GetLevel()
	local point = caster:GetAbsOrigin()
	local radius = ability:GetSpecialValueFor("radius")
	local dmg = ability:GetAbilityDamage()
	Timers:CreateTimer(0, function()
		if caster:IsChanneling() then
			local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
				caster:GetAbsOrigin(),							-- 搜尋的中心點
				nil,
				radius,					-- 搜尋半徑
				ability:GetAbilityTargetTeam(),	-- 目標隊伍
				ability:GetAbilityTargetType(),	-- 目標類型
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,-- 額外選擇或排除特定目標
				FIND_ANY_ORDER,					-- 結果的排列方式
				false) 

			if #units > 0 then
				local unit = units[RandomInt(1,#units)]
				if unit.B07T_old then
					for i=1,5 do
						unit = units[RandomInt(1,#units)]
						if unit.B07T_old == nil then
							break
						end
					end
				end
				if unit.B07T_old == nil then
				unit.B07T_old = true
					Timers:CreateTimer(0.35, function ()
						unit.B07T_old = nil
						end)
					AddFOWViewer(caster:GetTeam(), unit:GetAbsOrigin(), 300, 1, false)
					local ifx = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5_gold/luna_eclipse_impact_moonfall_gold.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
					ParticleManager:SetParticleControlEnt(ifx,0,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
					ParticleManager:SetParticleControlEnt(ifx,1,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
					ParticleManager:SetParticleControlEnt(ifx,2,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
					ParticleManager:SetParticleControlEnt(ifx,5,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
					ParticleManager:ReleaseParticleIndex(ifx)
					if unit:IsBuilding() then
						AMHC:Damage(caster, unit, dmg*0.3, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
					elseif unit:IsMagicImmune() then
						AMHC:Damage(caster, unit, dmg*0.5, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
					else
						AMHC:Damage(caster, unit, dmg, AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
					end
				end
			end
			return 0.1
		else
			return nil
		end
		end)
end
