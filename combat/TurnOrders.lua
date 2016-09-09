--
-- Author: (£þ.£þ)
-- Date: 2016-08-31 14:01:08
--
module(...,package.seeall) 
 
basicAttack = {
	whosTurn = 
	function()
		local data = CombatData.basicAttackOrderSet 
		local instanceGetter = function(v) 
			 
			return CombatLogic.isAlive(v) and v or nil 
		end 

		local trunOwner = getTurnOwner(data,instanceGetter)

		if not trunOwner then 
			basicAttack.reset()  
			trunOwner = getTurnOwner(data,instanceGetter)
		end

		
		if not trunOwner then 
			for i,v in ipairs(data) do
				print(i,v.status)
			end
			dump(data)
		end 
		print("\n本轮攻击者：",trunOwner:getCfgByKey("Name"),"speed",trunOwner:getAttr("speed"))
		return trunOwner
	end,
	reset = 
	function()
		local data = CombatData.basicAttackOrderSet 
		local instanceGetter = function(v)
			return v 
		end 

		resetTrunTag(data,instanceGetter)
	end,
	sort = 
	function()
		local heros = CombatData.basicAttackOrderSet
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
		local data = CombatData.groupNames
		local instanceGetter = function(v)
			return CombatData.getGroupByName(v)   
		end 

		local trunOwner = getTurnOwner(data,instanceGetter)

		if not trunOwner then 
			skill.reset()  
			trunOwner = getTurnOwner(data,instanceGetter)
		end
		print("\n本轮攻击者：",trunOwner:getName(),"speed",trunOwner:getSpeed())
		return trunOwner
	end,
	reset = 
	function()
		local data = CombatData.groupNames
		local instanceGetter = function(v)
			return CombatData.getGroupByName(v)   
		end 

		resetTrunTag(data,instanceGetter)
	end,
	sort = 
	function()
		local groupNames = CombatData.groupNames
		sort__(groupNames,{
			{	
				function(groupName)
					local group = CombatData.getGroupByName(groupName)   
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
		if instance then 
			local turnOrderTag = tempTurnOrderFlag__(instance)

			-- print("turnOrderTag",turnOrderTag,v)
			if not turnOrderTag  then 
				trunOwner = instance 
				tempTurnOrderFlag__(instance,true)
				break
			end 
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
	return tempVarOfInstance__(key,instance,val)
end