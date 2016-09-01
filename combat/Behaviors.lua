--
-- Author: (£þ.£þ)
-- Date: 2016-08-31 15:58:30
--
module(...,package.seeall) 
self = package.loaded[...]

basicAttack =
{
	start =
	function(hero)
		local skill = hero:getBasicSkill()
		local targets = targetFilters.getTargets(skill)

		if #targets > 0 then 
			skill:setTargets(targets)
			tempLoopFlag__(skill,true)
			print("_________tempLoopFlag__(skill,true)")
		else 
			basicAttack.over(hero)
		end   
	end,
	loop = 
	function(hero)
		local skill = hero:getBasicSkill()
		local loopFlag = tempLoopFlag__(skill)
		
		if not loopFlag then return end 

		hero:setSkillToCast(skill)
		hero:updateFrameStep()
		 
		if isHit(hero) then 
			combatLogic.onHit(skill)
		elseif isOver(hero) then  
			basicAttack.over(hero)
		end  

	end,
	over = 
	function(hero)
		local skill = hero:getBasicSkill()
		tempLoopFlag__(skill,false)  

		combatLogic.trans_status(hero,"STANDBY")
	end
} 

counterAttack = {}

comboAttack = {}

extraTurn = {}

standBy = {
	start =
	function(hero) 
	end,
	loop = 
	function(hero) 
	end,
	over = 
	function(hero) 
	end
}

castSkill = {}

dead={}


function do__(hero)
	local status = hero:getStatus() 
	self[status].start(hero)
end

function loop(hero)
	local status = hero:getStatus() 
	self[status].loop(hero)
end

function isHit(hero,animName,frame_dif)
	local skill = hero:getSkillToCast()
	local step = hero:getFrameStep()
	local animEvents = skill:getAnimEvent(animName)
	local frame_dif = frame_dif or 0


	for k,v in pairs(animEvents) do 
		local v = frame_dif + v
		local isSatisfy =  ___isHit(k,v,step,0,"hit") 
						or ___isHit(k,v,step,BULLET_FLYFRAME,"fire") 
						or ___showEffectHit(k,v,step,hero)
 	
 
		if isSatisfy then  
			return true 
		end 
	end

	return false  
end

function isOver(hero)
	local skill = hero:getSkillToCast()
	local step = hero:getFrameStep()

	local animEvents = skill:getAnimEvent()
	local interval = skill:getInterval()

	local hasShowEff = false
	for k,v in pairs(animEvents) do
		if string.find(k,"showEffect") then 
			hasShowEff = true 
			break
		end
	end

	if hasShowEff then 
		interval = interval+skill:getInterval("Animation1")
 	end

 	return step >= interval 
end

-- 当是showeffect时  老的逻辑是找到另一个 ccs动画接着放。。。。。
function ___showEffectHit(k,v,step,hero)
	local isShowEffEvt = ___isHit(k,v,step,0,"showEffect") 
	if isShowEffEvt then
		local skill = hero:getSkillToCast()
		local frame_dif = skill:getInterval()
		return isHit(hero,"Animation1",frame_dif)
	end  
	return false 
end
 
function ___isHit(k,v,step,frame_dif,evt_str)
	local isHitEvent = string.find(k,evt_str)
	local isThatFrame = step == (v+frame_dif)
	local isSatisfy = isThatFrame and isHitEvent
	return isSatisfy
end

local TEMP_LOOP_FLAG_KEY = "_loopFlag" 
function tempLoopFlag__(instance,val)
	local key = TEMP_LOOP_FLAG_KEY
	local value = instance[key]

	if val~=nil then 
		value = val  
	else
		return value
	end

	instance[key] = value 
	return instance 
end