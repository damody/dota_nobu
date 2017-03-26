--加藤段藏

LinkLuaModifier( "C08R_modifier", "scripts/vscripts/heroes/C_Neutral/C08.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "C08R_followthrough", "scripts/vscripts/heroes/C_Neutral/C08.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "C08R_hook_back", "scripts/vscripts/heroes/C_Neutral/C08.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_transparency", "scripts/vscripts/heroes/C_Neutral/C08.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier("modifier_C08D_old", "heroes/modifier_C08D_old.lua", LUA_MODIFIER_MOTION_NONE)

modifier_transparency = class({})

function modifier_transparency:DeclareFunctions()
	return { 
	--MODIFIER_EVENT_ON_ATTACK_LANDED,
	--MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	--MODIFIER_EVENT_ON_ABILITY_EXECUTED 
	}
end

function modifier_transparency:GetModifierInvisibilityLevel()
	return 1
end

function modifier_transparency:IsHidden()
	return false
end

function modifier_transparency:CheckState()
	local state = {
	[MODIFIER_STATE_INVISIBLE] = true
	}
	return state
end


function modifier_transparency:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE 
end

function modifier_transparency:GetEffectName()
	return "particles/items_fx/ghost.vpcf"
end


function C08D_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	caster:AddNewModifier(caster,ability,"modifier_transparency",{duration=20})
	--ability:ApplyDataDrivenModifier( caster, caster, "modifier_transparency", {duration = 20} )
end

function C08D_OnAttack( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local abilityDamage = ability:GetLevelSpecialValueFor( "C08D_Damage", ability:GetLevel() - 1 )
		local abilityDamageType = ability:GetAbilityDamageType()
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			PopupCriticalDamage(target, abilityDamage)
			AMHC:Damage( caster,target,abilityDamage,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end	
		keys.caster:RemoveModifierByName( "modifier_C08D" )
		keys.caster:RemoveModifierByName( "modifier_transparency" )
	end
end



function C08E_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	for i=1,5 do
		local particle = ParticleManager:CreateParticle("particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray_sparks.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
	end

	-- 搜尋
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用

	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		ApplyDamage({
			victim = unit,
			attacker = caster,
			ability = ability,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE,
		})
		if IsValidEntity(unit) then
			local dir = (caster:GetAbsOrigin()-unit:GetAbsOrigin()):Normalized()
			local ifx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_base_attack_explosion_b.vpcf",PATTACH_POINT,unit)
			ParticleManager:SetParticleControlEnt(ifx,3,unit,PATTACH_POINT,"attach_hitloc",unit:GetAbsOrigin()+Vector(0,0,200),true)
			ParticleManager:SetParticleControlForward(ifx,3,dir)
			ParticleManager:ReleaseParticleIndex(ifx)
		end
	end

	local dir = -caster:GetForwardVector()
	local distance = ability:GetSpecialValueFor("C08E_move_distance")
	local spell_point = caster:GetAbsOrigin()
	local target_point = spell_point+dir*distance
	FindClearSpaceForUnit(caster,target_point,false)
end

function C08E_OnUpgrade( keys )
	local caster = keys.caster
	local ability = caster:FindAbilityByName("C08D")
	local level = keys.ability:GetLevel()
	if (ability~= nil and ability:GetLevel() < level+1) then
		ability:SetLevel(level+1)
	end
end




function C08W_OnSpellStart( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
	ability:ApplyDataDrivenModifier(caster,target,"modifier_C08W_bleeding",{})
	ability:ApplyDataDrivenModifier(caster,target,"modifier_C08W_slience",{})
	local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )		
	AddFOWViewer(caster:GetTeamNumber(),target:GetAbsOrigin(),600,3.0,false)
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
end


function modifier_C08W_bleeding_OnIntervalThink( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local abilityDamage = ability:GetSpecialValueFor("damage")
	local abilityDamageType = ability:GetAbilityDamageType()
	local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )	
	StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )	
	if(not target:IsMagicImmune()) then
		if caster:IsAlive() then
			AMHC:Damage( caster,target,abilityDamage,ability:GetAbilityDamageType() )
		else
			AMHC:Damage( caster.donkey,target,abilityDamage,ability:GetAbilityDamageType() )
		end
		--ExecuteOrderFromTable({UnitIndex = target:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_STOP, Queue = false}) 
		target:Stop()
		ability:ApplyDataDrivenModifier(caster,target,"modifier_stunned",{duration = ability:GetSpecialValueFor("stun_time")})
	end
	AddFOWViewer(caster:GetTeamNumber(),target:GetAbsOrigin(),600,3.0,false)
	
end






C08R = class ({})

function C08R:OnSpellStart()
	local caster = self:GetCaster()
	local debuff_duraiton = self:GetSpecialValueFor("flux_duration")
	local dir = self:GetCursorPosition() - caster:GetOrigin()
	caster:SetForwardVector(dir:Normalized())
	caster:AddNewModifier(caster, self, "C08R_modifier", { duration = 2}) 
	caster:AddNewModifier(caster, self, "C08R_followthrough", { duration = 0.3 } )
end

function C08R:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_1 )
	return true
end

--------------------------------------------------------------------------------

function C08R:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
end

function C08R:OnOwnerDied()
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
end


--------------------------------------------------------------------------------
C08R_followthrough = class({})

function C08R_followthrough:IsHidden()
	return true
end


--------------------------------------------------------------------------------

function C08R_followthrough:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end


C08R_hook_back = class({})

--------------------------------------------------------------------------------

function C08R_hook_back:IsHidden()
	return true
end


--------------------------------------------------------------------------------

function C08R_hook_back:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end
function C08R_hook_back:OnIntervalThink()
	if (self.path ~= nil) then
		local target = self:GetParent()
		if IsValidEntity(self:GetParent()) then
			if (self.max_interval_Count >= self.interval_Count) then
				target:SetOrigin(self.path[self.interval_Count])
				self.interval_Count = self.interval_Count + 1
			else
				if self.target ~= nil then
					local order = {UnitIndex = target:entindex(),
									OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
									TargetIndex = self.target:entindex()}
					ExecuteOrderFromTable(order)
				end
				target:AddNewModifier(target,self:GetAbility(),"modifier_phased",{duration=0.1})
				target:RemoveModifierByName("C08R_hook_back")
			end
		end
	end
end
function C08R_hook_back:IsHidden()
	return true
end

function C08R_hook_back:IsDebuff()
	return false
end

function C08R_hook_back:OnCreated( event )
	self:StartIntervalThink(0.04) 
end


C08R_modifier = class ({})

function C08R_modifier:OnCreated( event )
	if IsServer() then
		local ability = self:GetAbility()
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
		if IsValidEntity(self:GetParent()) then
			self.oriangle = self:GetParent():GetAnglesAsVector().y
			self.hook_pos = self:GetParent():GetOrigin()
			self.oripos = self:GetParent():GetOrigin()
			self:StartIntervalThink(0.05) 
		end
	end
end

function C08R_modifier:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		self.interval_Count = self.interval_Count + 1
		
		local angle = math.abs(caster:GetAnglesAsVector().y - self.oriangle)
		--print("angle: "..(angle))
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
		hook_pts = { self.hook_pos }
		if (length > 100) then
			local pts = length / 100 + 1
			for i=1,pts do
				hook_pts[i] = self.hook_pos + vDirection:Normalized() * 100 * i
				--print("pts: ".. hook_pts[i].x.." "..hook_pts[i].y.." "..hook_pts[i].z)
			end
		end

		local next_hook_pos = self.hook_pos + vDirection:Normalized() * length
		self.distance_sum = self.distance_sum + 20 * self.interval_Count
		
		local particle = ParticleManager:CreateParticle("particles/a11/_2pudge_meathook_whale2.vpcf",PATTACH_WORLDORIGIN,caster)
		ParticleManager:SetParticleControl(particle,0, next_hook_pos)
		ParticleManager:SetParticleControl(particle,1,Vector(1.11 - self.interval_Count*0.1,0,0))
		ParticleManager:SetParticleControl(particle,4,Vector(1,0,0))
		ParticleManager:SetParticleControl(particle,5,Vector(1,0,0))
		ParticleManager:SetParticleControl(particle,3,self.hook_pos)
		ParticleManager:ReleaseParticleIndex(particle)
		self.particle[self.interval_Count] = particle
		if self.interval_Count > 3 then
			
			for _,hookpoint in pairs(hook_pts) do
				-- 拉到敵人
				local SEARCH_RADIUS = self.hook_width
				local z = GetGroundHeight(hookpoint, nil)
				hookpoint.z = z
				local direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
		                              hookpoint,
		                              nil,
		                              SEARCH_RADIUS,
		                              DOTA_UNIT_TARGET_TEAM_ENEMY,
		                              DOTA_UNIT_TARGET_ALL,
		                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		                              FIND_ANY_ORDER,
		                              false)
				local hashook = false
				for _,it in pairs(direUnits) do

					if (not it:IsBuilding()) and not string.match(it:GetUnitName(), "com_general") and not string.match(it:GetUnitName(), "warrior_souls") and not it:HasAbility("majia") then
						ApplyDamage({ victim = it, attacker = self:GetCaster(), damage = self.hook_damage, 
							damage_type = self.damage_type, ability = self:GetAbility()})
 						it:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_stunned",{duration = self:GetAbility():GetSpecialValueFor("stun_time")})
						hashook = true
						if (it:HasModifier("modifier_invisible")) then
							it:RemoveModifierByName("modifier_invisible")
						end
						caster:AddNewModifier(caster, self:GetCaster(), "C08R_hook_back", { duration = 2}) 
						caster:AddNewModifier(caster,nil,"modifier_phased",{duration=1})
						local hModifier = caster:FindModifierByNameAndCaster("C08R_hook_back", caster)
						if (hModifier ~= nil) then
							self.path[self.interval_Count + 1] = it:GetAbsOrigin()
							hModifier.path = self.path
							hModifier.max_interval_Count = self.interval_Count + 1
							hModifier.interval_Count = 1
							hModifier.particle = self.particle
							hModifier.target = it
							break
						end
					end
				end
				if (hashook == true) then
					self:StartIntervalThink( -1 )
					return
				end

				-- 拉到友軍
				direUnits = FindUnitsInRadius(caster:GetTeamNumber(),
			                          hookpoint,
			                          nil,
			                          SEARCH_RADIUS,
			                          DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			                          DOTA_UNIT_TARGET_ALL,
			                          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			                          FIND_ANY_ORDER,
			                          false)

				for _,it in pairs(direUnits) do
					if (not(it:IsBuilding()) and it ~= caster and not string.match(it:GetUnitName(), "com_general")) and not it:HasAbility("majia") then
						hashook = true
						caster:AddNewModifier(caster, self:GetCaster(), "C08R_hook_back", { duration = 2}) 
						caster:AddNewModifier(caster,nil,"modifier_phased",{duration=1})
						local hModifier = caster:FindModifierByNameAndCaster("C08R_hook_back", caster)
						if (hModifier ~= nil) then
							self.path[self.interval_Count + 1] = it:GetAbsOrigin()
							hModifier.path = self.path
							hModifier.max_interval_Count = self.interval_Count + 1
							hModifier.interval_Count = 1
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
		end
		self.hook_pos = next_hook_pos
	end
end

function C08R_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_disruptor_kinetic_fieldslow.vpcf"
end

function C08R_modifier:IsHidden()
	return true
end

function C08R_modifier:IsDebuff()
	return false
end

function C08R_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


C08T_EXCLUDE_TARGET_NAME = {
	npc_dota_cursed_warrior_souls	= true,
	npc_dota_the_king_of_robbers	= true,
	com_general = true,
	com_general2 = true,
}



function C08T_OnSpellStart( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	if C08T_EXCLUDE_TARGET_NAME[target:GetUnitName()] == nil then
		StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
		
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
		ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )		
		target:AddNoDraw()
		local dir = caster:GetForwardVector()
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
		caster.last_pos = caster:GetAbsOrigin()
		GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("C08T_timer"), 
			function( )
				if IsValidEntity(target) and target:HasModifier("modifier_C08T_bleeding") then
					if (caster:GetAbsOrigin()-caster.last_pos):Length2D() < 2000 then
						local dir = caster:GetForwardVector()
						FindClearSpaceForUnit(target,caster:GetAbsOrigin(),false)
						target:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})
					end
				end
				return nil
			end, duration-0.05)
		caster.C08T_IsMagicImmune = false
		if target:IsMagicImmune() then
			caster.C08T_IsMagicImmune = true
		end
		ability:ApplyDataDrivenModifier(caster,target,"modifier_C08T_bleeding",{})
	else
		caster:FindAbilityByName("C08T"):EndCooldown()
	end
