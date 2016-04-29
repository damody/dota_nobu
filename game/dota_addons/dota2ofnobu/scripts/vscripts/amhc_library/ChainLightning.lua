
--[[

闪电链有以下参数
{
	caster 			//施法者
	target 			//初始目标
	area 			//检索范围
	effect 			//特效路径，默认是zuus的闪电链, 如果改变特效路径，请确认这个闪电链是具有0和1两个控制点，如果有其他控制点请onHit自行创建
	interval		//跳跃间隔，默认是0.2
	max_num			//最大跳跃次数
	teams 			//下次跳跃筛选-队伍，默认DOTA_UNIT_TARGET_TEAM_ENEMY
	types 			//下次跳跃筛选-目标类型，默认DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	flags 			//下次跳跃筛选-状态，默认DOTA_UNIT_TARGET_FLAG_NONE
	onHit			//当闪电击中后触发，有三个参数，new_target(当前单位),old_target(上一个单位),num(当前跳跃次数)
}

使用方法：

--创建闪电链
ChainLightning
{
	caster = caster,
	target = target,
	max_num = 5,
	onHit = function( self,new,old,num )
		print("old ",old,"new ",new,num)
	end
}
]]

if ChainLightning == nil then
	ChainLightning = {}
end

setmetatable(ChainLightning,ChainLightning)

--施法者
ChainLightning.caster = nil

--命中的目标
ChainLightning.target = nil

--检索范围
ChainLightning.area = 300

--上一个命中的目标
ChainLightning.target_old = nil

--特效
ChainLightning.effect = "particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf"

--记录已命中的单位的组
ChainLightning.group = nil

--闪电链间隔
ChainLightning.interval = 0.2

--最大跳跃次数
ChainLightning.max_num = -1

--数值
ChainLightning.num = 0

--单位筛选
ChainLightning.teams = DOTA_UNIT_TARGET_TEAM_ENEMY
ChainLightning.types = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
ChainLightning.flags = DOTA_UNIT_TARGET_FLAG_NONE

function ChainLightning:run()
	
	if IsValidEntity(self.target) and self.target:IsAlive() then

		--创建特效
		if self.effect then
			local p = ParticleManager:CreateParticle(self.effect,PATTACH_CUSTOMORIGIN_FOLLOW,self.target_old)

			if self.caster == self.target_old then
				ParticleManager:SetParticleControlEnt(p,0,self.target_old,5,"attach_attack1",self.target_old:GetOrigin(),true)
			else
				ParticleManager:SetParticleControlEnt(p,0,self.target_old,5,"attach_hitloc",self.target_old:GetOrigin(),true)
			end
			
			ParticleManager:SetParticleControlEnt(p,1,self.target,5,"attach_hitloc",self.target:GetOrigin(),true)
			ParticleManager:ReleaseParticleIndex(p)
		end

		self.num = self.num + 1

		--触发
		if self.onHit then
			self:onHit(self.target,self.target_old,self.num)
		end

		if self.max_num ~= -1 then
			if self.num >= self.max_num then
				return
			end
		end

		table.insert( self.group,self.target )
		self.target_old = self.target

		--间隔一段时候寻找下一个目标
		timers(self.interval,function()
			local group = FindUnitsInRadius(self.caster:GetTeamNumber(), self.target_old:GetOrigin(), nil, self.area, self.teams, self.types, self.flags, FIND_CLOSEST, true)

			local yes = true
			repeat

				self.target = group[1]

				if vlua.find(self.group,self.target) == nil then
					yes = true
				else
					table.remove(group,1)
					yes = false
				end

				if #group == 0 then
					yes = true
				end

			until yes

			if self.target ~= self.target_old and #group ~= 0 then
				self:run()
			end
			
		end)
	else
		return
	end
end

function ChainLightning:__call( data )
	local t = Merge(data,self)

	t.group = {}
	t.target_old = t.caster

	t:run()

	return t
end