
LinkLuaModifier( "A11E_modifier", "scripts/vscripts/heroes/A_Oda/A11_Hattori_Hanzo.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "A11E_followthrough", "scripts/vscripts/heroes/A_Oda/A11_Hattori_Hanzo.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "A11E_hook_back", "scripts/vscripts/heroes/A_Oda/A11_Hattori_Hanzo.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_transparency", "scripts/vscripts/heroes/A_Oda/A11_Hattori_Hanzo.lua",LUA_MODIFIER_MOTION_NONE )

modifier_transparency = class({})

function modifier_transparency:DeclareFunctions()
	return { MODIFIER_EVENT_ON_ATTACK_LANDED,
	MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end

function modifier_transparency:OnAbilityExecuted(params)
	if IsServer() then
		self:GetParent():RemoveModifierByName( "modifier_A11D" )
		self:Destroy()
	end
end

function modifier_transparency:AttackProc(params)
	local hAbility = self:GetAbility()
	local hTarget = params.target
	local nFXIndex = ParticleManager:CreateParticle( "particles/shadow_raze_gen/raze.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( nFXIndex, 0, hTarget:GetAbsOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 133, 0, 162 ) )
	--local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), hTarget:GetOrigin(), nil, hAbility:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
end

function modifier_transparency:GetModifierInvisibilityLevel()
	return 50
end

function modifier_transparency:IsHidden()
	return true
end

function modifier_transparency:CheckState()
	local state = {
	[MODIFIER_STATE_INVISIBLE] = true
	}
	return state
end

function modifier_transparency:OnAttackLanded( params )
	if IsServer() then
		if params.attacker == self:GetParent() then
		EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "Hero_Nevermore.Pick", self:GetCaster() )
		self:AttackProc(params)
		self:Destroy()
		end
	end
end

function modifier_transparency:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function modifier_transparency:GetEffectName()
	return "particles/items_fx/ghost.vpcf"
end


