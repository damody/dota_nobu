--require("other.heromsg")
-- 当玩家使用玄武斧
function OnPlayerUseXuanwufu(keys)
    local caster = keys.caster
    local name =caster:GetUnitName()
    caster.startsize = caster:GetModelScale()
    if not caster.__isBig then --- -如果玩家不在变大的状态，那么变大
        caster.__isBig = true
        local i = 0
        Timers:CreateTimer(function()
            if i <= 25 then
                caster:SetModelScale(caster.startsize + i / 50)
                i = i + 1
                return 0.01
            else
                return nil
            end
        end)
    end
end
-- 当玄武斧的状态小时
function OnPlayerXuanwufuDisactivated(keys)
    local caster = keys.caster
    local name =caster:GetUnitName()
    local startsize = caster.startsize
    if caster.__isBig then -- 如果玩家正在变大的状态，那么变小
        local i = 0
        Timers:CreateTimer(function()
            if i <= 25 then
                caster:SetModelScale( startsize + (25 - i) / 50 )
                i = i + 1
                return 0.01
            else
                return nil
            end
        end)
        caster.__isBig = false
    end
end