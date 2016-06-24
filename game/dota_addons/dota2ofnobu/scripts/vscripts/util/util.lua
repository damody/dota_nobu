
STARTING_GOLD = 500--650
DEBUG = true
GameMode = nil

TRUE = 1
FALSE = 0


function GetDistanceBetweenTwoVec2D(a, b)
    local xx = (a.x-b.x)
    local yy = (a.y-b.y)
    return math.sqrt(xx*xx + yy*yy)
end

function GetRadBetweenTwoVec2D(a,b)
	local y = b.y - a.y
	local x = b.x - a.x
	return math.atan2(y,x)
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
    local maxrad = math.max(rada,radb)
    local minrad = math.min(rada,radb)
    
    if rada >= 0 and radb >= 0 then
        if(a<=maxrad and a>=minrad)then
            print("true")
            return true
        end
    elseif rada >=0 and radb < 0 then

    elseif rada < 0 and radb >= 0 then
        if(a<maxrad and a>minrad)then
            print("true")
            return true
        end
    elseif rada < 0 and radb < 0 then
        if(a<maxrad and a>minrad)then
            print("true")
            return true
        end
    end

	return false
end

function IsPointInCircularSector(cx,cy,ux,uy,r,theta,px,py)
    local dx = px - cx
    local dy = py - cy

    local length = math.sqrt(dx * dx + dy * dy)

    if (length > r) then
        return false
    end

    local vec = Vector(dx,dy,0):Normalized()
    return math.acos(vec.x * ux + vec.y * uy) < theta
 end 


function SetTargetToTraversable(target)
    local vecTarget = target:GetOrigin() 
    local vecGround = GetGroundPosition(vecTarget, nil)

    UnitNoCollision(target,target,0.1)
end
 

function ParticleManager:DestroyParticleSystem(effectIndex,bool)
    if(bool)then
        ParticleManager:DestroyParticle(effectIndex,true)
        ParticleManager:ReleaseParticleIndex(effectIndex) 
    else
        Timer.Wait 'Effect_Destroy_Particle' (4,
            function()
                ParticleManager:DestroyParticle(effectIndex,true)
                ParticleManager:ReleaseParticleIndex(effectIndex) 
            end
        )
    end
end

function ParticleManager:DestroyParticleSystemTime(effectIndex,time)
    Timer.Wait 'Effect_Destroy_Particle_Time' (time,
        function()
            ParticleManager:DestroyParticle(effectIndex,true)
            ParticleManager:ReleaseParticleIndex(effectIndex) 
        end
    )
end

function is_spell_blocked(target)
	if target:HasModifier("modifier_item_sphere_target") then
		target:RemoveModifierByName("modifier_item_sphere_target")  --The particle effect is played automatically when this modifier is removed (but the sound isn't).
		target:EmitSound("DOTA_Item.LinkensSphere.Activate")
		return true
	end
	return false
end