	bj_PI                            = 3.14159
	bj_RADTODEG                      = 180.0/bj_PI
	bj_DEGTORAD                      = bj_PI/180.0


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