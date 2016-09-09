--
-- Author: (£þ.£þ)
-- Date: 2016-08-25 16:20:15
--
local _ = (...):match("(.-)[^%.]+$") 
require("framework.init")
require('app.net.protobuf')
local pbPath = "res/sound/bg.mp3"
-- if device.platform == 'android' then
-- 	pbPath = CCFileUtils:sharedFileUtils():fullPathForFilename('sound/bg.mp3')
-- end 
if CCFileUtils:sharedFileUtils():isFileExist(pbPath) then
	protobuf.register(CCFileUtils:sharedFileUtils():getFileData(pbPath))
else
	debugLayer:error("找不到协议:", pbPath)
end

serpent = require("app.combat.___serpent")
serialize = serpent.block

function writeTable(table,name,path)
	local path = path or 
	CCFileUtils:sharedFileUtils():getWritablePath() .. '/scripts/app/combat/'

	local tableStr = "return\n"..serialize(table) 
	io.writefile(
	path..name
	, tableStr) 
end

function decodeLocalMsg(name,msg)  
	local name = name or "LevelBegin"
	local msg = msg or require(_.."___LOCAL_MSG_FOR_TEST")
	return
	protobuf.decode("PS.ProtoBuf." .. name, msg) 
end


function class__(classname, super)
	local superType = type(super)
	local cls

	if superType ~= "function" and superType ~= "table" then
		superType = nil
		super = nil
	end

	if superType == "function" or (super and super.__ctype == 1) then
		-- inherited from native C++ Object
		cls = {}

		if superType == "table" then
			-- copy fields from super
			for k,v in pairs(super) do cls[k] = v end
			cls.__create = super.__create
			cls.super	= super
		else
			cls.__create = super
			cls.ctor = function() end
		end

		cls.__cname = classname
		cls.__ctype = 1

		function cls.new(...)
			-- print("_______________cls.new(...)__")
			local instance = cls.__create(...)
			-- copy fields from class to native object
			for k,v in pairs(cls) do  
				local newVarValue = 0 
				if v == "{}" then 
					newVarValue = {}
				elseif v == "nil" then 
					newVarValue = nil
				elseif tonumber(v) then
					newVarValue = tonumber(v) 
				end   
				-- print("v",v,"newVarValue",newVarValue)
				instance[k] = newVarValue
		 	end
			instance.class = cls
			instance:ctor(...)
			return instance
		end

	else
		-- inherited from Lua Object
		if super then
			cls = {}
			setmetatable(cls, {__index = super})
			cls.super = super
		else
			cls = {ctor = function() end}
		end

		cls.__cname = classname
		cls.__ctype = 2 -- lua
		cls.__index = cls

		function cls.new(...) 
			-- print("_______________cls.new(...)__no super")
			local instance = setmetatable({}, cls)

			for k,v in pairs(super) do  
				 
				if v == "{}" then 
					instance[k] = {}
				elseif v == "nil" then 
					-- print("____v == nil")
					instance[k] = false
				elseif tonumber(v) then
					instance[k] = tonumber(v) 
				elseif type(v) == "string" then 
					instance[k] = v 
						
				end   
				
				-- if v == newVarValue  then print("v",v,"newVarValue",newVarValue,type(newVarValue)) os.exit() end 
				-- instance[k] = newVarValue

				-- print("v",v,instance[k],type(instance[k]))
		 	end

			instance.class = cls
			instance:ctor(...)
			return instance
		end
	end

	return cls
end



function queryByType(table, key, val)
	if table then
		key = key or 'type'
		local leftIndex = 1
		local middleIndex = 1
		local rightIndex = #table

		while leftIndex <= rightIndex do
			midIndex= math.floor((leftIndex + rightIndex)/2)
			local midItem = table[midIndex]

			if midItem[key] == val then
				return midItem
			elseif val < midItem[key] then
				rightIndex = midIndex - 1
			else
				leftIndex = midIndex + 1
			end
		end
	end
end

--- 根据type读取相应的配置文件
-- @param propType 物品Type
-- @param configType 配置文件，取lua文件名
-- @return 返回配置文件中物品的配置信息
function getConfig(propType, configType, compareStr)
	compareStr = compareStr and compareStr or 'ID'
	local config = require('app.config.' .. configType)
	if config then
		return queryByType(config, compareStr, checkint(propType))
	end
