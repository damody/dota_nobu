function SetUtilsLevel()
	for i = 0,9 do
		if PlayerResource:IsValidPlayerID(i) then
			local player = PlayerResource:GetPlayer(i)
			if player ~= nil then
				local hero = player:GetAssignedHero() 
				if hero ~= nil then	
					local abi = hero:FindAbilityByName("UtilsAbility_Utils") 
					if abi:GetLevel() <	1 then 
						abi:SetLevel(1)
					end
				end
			end
		end
	end
end
function CreateTreasureMap()
	ShowCustomHeaderMessage("#CustomTaskInfo_1", RandomInt(0, 4) ,0,9) 
	local newItem = CreateItem("item_1202", nil, nil )
	local drop = CreateItemOnPositionSync( RandomVector(RandomInt(0, 3000) ) , newItem )
end
-----------------------------------------------------------------------------------------------------------
--计时器
-----------------------------------------------------------------------------------------------------------
function CustomTimer( timerName,fun,delay )
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString(timerName),function( )
		if GameRules._IsGamePaused then return 0.1 end
		return fun()
	end,delay)
end
--判断游戏是否暂停
function GamePaused()
	old = GameRules:GetGameTime()
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("GamePaused"),function( )
		local new = GameRules:GetGameTime()

		if new == old then
			GameRules._IsGamePaused = true
		else
			GameRules._IsGamePaused = false
		end
		old = new

		return 0.1
	end,0)
end
 
--判断实体有效
function IsValidAndAlive( unit )
	if IsValidEntity(unit) then
		if unit:IsAlive() then
			return true
		else
			return false
		end
	end
	return nil
end

-----------------------------------------------------------------------------------------------------------
 
-----------------------------------------------------------------------------------------------------------
--投掷
-----------------------------------------------------------------------------------------------------------
--Target  		目标
--Center 		中心，可以是单位也可以说点，自己也行哦
--Duration 		持续时间
--Distance 		投掷距离
--Height 		投掷高度
--ShouldStun 	是否击晕
--Fun 			落地后执行的函数
function Knockback( Target,Center,Duration,Distance,Height,ShouldStun,Fun )

	--对参数进行判断
	if type(Target)~="table" or (type(Center) ~= "userdata" and type(Center)~="table") then
		print("Error is Target or Center")
		return
	end
	if type(Duration)~="number" or type(Distance)~="number" or type(Height)~="number" or type(ShouldStun)~="boolean" then
		print("Error is Duration or Distance or Height or ShouldStun")
		return
	end

	if IsValidAndAlive(Target)~=true then
		return
	end

	local _dis = 0
	local _h = 0
	local _dura = 0
	local _time = 0.02
	local _angle = 0
	local _angle_speed = 180/(Duration / _time)
	local _dis_speed = Distance / (Duration / _time)
	local _target_abs = Target:GetAbsOrigin()
	local _center_abs = nil
	if Center.x then
		_center_abs = Center
	else
		if IsValidAndAlive(Center)~=true then return end
		_center_abs = Center:GetAbsOrigin()
	end

	local _face = (_target_abs - _center_abs):Normalized()

	if ShouldStun then
		Target:AddNewModifier(nil,nil,"modifier_stunned",{duration=Duration})
	else
		Target:AddNewModifier(nil,nil,"modifier_rooted",{duration=Duration})
	end

	CustomTimer("Knockback",function( )
		if IsValidAndAlive(Target)~=true then return nil end
		if _dura > Duration then
			local vec = GetGroundPosition(Target:GetAbsOrigin(),Target)
			if type(Fun) == "function" then
				local target_vec = Target:GetOrigin()
				if target_vec.z <= (vec.z+128) then
					Fun()
				end
			end
			if IsValidAndAlive(Target)~=true then return nil end
			Target:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})
			Target:SetAbsOrigin(vec)
			return nil
		end

		--对位移的距离进行累加
		if _dis < Distance then
			_dis = _dis + _dis_speed
		end

		--对高度进行计算
		_angle = _angle_speed + _angle
		_h = Height*math.sin(math.rad(_angle))
		
		--设置位移和高度
		local vec = _target_abs + _face * _dis
		Target:SetAbsOrigin(vec + Target:GetUpVector() * _h)

		_dura = _dura + _time
		return _time
	end,0)
end
function IsAtAngle( caster,target,face,minAngle,maxAngle )
	
	local caster_abs = caster:GetAbsOrigin()
	local target_abs = target:GetAbsOrigin()
	local angle = VectorToAngles(face)
	local angle1 = (angle.y - minAngle%360)
	local angle2 = (angle.y + maxAngle%360)

	local to = (target_abs - caster_abs):Normalized()
	local angle_to = VectorToAngles(to)

	if angle_to.y<angle2 and angle_to.y>angle1 then
		return true
	end

	return false
end

-----------------------------------------------------------------------------------------------------------
function CustomCreateParticle( name,const,target,duration,immediately,fun )
	local p = ParticleManager:CreateParticle(name,const,target)

	CustomTimer("CustomCreateParticle",function( )
		ParticleManager:DestroyParticle(p,immediately)

		if fun then
			if type(fun) == "function" then
				fun()
			end
		end
		return nil
	end,duration)

	return p
end
function SortByKey(argtable) 
    local key_table = {}  
    --取出所有的键  
    local callback_table = {}
    for key,_ in pairs(argtable) do  

        table.insert(key_table,key)  
    end  
    --对所有键进行排序  
    table.sort(key_table)  
    for _,key in pairs(key_table) do  
        table.insert(callback_table,argtable[key])  
    end  
    return callback_table
end
function LoadScriptFunction(Path,FunctionName)
	if Path == nil or FunctionName == nil then return end
	local File = require(Path)
	if _G[FunctionName] == nil then return false end
	return _G[FunctionName]
end
require('Utils/common')