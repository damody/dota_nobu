print("nobu:util")

--【particle】
function check_particle_alive(particle)
  --【Timer】
	Timers:CreateTimer(1,function()
    if particle ~= nil then
      print("particle is alive :" .. tostring(particle))
  		return 1
    else
      print("particle is destroy")
      return nil
    end
	end)
end

function NobuDestoryParticle (particle,duration)
  Timers:CreateTimer(duration,function()
    print("destory")
    ParticleManager:DestroyParticle(particle,true)
  end)
end

function NobuDummyCreateSound (...)
  local caster,point,sound = ...
  -- Dummy
  local dummy = CreateUnitByName("hide_unit", point, false, caster, caster, caster:GetTeam())
   --添加馬甲技能
  dummy:AddAbility("majia"):SetLevel(1)
  StartSoundEvent( sound, dummy )
  --刪除馬甲
  Timers:CreateTimer( 0.01, function()
    dummy:ForceKill( true )
    return nil
  end )
end
