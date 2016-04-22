require('game.ZSSpawner')
print("AI success!")
local target_shu_mid = Entities:FindByName(nil, "shu_mid_1")
thisEntity:SetMustReachEachGoalEntity(true)
thisEntity:SetInitialGoalEntity(target_shu_mid)
local model=thisEntity:FirstMoveChild()
if model ~= nil then 

   model:SetModel("models/heroes/juggernaut/jugg_sword.vmdl")
else 
	model=model:NextMovePeer()
end