--
-- Author: (£þ.£þ)
-- Date: 2016-09-02 15:38:03
--

local Effect = class("Effect",
					{ 
					 action = nil,
					 targetConditions = nil,
					 targetFilter = nil,
					 triggerEvent = nil, -- 包含 {eventName，targetFilter}
					 round = nil,

					})

function Effect:ctor(params)
	local targetConditions = params.targetConditions
	local action = params.action
	local targetFilter = params.targetFilter
	local triggerEvent = params.triggerEvent
	local round  = params.round
	
	self:setTargetFilter(targetFilter)
	self:setTriggerEvent(triggerEvent)
	self:setAction(action)
	self:setTargetConditions(targetConditions)

	self:setRound(round) 
	print("effct has been ceated!",params.ClassName) 
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



function Effect:updateRound(gap)
	local gap = gap or 1 
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

return Effect