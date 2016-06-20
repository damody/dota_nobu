print ( '[Nobu] GAME INIT' )


--【GLOBAL】
if Nobu == nil then
    _G.Nobu = class({})
end
Nobu["A_Start_Ent"]  = Entities:FindByName(nil,"A_Start_Ent")
Nobu["B_Start_Ent"]  = Entities:FindByName(nil,"B_Start_Ent")

--【LOCAL】

--【TEST】
-- local test_ent = Entities:FindByName(nil,"Test_QQQ")
-- local item_point = test_ent:GetAbsOrigin()
-- local Test_ITEM ={
-- "item_D01"
-- }

--local test_ent = Entities:FindByName(nil,"Test_QQQ")

local function Test( ... )
	print("Test")
	for i,v in ipairs(Test_ITEM) do
		local item = CreateItem(v,nil, nil)
		--local vec =( RandomInt(1,100) , RandomInt(1,100) )
		CreateItemOnPositionSync(item_point+Vector(i*100,0), item)
	end

end



--【考章魚】
	--[[
		bug:物品一開始創造的點位子都是(0,0,0)，要撿起來移動才會移動向量。
	]]
local meat_born_duration = 3--325
local meat = nil

local BarBQ_check  = function ( )

	print("v.BarBQ")
	local debug = true
	for i,v in ipairs(meat) do
		local temp_ent = v.BarBQ
		-- if temp_ent == nil then
		-- 	local item = CreateItem("item_S01",nil, nil)
		-- 	CreateItemOnPositionSync(v:GetAbsOrigin(), item)
		-- 	v.BarBQ = item
		-- 	item:SetAbsOrigin(point)
		-- else
		-- 	local point = v:GetAbsOrigin()
		-- 	local point2 = temp_ent:GetAbsOrigin()
		-- 	local distance = nobu_distance( point,point2 )
		-- 	if debug then
		-- 		print(	distance	)
		-- 		print(temp_ent)
		-- 		debug = false
		-- 	end
		-- 	if distance > 50 then
		-- 		local item = CreateItem("item_S01",nil, nil)
		-- 		CreateItemOnPositionSync(v:GetAbsOrigin(), item)
		-- 		v.BarBQ = item
		-- 		item:SetAbsOrigin(point)
		-- 	end		 

		-- end
	end

	return meat_born_duration


 --    local temp_point_x
 --    local temp_point_y
	-- local TempInteger 
	-- temp_point_x = GetRectCenterX ( gg_rct_FU_BarBQ_A )
	-- temp_point_y = GetRectCenterY ( gg_rct_FU_BarBQ_A )
	-- TempInteger = 0
	-- EnumItemsInRect ( gg_rct_FU_BarBQ_A , nil , BarBQ_check2 )
	-- bj_forLoopAIndex = 1
	-- bj_forLoopAIndexEnd = ( 5 - TempInteger )
	-- for _i = 1, 10000 do
	-- 	if bj_forLoopAIndex > bj_forLoopAIndexEnd then break end
	-- 	CreateItem ( 1953723442 , temp_point_x , temp_point_y )
	-- 	bj_forLoopAIndex = bj_forLoopAIndex + 1
	-- end
	-- temp_point_x = GetRectCenterX ( gg_rct_FU_BarBQ_B )
	-- temp_point_y = GetRectCenterY ( gg_rct_FU_BarBQ_B )
	-- TempInteger = 0
	-- EnumItemsInRect ( gg_rct_FU_BarBQ_B , nil , BarBQ_check2 )
	-- bj_forLoopAIndex = 1
	-- bj_forLoopAIndexEnd = ( 5 - TempInteger )
	-- for _i = 1, 10000 do
	-- 	if bj_forLoopAIndex > bj_forLoopAIndexEnd then break end
	-- 	CreateItem ( 1953723442 , temp_point_x , temp_point_y )
	-- 	bj_forLoopAIndex = bj_forLoopAIndex + 1
	-- end
end

local Trig_BarBQ  = function ( )
	for i,v in ipairs(meat) do
		local item = CreateItem("item_S01",nil, nil)
		CreateItemOnPositionSync(v:GetAbsOrigin(), item)
		item:SetAbsOrigin(v:GetAbsOrigin())
		v.BarBQ = item
	end

	Timers:CreateTimer (  meat_born_duration ,  BarBQ_check )
end

local InitTrig_Game_Init  = function ( )
	--【Test】
	test_ent = Entities:FindByName(nil,"Test_QQQ")
	item_point = test_ent:GetAbsOrigin()
	Test_ITEM ={
	"item_c05",
	"item_D01",
	"item_D02",
	"item_D03",
	"item_D09",
	"item_Q02",
	"item_Q03",
	"item_Q04"
	}


	meat = Entities:FindAllByName("item_meat*")
	Trig_BarBQ ( )
	Test ( )
end

--【Init】
Timers:CreateTimer (  0.01 ,  InitTrig_Game_Init )