function A11W_Levelup( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("A11D")
	local level = keys.ability:GetLevel()
	
	if (ability:GetLevel() < level) then
		ability:SetLevel(level)
	end
end

function A11R_Levelup( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("A11D")
	local level = keys.ability:GetLevel()
	
	if (ability:GetLevel() < level) then
		ability:SetLevel(level)
	end
end

function A11D( keys )
	local caster = keys.caster
	local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_transparency", {duration = 20} )
end

function A11D_End( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local modifierName = "modifier_A11D"
		local abilityDamage = ability:GetLevelSpecialValueFor( "A11D_Damage", ability:GetLevel() - 1 )
		local abilityDamageType = ability:GetAbilityDamageType()
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			
			local damageTable = {
				victim = target,
				attacker = caster,
				damage = abilityDamage,
				damage_type = abilityDamageType
			}
			ApplyDamage( damageTable )
		end	
		keys.caster:RemoveModifierByName( modifierName )
	end
end

function A11W( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "A11W_Duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "A11W_attack", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

	local people = ability:GetLevel() + 1
	local eachAngle = 6.28 / people
	local illusion = {}
	local target_pos = {}
	local radius = 700
	local origin_go_index = RandomInt(1, people)
	local random_angle = RandomInt(-20, 20) * 0.1
	local origin_pos = caster:GetOrigin()

	for i=1,people do
		if (i ~= origin_go_index) then
			-- handle_UnitOwner needs to be nil, else it will crash the game.
			illusion[i] = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
			illusion[i]:SetPlayerID(caster:GetPlayerID())
			illusion[i]:SetControllableByPlayer(player, true)
			
			-- Level Up the unit to the casters level
			local casterLevel = caster:GetLevel()
			for j=1,casterLevel-1 do
				illusion[i]:HeroLevelUp(false)
			end

			-- Set the skill points to 0 and learn the skills of the caster
			illusion[i]:SetAbilityPoints(0)
			for abilitySlot=0,15 do
				local ability = caster:GetAbilityByIndex(abilitySlot)
				if ability ~= nil then 
					local abilityLevel = ability:GetLevel()
					local abilityName = ability:GetAbilityName()
					local illusionAbility = illusion[i]:FindAbilityByName(abilityName)
					illusionAbility:SetLevel(abilityLevel)
				end
			end

			-- Recreate the items of the caster
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					local itemName = item:GetName()
					local newItem = CreateItem(itemName, illusion[i], illusion[i])
					illusion[i]:AddItem(newItem)
				end
			end
			-- Set the unit as an illusion
			-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
			illusion[i]:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
			illusion[i]:SetBaseDamageMin(-1000)
			illusion[i]:SetBaseDamageMax(-1000)
			-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
			illusion[i]:MakeIllusion()

			illusion[i]:SetHealth(caster:GetHealth())
			illusion[i]:SetRenderColor(255,0,255)
		end
	end
	
	Timers:CreateTimer( 0.1, 
		function()
			for i=1,people do
				target_pos[i] = Vector(math.sin(eachAngle*i+random_angle), math.cos(eachAngle*i+random_angle), 0) * radius
				if (i ~= origin_go_index) then
					ProjectileManager:ProjectileDodge(illusion[i])
					ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, illusion[i])
					illusion[i]:SetAbsOrigin(origin_pos+target_pos[i])
					ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, illusion[i])
					illusion[i]:SetForwardVector(target_pos[i]:Normalized())
					illusion[i]:AddNewModifier(illusion[i],ability,"modifier_phased",{duration=0.1})
				else
					ProjectileManager:ProjectileDodge(caster)
					ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
					caster:SetAbsOrigin(origin_pos+target_pos[i])
					ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
					caster:SetForwardVector(target_pos[i]:Normalized())
					caster:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
				end
			end
			return nil
		end )
end


A11E = class ({})

function A11E:OnSpellStart()
	local caster = self:GetCaster()
	local debuff_duraiton = self:GetSpecialValueFor("flux_duration")
	local dir = self:GetCursorPosition() - caster:GetOrigin()
	caster:SetForwardVector(dir:Normalized())
	caster:AddNewModifier(caster, self, "A11E_modifier", { duration = 2}) 
	caster:AddNewModifier(caster, self, "A11E_followthrough", { duration = 0.3 } )
end

function A11E:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_1 )
	return true
end

--------------------------------------------------------------------------------

function A11E:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
end

function A11E:OnOwnerDied()
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
end

function A11E:OnUpgrade()
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("A11D")
	local level = self:GetLevel()
	
	if (ability:GetLevel() < level) then
		ability:SetLevel(level)
	end
end

A11E_followthrough = class({})

--------------------------------------------------------------------------------

function A11E_followthrough:IsHidden()
	return true
end


--------------------------------------------------------------------------------

function A11E_followthrough:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end


A11E_hook_back = class({})

--------------------------------------------------------------------------------

function A11E_hook_back:IsHidden()
	return true
end


--------------------------------------------------------------------------------

function A11E_hook_back:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end
function A11E_hook_back:OnIntervalThink()
	if (self.path ~= nil) then
		local target = self:GetParent()
		if (self.interval_Count > 1) then
			target:SetOrigin(self.path[self.interval_Count])
			self.interval_Count = self.interval_Count - 1
		else
			target:AddNewModifier(target,self:GetAbility(),"modifier_phased",{duration=0.1})
			target:RemoveModifierByName("A11E_hook_back")
		end
	end
end
function A11E_hook_back:IsHidden()
	return true
end

function A11E_hook_back:IsDebuff()
	return true
end

function A11E_hook_back:OnCreated( event )
	self:StartIntervalThink(0.07) 
end


A11E_modifier = class ({})

function A11E_modifier:OnCreated( event )
	local ability = self:GetAbility()
	self:GetParent():EmitSound("A11E.sound")
	self.hook_width = ability:GetSpecialValueFor("hook_width")
	self.hook_distance = ability:GetSpecialValueFor("hook_distance")
	self.hook_damage = ability:GetSpecialValueFor("hook_damage")
	if IsServer() then
		self.damage_type = ability:GetAbilityDamageType()
	end
	self.distance_sum = 0
	self.interval_Count = 0
	self.path = {}
	self.particle = {}
	self.oriangle = self:GetParent():GetAnglesAsVector().y
	self.hook_pos = self:GetParent():GetOrigin()
	self.oripos = self:GetParent():GetOrigin()
	self:StartIntervalThink(0.05) 

end

function A11E_modifier:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		self.interval_Count = self.interval_Count + 1
		local angle = math.abs(caster:GetAnglesAsVector().y - self.oriangle)
		print("angle: "..(angle))
		if (angle > 45) then
			if (angle > 80) then
				angle = angle * 4
			else
				angle = angle * 2
			end
		end
		local vDirection =  caster:GetForwardVector()
		self.path[self.interval_Count] = self.hook_pos
		local length = (20+angle*0.2) * self.interval_Count
		local next_hook_pos = self.hook_pos + vDirection:Normalized() * length + (self:GetParent():GetOrigin() - self.oripos)
		self.oripos = self:GetParent():GetOrigin()
		length = (next_hook_pos - self.hook_pos):Length()
		hook_pts = {}
		if (length > 100) then
			local pts = length / 100 + 1
			for i=1,pts do
				hook_pts[i] = self.hook_pos + vDirection:Normalized() * 100 * i
				print("pts: ".. hook_pts[i].x.." "..hook_pts[i].y.." "..hook_pts[i].z)
			end
		end

		self.distance_sum = self.distance_sum + 20 * self.interval_Count
		
		local particle = ParticleManager:CreateParticle("particles/a11/_2pudge_meathook_whale2.vpcf",PATTACH_WORLDORIGIN,caster)
		ParticleManager:SetParticleControl(particle,0, next_hook_pos)
		ParticleManager:SetParticleControl(particle,1,Vector(1.11 - self.interval_Count*0.1,0,0))
		ParticleManager:SetParticleControl(particle,4,Vector(1,0,0))
		ParticleManager:SetParticleControl(particle,5,Vector(1,0,0))
		ParticleManager:SetParticleControl(particle,3,self.hook_pos)
		ParticleManager:ReleaseParticleIndex(particle)
		self.particle[self.interval_Count] = particle
		local SEARCH_RADIUS = self.hook_width
		for _,hookpoint in pairs(hook_pts) do
			-- 拉到敵人
			local hashook = false
			local direUnits = FindUnitsInRadius( caster:GetTeamNumber(), hookpoint, nil, SEARCH_RADIUS, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )

			for _,it in pairs(direUnits) do
				if (not(it:IsBuilding())) then
					ApplyDamage({ victim = it, attacker = self:GetCaster(), damage = self.hook_damage, 
						damage_type = self.damage_type, ability = self:GetAbility()})
					hashook = true
					it:AddNewModifier(it, self:GetCaster(), "A11E_hook_back", { duration = 2}) 
					local hModifier = it:FindModifierByNameAndCaster("A11E_hook_back", it)
					if (hModifier ~= nil) then
						hModifier.path = self.path
						hModifier.interval_Count = self.interval_Count
						hModifier.particle = self.particle
						break
					end
					break
				end
			end
			if (hashook == true) then
				self:StartIntervalThink( -1 )
				return
			end

			-- 拉到友軍
			direUnits = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
		                          hookpoint,
		                          nil,
		                          SEARCH_RADIUS,
		                          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		                          DOTA_UNIT_TARGET_ALL,
		                          DOTA_UNIT_TARGET_FLAG_NONE,
		                          FIND_ANY_ORDER,
		                          false)

			for _,it in pairs(direUnits) do
				if (not(it:IsBuilding()) and it ~= caster) then
					hashook = true
					it:AddNewModifier(it, self:GetCaster(), "A11E_hook_back", { duration = 2}) 
					local hModifier = it:FindModifierByNameAndCaster("A11E_hook_back", it)
					if (hModifier ~= nil) then
						hModifier.path = self.path
						hModifier.interval_Count = self.interval_Count
						hModifier.particle = self.particle
						break
					end
					break
				end
			end
			-- 拉到或距離到上限了
			if (self.distance_sum > self.hook_distance or hashook == true) then
				self:StartIntervalThink( -1 )
				return
			end
		end
		
		self.hook_pos = next_hook_pos
	end
