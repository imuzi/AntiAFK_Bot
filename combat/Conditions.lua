--
-- Author: (£þ.£þ)
-- Date: 2016-09-01 14:02:24
--
 
module(...,package.seeall) 

self = package.loaded[...]

-- {
-- 	name="attribute",
-- 	params = {key="hpPercent",value=30,comp="=="}
	 
-- },
-- {
-- 	name="haveBuff",
-- 	params = {id=1,actionName=""}
	 
-- }  

haveBuff = function(target,params)
	return true 

end

-- 主属性 阈值
attribute = function(target,params)
	return true 

end

-- 表属性 满足
cfg = function(target,params)
	return true 
end

-- 实例变量属性
instanceVar = function(target,params)
	return true 
end


luck = function(target,params) 
	-- return random__()
end




function meets(target,targetConditions)
	local isMeet = true
 
	for i,v in ipairs(targetConditions) do
		local type_ = v.name
		local params =v.params
		isMeet = isMeet and self[type_](target,params) 
	end

	return isMeet
end
 