end

function modifier_C08T_bleeding_OnIntervalThink( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local abilityDamage = ability:GetSpecialValueFor("damage")
	local abilityDamageType = ability:GetAbilityDamageType()
	caster:Heal(abilityDamage,caster)
	StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", caster )	
	if (caster:GetAbsOrigin()-caster.last_pos):Length2D() > 2000 or not caster:IsAlive() then
		target:RemoveModifierByName("modifier_C08T_bleeding")
		FindClearSpaceForUnit(target,caster.last_pos,false)
		target:AddNewModifier(caster,nil,"modifier_phased",{duration=0.1})
	else
		target:SetAbsOrigin(caster:GetAbsOrigin())
		if caster.C08T_IsMagicImmune == false then
			AMHC:Damage(caster,target,abilityDamage,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
		end
	end
	caster.last_pos = caster:GetAbsOrigin()
end


function modifier_C08T_OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	target:RemoveNoDraw()
end


c08d_lock=false
function modifier_C08D_old_duge_OnTakeDamage( event )
	-- Variables

	if IsServer() then
		local damage = event.DamageTaken
		local ability = event.ability
		if ability then
			local caster =ability:GetCaster()
			if damage > caster:GetHealth() and caster:GetMana()>=800 and not c08d_lock then
				c08d_lock=true
				local newHealth = caster:GetMaxHealth() + damage
				local newMana =caster:GetMana()-800
				caster:SetHealth(newHealth)
				caster:SetMana(newMana)
				caster:AddNewModifier(caster, ability, "modifier_C08D_old", {duration = 16})
				caster:AddNewModifier(caster, ability, "modifier_C08D_old_armor", {})
				GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("C08D_old_timer"), 
				function( )
					c08d_lock=false
					return nil
				end, 16)
			end
		end
	end
end




function C08W_old_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local particle = ParticleManager:CreateParticle("particles/item/item_thunderstorms_cloud_dust.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
	local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
		caster:GetAbsOrigin(),			-- 搜尋的中心點
		nil, 							-- 好像是優化用的參數不懂怎麼用
		ability:GetCastRange(),			-- 搜尋半徑
		ability:GetAbilityTargetTeam(),	-- 目標隊伍
		ability:GetAbilityTargetType(),	-- 目標類型
		ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
		FIND_ANY_ORDER,					-- 結果的排列方式
		false) 							-- 好像是優化用的參數不懂怎麼用
	-- 處理搜尋結果
	for _,unit in ipairs(units) do
		if not unit:IsMagicImmune() and not unit:IsBuilding() then
			ApplyDamage({
				victim = unit,
				attacker = caster,
				ability = ability,
				damage = ability:GetSpecialValueFor("C08W_old_Damage"),
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NONE,
			})
			ability:ApplyDataDrivenModifier(caster,unit,"modifier_C08W_old_aoe",nil)
		end
	end
	caster:AddNewModifier(caster,ability,"modifier_transparency",{duration=20})
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("C08W_old_timer"), 
		function( )
			ParticleManager:DestroyParticle(particle,false)
			return nil
		end, 1)
