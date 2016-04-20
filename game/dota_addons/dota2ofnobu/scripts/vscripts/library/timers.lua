	print("@@@ : timers.lua Init ")


	--[[

		計時器函數Timer
		調用方法：
		Timer.Wait '5秒後打印一次' (5,
			function()
				print '我已經打印了一次文本'
			end
		)

		Timer.Loop '每隔1秒打印一次,一共打印5次' (1, 5,
			function(i)
				print('這是第' .. i .. '次打印')
				if i == 5 then
					print('我改變主意了,我還要打印10次,但是間隔降低為0.5秒')
					return 0.5, i + 10
				end
				if i == 10 then
					print('我好像打印的太多了,算了不打印了')
					return true
				end
			end
		)
	]]

	--全局計時器表
	Timer = {}
	
	local Timer = Timer

	setmetatable(Timer, Timer)

	function Timer.Wait(name)
		--[[if not dota_base_game_mode then
	        print('WARNING: Timer created too soon!')
	        return
	    end]]--
	    
		return function(t, func)
			local ent	= GameRules:GetGameModeEntity()

			ent:SetThink(func, DoUniqueString(name), t)
		end
	end

	function Timer.Loop(name)
		--[[if not dota_base_game_mode then
	        print('WARNING: Timer created too soon!')
	        return
	    end]]--
	    
		return function(t, count, func)
			if not func then
				count, func = -1, count
			end
			
			local times = 0
			local function func2()
				times 				= times + 1
				local t2, count2	= func(times)
				t, count = t2 or t, count2 or count
				
				if t == true or times == count then
					return nil
				end

				return t
			end
			
			local ent 	= GameRules:GetGameModeEntity()
			
			ent:SetThink(func2, DoUniqueString(name), t)
		end
	end

	TIMERS_THINK = 0.01

	if Timers == nil then
	  print ( '[Timers] creating Timers' )
	  Timers = {}
	  Timers.__index = Timers
	end

	function Timers:new( o )
	  o = o or {}
	  setmetatable( o, Timers )
	  return o
	end

	function Timers:start()
	  Timers = self
	  self.timers = {}
	  
	  local ent = Entities:CreateByClassname("info_target") -- Entities:FindByClassname(nil, 'CWorld')
	  ent:SetThink("Think", self, "timers", TIMERS_THINK)
	end

	function Timers:Think()
	  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
	    return
	  end

	  -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
	  local now = GameRules:GetGameTime()

	  -- Process timers
	  for k,v in pairs(Timers.timers) do
	    local bUseGameTime = true
	    if v.useGameTime ~= nil and v.useGameTime == false then
	      bUseGameTime = false
	    end
	    local bOldStyle = false
	    if v.useOldStyle ~= nil and v.useOldStyle == true then
	      bOldStyle = true
	    end

	    local now = GameRules:GetGameTime()
	    if not bUseGameTime then
	      now = Time()
	    end

	    if v.endTime == nil then
	      v.endTime = now
	    end
	    -- Check if the timer has finished
	    if now >= v.endTime then
	      -- Remove from timers list
	      Timers.timers[k] = nil
	      
	      -- Run the callback
	      local status, nextCall = pcall(v.callback, GameRules:GetGameModeEntity(), v)

	      -- Make sure it worked
	      if status then
	        -- Check if it needs to loop
	        if nextCall then
	          -- Change its end time

	          if bOldStyle then
	            v.endTime = v.endTime + nextCall - now
	          else
	            v.endTime = v.endTime + nextCall
	          end

	          Timers.timers[k] = v
	        end

	        -- Update timer data
	        --self:UpdateTimerData()
	      else
	        -- Nope, handle the error
	        Timers:HandleEventError('Timer', k, nextCall)
	      end
	    end
	  end
	  return TIMERS_THINK
	end

	function Timers:HandleEventError(name, event, err)
	  print(err)

	  -- Ensure we have data
	  name = tostring(name or 'unknown')
	  event = tostring(event or 'unknown')
	  err = tostring(err or 'unknown')

	  -- Tell everyone there was an error
	  --Say(nil, name .. ' threw an error on event '..event, false)
	  --Say(nil, err, false)

	  -- Prevent loop arounds
	  if not self.errorHandled then
	    -- Store that we handled an error
	    self.errorHandled = true
	  end
	end

	function Timers:CreateTimer(name, args)
	  if type(name) == "function" then
	    args = {callback = name}
	    name = DoUniqueString("timer")
	  elseif type(name) == "table" then
	    args = name
	    name = DoUniqueString("timer")
	  elseif type(name) == "number" then
	    args = {endTime = name, callback = args}
	    name = DoUniqueString("timer")
	  end
	  if not args.callback then
	    print("Invalid timer created: "..name)
	    return
	  end


	  local now = GameRules:GetGameTime()
	  if args.useGameTime ~= nil and args.useGameTime == false then
	    now = Time()
	  end

	  if args.endTime == nil then
	    args.endTime = now
	  elseif args.useOldStyle == nil or args.useOldStyle == false then
	    args.endTime = now + args.endTime
	  end

	  Timers.timers[name] = args
	end

	function Timers:RemoveTimer(name)
	  Timers.timers[name] = nil
	end

	function Timers:RemoveTimers(killAll)
	  local timers = {}

	  if not killAll then
	    for k,v in pairs(Timers.timers) do
	      if v.persist then
	        timers[k] = v
	      end
	    end
	  end

	  Timers.timers = timers
	end

	Timers:start()

