--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 16:50:16
--
local _ = (...):match("(.-)[^%.]+$") 
require(_.."___utils")


local combatData = require(_.."CombatData")
local combatLogic = require(_.."CombatLogic")
local skillLogic = require(_.."SkillLogic")

module(...,package.seeall) 

local scheduler = require("framework.scheduler")
local socket = require "socket"


looper = nil 
frame_count = 0
frame_step = 0
game_speed = 1

function init()
	combatData.init()
	sort_basic_attack_order(combatData.basicAttackOrderSet)


end

function start() 

	looper = scheduler.scheduleGlobal(main_loop, 0) 
end

function stop()
	if looper then 
		scheduler.unscheduleGlobal(looper)
		looper = nil
	end
end

function pause()
	-- body
end

function resume(  )
	-- body
end


function main_loop()
	frame_count = frame_count + 1 

	local dt = MAXSPEED/game_speed

	if frame_count%dt == 0 then 




		combatLogic.loop()
		skillLogic.loop()

		frame_step = frame_step + 1
	end

	print("_______fame_count",frame_count,"frame_step",frame_step)
end


function sort_basic_attack_order(heros)
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
		 		return hero:getGroupName() == "myself" and 0 or 1
		 	end,
		 	"<"
	 	},
	})
end