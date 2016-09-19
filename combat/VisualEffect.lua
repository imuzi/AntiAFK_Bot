--
-- Author: (£þ.£þ)
-- Date: 2016-09-09 14:20:43
--
local ccsPath = "skillEffect/"
local spinePath = "spine/"

local BULLET_ZORDER = 101
local CCS_ZORDER= 100

module(...,package.seeall) 

parent = nil

spines = {}

spineActionCurrent = {}
 

function init(scene)
	parent = scene


	__spines()
end


function loop()
	CombatData.foreachAllHeros(
	function(hero)
		
		updateAction(hero) 

	end)
end



 
function updateAction(hero,name,isloop)
	local spine = __getSpine(hero)

	local name,isloop = name,isloop
	if not name then 
		name,isloop = __getHeroAnimData(hero)
	end 

	if __getActionCurrent(hero) == name then return end 

	if not dealRun(hero) then 
		spine:setAnimation(0, name, isloop) 
	end

	print("hero ",hero:getCfgByKey("Name"),"ID",hero:getAttr("id"))
	print("spine:setAnimation",hero:getStatus(),name)

	__saveActionCurrent(name,hero) 
 	
end


local __ATTACK_STUATUSES = {
	STATUS.BASEACTION,
STATUS.BASICATTACK,
STATUS.COUNTERATTACK,
STATUS.COMBOATTACK,
STATUS.CASTSKILL,
}
-- VARN 跑的时候要多加 2*RUN_FRAME
local __runkeyMap = 
{
	[BASIC_SKILL_TYPE] = "IsMelee",
	["SkillA"] = "IsAMelee",
	["SkillB"] = "IsBMelee"
}
function isNeedRun(hero)  
	-- 暂定 敌方才跑  WARN
	local skill = hero:getSkillToCast()
	local target = skill:getTargets()[1]
	local isEnemy = hero:getGroup():getName() ~= target:getGroup():getName()
	local skillKeyType = skill:getKeyType()
	local meleeKey = __runkeyMap[skillKeyType]

 	local isShortRange = hero:getAvatarCfgByKey(meleeKey) == 1

 	return isEnemy and isShortRange
end

function isAttackStatus(hero)
	local status = hero:getStatus()
	local isContain = false 
	for i,v in ipairs(__ATTACK_STUATUSES) do
		if v == status then 
			isContain = true
			break 
		end
	end 

	if isContain then 
		__topSpineZorder(hero)
	else
		__resetSpineZorder(hero)
	end  

	return isContain
end

-- 普通骨骼的宽度 WARN
local NORMAL_SPINE_WIDHT = 100  
-- 处理近战跑动
function dealRun(hero) 
	 
	if not isAttackStatus(hero) or not isNeedRun(hero) then 
		return false
	end  
 	
 	-- __topSpineZorder(hero)

	local target = hero:getSkillToCast():getTargets()[1]
	 
	local tarX,tarY = __getSpineOriginPos(target) 
	local backX,backY = __getSpineOriginPos(hero)
	local moveBackDelay = (RUN_FRAME + hero:getSkillToCast():getInterval())/LOGIC_FPS 



	tarX = target:getGroup():getName() == DEFENDER and tarX-NORMAL_SPINE_WIDHT or tarX+NORMAL_SPINE_WIDHT

	manualUpdateAction(hero,"run",false)
	local spineNode = __getSpineNode(hero)
	transition.moveTo(
		spineNode, 
		{
		time = RUN_FRAME/LOGIC_FPS, x = tarX, y = tarY, 
		onComplete = 
		function ()
			local spine = __getSpine(hero)
		 	local name_after,loop_after = __getHeroAnimData(hero) 
			spine:setAnimation(0,name_after,loop_after)  
		end
		})
 
	parent:performWithDelay(
		function()
			manualUpdateAction(hero,"run",false)
			spineNode:setScaleX(spineNode:getScaleX()*-1)
			transition.moveTo(
				spineNode, 
				{
				time = RUN_FRAME/LOGIC_FPS, x = backX, y = backY, 
				onComplete = 
				function ()
					local spine = __getSpine(hero)
				--  	local name_after,loop_after = __getHeroAnimData(hero) 
					spine:setAnimation(0,"wait",true)  
					spineNode:setScaleX(spineNode:getScaleX()*-1) 
					__resetSpineZorder(hero)
				end
				})
		end,
		moveBackDelay
		) 


	return true

end

