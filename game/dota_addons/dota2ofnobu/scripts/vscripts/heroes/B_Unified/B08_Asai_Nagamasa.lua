	B08W = class({})
local mover = require('amhc_library/mover')
function B08W_Action( keys )
	-- local  caster 	 = keys.caster

	-- --劍刃風暴定義
	-- local modifierData = {
	-- 	duration = 40,
	-- 	damage = 400
	-- }
	-- caster:AddNewModifier( caster, B08W, "modifier_juggernaut_blade_fury", modifierData )
end


function B08E_Action( keys )
	local caster = keys.caster
	local target = keys.target
	local level  = keys.ability:GetLevel()

	--move
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())

	-- 	--移动到目标
	-- local m = mover:create
	-- {
	--         type = 'target',
	--         unit = caster,        dest = target,
	--         speed = 999999,
	--         max_height = target:GetAbsOrigin().z,
	-- }
	-- m:run()
end


function B08R_Action( keys )
	local caster = keys.caster
	local target = keys.target
	local level  = keys.ability:GetLevel()

	print(keys)

	--move
	caster:AddNewModifier(nil,nil,"modifier_phased",{duration=0.1})--添加0.1秒的相位状态避免卡位
	caster:SetAbsOrigin(target:GetAbsOrigin())

	-- 	--移动到目标
	-- local m = mover:create
	-- {
	--         type = 'target',
	--         unit = caster,        dest = target,
	--         speed = 999999,
	--         max_height = target:GetAbsOrigin().z,
	-- }
	-- m:run()
end
