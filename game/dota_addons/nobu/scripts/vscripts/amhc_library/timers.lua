

--[[
本计时器自始自终都是运行着一个计时器，实现一个计时器模拟出子计时器的效果
欲使用本计时器，可直接初始化AMHCInit()，或者自己require本计时器文件

timers( int delay, handle func, [parent]) --延迟一段时间后调用func

timers( int delay, int interval, int count, handle func, [parent]) --延迟一段时间后调用func，按照一定时间间隔循环调用func

timers( int interval, int count, handle func, [parent]) -- 一开始会调用一次func，之后按照一定时间间隔循环调用func，count为-1时为无限循环

注：1.func函数有一个固定的参数，即计时器本身，可以访问计时器的一些属性，如示例2
	2.计时器会随着游戏暂停而暂停，就算是有延迟的计时器，延迟时也是会暂停

计时器属性：
	--计时器id
	timer.id = ''

	-- 计时器周期
	timer.interval = 0.1

	--计时器创建时间
	timer.spawn_time = 0

	-- 计时器已存在时间,不包括延迟的时间
	timer.time = 0

	-- 计时器第一次调用延迟
	timer.delay = 0

	-- 计时器循环次数
	timer.count = -1

	-- 计时器当前循环次数
	timer.current_count = 0

	-- 绑定的单位,单位死亡，计时器将被删除
	timer.partent = nil

	-- 标记是否删除计时器
	timer.is_remove = false

	--函数
	timer.callback = nil

注：如果想要增加或者减少计时器周期，可以直接 timer+1 或者 timer-1 ，如示例2就可以t+1来提高1秒的周期间隔，也就是6秒了

--示例1
timers(5,function()
	print("timers")
end)

--示例2
timers(5,-1,function( t )
	if t.current_count == 5 then
		t:remove()
	end
end)

]]

if timers == nil then
	timers = {}
	timers.timers = {}
	timers.oldTimes = {}
	timers.delay = {}
	timers.__index = timers
	setmetatable(timers,timers)
end

-- 计时器属性
local timers_info = function()
	local mt = {}

	--计时器id
	mt.id = ''

	-- 计时器周期
	mt.interval = 0.1

	--计时器创建时间
	mt.spawn_time = 0

	-- 计时器已存在时间,不包括延迟的时间
	mt.time = 0

	-- 计时器第一次调用延迟
	mt.delay = 0

	-- 计时器循环次数
	mt.count = -1

	-- 计时器当前循环次数
	mt.current_count = 0

	-- 绑定的单位
	mt.partent = nil

	-- 标记是否删除计时器
	mt.is_remove = false

	--函数
	mt.callback = nil

	function mt:__add(a)
		if type(a) == 'number' then
			self.interval = self.interval + a
		end
		return self
	end

	function mt:__sub(a)
		if type(a) == 'number' then
			self.interval = self.interval - a
		end
		return self
	end

	function mt:remove()
		self.is_remove = true
	end

	setmetatable(mt,mt)
	return mt
end

-- 计时器回调函数
local timers_call = function( timer )

	-- 如果循环次数为1直接调用函数
	if timer.count == 1 then
		timer:remove()
	end

	if timer.is_remove then
		return
	end

	timer.time = GameRules:GetGameTime() - timer.spawn_time

	-- 循环次数判断
	if timer.count ~= -1 then
		if timer.current_count >= timer.count-1 then
			timer:remove()
		end
	end
	timer.current_count = timer.current_count + 1

	if timer.callback then timer:callback(timer) end
end

-- 运行计时器
local timers_start = function()
	GameRules:GetGameModeEntity():SetContextThink("timers", function()

		if GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME then
		    return nil
		end

		-- 游戏暂停不作为
		if GameRules:IsGamePaused() then
			return 0.02
		end

		for k,v in pairs(timers.timers) do

			if not v.is_remove then
				-- 当单位死亡删除计时器
				if v.partent then
					if IsValidEntity(v.partent) and v.partent:IsAlive() then
						v:remove()
					end
				end

				-- 先延迟
				if timers.delay[k] ~= nil then
					timers.delay[k] = GameRules:GetGameTime() - v.spawn_time
					if timers.delay[k] >= v.delay then
						timers.delay[k] = nil

						if v.callback ~= nil then v.callback(v) end
						v.current_count = v.current_count + 1
					end
				else
					local time = GameRules:GetGameTime()
					if time - timers.oldTimes[k] >= v.interval then
						timers.oldTimes[k] = time
						timers_call(v)
					end
				end
			else
				timers.timers[k] = nil
			end
		end

		return 0.02
	end, 0)
end
timers_start()--启动

-- 创建计时器
function timers:__call(...)
	local name = DoUniqueString('timers')
	local args = {...}

	local t = timers_info()
	t.id = name
	t.time = GameRules:GetGameTime()
	t.spawn_time = t.time

	if #args == 2 then
		local delay,func,partent = ...
		t.delay = delay
		t.callback = func
		t.count = 1
		t.partent = partent


	elseif #args == 3 then
		local interval,count,func,partent = ...
		t.callback = func
		t.interval = interval
		t.count = count
		t.delay = 0
		t.partent = partent


	elseif #args == 4 then
		local delay,interval,count,func,partent = ...
		t.delay = delay
		t.callback = func
		t.interval = interval
		t.count = count
		t.partent = partent


	end

	timers.oldTimes[name] = t.time
	timers.delay[name] = t.delay
	timers.timers[name] = t

	return t,name
end