-- 处理发射子弹表现
function dealBullet(hero)
	local flyItem = hero:getAvatarCfgByKey("FlyItem") --"skillfly116" --

	local animation = newCcs(
		{
		fullPathName="flyItem/"..flyItem 
		}) 

	__addToScene(animation,BULLET_ZORDER)

	
	local target = hero:getSkillToCast():getTargets()[1]
	local tarX,tarY = __getSpineOriginPos(target) 
	local backX,backY = __getSpineOriginPos(hero) 

	local tan = (tarY - backY) / (backX - tarX)
	local rotate = math.deg(math.atan(tan))
	animation:setRotation(rotate)
 
	animation:pos(backX,backY+90)
	animation:setScaleX(__getSpineNode(hero):getScaleX())


	transition.moveTo(animation, 
		{x = tarX, y = tarY+90, time = BULLET_FLYFRAME/LOGIC_FPS, 
		onComplete = 
		function ()
			animation:removeFromParentAndCleanup(true)
			 
		end})
end



local ccs_skill_headers = {
["SkillA"] = {"SkillAHitEffectBg",
"SkillAHitEffectFg",},

["SkillB"] ={
	"SkillBHitEffectBg",
"SkillBHitEffectFg"
}

}
-- 处理 骨骼和 cocos动画衔接问题
function dealShowEffect(hero)
	local keyType = hero:getSkillToCast():getKeyType() 
	local headers = ccs_skill_headers[keyType]

	local is_defender = hero:getGroup():getName() == DEFENDER

	local targets = hero:getSkillToCast():getTargets()
	local target = targets[1]
	local tarX,tarY = __getSpineOriginPos(target) 

	local scaleX = 1

	local isAoe = #targets >1

	local p = {x =   200, y = 250}
	if not is_defender then
		p.x = display.width - 200
		scaleX = -1
	end

	local x,y = isAoe and p.x or tarX,isAoe and p.y or tarY

	for i,v in ipairs(headers) do
		local ccsData = hero:getAvatarCfgByKey(v)
		for _i,_v in ipairs(ccsData) do
			local jsonName,animName = unpack(_v)

			local animation = 
			newCcs({fullPathName="skillEffect/"..jsonName,
				actionName = animName,
				x=x,
				y=y
				}) 

			__addToScene(animation,CCS_ZORDER)
 			
 			animation:setScaleX(scaleX)
			

			animation:getAnimation():setFrameEventCallFunc(function (bone, evt, originFrameIndex, currentFrameIndex)
					if evt == "over" then
						animation:removeFromParentAndCleanup(true) 
					elseif string.sub(evt, 1, 9) == "playSound" then
						local mp3Name = string.sub(evt, 10, -1)
						audioManager:playSound(string.format("sound/skill/%s.mp3", mp3Name))
					end
				end)

		end
	end

end


-- 处理属性改变的表现
function dealAttributeChanged(hero,attrName,value)

end

-- 头顶图标
function dealHeadIcons( ... )
	
end

 


function __getHeroAnimData(hero)
	local status = hero:getStatus()  
	local isCasting = status == STATUS.CASTSKILL 

	local actionKey = isCasting and hero:getSkillToCast():getKeyType() or status 

	local actionData = SPINE_ACTION_MAP[actionKey]
	local name,isloop = unpack(actionData) 

	return name,isloop
end

 
 
function manualUpdateAction(hero,name,loop,isReset)
	local spine = __getSpine(hero)

	spine:setAnimation(0, name, isloop) 

	if not isReset then return end 

	local name_after,loop_after = __getHeroAnimData(hero)
	print("name_after,loop_after",name_after,loop_after)
	spine:addAnimation(0,name_after,loop_after,0)  

end










function __ccs()
	-- body
end


function __spines()
	CombatData.foreachAllHeros(
	function(hero)
		local spine,spineNode = __createSpine(hero)

		__addToScene(spineNode) 
		__saveSpine(spine,hero)

		__resetSpineZorder(hero)
	end)

	
end


function __createSpine(hero)
	local avatarCfg = hero:getAvatarCfg()
	  -- FIXME战斗表现所用音效都在avatar表中
  
  	local is_defender = hero:getGroup():getName() == DEFENDER 

	local spine = loadSpine(avatarCfg)
	local spineNode = tolua.cast(spine, "CCNode") 

	local scaleX = is_defender and 1 or -1 
	local x,y = __getSpineOriginPos(hero) 
 
 	spineNode:setPosition(x,y)  
 	spineNode:setScaleX(scaleX)
 

 	
 	ui.newTTFLabel({text=hero:getCfgByKey("Name")})
 	:addTo(spineNode)
 	:setScaleX(scaleX)


--  	print("_____spineNode:getContentSize().width___"
--  	,spine:boundingBox():getMaxX(),
-- spine:boundingBox():getMidX(),
-- spine:boundingBox():getMinX(),
-- spine:boundingBox():getMaxY(),
-- spine:boundingBox():getMidY(),
-- spine:boundingBox():getMinY(),
--  	 spineNode:getContentSize().width)	
 	-- spine:setScriptHandler(__spineEventHandler)
 	return spine,spineNode