end



function modifier_C08W_old_OnAttack( keys )
	if not keys.target:IsUnselectable() or keys.target:IsUnselectable() then		-- This is to fail check if it is item. If it is item, error is expected
		-- Variables
		local caster = keys.caster
		local target = keys.target
		local ability = keys.ability
		local abilityDamage = ability:GetLevelSpecialValueFor( "C08W_old_trans_Damage", ability:GetLevel() - 1 )
		local abilityDamageType = ability:GetAbilityDamageType()
		if (not target:IsBuilding()) then
			-- Deal damage and show VFX
			local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
			ParticleManager:SetParticleControl( fxIndex, 0, caster:GetAbsOrigin() )
			ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )
			StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
			PopupCriticalDamage(target, abilityDamage)
			AMHC:Damage( caster,target,abilityDamage,AMHC:DamageType( "DAMAGE_TYPE_PHYSICAL" ) )
		end	
		keys.caster:RemoveModifierByName( "modifier_C08W_old" )
		keys.caster:RemoveModifierByName( "modifier_transparency" )
	end
end


function C08E_old_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta.vpcf", PATTACH_CUSTOMORIGIN, caster )
	StartSoundEvent( "Hero_NyxAssassin.Vendetta.Crit", target )
	ParticleManager:SetParticleControl( fxIndex, 0, target:GetAbsOrigin() )
	ParticleManager:SetParticleControl( fxIndex, 1, target:GetAbsOrigin() )		
	--暈眩
	target:AddNewModifier(caster,ability,"modifier_stunned",{duration=1})
	--傷害
	local dmg = ability:GetAbilityDamage()
	AMHC:Damage( caster,target, dmg,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT,0.6)
	counter=0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("C08E_old_timer"), 
	function( )
		AMHC:CreateParticle("particles/a07e/a07e.vpcf",PATTACH_ABSORIGIN,false,target,0.5,nil)
		local pos 
		if IsValidEntity(target) then
			pos = target:GetAbsOrigin()
		else
			pos = ability:GetCursorPosition()
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(),	-- 關係參考
			pos,			-- 搜尋的中心點
			nil, 							-- 好像是優化用的參數不懂怎麼用
			300,			-- 搜尋半徑
			ability:GetAbilityTargetTeam(),	-- 目標隊伍
			ability:GetAbilityTargetType(),	-- 目標類型
			ability:GetAbilityTargetFlags(),-- 額外選擇或排除特定目標
			FIND_ANY_ORDER,					-- 結果的排列方式
			false) 							-- 好像是優化用的參數不懂怎麼用
		-- 處理搜尋結果
		for _,unit in ipairs(units) do
			if not unit:IsMagicImmune() and not unit:IsBuilding() then
				unit:AddNewModifier(caster,ability,"modifier_stunned",{duration=ability:GetSpecialValueFor("stun_duration")})
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = ability:GetSpecialValueFor("damage"),
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		end
		StartSoundEvent( "A07T.attack", target )
		counter=counter+1
		target:Stop()
		if(counter==3)then
			return nil
		end
		return 0.6
	end, 1.1)
