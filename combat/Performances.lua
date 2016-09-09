--
-- Author: (£þ.£þ)
-- Date: 2016-09-09 14:20:43
--
local ccsPath = "skillEffect/"
local spinePath = "spine/"

module(...,package.seeall) 

fatherScene = nil

spines = {}

spineActionCurrent = {}


function init(scene)
	fatherScene = scene


	__spines()
end


function loop()
	CombatData.foreachAllHeros(
	function(hero)
		
		updateAction(hero) 

	end)
end




function __setAction(spine,name)
	-- body
end

function updateAction(hero,name,isloop)
	local spine = __getSpine(hero)

	local name,isloop = name,isloop
	if not name then 
		local status = hero:getStatus() 
		local actionData = SPINE_ACTION_MAP[status]
		name,isloop = unpack(actionData) 
	end 

	if __getActionCurrent(hero) == name then return end 

	spine:setAnimation(0, name, isloop) 

	print("hero ",hero:getCfgByKey("Name"),"ID",hero:getAttr("id"))
	print("spine:setAnimation",status,name)

	__saveActionCurrent(name,hero)
 	
end

function manualUpdateAction(hero,name,loop)

end













function __spines()
	CombatData.foreachAllHeros(
	function(hero)
		local spine,spineNode = __createSpine(hero)

		__addToScene(spineNode)
		__setAction(spine,"wait",true)  
		__saveSpine(spine,hero)

		
	end)

	
end


function __createSpine(hero)
	local avatarType = hero:getCfgByKey("AvatarType")
	local avatarCfg = getConfig(avatarType, "AvatarConfig")  -- FIXME战斗表现所用音效都在avatar表中
  
  	local is_defender = hero:getGroup():getName() == DEFENDER 

	local spine = loadSpine(avatarCfg)
	local spineNode = tolua.cast(spine, "CCNode") 

	local scaleX = is_defender and 1 or -1 
	local x,y = __getSpineOriginPos(hero) 
 
 	spineNode:setPosition(x,y)  
 	spineNode:setScaleX(scaleX)

 	spineNode:addChild(ui.newTTFLabel({text=dir}), 10000)


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
	-- body
end

function __saveSpine(spine,hero)
	local heroSvrId = hero:getAttr("id")
	spines[heroSvrId] = spine
end

function __getSpine(hero)
	local heroSvrId = hero:getAttr("id")
	return spines[heroSvrId]
end

function __saveActionCurrent(name,hero)
	local heroSvrId = hero:getAttr("id")
	spineActionCurrent[heroSvrId] = name
end

function __getActionCurrent(hero)
	local heroSvrId = hero:getAttr("id")
	return spineActionCurrent[heroSvrId] 
end

 

function __addToScene(node, zOrder)
	local zOrder = zOrder or 0
 
	fatherScene:addChild(node,zOrder)
end