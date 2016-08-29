--
-- Date: 2016-08-12 14:39:30
--
 
require("framework.init")
local serpent = require("app.combat.___serpent")
 
module(...,package.seeall)

local json = require("cjson")

--
local AvatarConfig = require("app.config.AvatarConfig") 
---HitEffectBg 字段的动画 没有事件
local ccsPath = "skillEffect/"
local spinePath = "spine/"
-- local fileUtil = CCFileUtils:sharedFileUtils()
-- fileUtil:addSearchPath("res/")

local ccs_skill_headers = {
skillA = 
-- "SkillAHitEffectBg",
"SkillAHitEffectFg",
skillB =
-- "SkillBHitEffectBg",
"SkillBHitEffectFg"
}

-- 拥有 影响逻辑的事件的 动作名字
local event_animName = {
"Animation1",
"Animation2"	
}



local spine_anim_header = "Spine"

local spine_actionNames = { 
"attack",
-- "attack2",
-- "death",
-- "hit",
-- "run",
"skill1",
"skill2",
-- "stun",
-- "wait"
}

local spine_events = { 
-- "moveToAndScale",
-- "scaleTo",
-- "moveBy",
-- "reset",
-- "shake",
-- "createColorLayer",
-- "createImageafter", -- this is meaning onCastSkill ..
-- "createImagebefore", -- this is meaning onCastSkill ..
-- "createImage1",
-- "clearColorLayer",
"hit",
-- "slowly",
"fire",
-- "showEffect",
-- "fireEffect",
-- "fireSkill"
}


local skillStruct = {
	base,skillA,skillB
}
-- hits 只是命中点  不一定造成伤害 可是个伤害和效果的数组 谁在前 谁先作用。。
-- interval,hits 
local FRAME_DEF = 30
-- spine的 动画 点 几率的是真实的时间 需要转成帧
-- 四舍五入 or  非整即加
function time_to_frame(time) 
	local frame,modf = math.modf(FRAME_DEF*time)
	if modf > 0.5 then--[[if modf ~= 0 then]] 
		 frame = frame + 1
	end 
	-- print("···FRAME_DEF*time",FRAME_DEF*time,frame)
	return frame
end

function __g_skillStruct()
	local skillAnimData = {}
	for i,v in ipairs(AvatarConfig) do
		local animData = {}


		local spineName = v[spine_anim_header]

		animData =  
		getSpineAnimEvetnPoint(spineName,nil,v) 


		for k,ccsHeader in pairs(ccs_skill_headers) do 
			local bigSkillList = v[ccsHeader]
			isBigSkill = #bigSkillList

			for _,skillData in ipairs(bigSkillList) do
				local ccsAnimData = getCcsAnimEvetnPoint(unpack(skillData))
 
				for __,__v in pairs(ccsAnimData) do
 
					animData[__] = __v
					-- table.insert(animData,__v)
				end
				
			end

		end 

		print("---------v.id",v.ID)
		skillAnimData[tostring(v.ID)] = animData
	end

	local tableStr = serpent.block(skillAnimData) --table_tostring(skillAnimData)
	tableStr = "return\n"..tableStr 
	io.writefile(
		CCFileUtils:sharedFileUtils():getWritablePath()
	 .. '/scripts/app/combat/__skill_anim_events.lua', tableStr) 

end


 

function newSpine(dir)
	local cache = 0---1
	local scale = 1--scale or 1
	local withMask = 0--withMask or 1
 
	local spine 
	spine = SkeletonAnimation:createWithFile(dir, false, scale, withMask, cache)

	return spine
end

 -- fuck u all
local colorfulEventKeys = {
["event1"]=true,
["event"]=true,
["even"]=true
} 
function getCcsAnimEvetnPoint(jsonName,animName)
	local resPath = CCFileUtils:sharedFileUtils():getWritablePath() .. 'res/'
	local jsonDir = resPath..ccsPath..jsonName..".ExportJson"
	print("____________jsonDir",jsonDir)

	local file =  io.open(jsonDir, "r")
	if not file then return end 
 	local jsonstring = file:read("*a")
    io.close(file)

 	
    -- print("_____________jsonstring",jsonstring)

	local jsondata = json.decode(jsonstring)
	local animName = animName or "Animation2" 

	local data = {}

	for _,v in ipairs(jsondata.animation_data) do
		local mov_data = v.mov_data

		for __,anim in ipairs(mov_data) do
			data[anim.name] = data[anim.name] or {}
			-- if anim.name == animName then 

				for ___,events in ipairs(anim.mov_bone_data) do

					if colorfulEventKeys[events.name]  then 
						local frame_data = events.frame_data 
						for ____,framedata in ipairs(frame_data) do 
							local eventName = framedata.evt 
							local point = framedata.fi
							-- print("____eventName,____point",eventName,point)
							if eventName ~= nil then 
								data[anim.name][eventName] = point
							end

							-- table.insert(data[anim.name]})--{eventName=eventName,point=point})
						end 
					end
					
				end
			local interval = anim.dr--data[anim.name]["over"] or data[anim.name]["over1"]

			data[anim.name].interval = interval
			-- print("------actionName----interval =",anim.name,interval)
			 
			-- end 
		end
	end
 	-- print(table_tostring(data))
	return data--[animName]
end

 

function getSpineAnimEvetnPoint(jsonName,animName,avatarData)
	local resPath = CCFileUtils:sharedFileUtils():getWritablePath() .. 'res/'
	local jsonDir = resPath..spinePath..jsonName..".json" 

	print("____________jsonDir",jsonDir) 
	local file =  io.open(jsonDir, "r")
	if not file then return end 
 	local jsonstring = file:read("*a")
    io.close(file)

 	
	local jsondata = json.decode(jsonstring)
	local animName = animName or "attack" 

	local spineProj = newSpine(jsonDir)

	local data = {}
	for actionName,actionData in pairs(jsondata.animations) do 
		local __actionName 

		if string.find(actionName, avatarData.Avatar) or avatarData.IsSkin==1 then 

			-- print("-------actionName",actionName,avatarData.Avatar.."_")
			__actionName = string.gsub(actionName, avatarData.Avatar.."_", "") 
	 
			data[__actionName] = data[__actionName] or {}

			local haveHitEvent = false
			local isNeedCheckActionName = table.indexof(spine_actionNames, actionName)
			if actionData.events then 
				for i,v in ipairs(actionData.events) do
					local eventName = v.name
					local point = v.time 


					if isNeedCheckActionName and (string.find(eventName,"hit") or string.find(eventName,"fire")) then 
						 
						haveHitEvent = true
					end
					-- print("____actionName",actionName)
					-- print("____eventName,____point",eventName,point*30)
	 
				 
					data[__actionName][eventName] = time_to_frame(point)
					 
					-- table.insert(data[__actionName] , {eventName=eventName,point=point})
				end
			end

			if not haveHitEvent and isNeedCheckActionName then
				print("WARNING: "..jsonName.." "..actionName.." hit event not exists")
			end
			local interval = spineProj:getAnimationDuration(actionName)
			spineProj:setAnimation(0, actionName, true)
			data[__actionName].interval = time_to_frame(interval)
			-- print("------actionName----interval =",actionName,interval*30)

		end
	end

	 
	-- print(table_tostring(data))
	return data--[animName]

end

 

__g_skillStruct()
--Spine part 



