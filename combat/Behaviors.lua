--
-- Author: (£þ.£þ)
-- Date: 2016-08-31 15:58:30
--
module(...,package.seeall) 
self = package.loaded[...]

frame_point_scale = 1 

-- 基本行为  所谓的技能触发连击 并非连击 只是再做一次基本行为  
baseAction = 
{
	begin =
	function(hero) 
		local skill = hero:getSkillToCast() or hero:getBasicSkill()  -- 
		local targets = TargetFilters.getTargets(skill)
		skill:setTargets(targets)

		if #targets > 0 then 
			SkillLogic.castSkill(skill) 
			tempLoopFlag__(skill,true)
			return true 
		else 
			-- WARN::无目标 技能不能放时  机会还给回去  FIX 如果不停还回去 是否 反复执行
			resetTurnOrders(hero)
			
			over(hero)
			return false 
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
			CombatLogic.onHit(skill)
		elseif isOver(hero) then  
			print("________over")
			over(hero)
		end   
	end,
	over = 
	function(hero) 

		local skill = hero:getSkillToCast()
		tempLoopFlag__(skill,false)   
		CombatLogic.trans_status(hero,"STANDBY") 

		hero:setSkillToCast(nil)
		hero:setCastingEffectList({})
	end
}

castSkill = 
{
	begin =
	function(hero) 
		if baseAction.begin(hero) then 
			SkillLogic.onSkillCasted(hero:getSkillToCast())
		end 
	end,
	loop = 
	function(hero)
		baseAction.loop(hero) 
	end,
	over = 
	function(hero)
		baseAction.over(hero)
 
		if not CombatLogic.checkCombo() then  
			CombatLogic.checkCounterOwner()
		end
 
	end
}


basicAttack =
{
	begin =
	function(hero) 
		baseAction.begin(hero)
	end,
	loop = 
	function(hero)
		baseAction.loop(hero) 
	end,
	over = 
	function(hero)
		baseAction.over(hero) 

		if not CombatLogic.checkCombo() then  
			CombatLogic.checkCounterOwner()
		end
 
	end
} 

counterAttack = {
	begin =
	function(hero)
		
		-- baseAction.begin(hero)
		local skill = hero:getBasicSkill()  -- 
		local targets = {CombatLogic.turnOwner} 

		SkillLogic.castSkill(skill)
		skill:setTargets(targets)
		tempLoopFlag__(skill,true)
		
	end,
	loop = 
	function(hero)
		baseAction.loop(hero) 
	end,
	over = 
	function(hero)
		baseAction.over(hero) 
	end
}

