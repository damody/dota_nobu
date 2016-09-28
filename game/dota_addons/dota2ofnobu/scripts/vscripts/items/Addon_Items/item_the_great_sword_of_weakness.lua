--天之叢雲．銘刀
LinkLuaModifier("modifier_weakness", "heroes/modifier_weakness.lua", LUA_MODIFIER_MOTION_NONE)

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local time = caster:GetIntellect()/40*0.6+0.6
    if target:IsMagicImmune() and time > 1 then
        time = 1
    end
    target:AddNewModifier(caster, ability, "modifier_weakness", {duration = time})
end

