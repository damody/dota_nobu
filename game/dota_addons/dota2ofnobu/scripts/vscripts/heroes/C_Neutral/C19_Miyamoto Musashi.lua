--global
	udg_C19T_LV = {}
	udg_C19T_Attact  = {}
	udg_C19T_Boolean = {}
	udg_C19T_Index = {}
	udg_C19T_LV = {}
--ednglobal



function C19T_Effect takes  u,  u2,  i returns nothing
local  r=0
local  x=GetX(u)
local  y=GetY(u)
local  x2=GetX(u2)
local  y2=GetY(u2)
local  a=bj_RADTODEG*Atan2(y2-y,x2-x)+GetRandom(-30,30)
local string es="Objects\\Spawnmodels\\Human\\HumanBlood\\BloodElfSpellThiefBlood.mdl"
 ApplyTimedLife(Create(Player(15),'h008',x,y,a),'BTLF',2)
 DestroyEffect(AddSpecialEffectTarget(es,u2,"head"))
 DestroyEffect(AddSpecialEffectTarget(es,u2,"chest"))
 DestroyEffect(AddSpecialEffectTarget(es,u2,"mount"))
 X(u,x2+100*Cos(a*bj_DEGTORAD))
 Y(u,y2+100*Sin(a*bj_DEGTORAD))
 Facing(u,a)
 TimeScale(u,3)
 Animation(u,"Attack Slam")
if udg_C19T_LV[i]==1 then
 r=GetRandom(110,110)
elseif udg_C19T_LV[i]==2 then
 r=GetRandom(110,110)
elseif udg_C19T_LV[i]==3 then
 r=GetRandom(110,110)
end
 DamageTarget(u,u2,r,true,false,ATTACK_TYPE_HERO,DAMAGE_TYPE_ACID,WEAPON_TYPE_WHOKNOWS)
end


function C19T_Copy(u,i)
	local  team  = u:GetTeamNumber()
	local  point = u:GetAbsOrigin()
	local  tu   = CreateUnitByName("C19T_SE",point,true,nil,nil,team)

	--播放動畫(透明度50%,顏色要改金),隨機播放攻擊動作
	u2: SetRenderColor(175,175,175)

	--紀錄特效單位在群組
	table.insert(udg_C19T_Attact[i],tu)

end


function C19T_Target takes nothing returns boolean
local  u=GetFilter()
local boolean b=IsEnemy(u,GetOwningPlayer(LoadHandle(YDHT,GetHandleId(GetExpired()), 1)))and not IsType(u,_TYPE_STRUCTURE)and GetState(u,_STATE_LIFE)>0 and GetPointValue(u) != 1
 u=nil
return b
end



function C19T takes nothing returns nothing


 bj_wantDestroy=false
 Add(udg_C19T_Attact[i],g)
	if udg_C19T_Boolean[i] then
		 C19T_Copy(u,i)
	end

		loop
			 ydl_=FirstOf(g)
			exitwhen ydl_==nil	
			 Remove(g,ydl_)
			 EnumsInRange(g2,GetX(ydl_),GetY(ydl_),450,b)
			 u2=PickRandom(g2)
				if u2==nil then
					 Remove(udg_C19T_Attact[i],ydl_)
						if ydl_!=u then
							 Remove(ydl_)
						else
							 udg_C19T_Boolean[i]=false
						end
				else
					 Remove(g,u2)
					 C19T_Effect(u,u2,i)
				end
		 Clear(g2)
	end

 udg_C19T_Index[i]=udg_C19T_Index[i]+1

	if udg_C19T_LV[i] ==1 then
		 ti=5
	elseif udg_C19T_LV[i] ==2 then
		 ti=6
	elseif udg_C19T_LV[i] ==3 then
		 ti=7
	end
	//here error is ydl_=nil but keep use the ydl_
		if udg_C19T_Index[i]>=ti then
			loop
				 ydl_=FirstOf(udg_C19T_Attact[i])
				exitwhen ydl_==nil
					 Remove(udg_C19T_Attact[i],ydl_)
						if ydl_!=u then
							 Remove(ydl_)
						end
			end
			 Invulnerable(u,false)
			 TimeScale(u,1)
		else
			 Invulnerable(u,true)
			 Start(t,0.33,false,function C19T)
		end
end

function Trig_C19TActions takes nothing returns nothing
	local  u 	 = keys.caster --施法單位
	local  u2 	 = keys.target --目標單位
    local  i 	 = u:GetPlayerID() --獲取玩家ID
    local  point = u2:GetAbsOrigin() --獲取目標的座標

    --global set
	udg_C19T_Index[i] = 1
	udg_C19T_Boolean[i] = true
	udg_C19T_LV[i]  = keys.ability:GetLevel()--獲取技能等級

	--call function
	C19T_Copy(u,i)
	C19T_Effect(u,u2,i)

	--timer
	Timers:CreateTimer(1,function()
		local  ti 		= 0
		local  b   		= Condition(function C19T_Target)
		local  group 	= {}

		--check the group of badguys units
		group = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                              point,
                              nil,
                              SEARCH_RADIUS,
                              DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

		if udg_C19T_Boolean[i] then
		 	C19T_Copy(u,i)
		end

		if #group ~= 0 then
			local rdm_int = RandomInt(1,#group)


		else
		end	

		while(condition)
		do
		   statements
		end








		if  then
			return time
		else
		end
	end)
end


