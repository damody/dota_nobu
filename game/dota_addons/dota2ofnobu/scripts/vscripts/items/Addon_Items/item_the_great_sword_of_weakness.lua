--天之叢雲．銘刀
LinkLuaModifier("modifier_weakness", "heroes/modifier_weakness.lua", LUA_MODIFIER_MOTION_NONE)

function Shock( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
    local time = caster:GetIntellect()/40*0.6+0.6
    if target:IsMagicImmune() then
    	if time > 3 then
    		time = 3
    	end
    end
    if time > 4.2 then
		time = 4.2
	end
    AMHC:Damage(caster,keys.target, 1,AMHC:DamageType( "DAMAGE_TYPE_PURE" ) )
    if _G.EXCLUDE_TARGET_NAME[target:GetUnitName()] == nil then
        target:AddNewModifier(caster, ability, "modifier_weakness", {duration = time})
    end
end

