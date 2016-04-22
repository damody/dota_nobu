require("utils/utils_print")
require('utils/timers')
function fengbaozhizhang_01(keys)  --风暴之杖  无需修改
	-- body
	local height = 380
	local caster=EntIndexToHScript(keys.caster_entindex)
	local target=keys.target
	target:Purge(true,true,true,false,true)
	local target_point =target:GetOrigin()
	local ptc1 = ParticleManager:CreateParticle("particles/fengbaozhizhang/cyclone.vpcf", PATTACH_CUSTOMORIGIN, hIceEffect) 	
	    ParticleManager:SetParticleControl(ptc1, 0,target_point)
	    ParticleManager:SetParticleControl(ptc1, 1, target_point)
    fengbaozhizhang_xuanzhuan(target,height)
    fengbaozhizhang_up(target)
    Timers:CreateTimer(4.25,function()
    	-- body
    	fengbaozhizhang_down(target)
    	ParticleManager:DestroyParticle(ptc1,false)
    	return nil
    end)   	
end
function fengbaozhizhang_xuanzhuan(target,height)
	-- body
	local now_height = 0
	local over = false 
	local forwardvec = target:GetForwardVector()
	local pervec = Vector(0,0,60)
	local origin = target:GetAbsOrigin()
	Timers:CreateTimer(4.4,function()
		-- body
		over = true
	end)
	ang_left =QAngle(0, 80, 0)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("fengbaozhizhang_01"),function()  	 
	    point_rotate = RotatePosition(origin, ang_left, forwardvec)
	    target:SetForwardVector(point_rotate)
	    forwardvec=forwardvec+point_rotate
		if over == true then return nil end 
	    return 0.01
    end,0)
end
function fengbaozhizhang_up(target)
	-- body
	local target_ori = target:GetAbsOrigin()
    target:SetAbsOrigin(target_ori+Vector(0,0,380))
end
function fengbaozhizhang_down(target)  --耗时0.5秒
	-- body
	  local target_ori = target:GetAbsOrigin() 
	  local delta = 0
      GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("fengbaozhizhang_02"),function()  	 
	    local target_ori = target:GetAbsOrigin()
	    target:SetAbsOrigin(target_ori-Vector(0,0,36)) 
	    delta=delta + 36
	    if delta>360 then 
	    	target:SetAbsOrigin(GetGroundPosition(target_ori,target))
	    	return nil 
	    end 
	    return 0.02
    end,0)
end