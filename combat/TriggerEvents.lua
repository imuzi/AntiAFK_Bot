--
-- Author: (£þ.£þ)
-- Date: 2016-09-02 09:13:17
--

module(...,package.seeall) 

eventNames = 
{
	"combatBegin",
	"behaviorBegin",
	"behaviorOver",
	"turnBegin",
	"turnOver",
	"onHit",
	"skillHit",
	"basicHit",
	"critHit",
	"effectOver",
	"effectBegin",

}

-- behaviorBegin = {}
-- behaviorOver = {} 



-- turnBegin = {} 

-- turnOver = {}

-- skillHit = {}

-- basicHit = {}

-- critHit = {} 



function listen(evtName)
	print("\n\n\n\n --listen",evtName)
	-- for _,name in ipairs(eventNames) do


		CombatData.foreachAllHeros(
		function(hero)
			local effList = hero:getEffectList()
			local tempEffList = hero:getTempEffectList()
			local castingEffect = hero:getCastingEffectList()
			local buffList = hero:getBuffList()
			local deBuffList = hero:getDeBuffList()

			foreachEffectList(effList,evtName)
			-- print("size--effList",#effList)
			foreachEffectList(tempEffList,evtName)
			foreachEffectList(castingEffect,evtName)
			foreachEffectList(buffList,evtName)
			foreachEffectList(deBuffList,evtName,false,true)
			-- print("size--tempEffList",#tempEffList)
		end)
		 

	print("listen End \n\n")
 
end 


function checkDoEffect(eff,evtName)
	if matchs(eff,evtName) then  
		SkillLogic.doEffect(eff) 
		return true 
 	end

 	return false 
end

----  这里有问题 每次 应该把 当前 时间 所需要的 信息 保存  比如 onHit 该保存 施方和 受方 
--  这里应该是 当无filter 时 就是全部了 。。 有的时候 判断 是自己还是  对方  该是一个condition 才对 不
-- 应该是targetfitler  ————FIXME
function matchTarget(eff)
	local caster = eff:getSkill():getCaster()

	local targetFilter = eff:getTriggerEvent().targetFilter
	local hasTargetFilter = type(targetFilter) == "table"  -- 如果没有targetfiter 则为自己

	local targets = hasTargetFilter and TargetFilters.do__(targetFilter,caster) or {caster}

	local isIn = false

	for i,v in ipairs(targets) do
		if v:getAttr("id") == caster:getAttr("id") then 
			isIn = true 
			break
		end 
	end
	
	-- print("______isIn",isIn)
	return isIn
end

function matchName(eff,evtName)	 
	-- print("eff:getTriggerEvent().name",eff:getTriggerEvent().name,evtName)
	return eff:getTriggerEvent().name == evtName
end

 
function matchs(eff,evtName)  
	local mathNames = matchName(eff,evtName)
					or matchEffectOverEvent(eff,evtName)
					-- or matchEffectBeginEvent(eff,evtName)
	local matchs = mathNames and matchTarget(eff)	

	-- print("mathNames",mathNames,matchs)		
	return matchs
end


function foreachEffectList(val,evtName,removeAfterDone,isDeBuffList)
	local indexsToRemove = {} 
	local list = val 

	local eachFunc = function(effect)
		decreaseEffectRound(effect,evtName)
		-- print("________foreachEffectList_____\n\n",#list)
		 
		local shouldRemove = --[[(removeAfterDone and]] 
		checkDoEffect(effect,evtName) or isEffectOver(effect)
		return shouldRemove
	end

	for i,v in ipairs(list) do
		local shouldRemove
		local isBuffList = #v > 1 
		if isBuffList then 
			for _i,_v in ipairs(v) do 
				shouldRemove = eachFunc(_v)
			end 
		else 
			shouldRemove = eachFunc(v)
		end
		

		if shouldRemove then 
			table.insert(indexsToRemove,i)
		end   
	end 

	local size = #indexsToRemove

	for i=size,1,-1 do
		local index = indexsToRemove[i] 

		onEffectRemove(list[index],isDeBuffList)
		table.remove(list,index)

		print("onBuffRemoved",index,"size",#list)
	end

end

function decreaseEffectRound(eff,evtName)
	if evtName == "turnOver" then
		eff:updateRound() 
	end
end

-- 这个点不确定 所以 逻辑不成立
-- function matchEffectBeginEvent(eff,evtName)  
-- 	if evetName ~= "turnBegin" then return false end  
-- 	local triggerEvent = "effectBegin" 
-- 	return isEffBorn(eff) and matchName(eff,triggerEvent) 
-- end

function matchEffectOverEvent(eff,evtName)  
	if evetName ~= "turnOver" then return false end  
	local triggerEvent = "effectOver" 
	return isEffectOver(eff) and matchName(eff,triggerEvent) 
end

function isEffectOver(eff)
	local roundLeft = eff:getRound() 
	return roundLeft < 1
end

-- function isEffBorn(eff)
-- 	local roundLeft = eff:getRound()
-- 	local originRound = eff:getParams().round
-- 	return roundLeft == originRound
-- end


-- 当有BUFF被移除时检测 sleep的BUFF是否要生效了  FIXEME WARN
-- 还有在驱散的时候要做个检测FIXEME WARN
function onEffectRemove(val,isDeBuffList)
	local isBuffList = #val > 1 
	if isBuffList then 
		local host = val[1]:getHost()
		local buffList
		if isDeBuffList then 
			buffList = host:getDeBuffList()
		else
			buffList = host:getBuffList() 
		end 

		for i,v in ipairs(buffList) do
			if v[1]:sleep() then 
				if not SkillLogic.check_buff_stack(v,isDeBuffList) then 
					for _i,_v in ipairs(v) do
						_v:awake()
					end
				end 
			end 
		end 

	end 

end
