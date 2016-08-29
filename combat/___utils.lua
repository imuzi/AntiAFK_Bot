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


function class(classname, super)
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
			local instance = cls.__create(...)
			-- copy fields from class to native object
			for k,v in pairs(cls) do instance[k] = v end
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
			local instance = setmetatable({}, cls)
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







--  
function sort__(tar_table,sorParmas)  
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

 	

	table.sort(tar_table, 
		function(a, b) 
	 		local sortOne 
	 		sortOne = 
	 		function(depth)
	 			local h,l,sort_type = get_conditions(depth,a,b)--conditions[depth]
	 			if not h then return false end 
	 			
	 			-- local h,l = unpack(_conditions)
	 			depth = depth + 1  
	 			
	 			if h==l then  
	 				return sortOne(depth)
	 			else
	 				local result = sort_type == "<" and h<l or h>l
	 				return result
	 			end  
			end
			return sortOne(1) 
		end
	) 
end
	