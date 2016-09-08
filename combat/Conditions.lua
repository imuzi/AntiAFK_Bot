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

haveBuff = function(instance,params)
	return true 

end

-- 主属性 阈值
attribute = function(instance,params)
	return true 

end

-- 表属性 满足
cfg = function(instance,params)
	return true 
end

-- 实例变量属性
instanceVar = function(instance,params)
	return true 
end


luck = function(instance,params) 
	-- return random__()
end



-- 可用与检测一切对象的属性满足条件  现只用来做targetConditions
function meets(instance,targetConditions) 
	if type(targetConditions)~="table" then return true end 
	local isMeet = true

	for i,v in ipairs(targetConditions) do
		local type_ = v.name
		local params =v.params
		isMeet = isMeet and self[type_](instance,params) 
	end

	return isMeet
end
 