
----------------------
-- 作者：裸奔的代码
-- 参与者：
-- 创建日期：2015/6/11
-- 修改日期：2015/6/11
----------------------

if AMHC == nil then
	AMHC = class({})
end

--初始化
function AMHCInit()

require("amhc_library/KV")

--------------------
--这里定义私有变量--
--------------------

--颜色
local __msg_type = {}
local __color = {
	red 	={255,0,0},
	orange	={255,127,0},
	yellow	={255,255,0},
	green 	={0,255,0},
	blue 	={0,0,255},
	indigo 	={0,255,255},
	purple 	={255,0,255},
}

--------------------------
--从这里开始定义成员函数--
--------------------------

--====================================================================================================
--函数自动类型判断
--如果某个参数可以是多种类型，用/分隔，比如string/number
function AMHC:Reload( _t, _f, _s )

	--记录参数类型
	local params = {}
	for k in string.gmatch(_s,"[^,]+") do
		table.insert(params,k)
	end

	--存储函数
	local func = _t[_f]

	--重写函数
	_t[_f] = function( self,... )
		local args = {...}

		--是否有多余参数
		if #args > #params then
			error("AMHC:".._f.." called with "..tostring(#args).." arguments - expected "..tostring(#params),2)
		end

		--检测类型
		for k,v in pairs(args) do
			local _type = type(v)
			if string.find(params[k],'/') ~= nil then

				local x = false
				for s in string.gmatch(params[k],"[^/]+") do
					if _type ~= s then
						x = true
					else
						x = false
						break
					end
				end
	
				if x then
					error("AMHC:".._f.." param "..tostring(k-1).." is not "..params[k],2)
				end
			else
				if _type ~= params[k] then
					error("AMHC:".._f.." param "..tostring(k-1).." is not "..params[k],2)
				end
			end
		end

		--调用原来的函数
		return func( self,...)
	end
end
--====================================================================================================
--判断实体有效，存活，非存活于一体的函数
--返回true	有效且存活
--返回false	有效但非存活
--返回nil	无效实体
function AMHC:IsAlive( ... )
	local entity = ...
	if IsValidEntity(entity) then
		if entity:IsAlive() then
			return true
		end
		return false
	end
	return nil
end
AMHC:Reload( AMHC, "IsAlive", "table" )
--====================================================================================================


--====================================================================================================
--创建计时器

function AMHC:Timer( ... )
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
AMHC:Reload( AMHC, "Timer", "string,function,number,table" )

--便于实体直接调用
function CBaseEntity:Timer(fun,delay)
	AMHC:Timer( self:GetClassname()..tostring(RandomInt(1,10000)),fun,delay,self )
end

--====================================================================================================


--====================================================================================================
--创建带有计时器的特效，计时器结束删除特效，并有一个callback函数
function AMHC:CreateParticle(...)
	
	local particleName,particleAttach,immediately,owningEntity,duration,callback = ...
	
	local p = ParticleManager:CreateParticle(particleName,particleAttach,owningEntity)

	local time = GameRules:GetGameTime();
	self:Timer(particleName,function()
		if (GameRules:GetGameTime()-time)>=duration then
			ParticleManager:DestroyParticle(p,immediately)
			if callback~=nil then callback() end
			return nil
		end

		return 0.01
	end,0)

	return p
end
AMHC:Reload( AMHC, "CreateParticle", "string,number,boolean,table,number,function" )

--创建带有计时器的特效，只对某玩家显示，计时器结束删除特效，并有一个callback函数
function AMHC:CreateParticleForPlayer(...)
	local particleName,particleAttach,immediately,owningEntity,owningPlayer,duration,callback = ...
	
	local p = ParticleManager:CreateParticleForPlayer(particleName,particleAttach,owningEntity,owningPlayer)

	local time = GameRules:GetGameTime();
	self:Timer(particleName,function()
		if (GameRules:GetGameTime()-time)>=duration then
			ParticleManager:DestroyParticle(p,immediately)
			if callback~=nil then callback() end
			return nil
		end

		return 0.01
	end,0)

	return p
end
AMHC:Reload( AMHC, "CreateParticleForPlayer", "string,number,boolean,table,table,number,function" )
--====================================================================================================


--====================================================================================================
--定义常量
AMHC.MSG_BLOCK 		= "particles/msg_fx/msg_block.vpcf"
AMHC.MSG_ORIT 		= "particles/msg_fx/msg_crit.vpcf"
AMHC.MSG_DAMAGE 	= "particles/msg_fx/msg_damage.vpcf"
AMHC.MSG_EVADE 		= "particles/msg_fx/msg_evade.vpcf"
AMHC.MSG_GOLD 		= "particles/msg_fx/msg_gold.vpcf"
AMHC.MSG_HEAL 		= "particles/msg_fx/msg_heal.vpcf"
AMHC.MSG_MANA_ADD 	= "particles/msg_fx/msg_mana_add.vpcf"
AMHC.MSG_MANA_LOSS 	= "particles/msg_fx/msg_mana_loss.vpcf"
AMHC.MSG_MISS 		= "particles/msg_fx/msg_miss.vpcf"
AMHC.MSG_POISION 	= "particles/msg_fx/msg_poison.vpcf"
AMHC.MSG_SPELL 		= "particles/msg_fx/msg_spell.vpcf"
AMHC.MSG_XP 		= "particles/msg_fx/msg_xp.vpcf"

table.insert(__msg_type,AMHC.MSG_BLOCK)
table.insert(__msg_type,AMHC.MSG_ORIT)
table.insert(__msg_type,AMHC.MSG_DAMAGE)
table.insert(__msg_type,AMHC.MSG_EVADE)
table.insert(__msg_type,AMHC.MSG_GOLD)
table.insert(__msg_type,AMHC.MSG_HEAL)
table.insert(__msg_type,AMHC.MSG_MANA_ADD)
table.insert(__msg_type,AMHC.MSG_MANA_LOSS)
table.insert(__msg_type,AMHC.MSG_MISS)
table.insert(__msg_type,AMHC.MSG_POISION)
table.insert(__msg_type,AMHC.MSG_SPELL)
table.insert(__msg_type,AMHC.MSG_XP)

--显示数字特效，可指定颜色，符号
function AMHC:CreateNumberEffect( ... )
	local entity,number,duration,msg_type,color,icon_type = ...

	--判断实体
	if self:IsAlive(entity)==nil then
		return
	end

	icon_type = icon_type or 9

	--对采用的特效进行判断
	local is_msg_type = false
	for k,v in pairs(__msg_type) do
		if msg_type == v then
			is_msg_type = true;
			break;
		end
	end

	if not is_msg_type then
		error("AMHC:CreateNumberEffect param 3: not valid msg type;example:AMHC.MSG_GOLD",2);
	end

	--判断颜色
	if type(color)=="string" then
		color = __color[color] or {255,255,255}
	else
		if #color ~=3 then
			error("AMHC:CreateNumberEffect param 4: color error; format example:{255,255,255}",2);
		end
	end
	local color_r = tonumber(color[1]) or 255;
	local color_g = tonumber(color[2]) or 255;
	local color_b = tonumber(color[3]) or 255;
	local color_vec = Vector(color_r,color_g,color_b);

	--处理数字
	number = math.floor(number)
	local number_count = #tostring(number) + 1

	--创建特效
    local particle = AMHC:CreateParticle(msg_type,PATTACH_CUSTOMORIGIN_FOLLOW,false,entity,duration)
    ParticleManager:SetParticleControlEnt(particle,0,entity,5,"attach_hitloc",entity:GetOrigin(),true)
    ParticleManager:SetParticleControl(particle,1,Vector(10,number,icon_type))
    ParticleManager:SetParticleControl(particle,2,Vector(duration,number_count,0))
    ParticleManager:SetParticleControl(particle,3,color_vec)
end
AMHC:Reload(AMHC,"CreateNumberEffect","table,number,number,string,table/string,number")
--====================================================================================================


--====================================================================================================
--查找table1中指定的table2
function AMHC:FindTable( src,target )
	if type(src)~="table" and type(target)~="table" then
		error("AMHC:RemoveTable :source or target is not table",2)
	end

	for k,v in pairs(src) do
		if v == target then
			return k,v
		end
	end
	return nil
end

--删除table1中指定的table2
--table1中必须是按照数字进行排列的
function AMHC:RemoveTable( src,target )
	if type(src)~="table" and type(target)~="table" then
		error("AMHC:RemoveTable :source or target is not table",2)
	end

	local k = self:FindTable( src,target )

	if k == nil then
		error("AMHC:RemoveTable :the source table have not target table",2)
	end

	if type(k) ~= "number" then
		error("AMHC:RemoveTable :the source table exist Non-numeric mark's element",2)
	end

	return table.remove(src,k)
end
--====================================================================================================


--====================================================================================================
--创建单位
function AMHC:CreateUnit( ... )
	local unitName,origin,face,owner,teamNumber,callback = ...
	
	--创建单位
	local unit = CreateUnitByName(unitName,origin,true,nil,nil,teamNumber)

	if unit then

		--设置单位面朝方向
		if type(face)=="number" then
			unit:SetAngles(0,face,0)
		elseif type(face)=="userdata" then
			unit:SetForwardVector(face)
		end

		--如果有召唤者
		if owner ~= nil then
			unit:SetOwner(owner)
			unit:SetParent(owner,owner:GetUnitName())
			unit:SetControllableByPlayer(owner:GetPlayerOwnerID(),true)
		end
	end

	--回调函数
	if callback ~= nil then
		callback(unit)
	end

	return unit
end
AMHC:Reload( AMHC, "CreateUnit", "string,userdata,userdata,table,number,function" )
--====================================================================================================


--====================================================================================================
--复活英雄
function AMHC:RespawnHero( ... )
	local hero,origin = ...

	if not hero:IsHero() then
		error("AMHC:RespawnHero error: this unit is not hero",2)
	end
	if self:IsAlive(hero)==false then
		hero:RespawnHero(true,true,true)
		hero:SetAbsOrigin(origin)
		FindClearSpaceForUnit(hero, origin, true)
	end
end
AMHC:Reload( AMHC, "RespawnHero", "table,userdata" )
--====================================================================================================


--====================================================================================================
--给予玩家金钱
function AMHC:GivePlayerGold( playerid,gold )
	local player = PlayerResource:GetPlayer(playerid)

	if player then
		local hero = player:GetAssignedHero()

		if hero then
			hero:EmitSoundParams("General.Sell",200,200,1)
			PlayerResource:SetGold(playerid,PlayerResource:GetReliableGold(playerid) + gold,true)
			self:CreateNumberEffect( hero,gold,1,self.MSG_GOLD,"yellow",0 )
		end
	end
end
AMHC:Reload( AMHC, "GivePlayerGold", "number,number" )
--====================================================================================================


--====================================================================================================
--伤害API简化
--AMHC:Damage( attacker,victim,damage,damageType,[percent] )
--@attacker 伤害来源
--@victim 受害者
--@damage 伤害
--@damageType 伤害类型
--@scale 可选参数，伤害的比例

function AMHC:Damage( ... )
	local attacker,victim,damage,damageType,scale,show = ...

	if self:IsAlive(attacker)~=true or self:IsAlive(victim)~=true then
		return nil
	end

	if type(damage) == "string" then
		if damage == "health" then
			damage = victim:GetHealth()
		elseif damage == "health_attacker" then
			damage = attacker:GetHealth()
		elseif damage == "max_health" then
			damage = victim:GetMaxHealth()
		elseif damage == "max_health_attacker" then
			damage = attacker:GetMaxHealth()
		elseif damage == "mana" then
			damage = victim:GetMana()
		elseif damage == "mana_attacker" then
			damage = attacker:GetMana()
		elseif damage == "max_mana" then
			damage = victim:GetMaxMana()
		elseif damage == "max_mana_attacker" then
			damage = attacker:GetMaxMana()
		end
	end

	scale = scale or 1

	if scale<0 then
		scale = 1
	end

	damage = (damage * scale)

	if show then
		self:CreateNumberEffect(victim,damage,1,self.MSG_DAMAGE,'red')
	end

	local damageTable = {
		victim = victim,
		attacker = attacker,
		damage = damage,
		damage_type = damageType,
	}
	
	ApplyDamage(damageTable)
end
AMHC:Reload(AMHC,"Damage","table,table,number/string,number,number,string/number/boolean")

--提供一个便利的接口
function CDOTA_BaseNPC:Damage( victim,damage,damageType,scale )
	AMHC:Damage( self,victim,damage,damageType,scale )
end

--匹配伤害类型
function AMHC:DamageType( _type )
	if _type == "DAMAGE_TYPE_MAGICAL" then
		return DAMAGE_TYPE_MAGICAL
	elseif _type == "DAMAGE_TYPE_PHYSICAL" then
		return DAMAGE_TYPE_PHYSICAL
	elseif _type == "DAMAGE_TYPE_PURE" then
		return DAMAGE_TYPE_PURE
	else
		error("AMHC:Damage:DamageType is error",2)
	end
end
--====================================================================================================


--====================================================================================================
--模型增大，并在一段时间内恢复原样
--@unit 单位
--@scale 增加比例,在1.0和5.0之间
--@duration 持续时间
function AMHC:AddModelScale( ... )
	local unit,scale,duration = ...

	if scale<1.0 and scale>5.0 then
		return
	end

	if self:IsAlive(unit)~=true then
		return
	end

	if unit._amhc_AddModelScale_first == nil then
		unit._amhc_AddModelScale_first = true
		unit._amhc_AddModelScale_min_scale = unit:GetModelScale()
	end

	local unit_scale = unit:GetModelScale()
	local maxScale = unit_scale*scale
	local speed = 0.03
	local time = GameRules:GetGameTime()
	local _add = unit_scale

	local deah = function()
		if AMHC:IsAlive(unit) ~= true then
			return false
		end
		return true
	end

	AMHC:Timer("AddModelScale",function( )--逐渐增大模型

		if not deah() then
			unit:SetModelScale(unit._amhc_AddModelScale_min_scale)
			return nil
		end

		if _add <= maxScale then
			_add = _add + speed
			unit:SetModelScale(_add)
		else
			AMHC:Timer("AddModelScale",function()--持续时间内

				if not deah() then
					unit:SetModelScale(unit._amhc_AddModelScale_min_scale)
					return nil
				end
				
				if GameRules:GetGameTime()-time>=duration then

					AMHC:Timer("AddModelScale",function()--逐渐减小模型

						if not deah() then
							unit:SetModelScale(unit._amhc_AddModelScale_min_scale)
							return nil
						end

						if _add > unit._amhc_AddModelScale_min_scale then
							_add = _add - speed
							unit:SetModelScale(_add)
						else
							return nil
						end
						
						return 0.01
					end,0)

					return nil
				end

				return 0.01
			end,0)

			return nil
		end

		return 0.01
	end,0)
end
AMHC:Reload(AMHC,"AddModelScale","table,number,number")
--====================================================================================================


--====================================================================================================
--增加或减少modifier数量
function AMHC:AddOrLowModifierCount( caster,ability,modifierName,_type,count )
end
AMHC:Reload(AMHC,"AddOrLowModifierCount","table,table,string,string,number")
--====================================================================================================


--====================================================================================================
--移动镜头
function AMHC:SetCamera( playerid,entity )
	PlayerResource:SetCameraTarget(playerid,entity)
	self:Timer("SetCamera",function()
		PlayerResource:SetCameraTarget(playerid,nil)
		return nil
	end,0.01)
end
AMHC:Reload(AMHC,"SetCamera","number,table")
--====================================================================================================


--====================================================================================================
--停止播放音效，两个接口，一个KV一个lua

--伤害系统
--触发器
--位移运动
--椭圆运动
--抛物运动
--同步技能等级
--增加或者减少modifier的数字
--弹射函数
--恢复生命值
--净化

--====================================================================================================
setmetatable(AMHC,AMHC)
end