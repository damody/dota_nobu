

if DamageSystem == nil then
	DamageSystem = {}

	setmetatable(DamageSystem,DamageSystem)

	DamageSystem.funcs = nil
end

--获取值
function DamageSystem:GetValue( mt,str )
	if self:IsChar(str) then return str end
	if tonumber(str) then return tonumber(str) end
	if self.funcs == nil then return 0 end
	if self.funcs[str] == nil then return 0 end
	return self.funcs[str](mt)
end

--判断字符
function DamageSystem:IsChar( s )
	return s == '+' or s == '-' or s == '*' or s == '/' or s == '(' or s == ')' or s == '%'
end

--初始化
function DamageSystem:Init( data )
	vlua.tableadd(self,data)
end

--数据处理
function DamageSystem:data( mt,str )
	local t = {}

	--分割字符串
	local s = ''
	for i=1,#str do
		local c = string.sub(str,i,i)

		if c == ' ' then c = '' end

		if self:IsChar(c) then

			if #s ~= 0 then table.insert(t,s) end

			table.insert(t,c)
			s = ''
		else
			s = s..c
		end
	end
	if #s ~= 0 then table.insert(t,s) end

	--转换数据
	for k,v in pairs(t) do
		local val = self:GetValue(mt,v)
		if val then t[k] = val end
	end

	return t
end

--运算
function DamageSystem:think( t )
	local o = ''

	for k,v in pairs(t) do
		o = o..tostring(v)
	end

	return loadstring('return '..o)(),o
end

--获取伤害类型，用于字符串转换
function DamageSystem:GetType( str )
	return loadstring('return '..tostring(str))()
end

--调用
function DamageSystem:__call( ... )

	local args = {...}

	if #args == 2 then
		local mt,str = ...

		if AMHC:IsAlive(mt.unit) ~= true then
			return 0
		end

		local data = self:data(mt,str)
		local n,o = self:think(data)

		print('DamageSystem:',str,'-->',o..' = '..tostring(n),mt.unit:GetUnitName())

		if mt.victim ~= nil and type(mt.victim) == 'table' and mt.damage_type ~= nil then
			return ApplyDamage
			{
				victim = mt.victim,
				attacker = mt.unit,
				damage = n or 0,
				damage_type = self:GetType(mt.damage_type) or DAMAGE_TYPE_PURE,
			}
		end

		return n

	elseif #args == 4 then
		local from,to,damage,damageType = ...

		return ApplyDamage
		{
			victim = to,
			attacker = from,
			damage = damage,
			damage_type = damageType,
		}
	end
end