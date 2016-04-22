-- 显示自定义错误
function ShowCustomErrorForPlayer(playerid, message)
    FireGameEvent( 'custom_error_show', { player_ID = playerid, _error = message } )
end

-- 更新木材信息
function UpdateLumberDataForPlayer(playerid, val)
    FireGameEvent("lumber_update", {PlayerID = playerid, Lumber = val})
end

-- 更新士气显示
function UpdateMoraleData(moraleTeam1, moraleTeam2)
    FireGameEvent("morale_update",{
        MoraleShu = moraleTeam1,
        MoraleWei = moraleTeam2,
    })
end

-- 为某个玩家在某个单位的位置弹出一个图形提示 @ todo 暂时无用
function PopupImageForPlayer(target, imageName, playerID)
    local pos = target:GetOrigin()
    local x = pos.x
    local y = pos.y
    local z = pos.z
    
    FireGameEvent("show_popup_image",{
        _x = x,
        _y = y,
        _z = z,
        _playerID = playerID,
        _image_name = imageName
    })
end

-- 为所有玩家在某个单位的位置弹出一个图标 @ todo 暂时无用
function PopupImageAll(target, imageName)
    local pos = target:GetOrigin()
    local x = pos.x
    local y = pos.y
    local z = pos.z
    
    FireGameEvent("show_popup_image_all",{
        _x = x,
        _y = y,
        _z = z,
        _image_name = imageName
    })
end
