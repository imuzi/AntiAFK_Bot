--
-- Author: (£þ.£þ)
-- Date: 2016-09-02 15:38:03
--

local Effect = class__("Effect",
					{ 
					 action = "nil",
					 targetConditions = "nil",
					 targetFilter = "nil",
					 triggerEvent = "nil", -- 包含 {eventName，targetFilter}
					 round = "nil",
					 times = "9999999", -- WARN  FIXME只是持续回合数限制有一些问题 比如 在接下来的几次攻击中 额外造成什么什么

					 skill = "nil",
					 host = "nil",
					 _sleep = "false" -- 针对有写效果在不确定情况下才执行 并非施放的时候FIXME
					})

function Effect:ctor(params)
	if params then 
		local targetConditions = params.targetConditions
		local action = params.action
		local targetFilter = params.targetFilter
		local triggerEvent = params.triggerEvent
		local round  = params.round 

		self:setParams(params)
		
		self:setTargetFilter(targetFilter)
		self:setTriggerEvent(triggerEvent)
		self:setAction(action)
		self:setTargetConditions(targetConditions)

		self:setRound(round)  
	end
 	
 	self:sleep(false)
end

function Effect:setSkill(val)
 	self.skill = val 
end

function Effect:getSkill(val)
 	return self.skill
end 

function Effect:setHost(val)
 	self.host = val 
end

function Effect:getHost(val)
 	return self.host
end   

function Effect:setParams(val)
	self.params = val
end
function Effect:getParams()
	return self.params
end

function Effect:getTargetFilter()
	return self.targetFilter
end

function Effect:getTriggerEvent()
	return self.triggerEvent
end

function Effect:getAction()
	return self.action
end

function Effect:getTargetConditions()
	return self.targetConditions
end


function Effect:setTargetFilter(val)
	self.targetFilter = val
end

function Effect:setTriggerEvent(val)
	self.triggerEvent = val
end

function Effect:setAction(val)
	self.action = val
end

function Effect:setTargetConditions(val)
	self.targetConditions = val
end



function Effect:updateTimes(gap)
	local gap = gap or -1 
	local times = self:getRound()

	times = times + gap

	self:setTimes(times)   
end

function Effect:setTimes(val)
	self.times = val 
end

function Effect:getTimes()
	return self.times
end

function Effect:updateRound(gap)
	local gap = gap or -1 
	local round = self:getRound()

	round = round + gap

	self:setRound(round)   
end

function Effect:setRound(val)
	self.round = val 
end

function Effect:getRound()
	return self.round
end


function Effect:sleep(val)
	return tempVarOfInstance__("_sleep",self,val)
end

function Effect:awake()
	self:sleep(false)

 	TriggerEvents.checkDoEffect(self,"effectBegin") 
end 

return Effect
