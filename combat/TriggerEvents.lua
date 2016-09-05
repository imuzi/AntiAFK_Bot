--
-- Author: (£þ.£þ)
-- Date: 2016-09-02 09:13:17
--

module(...,package.seeall) 

eventNames = 
{
	"behaviorBegin",
	"behaviorOver",
	"turnBegin",
	"turnOver",
	"skillHit",
	"basicHit",
	"critHit",
}

behaviorBegin = {}
behaviorOver = {} 



turnBegin = {} 

turnOver = {}

skillHit = {}

basicHit = {}

critHit = {}






 


-- -- 主属性 阈值
-- attributeThreshold = {}

-- -- 表属性 满足
-- cfgSatisfied = {}




function listen(evtName)
	for _,name in ipairs(eventNames) do
		local groupMap = combatData.groupMap
		for k,group in pairs(groupMap) do

			local heros = group:getHeros()
			for i,hero in ipairs(heros) do

				local effList = hero:getEffectList()
				for _i,effect in ipairs(effList) do

					if matchs(effect,evetName) then 
						skillLogic.doEffect(effect) 
				 	end
				end

			end
		end
	end
 
end 

---  triger 是否要计入 targetfilter  fix me 
function matchs(eff,evtName)
	local caster = eff:getSkill():getCaster()

	local targetFilter = eff:getTargetFilter()
	local targets = targetFilter.do__(targetFilter,caster)

	local isIn = false

	for i,v in ipairs(targets) do
		if v:getAttr("id") == caster:getAttr("id") then 
			isIn = true 
			break
		end 
	end
 
	return (eff:getTriggerEvent() == evtName) and isIn
end