end



-- 给实例添加一个临时的变量。。  便于查错
function tempVarOfInstance__(keyName,instance,val) 
	local key = keyName
	local value = instance[key]

	if val~=nil then 
		value = val  
	else
		return value
	end

	instance[key] = value 
	return instance  
end 


--  
--- sorting func begins 
function sort__(data,sorParmas)  
	if #data <= 1 then return data end

	local get_conditions = 
	function(depth,a,b)
		local sortData = sorParmas[depth] 
		if not sortData then return false end  
		local key,sort_type = unpack(sortData)
		local type_key = type(key) 

		sort_type = sort_type or "<"

		if type_key == "function" then
			return key(a),key(b),sort_type
		elseif type_key == "table" then 
			local keys = key 
			local val_a,val_b
			for _,cur_key in ipairs(keys) do
				val_a = val_a and val_a[cur_key] or a[cur_key]
				val_b = val_b and val_b[cur_key] or b[cur_key]  
			end

			return val_a,val_b,sort_type
		else 
			return a[key],b[key],sort_type  
		end  

		print([["sort keyParams sample:
			{
				{'ID',"<"},
				{function(a)
					return sort_order[a.baseInfo.id]
				end,">"},
				{{'baseInfo','id'},"<"}, 
			}"]])
 	end 
 	
 	local hasNIL = false 
 	local hasTempPriorityKey = false
	table.sort(data, 
		function(a, b)  
			if not a or not b then  
				hasNIL  = true 
				print("a or b is nil")
			-- elseif a.baseAttrs and b.baseAttrs then 
			-- 	print("__",a.baseAttrs.id,b.baseAttrs.id)
		 
		  	end 

			-- if a == b then 
			-- 	print("a==== b")
			-- end   

			if not a then 
				return true 
			elseif not b then 
				return false 
			elseif a == b then
				return false
			else 
				local result
		 		local sortOne 
		 		sortOne = 
		 		function(depth)
		 			local h,l,sort_type = get_conditions(depth,a,b)--conditions[depth]
		 			-- print("h,l",h,l,sort_type)
		 			if not h then return result end 

		 			if sort_type == "<" then
	 					result = h<l
	 				else 
	 					result = h>l
	 				end  
		 		 
		 			depth = depth + 1  
		 			
		 			if h==l then  
		 				result = sortOne(depth)   
		 			end  
		 			return result
				end

				result = sortOne(1) 

				-- check is there a temp sort priority key to reset after sorting 
				if tempSortPriority__(a) then hasTempPriorityKey = true end 
				-- print("___________result",result)
				return result
			end  
			
		end
	) 

	if hasTempPriorityKey then 
		-- print("____hasTempPriorityKey_____",hasTempPriorityKey)
		for i,v in ipairs(data) do
			-- print("v[TEMP_SORT_PRORITY_KEY]",tempSortPriority__(v))
			tempSortPriority__(v,false)
		end
	end 
	if hasNIL then 
		dump(data)
		os.exit()
	end 
	return data
end

local TEMP_SORT_PRORITY_KEY = "_sortPriority" 
function tempSortPriority__(instance,val)
	local key = TEMP_SORT_PRORITY_KEY
	return tempVarOfInstance__(key,instance,val)
end
	
------ sorting funcs end 


local __random_count = 0
local __random_recoder = {}
function random__(...)
	__random_count = __random_count+1
	local random_result = math.random(...)
	-- print("__________random_count",__random_count,random_result,...)

	local string_rec =  "\n"..__random_count.."^^^^"..random_result
	table.insert(__random_recoder, string_rec)
	
	return random_result
end

function set_random_count(var)
	dump(__random_recoder)
 	
	__random_recoder = {}
	__random_count = var or 0
end	











-----
function newCcs(param) 
	local anim 
	local armatureName

	local fullPathName = param.fullPathName
	local parent       = param.parent 
	local x            = param.x or display.cx
	local y            = param.y or display.cy
 	local actionName   = param.actionName or "Animation1"
	local cb           = param.cb or function() end
	local autoRemove   = param.autoRemove -- fix me by lxc  
	local zorder       = param.zorder or 0
	local speed        = param.speed or 1 
	local playSound    = param.playSound 

	local movementEvent = param.movementEvent or function() end 

	local armatureDataManager = CCArmatureDataManager:sharedArmatureDataManager()

	string.gsub(fullPathName,"([%w_]+)",function(v) 
		armatureName = v 
	end)   

	print("-----------------------------armatureName",fullPathName,armatureName,actionName)
	local __onLoaded = function()
	 	anim = CCArmature:create(armatureName):pos(x,y)   
	 	if parent then  
	 		anim:addTo(parent,zorder)
	 	end
	 	-- if playSound then 
		 -- 	animation:getAnimation():setFrameEventCallFunc(function (bone, evt, originFrameIndex, currentFrameIndex)
			-- 	if string.sub(evt, 1, 9) == "playSound" then
			-- 		local source = string.sub(evt, 10, string.len(evt)) 
			-- 		audioManager:playSound(string.format("sound/skill/%s.mp3", source))
			-- 	end
			-- end)
	 	-- end 

		if loop then 
			anim:getAnimation():setFrameEventCallFunc(function (bone, evt, originFrameIndex, currentFrameIndex)
				if string.sub(evt, 1, 11) == "gotoAndPlay" then
					local frame = checkint(string.sub(evt, 12, string.len(evt))) + 1
					anim:getAnimation():gotoAndPlay(frame)
				end  
			end)  
		end  

		anim:getAnimation():setMovementEventCallFunc(movementEvent)
 
		-- anim:performWithDelay(function()
		anim:getAnimation():play(actionName)

	 	anim:getAnimation():setSpeedScale(speed)
		 -- end, 0)
		-- play 要保证在 注册时间之前 不然会有各种问题 ccs bug
		
	end

 
	armatureDataManager:addArmatureFileInfo(fullPathName..".ExportJson")
	__onLoaded()
	 
	return anim 
end


function newSpine(dir)
	local cache = 0---1
	local scale = 1--scale or 1
	local withMask = 0--withMask or 1
 
	local spine 
	spine = SkeletonAnimation:createWithFile(dir, false, scale, withMask, cache)

	return spine
end






--- 引擎代码库版本
function engineCodeBaseVersion()
	if not __engineCodeBaseVersion then
		if not CCConfiguration.getCodeBaseVersion then
			__engineCodeBaseVersion = 0
		else
			__engineCodeBaseVersion = CCConfiguration:getCodeBaseVersion()
		end
	end
	print("==================__engineCodeBaseVersion", __engineCodeBaseVersion)
	return __engineCodeBaseVersion
end

--- 加载武将Spine
-- @param project 骨骼项目名
-- @param avatar 骨骼编号
-- @param isSkin 是否是用了皮肤机制进行换肤的，bool
-- @param cache 是否要缓存起来 int 1:缓的,其他:不缓
-- @param scale 缩放
-- @param withMask 是否是png8+jpg模式 int 1:是的,其他:不是
function loadWarriorSpine(project, avatar, isSkin, cache, scale, withMask)
	-- cache = cache or 0
	cache = -1
	scale = scale or 1
	withMask = withMask or 1
	-- local socket = require "socket"
	-- local t = socket.gettime()
	-- print("spine/" .. project .. ".zip", project .. ".json", project .. ".atlas", scale, withMask, cache)
	local spine
	if engineCodeBaseVersion() >= 1 then
		spine = SkeletonAnimation:createWithFile("spine/" .. project .. ".json", false, scale, withMask, cache)
	else
		spine = SkeletonAnimation:createWithZip("spine/" .. project .. ".zip", "spine/" .. project .. ".json", "spine/" .. project .. ".atlas", scale, withMask, cache)
	end

	-- print("加载", project, "耗时:", socket.gettime() - t)
	
	if isSkin then
		spine:setSkin(avatar)
	end
	return spine
end

--- 加载敌方关卡武将Spine
function loadSpine(avatarData) 
	return loadWarriorSpine(avatarData.Spine, avatarData.Avatar, avatarData.IsSkin == 1, nil, nil, 0)
end
