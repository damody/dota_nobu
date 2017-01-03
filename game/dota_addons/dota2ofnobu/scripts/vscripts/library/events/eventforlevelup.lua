
function Nobu:LevelUP( keys )
	--DeepPrintTable(keys)
	-- [   VScript              ]: {
	-- [   VScript              ]:    player                          	= 1 (number)
	-- [   VScript              ]:    level                           	= 26 (number)
	-- [   VScript              ]:    splitscreenplayer               	= -1 (number)
	-- [   VScript              ]: }	
	local level = keys.level
	local id    = keys.player
	local p 	     = PlayerResource:GetPlayer(id-1)
	local hero 	   = p: GetAssignedHero()
	local name   = hero:GetUnitName()
	
	print(name) -- 沒反應@"@?

	if string.match(name, "naga_siren") then -- 望月千代女
		local LuaB16 = require("heroes/B_Unified/B16_Mochidsuki_Chiyome")
		local newKeys = ({})
		newKeys.caster = hero
		LuaB16.B16_AbilityAdjust(newKeys)
	end
end 