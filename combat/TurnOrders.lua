--
-- Author: (£þ.£þ)
-- Date: 2016-08-31 14:01:08
--
module(...,package.seeall) 
 
basicAttack = {
	whosTurn = 
	function()
		local data = combatData.basicAttackOrderSet 
		local instanceGetter = function(v)
			return v 
		end 

		local trunOwner = getTurnOwner(data,instanceGetter)

		if not trunOwner then 
			basicAttack.reset()  
			trunOwner = getTurnOwner(data,instanceGetter)
		end
		print("本轮攻击者：",trunOwner:getCfgByKey("Name"),"speed",trunOwner:getAttr("speed"))
		return trunOwner
	end,
	reset = 
	function()
		local data = combatData.basicAttackOrderSet 
		local instanceGetter = function(v)
			return v 
		end 

		resetTrunTag(data,instanceGetter)
	end,
	sort = 
	function()
		local heros = combatData.basicAttackOrderSet
		sort__(heros,{
			{
				function(hero)
					return hero:getAttr("speed")
				end,
				">"
			},
		 	{
			 	function(hero)
			 		return hero:getAttr("position")
			 	end,
			 	"<"
		 	},
		 	{
			 	function(hero)
			 		return hero:getGroup():getName() == ATTACKER and 0 or 1
			 	end,
			 	"<"
		 	},
		})
	end
	
} 
 

skill = {
	whosTurn = 
	function() 
		local data = combatData.groupNames
		local instanceGetter = function(v)
			return combatData.getGroupByName(v)   
		end 

		local trunOwner = getTurnOwner(data,instanceGetter)

		if not trunOwner then 
			skill.reset()  
			trunOwner = getTurnOwner(data,instanceGetter)
		end
		print("本轮攻击者：",trunOwner:getName(),"speed",trunOwner:getSpeed())
		return trunOwner
	end,
	reset = 
	function()
		local data = combatData.groupNames
		local instanceGetter = function(v)
			return combatData.getGroupByName(v)   
		end 

		resetTrunTag(data,instanceGetter)
	end,
	sort = 
	function()
		local groupNames = combatData.groupNames
		sort__(groupNames,{
			{	
				function(groupName)
					local group = combatData.getGroupByName(groupName)   
					return group:getSpeed()
				end,
				">"
			}
		})
	end
	
}

 
-- 染红的写法 确保动态插入后 仍能正确寻找
function getTurnOwner(data,instanceGetter)
	local data = data
	local trunOwner = nil

	for i,v in ipairs(data) do
		local instance = instanceGetter(v)
		local turnOrderTag = tempTurnOrderFlag__(instance)

		-- print("turnOrderTag",turnOrderTag,v)
		if not turnOrderTag  then 
			trunOwner = instance 
			tempTurnOrderFlag__(instance,true)
			break
		end 
	end

	return trunOwner
end

function resetTrunTag(data,instanceGetter)
	local data = data
	for i,v in ipairs(data) do
		local instance = instanceGetter(v)  
		tempTurnOrderFlag__(instance,false) 
	end 

	print("_____resetTrunTag")
end


local TEMP_TURN_ORDER_KEY = "_turnOrderFlag" 
function tempTurnOrderFlag__(instance,val)
	local key = TEMP_TURN_ORDER_KEY
	local value = instance[key]

	if val~=nil then 
		value = val  
	else
		return value
	end

	instance[key] = value 
	return instance 
end