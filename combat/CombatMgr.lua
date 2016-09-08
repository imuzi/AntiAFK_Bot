--
-- Author: (£þ.£þ)
-- Date: 2016-08-23 16:50:16
--
local _ = (...):match("(.-)[^%.]+$") 
require(_.."___utils")
require(_.."Const")

combatData = require(_.."CombatData")
targetFilters = require(_.."TargetFilters")
turnOrders = require(_.."TurnOrders")
behaviors = require(_.."Behaviors")
castAi = require(_.."CastAi") 

triggerEvents = require(_.."TriggerEvents")


combatLogic = require(_.."CombatLogic")
skillLogic = require(_.."SkillLogic")
local CDUpdater = require(_.."CDUpdater")

module(...,package.seeall) 
 

local scheduler = require("framework.scheduler")
local socket = require "socket"


looper = nil 
frame_count = 0
frame_step = 0
game_speed = 1

function init()
	combatData.init() 

	turnOrders.basicAttack.sort()
	turnOrders.skill.sort()  

end

function start() 
 
	looper = scheduler.scheduleGlobal(main_loop, 0) 

	skillLogic.castPassiveSkills()

	triggerEvents.listen("combatBegin")
	
	print("combat,started!")
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

		CDUpdater.loop()

		frame_step = frame_step + 1
	end

	print("____________________________________________________________________________________\n\n\n"
		,frame_count%dt,dt
		,"\n_______fame_count",frame_count
		,"\nframe_step",frame_step
		,"\nMAXSPEED,game_speed",MAXSPEED,game_speed)
end

 