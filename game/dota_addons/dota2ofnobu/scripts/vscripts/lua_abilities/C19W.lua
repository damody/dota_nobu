if C19W == nil then
	C19W = class({})
end

--<<libery>>
--创建计时器
function C19W:Timer( ... )
	local name,fun,delay,entity = ...

	delay = delay or 0

	local ent = nil;
	if(entity ~= nil)then
		if self:IsAlive(entity)==nil then
			error("AMHC:Timer param 3: not valid entity",2);
		end
		ent = entity;
	else
		ent = GameRules:GetGameModeEntity();
	end

	local time = GameRules:GetGameTime()
	ent:SetContextThink(DoUniqueString(name),function( )

		if GameRules:GetGameTime()-time >= delay then
			ent:SetContextThink(DoUniqueString(name),function( )

				if not GameRules:IsGamePaused() then
					return fun();
				end

				return 0.01
			end,0)
			return nil
		end

		return 0.01
	end,0)
		
end
--<<endlibery>>

function C19W:OnSpellStart()
	local caster = self:GetCaster()
	local  id	 = u:GetPlayerID() --獲取玩家ID

	--劍刃風暴定義
	local modifierData = {
		duration = self:GetDuration(),
		damage = self:GetAbilityDamage()
	}
	caster:AddNewModifier( caster, self, "modifier_juggernaut_blade_fury", modifierData )	

	--播放動作
	caster:StartGestureWithPlaybackRate( ACT_GAUSS_SPINCYCLE, 1 

	--兩秒鐘後停止撥放動作
	--timer
	C19W:Timer( "C19W"..tostring(id),function( )
		caster:StartGesture( ACT_DOTA_IDLE )
		return nil
	end,2.0)
end