-- 先连击 再反击
comboAttack = {
	begin =
	function(hero)
		 
		baseAction.begin(hero)
	end,
	loop = 
	function(hero)
		baseAction.loop(hero) 
	end,
	over = 
	function(hero)
		baseAction.over(hero)

		CombatLogic.checkCounterOwner()
	 
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
	-- TriggerEvents.listen("behaviorBegin")
end

function loop(hero)
	getBehavior(hero).loop(hero)
end
function over(hero)
 	getBehavior(hero).over(hero)
 	-- TriggerEvents.listen("behaviorOver")
end

function resetTurnOrders(hero)
	local status = hero:getStatus()
	if status == STATUS.BASICATTACK then 
		TurnOrders.tempTurnOrderFlag__(hero,false)
	elseif status == STATUS.CASTSKILL then 
		TurnOrders.tempTurnOrderFlag__(hero:getGroup(),false)
	end 

end

function getBehavior(hero)
	local status = hero:getStatus() 
	-- print("status",status,hero:getCfgByKey("Name"))
	return self[status]
end

function isHit(hero,animName,frame_dif)
	local skill = hero:getSkillToCast()
	local step = hero:getFrameStep()
	local animEvents = skill:getAnimEvent(animName)
	local frame_dif = frame_dif or 0


	local isNeedRun = VisualEffect.isNeedRun(hero)
	frame_dif = isNeedRun and frame_dif+RUN_FRAME  or frame_dif

	for k,v in pairs(animEvents) do 
		local adjustedPoint = frame_dif + __dropFrameScale__(v,hero)

		if ___isHit(k,adjustedPoint,step,0,"fire",hero) then 
			VisualEffect.dealBullet(hero)
			-- os.exit()
		end 
		if ___isHit(k,adjustedPoint,step,0,"showEffect",hero) then 
			___dealShowEffectHit(k,v,step,hero)
		end 

		local isSatisfy =  ___isHit(k,adjustedPoint,step,0,"hit",hero) 
						or ___isHit(k,adjustedPoint,step,BULLET_FLYFRAME,"fire",hero) 
						-- or ___showEffectHit(k,v,step,hero)
 	
 
		if isSatisfy then  
			return true 
		end 
	end

	return false  
end

function isOver(hero)
	local step = hero:getFrameStep()
	local interval = getAdjustedInterval(hero)
 	return ___isFitFrame___(step,interval) --step >= interval 
end

function getAdjustedInterval(hero)
	local skill = hero:getSkillToCast()
	

	local animEvents = skill:getAnimEvent()
	local interval = skill:getInterval()

	interval = __dropFrameScale__(interval,hero)

	local hasShowEff,showEffPoint = __checkEvtInfo__("showEffect",animEvents)
	local hasFire = __checkEvtInfo__("fire",animEvents)

	if hasShowEff then 
		local lastTime = showEffPoint + skill:getInterval("Animation1")
		interval = math.max(interval,lastTime)
 	end 

	local isNeedRun = VisualEffect.isNeedRun(hero)
	interval = isNeedRun and interval+RUN_FRAME*2  or interval
	interval = hasFire and interval+BULLET_FLYFRAME or interval  -- 子弹是否需要等命中WARN

	return interval
end

-- 当是showeffect时  老的逻辑是找到另一个 ccs动画接着放。。。。。

-- 当多段出现时 规则如下 
-- Spine中 showeffect的事件的命名规则 定义如下 showEffect 第几段 下划线 cocos动作名  如：showEffect_1_animation1
--[[ string.gsub("showEffect_1_animation1","([%w]+)",function(v) 
		 print("______________________:::",v)
	end)]] --FIXME
  
function ___dealShowEffectHit(k,v,step,hero)
	-- local isShowEffEvt = ___isHit(k,v,step,0,"showEffect",hero) 
	-- if isShowEffEvt then

	 

		VisualEffect.dealShowEffect(hero)

		-- animati = hero:getAvatarCfgByKey(v)
		local skill = hero:getSkillToCast()
		local anim1 = skill:getAnimEvent("Animation1")
		for _k,_v in pairs (anim1) do 
			skill:getAnimEvent()["ccs".._k] = v + _v
		end 
		
		-- local frame_dif = skill:getInterval()
		-- return isHit(hero,"Animation1",frame_dif)
	-- end  
	-- return false 
end
 
function ___isHit(k,v,step,frame_dif,evt_str,hero) 
	local tarPoint = v+frame_dif
	local keyToRecord = k..tarPoint
	local isBeenRecord = hero:getFrameEventRecorder()[keyToRecord]
	if isBeenRecord then return false end 
 
	local isHitEvent = string.find(k,evt_str)
	local isThatFrame = ___isFitFrame___(step,tarPoint) --step >= (v+frame_dif)
	local isSatisfy = isThatFrame and isHitEvent

	if isSatisfy then hero:recordFrameEvent(keyToRecord) end 
	return isSatisfy
end

-- 目前用来做 技能降帧用
function ___isFitFrame___(step,framePoint)
	return step >= framePoint*frame_point_scale
end

-- 只scale 动作帧数 不scale runframe 和  bulletframe 。。 warn
function __dropFrameScale__(point,hero)
	return point*hero:getFrameScaleRatio()
end

function __checkEvtInfo__(evtName,animEvents)
	local hasEvt = false
	local evtPoint = 0
	for k,v in pairs(animEvents) do
		if string.find(k,evtName) then 
			hasEvt = true 
			evtPoint = v
			break
		end
	end 

	return hasEvt,evtPoint
end


local TEMP_LOOP_FLAG_KEY = "_loopFlag" 
function tempLoopFlag__(instance,val)
	local key = TEMP_LOOP_FLAG_KEY
	return tempVarOfInstance__(key,instance,val)
end
