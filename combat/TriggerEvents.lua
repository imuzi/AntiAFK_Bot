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
		local groupMap = combatData.groupMap
		for k,group in pairs(groupMap) do

			local heros = group:getHeros()
			for i,hero in ipairs(heros) do 

				local effList = hero:getEffectList()
				local tempEffList = hero:getTempEffectList()
				foreachEffectList(effList,evtName)
				-- print("size--effList",#effList)
				foreachEffectList(tempEffList,evtName)
				-- print("size--tempEffList",#tempEffList)
			end
		end
	-- end

	print("listen End \n\n")
 
end 


function checkDoEffect(eff,evtName)
	if matchs(eff,evtName) then  
		skillLogic.doEffect(eff) 
 	end
end


function matchTarget(eff)
	local caster = eff:getSkill():getCaster()

	local targetFilter = eff:getTriggerEvent().targetFilter
	local targets = targetFilters.do__(targetFilter,caster)

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


function foreachEffectList(val,evtName)
	local indexsToRemove = {} 
	local list = val 
	for i,v in ipairs(list) do

		local effect = v 

		decreaseEffectRound(effect,evtName)
		-- print("________foreachEffectList_____\n\n",#list)
		checkDoEffect(effect,evtName)

		if isEffectOver(effect) then 
			table.insert(indexsToRemove,i)
		end   
	end 

	local size = #indexsToRemove

	for i=size,1,-1 do
		local index = indexsToRemove[i] 
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


function removeEff(eff)
	if isEffectOver(eff) then 

	end 
end
 

