
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
	

end 