end

function A11E_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_disruptor_kinetic_fieldslow.vpcf"
end

function A11E_modifier:IsHidden()
	return true
end

function A11E_modifier:IsDebuff()
	return false
end

function A11E_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function A11T( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = keys.target_points[1]
	local dir = caster:GetCursorPosition() - caster:GetOrigin()
	caster:SetForwardVector(dir:Normalized())
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local distance = ability:GetLevelSpecialValueFor( "distance", ability:GetLevel() - 1 )
	local radius =  ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local collision_radius = ability:GetLevelSpecialValueFor( "collision_radius", ability:GetLevel() - 1 )
	local projectile_speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
	local right = caster:GetRightVector()
	casterLoc = keys.target_points[1] - right:Normalized() * 300
	Timers:CreateTimer( 0.3, function()
		caster:AddNoDraw()
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_A11T", {duration = 3.7} )
	end)
	
	-- Find forward vector
	local forwardVec = targetLoc - casterLoc
	forwardVec = forwardVec:Normalized()
	
	-- Find backward vector
	local backwardVec = casterLoc - targetLoc
	backwardVec = backwardVec:Normalized()
	
	-- Find middle point of the spawning line
	local middlePoint = casterLoc + ( radius * backwardVec )
	
	-- Find perpendicular vector
	local v = middlePoint - casterLoc
	local dx = -v.y
	local dy = v.x
	local perpendicularVec = Vector( dx, dy, v.z )
	perpendicularVec = perpendicularVec:Normalized()

	local sumtime = 0
	-- Create timer to spawn projectile
	Timers:CreateTimer( function()
			-- Get random location for projectile
			for c = 1,4 do
				local random_distance = RandomInt( -radius, radius )
				local spawn_location = middlePoint + perpendicularVec * random_distance
				
				local velocityVec = Vector( forwardVec.x, forwardVec.y, 0 )
				
				-- Spawn projectiles
				local projectileTable = {
					Ability = ability,
					EffectName = "particles/a11t/a11t.vpcf",
					vSpawnOrigin = spawn_location,
					fDistance = distance,
					fStartRadius = collision_radius,
					fEndRadius = collision_radius,
					Source = caster,
					bHasFrontalCone = false,
					bReplaceExisting = false,
					bProvidesVision = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_MECHANICAL,
					vVelocity = velocityVec * projectile_speed
				}
				ProjectileManager:CreateLinearProjectile( projectileTable )
			end
			-- Check if the number of machines have been reached
			if sumtime >= 4 then
				return nil
			else
				sumtime = sumtime + 0.125
				return 0.125
			end
		end
	)
end

function A11T_End( keys )
	local caster = keys.caster
	caster:RemoveNoDraw()
end
