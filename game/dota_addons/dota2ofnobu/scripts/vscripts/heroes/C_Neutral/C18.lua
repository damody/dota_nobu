function C18D_OnAbilityExecuted( keys )
	-- 開關型技能不能用
	if keys.event_ability:IsToggle() then return end
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_C18D") then
		local handle = caster:FindModifierByName("modifier_C18D")
		if handle then
			local c = handle:GetStackCount()
			c = c + 1
			ability:ApplyDataDrivenModifier(caster,caster,"modifier_C18D",nil)
			handle:SetStackCount(c)
		end
	else
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_C18D",nil)
		local handle = caster:FindModifierByName("modifier_C18D")
		if handle then
			handle:SetStackCount(1)
		end
	end
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		if item ~= nil then
			local itemName = item:GetName()
			if itemName == "item_flash_ring" or itemName == "item_flash_shoes" or itemName == "item_magic_ring" then
				if item:IsCooldownReady() then
					item:StartCooldown(3)
				end
			end
		end
	end
end

function C18D_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_C18D") then
		local handle = caster:FindModifierByName("modifier_C18D")
		if handle then
			local c = handle:GetStackCount()
			
			local base = ability:GetSpecialValueFor("base")
			local lvbuff = ability:GetSpecialValueFor("lvbuff")*caster:GetIntellect()
			local dmg = (base+lvbuff)*c
			local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
			nil,  400 , DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE, 0, false)

			-- 處理搜尋結果
			for _,unit in ipairs(units) do
				unit:Stop()
				ApplyDamage({
					victim = unit,
					attacker = caster,
					ability = ability,
					damage = dmg,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage_flags = DOTA_DAMAGE_FLAG_NONE,
				})
			end
		end
	end
end

function C18W_OnSpellStart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	caster.C18W = {}
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C18W",{duration = duration})
end

function C18W_OnIntervalThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("radius")
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(),
			nil,  radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for i,unit in pairs(units) do
		if unit.C18W_mark == nil then
			unit.C18W_mark = true
			table.insert(caster.C18W, unit)
		end
	end
	for i,unit in pairs(caster.C18W) do
		unit:SetAbsOrigin(caster:GetAbsOrigin()-caster:GetForwardVector()*100)
		unit:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	end
end

function C18W_OnDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("duration")
	for i,unit in pairs(caster.C18W) do
		unit.C18W_mark = nil
		unit:AddNewModifier(caster,ability,"modifier_phased",{duration=0.1})
	end
end

function C18E_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level  = keys.ability:GetLevel()
	--move
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())
	if not target:IsMagicImmune() then
		AMHC:Damage( caster,target, ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
	end
	if ability.count == nil then
		ability.count = 1
		ability:EndCooldown()
		Timers:CreateTimer(4, function() 
			if ability:IsCooldownReady() then
				ability:StartCooldown(8)
			end
			ability.count = nil
		end)
	end
end

function C18R_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	AMHC:Damage( caster,caster,caster:GetHealth()*0.1,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
				caster:RemoveModifierByName(v:GetName())
			end
		end
	end
	ability:ApplyDataDrivenModifier(caster,caster,"modifier_C18R",{duration = duration})
end

function C18R_OnDestroy( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local am = caster:FindAllModifiers()
	for _,v in pairs(am) do
		if IsValidEntity(v:GetCaster()) and v:GetParent().GetTeamNumber ~= nil then
			if v:GetParent():GetTeamNumber() ~= caster:GetTeamNumber() or v:GetCaster():GetTeamNumber() ~= caster:GetTeamNumber() then
				caster:RemoveModifierByName(v:GetName())
			end
		end
	end
end

function C18T_OnSpellStart( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local allHeroes = HeroList:GetAllHeroes()
	local delay = ability:GetSpecialValueFor("delay")
	local count = ability:GetSpecialValueFor("count")
	local percent = ability:GetSpecialValueFor("percent")
	local c = 0
	Timers:CreateTimer(0, function() 
		for k, unit in pairs( allHeroes ) do
			if unit:GetPlayerID() and unit:GetTeam() ~= caster:GetTeam() then
				AddFOWViewer(caster:GetTeamNumber(), unit:GetAbsOrigin(), 300, 1, false)
				local ifx = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5_gold/luna_eclipse_impact_moonfall_gold.vpcf",PATTACH_ABSORIGIN_FOLLOW,unit)
				ParticleManager:SetParticleControlEnt(ifx,0,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
				ParticleManager:SetParticleControlEnt(ifx,1,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
				ParticleManager:SetParticleControlEnt(ifx,2,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
				ParticleManager:SetParticleControlEnt(ifx,5,unit,PATTACH_ABSORIGIN_FOLLOW,"attach_hitloc",Vector(0,0,0),true)
				ParticleManager:ReleaseParticleIndex(ifx)
				if unit:GetHealthPercent() > percent then
					AMHC:Damage( caster,unit,ability:GetAbilityDamage()*1.5,AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				else
					AMHC:Damage( caster,unit,ability:GetAbilityDamage(),AMHC:DamageType( "DAMAGE_TYPE_MAGICAL" ) )
				end
			end
		end
		c = c + 1
		if c < count then
			return delay
		end
		end)
	
end
