	bj_RADTODEG                      = 180.0/3.14159
	bj_DEGTORAD                      = 3.14159/180.0


function nobu_atan2( point,point2 )
	return math.atan2(point.y-point2.y,point.x-point2.x)
	-- body
end

function nobu_distance( point,point2 )
	return math.ceil(math.sqrt((point.x-point2.x)^2+(point.y-point2.y)^2))
	--math.sqrt(math.pow(point.y-point2.y, point.x-point2.x),2)
	-- body
end

function nobu_distance2( point, point2 )
	local dx = point.x - point2.x
	local dy = point.y - point2.y
	return math.sqrt( dx * dx + dy * dy )
end

function nobu_move( point, point2 , distance )
	local rad = math.atan2(point2.y-point.y,point2.x-point.x)
	return Vector(point.x+distance*math.cos(rad) ,  point.y+distance*math.sin(rad) , point.z)
end


function nobu_move_ver2( point, distance ,rad)
	return Vector(point.x+distance*math.cos(rad) ,  point.y+distance*math.sin(rad) , point.z)
end

function nobu_radtodeg( rad)
	return rad * bj_RADTODEG
end

function nobu_degtorad( deg)
	return deg * bj_DEGTORAD
end

function nobu_Normalized(point, point2)
	return (point2 - point):Normalized()
end

function GetRadBetweenTwoVec2D(a,b)
    local y = b.y - a.y
    local x = b.x - a.x
    return math.atan2(y,x)
end

function GetDistanceBetweenTwoVec2D(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function GetDistance(ent1,ent2)
     local pos_1=ent1:GetOrigin()
     local pos_2=ent2:GetOrigin()
     local x_=(pos_1[1]-pos_2[1])^2
     local y_=(pos_1[2]-pos_2[2])^2
     local dis=(x_+y_)^(0.5)
     return dis
end

--aVec:原点向量
--rectOrigin：单位原点向量
--rectWidth：矩形宽度
--rectLenth：矩形长度
--rectRad：矩形相对Y轴旋转角度
function IsRadInRect(aVec,rectOrigin,rectWidth,rectLenth,rectRad)
    local aRad = GetRadBetweenTwoVec2D(rectOrigin,aVec)
    local turnRad = aRad + (math.pi/2 - rectRad)
    local aRadius = GetDistanceBetweenTwoVec2D(rectOrigin,aVec)
    local turnX = aRadius*math.cos(turnRad)
    local turnY = aRadius*math.sin(turnRad)
    local maxX = rectWidth/2
    local minX = -rectWidth/2
    local maxY = rectLenth
    local minY = 0
    if(turnX<maxX and turnX>minX and turnY>minY and turnY<maxY)then
        return true
    else
        return false
    end
    return false
end

function IsRadBetweenTwoRad2D(a,rada,radb)
    local math2pi = math.pi * 2
    rada = rada + math2pi
    radb = radb + math2pi
    a = a + math2pi
    local maxrad = math.max(rada,radb)
    local minrad = math.min(rada,radb)
    if(a<maxrad and a>minrad)then
        return true
    end
    return false
end

function table.nums(table)
    if type(table) ~= "table" then return nil end
    local l = 0
    for k,v in pairs(table) do
        l = l+1
    end
    return l
end

function IsNumberInTable(Table,t)
    if Table == nil then return false end
    if type(Table) ~= "table" then return false end
    for i= 1,#Table do
        if t == Table[i] then
            return true
        end
    end
    return false
end

function IsRadInRect(aVec,rectOrigin,rectWidth,rectLenth,rectRad)
    local aRad = GetRadBetweenTwoVec2D(rectOrigin,aVec)
    local turnRad = aRad + (math.pi/2 - rectRad)
    local aRadius = GetDistanceBetweenTwoVec2D(rectOrigin,aVec)
    local turnX = aRadius*math.cos(turnRad)
    local turnY = aRadius*math.sin(turnRad)
    local maxX = rectWidth/2
    local minX = -rectWidth/2
    local maxY = rectLenth
    local minY = 0
    if(turnX<maxX and turnX>minX and turnY>minY and turnY<maxY)then
        return true
    else
        return false
    end
    return false
end

function  ApplyProjectile(keys,castvec,endvec,File)
--  local benti = Entities:FindByModel(sven_soul,"juggernaut.vmdl")
    --local testtable = FindAllByModel("juggernaut.vmdl")
--  sven_soul:SetAnimation("ACT_DOTA_ATTACK")
    local caster = keys.caster
    local vecCaster = caster:GetOrigin()
    local point = 1/#endvec*endvec
    local targetPoint = endvec
    local forwardVec = caster:GetForwardVector()
    local knifeTable = {
    Ability = keys.ability,
    fDistance = keys.DamageRadius,
    fStartRadius = 0,
    fEndRadius = 200,
    Source = caster,
    bHasFrontalCone = false,
    bRepalceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    fExpireTime = GameRules:GetGameTime()+10,
    bDeleteOnHit = false,
    vVelocity = point*3000,
    bProvidesVision =true,
    iVisionRadius = 0,
    iVisionTeamNumber = caster: GetTeamNumber(),
    vSpawnOrigin = castvec,
    EffectName = File,
}

ProjectileManager:CreateLinearProjectile(knifeTable)
end
function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
     end
     return _copy(object)
end
--删除table中的table
function TableRemoveTable( table_1 , table_2 )
    for i,v in pairs(table_1) do
        if v == table_2 then
            table.remove(table_1,i)
            return
        end
    end
end