end


function __getSpineOriginPos(hero)
	local position = hero:getAttr("position")
	local is_defender = hero:getGroup():getName() == DEFENDER

	local pos = STATION_POSITIONS[position]
	local x,y = pos.x,pos.y 
	x = is_defender and display.width-x or x 
	return x,y 
end


function __resetSpineZorder(hero)
	local position = hero:getAttr("position")
	local pos = STATION_POSITIONS[position]
	local y = pos.y == 0 and 1 or pos.y
	__getSpineNode(hero):setLocalZOrder(display.height/y)
end

function __topSpineZorder(hero) 
	__getSpineNode(hero):setLocalZOrder(display.height)
end

function __saveSpine(spine,hero)
	local heroSvrId = hero:getAttr("id")
	spines[heroSvrId] = spine
end

function __getSpine(hero)
	local heroSvrId = hero:getAttr("id")
	return spines[heroSvrId]
end

function __getSpineNode(hero) 
	return tolua.cast(__getSpine(hero),"CCNode")
end

function __saveActionCurrent(name,hero)
	local heroSvrId = hero:getAttr("id")
	spineActionCurrent[heroSvrId] = name
end

function __getActionCurrent(hero)
	local heroSvrId = hero:getAttr("id")
	return spineActionCurrent[heroSvrId] 
end

 

function __addToSpine(hero,node,zOrder)
	local is_defender = hero:getGroup():getName() == DEFENDER 
	local scaleX = is_defender and 1 or -1 

	node:setScaleX(scaleX)
	node:addTo(__getSpineNode(hero),zOrder)
	return scaleX
end

function __addToScene(node, zOrder)
	local zOrder = zOrder or 0
 
	parent:addChild(node,zOrder)
end

function __spineEventHandler(none, trackIndex, eventType, animationName, event, loopCount)
	if eventType ~= "EVENT" then return end 

	local evtName = event.data_name

	if evtName == "fire" then 

	end 


end

------- shanghai 

function showMiss(hero)
	 
	local s = display.newSprite("buffEffect/skillbf165.png", 0, 140) 
	transition.moveBy(s, {time = .5, y = 60, delay = .5, onComplete = function ()
		s:removeFromParentAndCleanup(true)
	end})

	__addToSpine(hero,s,100) 


	sequence = transition.sequence({ 
									CCFadeOut:create(0.25),
									CCFadeIn:create(0.25), 
									})

	__getSpineNode(hero):runAction(sequence)

end

function showDamage(damage,isCrit,isBlock,hero)
	 
	if damage > 0 then
		-- 扣血了
		local font = "nums/num3.fnt" -- 红色
		if isCrit --[[or isExtraDamage ]]then
			font = "nums/num2.fnt" -- 黄色
		elseif isBlock then
			font = "nums/num5.fnt" -- 灰色
		end 
		local label = ui.newBMFontLabel(
			{text = tostring(damage), font = font, x = 0, y = 180})
		local scaleX = __addToSpine(hero,label,100)
		local sequence = nil
		if isCrit then
			-- -- 屏幕还要震动一下
			-- if not self._curSkill then
			-- 	camera:shake(.4)
			-- end					
			local arr1 = CCArray:create()
			arr1:addObject(CCFadeOut:create(2))
			arr1:addObject(CCMoveBy:create(1, CCPoint(0, 80)))
			sequence = transition.sequence({ 
											CCScaleTo:create(0.3, 3*scaleX,3),
											CCScaleTo:create(0.1, 1*scaleX,1),
											CCDelayTime:create(0.2),
											CCSpawn:create(arr1),
											CCCallFunc:create(function ()
												label:removeFromParentAndCleanup(true)
											end)
											})
		else
			local arr1 = CCArray:create()
			arr1:addObject(CCFadeOut:create(2))
			arr1:addObject(CCMoveBy:create(1, CCPoint(0, 80)))
			sequence = transition.sequence({
											CCSpawn:create(arr1),
											CCCallFunc:create(function ()
												label:removeFromParentAndCleanup(true)
											end)
											})
		end
		
		label:runAction(sequence)

		manualUpdateAction(hero,"hit",false,true)

	elseif damage < 0 then
		-- 加血了
		damage = -damage
		local label = ui.newBMFontLabel(
			{text = tostring(damage), font = "nums/num4.fnt", x = 0, y = 180})
		__addToSpine(hero,label,100)
		transition.moveBy(label, {time = 0.8, y = 66, onComplete = function ()
			label:removeFromParentAndCleanup(true)
		end})
	end
end