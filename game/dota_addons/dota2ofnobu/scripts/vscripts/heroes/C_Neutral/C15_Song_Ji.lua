
function test( keys )
	local caster = keys.caster

	DeepPrintTable(keys)

end


function C15W( keys )
	local caster = keys.caster
	local target = keys.target
	local mana = target:GetMana()
	local time = keys.ability:GetLevel() + 2
	target:SetMana(0)
	Timers:CreateTimer( time, function()
		target:SetMana(mana+target:GetMana())
		return nil
	end )

	caster:AddSpeechBubble(1,"    喜歡我嗎?",3.0,0,-50)
end

function C15E( keys )
	local caster = keys.caster
	local target = keys.target
	local heal = 200 + 100 * keys.ability:GetLevel()

	if caster == target then
		caster:Heal(heal,caster)
		--AMHC:CreateNumberEffect(caster,miss,2,AMHC.MSG_MISS ,"red",10)
		PopupNumbers(target, "miss", Vector(255, 0, 0), 1.0, nil, POPUP_SYMBOL_PRE_MISS, nil ,true)
		--AMHC:CreateNumberEffect(caster,heal,2,AMHC.MSG_HEAL,"green",0)
	else
		target:Heal(heal,caster)
		AMHC:CreateNumberEffect(target,heal,2,AMHC.MSG_HEAL,"green",0)
		caster:Heal(heal/2,caster)
		AMHC:CreateNumberEffect(caster,heal/2,2,AMHC.MSG_HEAL,"green",0)
	end

	-- caster:AddSpeechBubble(1,"    婉約誓言",3.0,0,-50)
end

--[[
	Author: Noya
	Date: April 5, 2015.
	FURION CAN YOU TP TOP? FURION CAN YOU TP TOP? CAN YOU TP TOP? FURION CAN YOU TP TOP? 
]]
function Teleport( event )
	local caster = event.caster
	--local point = event.target_points[1]
	local point = event.target:GetAbsOrigin()
	
    FindClearSpaceForUnit(caster, point, true)
    caster:Stop() 
    EndTeleport(event)   
end

function CreateTeleportParticles( event )
	local caster = event.caster
	local point = event.target:GetAbsOrigin()
	local particleName = "particles/units/heroes/hero_furion/furion_teleport_end.vpcf"
	caster.teleportParticle = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(caster.teleportParticle, 1, point)	

	--紀錄單位
	caster.C15D_Target = event.target
end

function EndTeleport( event )
	local caster = event.caster
	local target = event.target
	ParticleManager:DestroyParticle(caster.teleportParticle, false)
	caster:StopSound("Hero_Furion.Teleport_Grow")

	--刪除buff
	caster.C15D_Target:RemoveModifierByName("modifier_C15D")
end