--
-- Author: (£þ.£þ)
-- Date: 2016-08-31 15:58:30
--
module(...,package.seeall) 
self = package.loaded[...]



__castSkill = 
{
	begin =
	function(hero) 
		local skill = hero:getSkillToCast()
		local targets = targetFilters.getTargets(skill)

		if #targets > 0 then 
			skillLogic.castSkill(skill)
			skill:setTargets(targets)
			tempLoopFlag__(skill,true)
		else 
			-- WARN::无目标 技能不能放时  机会还给回去  FIX 如果不停还回去 是否 反复执行
			resetTurnOrders(hero)
			
			over(hero)
		end   
	end,
	loop = 
	function(hero)
		local skill = hero:getSkillToCast()
		local loopFlag = tempLoopFlag__(skill)
		
		if not loopFlag then return end  

		hero:updateFrameStep()
		 
		if isHit(hero) then 
			print("________hit")
			combatLogic.onHit(skill)
		elseif isOver(hero) then  
			print("________over")
			over(hero)
		end   
	end,
	over = 
	function(hero)
		local skill = hero:getSkillToCast()
		tempLoopFlag__(skill,false)   
		combatLogic.trans_status(hero,"STANDBY") 

		hero:setSkillToCast(nil)
	end
}

castSkill = 
{
	begin =
	function(hero)
		combatLogic.turn_begin()
		__castSkill.begin(hero)
	end,
	loop = 
	function(hero)
		__castSkill.loop(hero) 
	end,
	over = 
	function(hero)
		__castSkill.over(hero)
 
		if not combatLogic.checkCombo() then  
			combatLogic.checkCounterOwner()
		end
 
	end
}


basicAttack =
{
	begin =
	function(hero) 
		__castSkill.begin(hero)
	end,
	loop = 
	function(hero)
		__castSkill.loop(hero) 
	end,
	over = 
	function(hero)
		__castSkill.over(hero) 

		if not combatLogic.checkCombo() then  
			combatLogic.checkCounterOwner()
		end
 
	end
} 

counterAttack = {
	begin =
	function(hero)
		
		__castSkill.begin(hero)
	end,
	loop = 
	function(hero)
		__castSkill.loop(hero) 
	end,
	over = 
	function(hero)
		__castSkill.over(hero) 
	end
}

-- 先连击 再反击
comboAttack = {
	begin =
	function(hero)
		 
		__castSkill.begin(hero)
	end,
	loop = 
	function(hero)
		__castSkill.loop(hero) 
	end,
	over = 
	function(hero)
		__castSkill.over(hero)

		combatLogic.checkCounterOwner()
		---- FIXME check combo
	end
}

extraTurn = {}

standBy = {
	begin =
	function(hero) 
	end,
	loop = 
	function(hero) 
	end,
	over = 
	function(hero) 
	end
}

function begin(hero) 
	getBehavior(hero).begin(hero) 
	-- triggerEvents.listen("behaviorBegin")
end

function loop(hero)
	getBehavior(hero).loop(hero)
end
function over(hero)
 	getBehavior(hero).over(hero)
 	-- triggerEvents.listen("behaviorOver")
end

function resetTurnOrders(hero)
	local status = hero:getStatus()
	if status == STATUS.BASICATTACK then 
		turnOrders.tempTurnOrderFlag__(hero,false)
	elseif status == STATUS.CASTSKILL then 
		turnOrders.tempTurnOrderFlag__(hero:getGroup(),false)
	end 

end

function getBehavior(hero)
	local status = hero:getStatus() 
	print("status",status,hero:getCfgByKey("Name"))
	return self[status]
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
	return tempVarOfInstance__(key,instance,val)
end