end



function C08R_old_OnSpellStart( keys ) 
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetAbsOrigin()
	local point2 = ability:GetCursorPosition() --keys.target_points[1] ability
	local vec = caster:GetForwardVector()
	local dummy = CreateUnitByName("npc_dummy_unit",point2 ,false,nil,nil,caster:GetTeam())
	dummy:AddAbility("majia_vison"):SetLevel(1)
	--modifier
	ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C08R_old_2",nil)
	local particle = ParticleManager:CreateParticle("particles/a19/a19_t.vpcf",PATTACH_POINT,dummy)
	ParticleManager:SetParticleControl(particle,0,point2)
	--紀錄
	dummy.C08R_old_P = particle
	local x1 = point2.x
	local y1 = point2.y
	local x2
	local y2
	local x3
	local y3
	local a1 = nobu_atan2( point,point2 )
	for i=1,4 do
		x2 = x1 + 138*i*math.cos(a1+90*3.14159/180)
		y2 = y1 + 138*i*math.sin(a1+90*3.14159/180)
		x3 = x1 + 138*i*math.cos(a1-90*3.14159/180)
		y3 = y1 + 138*i*math.sin(a1-90*3.14159/180)

			dummy = CreateUnitByName("npc_dummy_unit_Ver2",Vector(x2,y2) ,false,nil,nil,caster:GetTeam())
			dummy:FindAbilityByName("majia"):SetLevel(1)
			dummy:AddAbility("for_no_damage"):SetLevel(1)
			--modifier
			ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C08R_old_2",nil)
			--sound
			particle = ParticleManager:CreateParticle("particles/a19/a19_t.vpcf",PATTACH_POINT,dummy)
			ParticleManager:SetParticleControl(particle,0,Vector(x2,y2))
			--紀錄
			dummy.C08R_old_P = particle

		dummy = CreateUnitByName("npc_dummy_unit_Ver2",Vector(x3,y3) ,false,nil,nil,caster:GetTeam())
		dummy:FindAbilityByName("majia"):SetLevel(1)
		dummy:AddAbility("for_no_damage"):SetLevel(1)
		--modifier
		ability:ApplyDataDrivenModifier(caster,dummy,"modifier_C08R_old_2",nil)
		particle = ParticleManager:CreateParticle("particles/a19/a19_t.vpcf",PATTACH_POINT,dummy)
		ParticleManager:SetParticleControl(particle,0,Vector(x3,y3))
		--紀錄
		dummy.C08R_old_P = particle
	end
end

function modifier_C08R_old_2_OnDestroy( keys )
	ParticleManager:DestroyParticle(keys.target.C08R_old_P,false)
	keys.target:ForceKill(true)
	keys.target:Destroy()
end

