--
-- Author: (£þ.£þ)
-- Date: 2016-08-30 11:56:50
--

module(...,package.seeall) 

self = package.loaded[...]

-- logicKeys = {
-- 	"Target",
-- 	"TargetFilter",
-- 	"OrderRule",[[FrontHitRate ，BackHitRate]]
-- 	"Descend",
-- 	"SelectCount"

-- }
curSkill = nil 
--[[
		己方=0,
        敌方=1,
        自己=2,
		]]
Target = {
	function(skill)
		return skill:getCaster():getGroup():getHeros()
	end,
	function(skill)
		local myGroup = skill:getCaster():getGroup()
		local myGroupName = myGroup:getName()
		local tarGroup 
		local groupMap = combatData.groupMap

		for k,v in pairs(groupMap) do
			if v:getName() ~= myGroupName then 
				tarGroup = v
				break
			end 
		end
		return tarGroup:getHeros()
	end,
	function(skill)
		return {skill:getCaster()}
	end

}

--[[
		如果是冰冻状态，则是在这层筛选前，将冰冻目标剔除
		0: 全部
		1：前排，如果没有前排，则取后排所有人
		2：后排，如果没有后排，则取前排所有人
		3: 死亡
		如果是冰冻状态，则是在这层筛选过后，将冰冻目标剔除
		]]
TargetFilter = {
	function(targets)
		return targets
	end,
	function(targets)
		local targetsFilted = {}
 
		for i,v in ipairs(targets) do
			if __isFrontLine(v) then 
				table.insert(targetsFilted, v) 
			end
		end

		targetsFilted = #targetsFilted==0 and targets or targetsFilted
		return targetsFilted
	end,
	function(targets)
		local targetsFilted = {}
	
		for i,v in ipairs(targets) do
			if not __isFrontLine(v) then 
				table.insert(targetsFilted, v) 
			end
		end

		targetsFilted = #targetsFilted==0 and targets or targetsFilted
		return targetsFilted
	end,
	function(targets)
		local targetsFilted = {}
	
		for i,v in ipairs(targets) do
			if false then --fixe me 
				table.insert(targetsFilted, v) 
			end
		end

	 	return targetsFilted
	end,


}
--[[
		0： 随机排序  -- 影响表头 FrontHitRate ，BackHitRate
		1： 站位
		2： 攻击属性（Element）
		3： 性别（Gender）
		4： 攻击力（Atk）
		5： 防御力（Defence）
		6： 当前生命（HP)
		7： 最大生命（MaxHP)
		]]
	 
OrderRule = {
	function(hero) -- 根据前后牌选取的概率 来给出一个优先值  FIXME
		local sortPriority = tempSortPriority__(hero) --hero:sortPriority()
		if sortPriority then 
			return sortPriority 
		else  
			local probability = random__(1,100)
			local caster = curSkill:getCaster()
			local frontHitRate = caster:getCfgByKey("FrontHitRate")
			local backHitRate = caster:getCfgByKey("BackHitRate")

			local isSelectFronEasier = math.max(frontHitRate,backHitRate) == frontHitRate
			local isFrontHero = __isFrontLine(hero)

			local isHitFront = probability<frontHitRate

			local bingo = (isSelectFronEasier and isFrontHero and isHitFront)
						or (not isSelectFronEasier and not isFrontHero and not isHitFront)

			local bingo2 = ( isFrontHero and isHitFront)
						or ( not isFrontHero and not isHitFront)

			priority = 2
			priority = bingo2 and 1 or priority			
			priority = bingo and 0 or priority
			-- print("isSelectFronEasier,isFrontHero,isHitFront,priority",
			-- 	isSelectFronEasier,isFrontHero,isHitFront,priority)
			tempSortPriority__(hero,priority) -- hero:sortPriority(priority)
			return priority
		end
		
		
	end,
	function(hero)
		return hero:getAttr("position")
	end,
	function(hero)
		return hero:getCfgByKey("Element")
	end,
	function(hero)
		return hero:getCfgByKey("Gender")
	end,

	function(hero) 
		return hero:getAttr("attack")
	end,
	function(hero)
		return hero:getAttr("defence")
	end,
	function(hero)
		return hero:getAttr("hp")
	end,
	function(hero)
		return hero:getAttr("maxHP")
	end,

}
--[[
		0;升序
		1：降序
		]]
Descend = {
	"<",
	">" 
}

 
function getTargets(skill)
	curSkill = skill
	local targets

	targets = __doLogic("Target",skill,skill) 
	targets = clone(targets)
	print("targets",skill:getCfgByKey("Name"),#targets)
	targets = __doLogic("TargetFilter",skill,targets) 

	print("TargetFilter",skill:getCfgByKey("Name"),#targets)
	sort__(targets,{
		--Fixme ,冰冻 锁定 嘲讽 优先级 加入  
		-- {
		-- 	function(hero)
		-- 		return hero:getPriority()--hero:getCfgByKey("ID")
		-- 	end,
		-- 	"<"
		-- },
		{
			__getLogic("OrderRule",skill),
			__getLogic("Descend",skill)
		},
		-- {
		-- 	function(hero)
		-- 		return hero:getAttr("id")--hero:getCfgByKey("ID")
		-- 	end
		-- }
	})


	local final_targets = {}
	local selectCount = skill:getCfgByKey("SelectCount")

	for i=1,selectCount do
		local hero = targets[i]
		if hero then 
			table.insert(final_targets,hero)
		else
			break
		end 
	end

	print("skill__getTargets",skill:getCfgByKey("Name"),#final_targets)
	return final_targets 
end



function __doLogic(key,skill,param)
	local value = skill:getCfgByKey(key)
	value = value + 1  --  从0开始 所以 加+1

	local data = self[key]
	if not data then return value end 

	local _logic = data[value]

	assert(_logic~=nil,"TargetFilter中",key,"值错误:",value)
 	
 	print("__doLogic",key,"值:",value)
	local type_ = type(_logic)
	if type_ == "function" then 
		return _logic(param)
	else
		return _logic
	end 
end

function __getLogic(key,skill)
	local value = skill:getCfgByKey(key)
	value = value + 1
	print("__getLogic",key,"值:",value)
	return self[key][value]
end


function __isFrontLine(hero)
	return hero:getAttr("position")<3
end
